# Column-at-a-time reads of an OGR layer through GDAL's Arrow C stream.
#
# `OGR_L_GetArrowStream` hands back whole column buffers, so a read costs a
# handful of ccalls per batch; the row iterator costs ~7 ccalls per feature plus
# an `IFeature`/`IGeometry` pair to finalize. A 500k-point GeoPackage reads in
# 0.018 s here against 0.40 s through `DataFrame(layer)`.
#
# Column names and element types reproduce the row path exactly, so the two are
# interchangeable. Anything this consumer does not recognise -- an Arrow type
# with no row-path equivalent, a geometry that disagrees with the layer
# definition -- raises `_ArrowUnsupported` and abandons the whole layer, leaving
# `read` to fall back to the row path.

const _ArrowArrayStream = AG.GDAL.ArrowArrayStream
const _ArrowArray = AG.GDAL.ArrowArray
const _ArrowSchema = AG.GDAL.ArrowSchema

# WKB is the one geometry encoding every driver can produce, and it keeps the
# decoders below down to a single layout.
const _ARROW_STREAM_OPTIONS = [
    "INCLUDE_FID=YES",
    "GEOMETRY_ENCODING=WKB",
    "MAX_FEATURES_IN_BATCH=16384",
]

"""
    _ArrowUnsupported(reason)

Signals that the layer must be read through the row path instead. Raised from
anywhere inside the stream consumer; `_read_arrow` catches it and returns
`nothing`.
"""
struct _ArrowUnsupported <: Exception
    reason::String
end

Base.showerror(io::IO, e::_ArrowUnsupported) =
    print(io, "_ArrowUnsupported: ", e.reason)

# --- column plans -----------------------------------------------------------
# One plan per output column: which schema child it comes from, and how that
# child's buffers turn into the element type the row path would produce.

abstract type _ColumnPlan end

_child(plan::_ColumnPlan) = plan.child

"Fixed-width Arrow values of type `S`, stored as `T`."
struct _PrimitivePlan{S,T} <: _ColumnPlan
    child::Int
end

"Bit-packed Arrow booleans."
struct _BoolPlan <: _ColumnPlan
    child::Int
end

"Arrow utf8 (`O === Int32`) or large_utf8 (`O === Int64`)."
struct _StringPlan{O} <: _ColumnPlan
    child::Int
end

"Arrow binary (`O === Int32`) or large_binary (`O === Int64`)."
struct _BinaryPlan{O} <: _ColumnPlan
    child::Int
end

"""
Arrow date/timestamp values of type `S`, scaled to milliseconds by `MUL/DIV`.

`DateTime` matches the row path, which reads every OGR date, time and datetime
field through `OGR_F_GetFieldAsDateTime`.
"""
struct _DateTimePlan{S,MUL,DIV} <: _ColumnPlan
    child::Int
end

"""
WKB point blobs decoded to an `N`-element coordinate tuple, with `O`-wide
Arrow offsets.

Tuples keep the fast path fast: cloning each point into an `IGeometry` costs
more than the entire Arrow read, and `GeoInterface`/`GeometryOps` treat a tuple
as a point already.
"""
struct _PointPlan{N,O} <: _ColumnPlan
    child::Int
end

"WKB blobs parsed by GDAL into `IGeometry{G}`, with `O`-wide Arrow offsets."
struct _GeometryPlan{G,O} <: _ColumnPlan
    child::Int
end

_planeltype(::_PrimitivePlan{S,T}) where {S,T} = T
_planeltype(::_BoolPlan) = Bool
_planeltype(::_StringPlan) = String
_planeltype(::_BinaryPlan) = Vector{UInt8}
_planeltype(::_DateTimePlan) = Dates.DateTime
_planeltype(::_PointPlan{2}) = Tuple{Float64,Float64}
_planeltype(::_PointPlan{3}) = Tuple{Float64,Float64,Float64}
_planeltype(::_GeometryPlan{G}) where {G} = AG.IGeometry{G}

