const drivers = AG.listdrivers()
const drivermapping = Dict(
    ".shp" => "ESRI Shapefile",
    ".gpkg" => "GPKG",
    ".geojson" => "GeoJSON",
    ".vrt" => "VRT",
    ".sqlite" => "SQLite",
    ".csv" => "CSV",
    ".fgb" => "FlatGeobuf",
    ".pq" => "Parquet",
    ".arrow" => "Arrow",
    ".gml" => "GML",
    ".nc" => "netCDF",
)

function find_driver(fn::AbstractString)
    _, ext = splitext(fn)
    if ext in keys(drivermapping)
        return drivermapping[ext]
    end
    AG.extensiondriver(fn)
end

const lookup_type = Dict{Tuple{DataType, Int}, AG.OGRwkbGeometryType}(
    (GI.PointTrait, 2) => AG.wkbPoint,
    (GI.PointTrait, 3) => AG.wkbPoint25D,
    (GI.PointTrait, 4) => AG.wkbPointZM,
    (GI.MultiPointTrait, 2) => AG.wkbMultiPoint,
    (GI.MultiPointTrait, 3) => AG.wkbMultiPoint25D,
    (GI.MultiPointTrait, 4) => AG.wkbMultiPointZM,
    (GI.LineStringTrait, 2) => AG.wkbLineString,
    (GI.LineStringTrait, 3) => AG.wkbLineString25D,
    (GI.LineStringTrait, 4) => AG.wkbLineStringZM,
    (GI.MultiLineStringTrait, 2) => AG.wkbMultiLineString,
    (GI.MultiLineStringTrait, 3) => AG.wkbMultiLineString25D,
    (GI.MultiLineStringTrait, 4) => AG.wkbMultiLineStringZM,
    (GI.PolygonTrait, 2) => AG.wkbPolygon,
    (GI.PolygonTrait, 3) => AG.wkbPolygon25D,
    (GI.PolygonTrait, 4) => AG.wkbPolygonZM,
    (GI.MultiPolygonTrait, 2) => AG.wkbMultiPolygon,
    (GI.MultiPolygonTrait, 3) => AG.wkbMultiPolygon25D,
    (GI.MultiPolygonTrait, 4) => AG.wkbMultiPolygonZM,
)

"""
    read(fn::AbstractString; layer::Union{Integer,AbstractString}, kwargs...)

Read a file into a DataFrame. Any kwargs are passed to the driver, by default set to [`ArchGDALDriver`](@ref).
"""
function read(fn; kwargs...)
    ext = last(splitext(fn))
    dr = driver(ext)
    df = read(dr, fn; kwargs...)
    for geom in getgeometrycolumns(df)
        df[!, geom] = GeometryVector(df[!, geom])
    end
    df
end

@deprecate read(fn::AbstractString, layer::Union{AbstractString, Integer}; kwargs...) read(
    fn;
    layer,
    kwargs...,
)

"""
    read(driver::AbstractDriver, fn::AbstractString; kwargs...)

Read a file into a DataFrame using the specified driver. Any kwargs are passed to the driver, by default set to [`ArchGDALDriver`](@ref).
"""
function read(driver::AbstractDriver, fn::AbstractString; kwargs...)
    @debug "Using GDAL for reading, import $(package(driver)) for a native driver."
    read(ArchGDALDriver(), fn; kwargs...)
end

"""
    read(driver::ArchGDALDriver, fn::AbstractString; layer::Union{Integer,AbstractString}, kwargs...)

Read a file into a DataFrame using the ArchGDAL driver.
By default you only get the first layer, unless you specify either the index (0 based) or name (string) of the layer.
Other supported kwargs are passed to the [ArchGDAL read](https://yeesian.com/ArchGDAL.jl/stable/reference/#ArchGDAL.read-Tuple{AbstractString}) method.
"""
function read(driver::ArchGDALDriver, fn::AbstractString; layer = nothing, kwargs...)
    _isvalidlocal(fn) || error("File not found.")
    t = AG.read(fn; kwargs...) do ds
        ds.ptr == C_NULL && error("Unable to open $fn.")
        if AG.nlayer(ds) > 1 && isnothing(layer)
            @warn "This file has multiple layers, defaulting to first layer."
        end
        return read(driver, ds, isnothing(layer) ? 0 : layer)
    end
    return t
end