# --- C helpers --------------------------------------------------------------

_string(p::Cstring) = p == C_NULL ? "" : unsafe_string(p)

"Call `f` with a NULL-terminated `CSLConstList` built from `options`."
function _with_options(f, options::Vector{String})
    buffers = [push!(Vector{UInt8}(codeunits(o)), 0x00) for o in options]
    pointers = Ptr{UInt8}[pointer(b) for b in buffers]
    push!(pointers, Ptr{UInt8}(C_NULL))
    GC.@preserve buffers pointers begin
        return f(Ptr{Cstring}(pointer(pointers)))
    end
end

"Turn a non-zero `ArrowArrayStream` return code into an `_ArrowUnsupported`."
function _checkstream(
    code::Cint,
    stream::_ArrowArrayStream,
    streamptr::Ptr{_ArrowArrayStream},
    what::AbstractString,
)
    iszero(code) && return nothing
    detail = if stream.get_last_error == C_NULL
        ""
    else
        _string(ccall(stream.get_last_error, Cstring,
                      (Ptr{_ArrowArrayStream},), streamptr))
    end
    throw(_ArrowUnsupported(
        isempty(detail) ? "$what returned $code" : "$what returned $code: $detail",
    ))
end

@inline function _buffer(array::_ArrowArray, i::Int)
    array.n_buffers >= i ||
        throw(_ArrowUnsupported("Arrow array has $(array.n_buffers) buffers, needs $i"))
    return unsafe_load(array.buffers, i)
end

"Read bit `i` (0-based) of an Arrow bitmap; a NULL validity buffer means all valid."
@inline function _isvalid(bitmap::Ptr{UInt8}, i::Integer)
    bitmap == C_NULL && return true
    return !iszero(unsafe_load(bitmap, (i >> 3) + 1) & (0x01 << (i & 7)))
end

@inline function _bitat(bitmap::Ptr{UInt8}, i::Integer)
    return !iszero(unsafe_load(bitmap, (i >> 3) + 1) & (0x01 << (i & 7)))
end

# WKB packs a uint32 type code at byte 1 and coordinates from byte 5, so every
# multi-byte field sits at an odd address. Assembling them byte-wise keeps the
# loads honest about alignment; LLVM folds the shifts back into one load where
# the target allows it.
@inline function _loadle(::Type{UInt32}, p::Ptr{UInt8})
    return UInt32(unsafe_load(p, 1)) |
           UInt32(unsafe_load(p, 2)) << 8 |
           UInt32(unsafe_load(p, 3)) << 16 |
           UInt32(unsafe_load(p, 4)) << 24
end

@inline function _loadle(::Type{UInt64}, p::Ptr{UInt8})
    return UInt64(_loadle(UInt32, p)) | UInt64(_loadle(UInt32, p + 4)) << 32
end

@inline _loadle(::Type{Float64}, p::Ptr{UInt8}) =
    reinterpret(Float64, _loadle(UInt64, p))

# --- WKB point decoding -----------------------------------------------------

const _WKB_LITTLE_ENDIAN = 0x01

# XY, then the two spellings of XYZ: the EWKB high bit and ISO's 1000 offset.
@inline _ispointcode(::Val{2}, code::UInt32) = code == 0x00000001
@inline _ispointcode(::Val{3}, code::UInt32) =
    code == 0x80000001 || code == 0x000003e9

@inline function _decodepoint(::Val{N}, p::Ptr{UInt8}, nbytes::Integer) where {N}
    nbytes >= 5 + 8 * N ||
        throw(_ArrowUnsupported("point WKB is $nbytes bytes, needs $(5 + 8N)"))
    unsafe_load(p, 1) == _WKB_LITTLE_ENDIAN ||
        throw(_ArrowUnsupported("big-endian point WKB"))
    code = _loadle(UInt32, p + 1)
    _ispointcode(Val(N), code) ||
        throw(_ArrowUnsupported("WKB type 0x$(string(code; base=16)) in a point column"))
    coords = p + 5
    return if N == 2
        (_loadle(Float64, coords), _loadle(Float64, coords + 8))
    else
        (_loadle(Float64, coords), _loadle(Float64, coords + 8),
         _loadle(Float64, coords + 16))
    end
end

# --- column filling ---------------------------------------------------------
# `dest` is typed `AbstractVector` so one method serves both the narrow
# `Vector{T}` and the widened `Vector{Union{Missing,T}}`; the dynamic dispatch
# is per column per batch, and Julia specializes the body on the concrete type.

function _fill!(
    dest::AbstractVector, plan::_PrimitivePlan{S,T}, array::_ArrowArray, off::Int,
) where {S,T}
    m = Int(array.length)
    values = Ptr{S}(_buffer(array, 2)) + array.offset * sizeof(S)
    if iszero(array.null_count) && S === T && dest isa Vector{T}
        unsafe_copyto!(pointer(dest, off + 1), Ptr{T}(values), m)
        return nothing
    end
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        dest[off+k] = if _isvalid(validity, array.offset + k - 1)
            T(unsafe_load(values, k))
        else
            missing
        end
    end
    return nothing
end

function _fill!(dest::AbstractVector, ::_BoolPlan, array::_ArrowArray, off::Int)
    m = Int(array.length)
    bits = Ptr{UInt8}(_buffer(array, 2))
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        i = array.offset + k - 1
        dest[off+k] = _isvalid(validity, i) ? _bitat(bits, i) : missing
    end
    return nothing
end

function _fill!(
    dest::AbstractVector, ::_StringPlan{O}, array::_ArrowArray, off::Int,
) where {O}
    m = Int(array.length)
    offsets = Ptr{O}(_buffer(array, 2)) + array.offset * sizeof(O)
    data = Ptr{UInt8}(_buffer(array, 3))
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        if _isvalid(validity, array.offset + k - 1)
            from = unsafe_load(offsets, k)
            len = unsafe_load(offsets, k + 1) - from
            dest[off+k] = len > 0 ? unsafe_string(data + from, len) : ""
        else
            dest[off+k] = missing
        end
    end
    return nothing
end

function _fill!(
    dest::AbstractVector, ::_BinaryPlan{O}, array::_ArrowArray, off::Int,
) where {O}
    m = Int(array.length)
    offsets = Ptr{O}(_buffer(array, 2)) + array.offset * sizeof(O)
    data = Ptr{UInt8}(_buffer(array, 3))
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        if _isvalid(validity, array.offset + k - 1)
            from = unsafe_load(offsets, k)
            len = Int(unsafe_load(offsets, k + 1) - from)
            bytes = Vector{UInt8}(undef, len)
            len > 0 && GC.@preserve bytes unsafe_copyto!(pointer(bytes), data + from, len)
            dest[off+k] = bytes
        else
            dest[off+k] = missing
        end
    end
    return nothing
end

function _fill!(
    dest::AbstractVector, ::_DateTimePlan{S,MUL,DIV}, array::_ArrowArray, off::Int,
) where {S,MUL,DIV}
    m = Int(array.length)
    values = Ptr{S}(_buffer(array, 2)) + array.offset * sizeof(S)
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        if _isvalid(validity, array.offset + k - 1)
            raw = Int64(unsafe_load(values, k))
            ms = DIV === 1 ? raw * MUL : fld(raw * MUL, DIV)
            dest[off+k] = Dates.DateTime(Dates.UTM(Dates.UNIXEPOCH + ms))
        else
            dest[off+k] = missing
        end
    end
    return nothing
end