function read(::ArchGDALDriver, ds, layer)
    df, gnames, sr = AG.getlayer(ds, layer) do table
        if table.ptr == C_NULL
            throw(
                ArgumentError(
                    "Given layer id/name doesn't exist. For reference this is the dataset:\n$ds",
                ),
            )
        end
        names, x = AG.schema_names(AG.layerdefn(table))
        sr = AG.getspatialref(table)
        return DataFrame(table), names, sr
    end
    if "" in names(df)
        rename!(df, Symbol("") => :geometry)
        replace!(gnames, Symbol("") => :geometry)
    elseif "geom" in names(df)
        rename!(df, Symbol("geom") => :geometry)
        replace!(gnames, Symbol("geom") => :geometry)
    end
    crs = sr.ptr == C_NULL ? nothing : GFT.WellKnownText(GFT.CRS(), AG.toWKT(sr))
    geometrycolumns = Tuple(gnames)
    metadata!(df, "crs", crs; style = :note)
    metadata!(df, "geometrycolumns", geometrycolumns; style = :note)

    # Also add the GEOINTERFACE:property as a namespaced thing
    metadata!(df, "GEOINTERFACE:crs", crs; style = :note)
    metadata!(df, "GEOINTERFACE:geometrycolumns", geometrycolumns; style = :note)
    return df
end

"""
    write(fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn`. A driver is selected based on the extension of `fn`.
"""
function write(fn::AbstractString, table; kwargs...)
    ext = last(splitext(fn))
    write(driver(ext), fn, table; kwargs...)
end

"""
    write(driver::AbstractDriver, fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn` using the specified driver. Any kwargs are passed to the driver, by default set to [`ArchGDALDriver`](@ref).
"""
function write(driver::AbstractDriver, fn::AbstractString, table; kwargs...)
    @debug "Using GDAL for writing, import $(package(driver)) for a native driver."
    write(ArchGDALDriver(), fn, table; kwargs...)
end