function _fill!(
    dest::AbstractVector, ::_PointPlan{N,O}, array::_ArrowArray, off::Int,
) where {N,O}
    m = Int(array.length)
    offsets = Ptr{O}(_buffer(array, 2)) + array.offset * sizeof(O)
    data = Ptr{UInt8}(_buffer(array, 3))
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        from = unsafe_load(offsets, k)
        nbytes = Int(unsafe_load(offsets, k + 1) - from)
        if nbytes > 0 && _isvalid(validity, array.offset + k - 1)
            dest[off+k] = _decodepoint(Val(N), data + from, nbytes)
        else
            _missingok(dest)
            dest[off+k] = missing
        end
    end
    return nothing
end

function _fill!(
    dest::AbstractVector, ::_GeometryPlan{G,O}, array::_ArrowArray, off::Int,
) where {G,O}
    m = Int(array.length)
    offsets = Ptr{O}(_buffer(array, 2)) + array.offset * sizeof(O)
    data = Ptr{UInt8}(_buffer(array, 3))
    validity = Ptr{UInt8}(_buffer(array, 1))
    @inbounds for k in 1:m
        from = unsafe_load(offsets, k)
        nbytes = Int(unsafe_load(offsets, k + 1) - from)
        if nbytes > 0 && _isvalid(validity, array.offset + k - 1)
            geom = AG.fromWKB(unsafe_wrap(Vector{UInt8}, data + from, nbytes))
            geom isa AG.IGeometry{G} || throw(_ArrowUnsupported(
                "geometry is $(typeof(geom)) in a $G column",
            ))
            dest[off+k] = geom
        else
            _missingok(dest)
            dest[off+k] = missing
        end
    end
    return nothing
end

# A geometry that the validity bitmap did not flag: the column was sized for
# non-missing values, so hand the layer to the row path rather than lie about
# its element type.
@inline function _missingok(dest::AbstractVector)
    Missing <: eltype(dest) ||
        throw(_ArrowUnsupported("NULL geometry outside the validity bitmap"))
    return nothing
end

# --- schema walking ---------------------------------------------------------

const _INT_FORMATS = Dict{String,DataType}(
    "c" => Int8, "C" => UInt8,
    "s" => Int16, "S" => UInt16,
    "i" => Int32, "I" => UInt32,
    "l" => Int64, "L" => UInt64,
)

const _FLOAT_FORMATS = Dict{String,DataType}("f" => Float32, "g" => Float64)

const _OFFSET_WIDTHS = Dict{String,DataType}("z" => Int32, "Z" => Int64)

"""
    _rowpathtype(fielddefn) -> Union{DataType,Nothing}

The element type `ArchGDAL.getfield` produces for this field, or `nothing` for
field types the Arrow consumer declines (lists, time-of-day, UUID).
"""
function _rowpathtype(fielddefn)
    fieldtype = AG.getfieldtype(fielddefn)
    fieldtype === AG.OFSTBoolean && return Bool
    fieldtype === AG.OFSTInt16 && return Int16
    fieldtype === AG.OFSTFloat32 && return Float32
    fieldtype === AG.OFSTJSON && return String
    fieldtype === AG.OFTInteger && return Int32
    fieldtype === AG.OFTInteger64 && return Int64
    fieldtype === AG.OFTReal && return Float64
    fieldtype === AG.OFTString && return String
    fieldtype === AG.OFTBinary && return Vector{UInt8}
    (fieldtype === AG.OFTDate || fieldtype === AG.OFTDateTime) &&
        return Dates.DateTime
    return nothing
end

"Plan for an attribute column whose row-path element type is `T`."
function _fieldplan(format::String, ::Type{T}, child::Int) where {T}
    if T === Bool
        format == "b" && return _BoolPlan(child)
    elseif T === String
        format == "u" && return _StringPlan{Int32}(child)
        format == "U" && return _StringPlan{Int64}(child)
    elseif T === Vector{UInt8}
        format == "z" && return _BinaryPlan{Int32}(child)
        format == "Z" && return _BinaryPlan{Int64}(child)
    elseif T === Dates.DateTime
        return _datetimeplan(format, child)
    elseif T <: Integer
        S = get(_INT_FORMATS, format, nothing)
        S === nothing || return _PrimitivePlan{S,T}(child)
    elseif T <: AbstractFloat
        S = get(_FLOAT_FORMATS, format, get(_INT_FORMATS, format, nothing))
        S === nothing || return _PrimitivePlan{S,T}(child)
    end
    throw(_ArrowUnsupported("Arrow format \"$format\" for a $T column"))
end

"""
    _datetimeplan(format, child)

Plan for Arrow's date32 (`tdD`), date64 (`tdm`) and timestamp (`ts*`) types.

Timestamps carrying an explicit zone offset are declined: GDAL reports GeoPackage
datetimes as `UTC` and writes the stored wall-clock value, which is what the row
path returns, while an offset would shift every value.
"""
function _datetimeplan(format::String, child::Int)
    format == "tdD" && return _DateTimePlan{Int32,86_400_000,1}(child)
    format == "tdm" && return _DateTimePlan{Int64,1,1}(child)
    if startswith(format, "ts") && length(format) >= 4 && format[4] == ':'
        zone = format[5:end]
        (isempty(zone) || zone == "UTC") ||
            throw(_ArrowUnsupported("timestamp zone \"$zone\""))
        format[3] == 's' && return _DateTimePlan{Int64,1000,1}(child)
        format[3] == 'm' && return _DateTimePlan{Int64,1,1}(child)
        format[3] == 'u' && return _DateTimePlan{Int64,1,1000}(child)
        format[3] == 'n' && return _DateTimePlan{Int64,1,1_000_000}(child)
    end
    throw(_ArrowUnsupported("Arrow format \"$format\" for a DateTime column"))
end

"Plan for a geometry column declared as `geomtype` in the layer definition."
function _geometryplan(format::String, geomtype, child::Int)
    O = get(_OFFSET_WIDTHS, format, nothing)
    O === nothing &&
        throw(_ArrowUnsupported("Arrow format \"$format\" for a geometry column"))
    geomtype === AG.wkbPoint && return _PointPlan{2,O}(child)
    geomtype === AG.wkbPoint25D && return _PointPlan{3,O}(child)
    # A layer that does not declare its geometry type may hold anything, and the
    # row path types the column from the geometries themselves.
    geomtype === AG.wkbUnknown &&
        throw(_ArrowUnsupported("layer geometry type is wkbUnknown"))
    return _GeometryPlan{geomtype,O}(child)
end