"""
    write(driver::ArchGDALDriver, fn::AbstractString, table; layer_name="data", crs::Union{GFT.GeoFormat,Nothing}=getcrs(table), driver::Union{Nothing,AbstractString}=nothing, options::Dict{String,String}=Dict(), geom_columns::Tuple{Symbol}=getgeometrycolumns(table), kwargs...)

Write the provided `table` to `fn` using the ArchGDAL driver.
"""
function write(
    ::ArchGDALDriver,
    fn::AbstractString,
    table;
    layer_name::AbstractString = "data",
    crs::Union{GFT.GeoFormat, Nothing} = getcrs(table),
    driver::Union{Nothing, AbstractString} = nothing,
    options::Dict{String, String} = Dict{String, String}(),
    geom_columns = nothing,
    geometrycolumn = getgeometrycolumns(table),
    chunksize = 20_000,
    update = false,
    kwargs...,
)
    rows = Tables.rows(table)
    sch = Tables.schema(rows)

    # Determine geometry columns
    if !isnothing(geom_columns)  # backwards compatible
        geometrycolumn = geom_columns
    end
    isnothing(geometrycolumn) && error(
        "Please set the `geometrycolumn` kwarg or define `GI.geometrycolumns` for $(typeof(table))",
    )

    # Accept both Symbol and Tuple{Symbol}
    geometry_columns = if geometrycolumn isa NTuple{N, <:Symbol} where {N}
        geometrycolumn
    elseif geometrycolumn isa Symbol
        (geometrycolumn,)
    else
        throw(
            ArgumentError(
                "geometrycolumn must be a Symbol or a Tuple of Symbols, got a $(typeof(geometrycolumn))",
            ),
        )
    end

    geom_types = []
    for geom_column in geometry_columns
        geometry = getproperty(first(rows), geom_column)
        trait = GI.geomtrait(geometry)
        ndim = GI.ncoord(geometry)
        geom_type = get(lookup_type, (typeof(trait), ndim), nothing)
        isnothing(geom_type) && throw(
            ArgumentError(
                "Can't convert $trait with $ndim dimensions of column $geom_column to ArchGDAL yet.",
            ),
        )
        push!(geom_types, geom_type)
    end

    # Set geometry name in options
    if !("geometry_name" in keys(options))
        options["geometry_name"] = String(first(geometry_columns))
    end

    # Find driver
    if driver !== nothing
        driver = AG.getdriver(driver)
    else
        driver = AG.getdriver(find_driver(fn))
    end

    # Figure out attributes
    fields = Vector{Tuple{Symbol, DataType}}()
    for (name, type) in zip(sch.names, sch.types)
        if !(name in geometry_columns)
            GI.isgeometry(type) &&
                @warn "Writing $name as a non-spatial column, use the `geometrycolumn` argument to write as a geometry."
            nmtype = nonmissingtype(type)
            if !hasmethod(convert, (Type{AG.OGRFieldType}, Type{nmtype}))
                error("Can't convert $type to an OGRFieldType. Please report an issue.")
            end
            push!(fields, (Symbol(name), nmtype))
        end
    end
    if update
        _isvalidlocal(fn) || error("Can't update non-existent file.")
        f = AG.read
        ckwargs = (; flags = AG.OF_UPDATE)
    else
        f = AG.create
        ckwargs = (; driver)
    end
    f(fn; ckwargs...) do ds
        AG.newspatialref() do spatialref
            if isnothing(crs)
                crs = GFT.WellKnownText2(
                    GFT.CRS(),
                    """LOCAL_CS["Undefined SRS",LOCAL_DATUM["unknown",32767],UNIT["unknown",0],AXIS["Easting",EAST],AXIS["Northing",NORTH]]""",
                )
            end

            AG.importCRS!(spatialref, crs)

            can_create_layer = AG.testcapability(ds, "CreateLayer")
            can_use_transaction = AG.testcapability(ds, "Transactions")

            AG.createlayer(;
                name = layer_name,
                dataset = can_create_layer ? ds : AG.create(AG.getdriver("Memory")),
                geom = first(geom_types),  # how to set the name though?
                spatialref = spatialref,
                options = stringlist(options),
            ) do layer
                for (i, (geom_column, geom_type)) in
                    enumerate(zip(geometry_columns, geom_types))
                    if i > 1
                        AG.writegeomdefn!(layer, string(geom_column), geom_type)
                    end
                end
                fieldindices = Int[]
                for (name, type) in fields
                    AG.createfielddefn(String(name), convert(AG.OGRFieldType, type)) do fd
                        AG.setsubtype!(fd, convert(AG.OGRFieldSubType, type))
                        AG.addfielddefn!(layer, fd)
                    end
                    push!(fieldindices, AG.findfieldindex(layer, name, false))
                end

                for chunk in Iterators.partition(rows, chunksize)
                    can_use_transaction &&
                        AG.GDAL.gdaldatasetstarttransaction(ds.ptr, false)

                    for row in chunk
                        AG.addfeature(layer) do feature
                            for (i, (geom_column)) in enumerate(geometry_columns)
                                AG.GDAL.ogr_f_setgeomfielddirectly(
                                    feature.ptr,
                                    i - 1,
                                    _convert(
                                        AG.Geometry,
                                        Tables.getcolumn(row, geom_column),
                                    ),
                                )
                            end
                            for (i, (name, _)) in zip(fieldindices, fields)
                                field = Tables.getcolumn(row, name)
                                if !ismissing(field)
                                    AG.setfield!(feature, i, field)
                                else
                                    AG.GDAL.ogr_f_setfieldnull(feature.ptr, i)
                                end
                            end
                        end
                    end
                    if can_use_transaction
                        try
                            AG.GDAL.gdaldatasetcommittransaction(ds.ptr)
                        catch e
                            e isa AG.GDAL.GDALError &&
                                AG.GDAL.gdaldatasetrollbacktransaction(ds.ptr)
                            rethrow(e)
                        end
                    end
                end
                if !can_create_layer
                    @warn "Can't create layers in this format, copying from memory instead."
                    AG.copy(
                        layer;
                        dataset = ds,
                        name = layer_name,
                        options = stringlist(options),
                    )
                end
            end
        end
    end
    fn
end

# This should be upstreamed to ArchGDAL
const lookup_method = Dict{DataType, Function}(
    GI.PointTrait => AG.unsafe_createpoint,
    GI.MultiPointTrait => AG.unsafe_createmultipoint,
    GI.LineStringTrait => AG.unsafe_createlinestring,
    GI.LinearRingTrait => AG.unsafe_createlinearring,
    GI.MultiLineStringTrait => AG.unsafe_createmultilinestring,
    GI.PolygonTrait => AG.unsafe_createpolygon,
    GI.MultiPolygonTrait => AG.unsafe_createmultipolygon,
)

function _convert(::Type{T}, geom) where {T <: AG.Geometry}
    f = get(lookup_method, typeof(GI.geomtrait(geom)), nothing)
    isnothing(f) && error(
        "Cannot convert an object of $(typeof(geom)) with the $(typeof(type)) trait (yet). Please report an issue.",
    )
    return f(GI.coordinates(geom))
end

function _convert(::Type{T}, geom::AG.IGeometry) where {T <: AG.Geometry}
    return AG.unsafe_clone(geom)
end