"""
    _columnplans(layer, schema) -> (names, plans)

Match the stream's schema children to the layer's FID, geometry and attribute
fields, in the column order `Tables.columnnames` reports for a feature.
"""
function _columnplans(layer, schema::_ArrowSchema)
    _string(schema.format) == "+s" ||
        throw(_ArrowUnsupported("root Arrow type \"$(_string(schema.format))\""))

    children = Dict{Symbol,Tuple{Int,String}}()
    for i in 1:schema.n_children
        child = unsafe_load(unsafe_load(schema.children, i))
        child.dictionary == C_NULL ||
            throw(_ArrowUnsupported("dictionary-encoded column"))
        name = Symbol(_string(child.name))
        haskey(children, name) &&
            throw(_ArrowUnsupported("duplicate Arrow column $name"))
        children[name] = (i, _string(child.format))
    end

    function claim(name::Symbol, what::AbstractString)
        entry = get(children, name, nothing)
        entry === nothing &&
            throw(_ArrowUnsupported("no Arrow column for $what $name"))
        delete!(children, name)
        return entry
    end

    names = Symbol[]
    plans = _ColumnPlan[]
    defn = AG.layerdefn(layer)

    fidcolumn = AG._fidcolumn(layer)
    if fidcolumn !== Symbol("")
        i, format = claim(fidcolumn, "FID column")
        format == "l" ||
            throw(_ArrowUnsupported("Arrow format \"$format\" for the FID column"))
        push!(names, fidcolumn)
        push!(plans, _PrimitivePlan{Int64,Int64}(i))
    end

    for g in 0:(AG.ngeom(defn)-1)
        geomdefn = AG.getgeomdefn(defn, g)
        name = Symbol(AG.getname(geomdefn))
        # GDAL labels an unnamed geometry column "wkb_geometry" in the Arrow
        # schema; the row path keeps it unnamed and `read` renames it later.
        i, format = if name === Symbol("") && !haskey(children, name)
            claim(Symbol("wkb_geometry"), "unnamed geometry field")
        else
            claim(name, "geometry field")
        end
        push!(names, name)
        push!(plans, _geometryplan(format, AG.gettype(geomdefn), i))
    end

    for f in 0:(AG.nfield(defn)-1)
        fielddefn = AG.getfielddefn(defn, f)
        name = Symbol(AG.getname(fielddefn))
        T = _rowpathtype(fielddefn)
        T === nothing && throw(_ArrowUnsupported(
            "OGR field type $(AG.getfieldtype(fielddefn)) of column $name",
        ))
        i, format = claim(name, "field")
        push!(names, name)
        push!(plans, _fieldplan(format, T, i))
    end

    # The row path hides the FID whenever `_fidcolumn` is empty, so the stream's
    # FID child is the one column left over; anything else means the schema is
    # not what this consumer assumes.
    for (name, _) in children
        String(name) in ("OGC_FID", AG.fidcolumnname(layer)) ||
            throw(_ArrowUnsupported("unclaimed Arrow column $name"))
    end

    return names, plans
end

# --- widening and narrowing -------------------------------------------------

"Copy the filled prefix of `col` into a vector that also accepts `missing`."
function _widen(col::Vector{T}, filled::Int) where {T}
    wide = Vector{Union{Missing,T}}(undef, length(col))
    copyto!(wide, 1, col, 1, filled)
    return wide
end

"""
    _narrow(col)

Drop `Missing` from a column that ended up without any, and reduce an
all-missing column to `Vector{Missing}`.

Both match `DataFrame(layer)`, which types each column from the values it sees
rather than from the layer's nullability flags.
"""
function _narrow(col::Vector{T}) where {T}
    Missing <: T || return col
    nmissing = count(ismissing, col)
    nmissing == 0 && return convert(Vector{nonmissingtype(T)}, col)
    nmissing == length(col) && return convert(Vector{Missing}, col)
    return col
end

# --- stream consumption -----------------------------------------------------

function _consumebatch!(
    columns::Vector{AbstractVector},
    plans::Vector{_ColumnPlan},
    array::_ArrowArray,
    nchildren::Int,
    total::Int,
)
    array.n_children == nchildren || throw(_ArrowUnsupported(
        "batch has $(array.n_children) children, schema has $nchildren",
    ))
    m = Int(array.length)
    filled = total + m
    for (c, plan) in enumerate(plans)
        child = unsafe_load(unsafe_load(array.children, _child(plan)))
        child.length == array.length || throw(_ArrowUnsupported(
            "child $(_child(plan)) has $(child.length) rows, batch has $(array.length)",
        ))
        col = columns[c]
        if !iszero(child.null_count) && !(Missing <: eltype(col))
            col = _widen(col, total)
            columns[c] = col
        end
        length(col) < filled && resize!(col, filled)
        _fill!(col, plan, child, total)
    end
    return filled
end

function _consume(
    stream::_ArrowArrayStream,
    streamptr::Ptr{_ArrowArrayStream},
    plans::Vector{_ColumnPlan},
    nchildren::Int,
    nfeature::Int,
)
    columns = AbstractVector[
        Vector{_planeltype(plan)}(undef, nfeature) for plan in plans
    ]
    arrayref = Ref{_ArrowArray}()
    total = 0
    GC.@preserve arrayref begin
        arrayptr = Base.unsafe_convert(Ptr{_ArrowArray}, arrayref)
        while true
            _checkstream(
                ccall(stream.get_next, Cint,
                      (Ptr{_ArrowArrayStream}, Ptr{_ArrowArray}), streamptr, arrayptr),
                stream, streamptr, "get_next",
            )
            array = arrayref[]
            array.release == C_NULL && break
            try
                total = _consumebatch!(columns, plans, array, nchildren, total)
            finally
                ccall(array.release, Cvoid, (Ptr{_ArrowArray},), arrayptr)
            end
        end
    end
    for c in eachindex(columns)
        length(columns[c]) == total || resize!(columns[c], total)
    end
    return columns, total
end

function _streamcolumns(layer, nfeature::Int)
    streamref = Ref{_ArrowArrayStream}()
    GC.@preserve streamref begin
        streamptr = Base.unsafe_convert(Ptr{_ArrowArrayStream}, streamref)
        opened = _with_options(_ARROW_STREAM_OPTIONS) do options
            AG.GDAL.ogr_l_getarrowstream(layer.ptr, streamptr, options)
        end
        # A failed call leaves the stream struct uninitialized, so there is
        # nothing to release.
        opened || throw(_ArrowUnsupported("OGR_L_GetArrowStream failed"))
        stream = streamref[]
        try
            schemaref = Ref{_ArrowSchema}()
            names, plans, nchildren = GC.@preserve schemaref begin
                schemaptr = Base.unsafe_convert(Ptr{_ArrowSchema}, schemaref)
                _checkstream(
                    ccall(stream.get_schema, Cint,
                          (Ptr{_ArrowArrayStream}, Ptr{_ArrowSchema}),
                          streamptr, schemaptr),
                    stream, streamptr, "get_schema",
                )
                schema = schemaref[]
                try
                    ns, ps = _columnplans(layer, schema)
                    (ns, ps, Int(schema.n_children))
                finally
                    schema.release == C_NULL ||
                        ccall(schema.release, Cvoid, (Ptr{_ArrowSchema},), schemaptr)
                end
            end
            columns, total = _consume(stream, streamptr, plans, nchildren, nfeature)
            return names, columns, total
        finally
            stream.release == C_NULL ||
                ccall(stream.release, Cvoid, (Ptr{_ArrowArrayStream},), streamptr)
        end
    end
end

"""
    _read_arrow(layer) -> Union{Nothing,DataFrame}

Read `layer` through GDAL's Arrow C stream, or return `nothing` to ask for the
row path.

The row path takes over for layers the stream cannot serve identically:

| condition | why |
|---|---|
| `OLCFastGetArrowStream` is false | the generic OGR stream iterates features anyway |
| unknown feature count | the columns cannot be sized up front |
| empty layer | `Tables.schema` types an empty layer from its nullability flags |
| unsupported Arrow or OGR type | lists, time-of-day, dictionary encodings |
| `wkbUnknown` geometry column | element type comes from the geometries themselves |
| WKB that disagrees with the layer definition | big-endian, or a type the column does not declare |
"""
function _read_arrow(layer)::Union{Nothing,DataFrame}
    iszero(AG.GDAL.ogr_l_testcapability(layer.ptr, AG.GDAL.OLCFastGetArrowStream)) &&
        return nothing
    nfeature = AG.nfeature(layer)
    nfeature > 0 || return nothing
    try
        names, columns, total = _streamcolumns(layer, Int(nfeature))
        return DataFrame(
            Pair{Symbol,AbstractVector}[
                name => _narrow(col) for (name, col) in zip(names, columns)
            ];
            copycols=false,
        )
    catch e
        e isa _ArrowUnsupported || rethrow()
        @debug "Reading $(AG.getname(layer)) through the row path: $(e.reason)"
        # Abandoning a partly consumed stream leaves the layer's cursor mid-file.
        AG.resetreading!(layer)
        return nothing
    end
end
