function stringlist(dict::Dict{String, String})
    sv = Vector{String}()
    for (k, v) in pairs(dict)
        push!(sv, uppercase(string(k)) * "=" * string(v))
    end
    return sv
end

function getgeometrycolumns(table)
    if GI.isfeaturecollection(table)
        return GI.geometrycolumns(table)
    elseif first(DataAPI.metadatasupport(typeof(table)))
        gc = DataAPI.metadata(table, "GEOINTERFACE:geometrycolumns", nothing)
        if isnothing(gc) # fall back to searching for "geometrycolumns" as a string
            gc = DataAPI.metadata(table, "geometrycolumns", (:geometry,))
        end
        return gc
    else
        return (:geometry,)
    end
end

function getcrs(table)
    if GI.isfeaturecollection(table)
        return GI.crs(table)
    end
    crs = geomcrs(table)
    if !isnothing(crs)
        return crs
    end
    if first(DataAPI.metadatasupport(typeof(table)))
        crs = DataAPI.metadata(table, "GEOINTERFACE:crs", nothing)
        if isnothing(crs) # fall back to searching for "crs" as a string
            crs = DataAPI.metadata(table, "crs", nothing)
        end
        return crs
    end
    nothing
end

function geomcrs(table)
    rows = Tables.rows(table)
    geom_column = first(getgeometrycolumns(table))
    if hasproperty(first(rows), geom_column)
        return GI.crs(getproperty(first(rows), geom_column))
    else
        return nothing
    end
end

# Override some GeoInterface functions specifically for DataFrames

# These are the basic metadata definitions from which all else follows.

function GI.crs(table::DataFrame)
    crs = DataAPI.metadata(table, "GEOINTERFACE:crs", nothing)
    if isnothing(crs) # fall back to searching for "crs" as a string
        crs = DataAPI.metadata(table, "crs", nothing)
    end
    return crs
end

function GI.geometrycolumns(table::DataFrame)
    gc = DataAPI.metadata(table, "GEOINTERFACE:geometrycolumns", nothing)
    if isnothing(gc) # fall back to searching for "geometrycolumns" as a string
        gc = DataAPI.metadata(table, "geometrycolumns", (:geometry,))
        # TODO: we could search for columns named e.g. `:geometry`, `:geom`. `:shape`, and caps/lowercase versions.
        # But should we?
    end
    return gc
end

# We don't define DataFrames as feature collections explicitly, since
# that would complicate handling.  But, we can still implement the 
# feature interface, for use in generic code. And dispatch can always
# handle a DataFrame by fixing the trait in a specialized method.

# GI.isfeaturecollection(::Type{<:DataFrame}) = true

# Here, we define a feature as a DataFrame row.
function GI.getfeature(df::DataFrame, i::Integer)
    return view(df, i, :)
end
# This is simply an optimized method, since we know what we have to do already.
GI.getfeature(df::DataFrame) = eachrow(df)

# GI.isfeature(::Type{<:DataFrameRow}) = true
# The geometry is defined as the first of the geometry columns.
# TODO: how should we choose between the geometry columns?
function GI.geometry(row::DataFrameRow)
    return row[first(GI.geometrycolumns(row))]
end

# The properties are all other columns.
function GI.properties(row::DataFrameRow)
    return row[DataFrames.Not(first(GI.geometrycolumns(row)))]
end

# Since `DataFrameRow` is simply a view of a DataFrame, we can reach back 
# to the original DataFrame to get the metadata.
GI.geometrycolumns(row::DataFrameRow) = GI.geometrycolumns(getfield(row, :df)) # get the parent of the row view
GI.crs(row::DataFrameRow) = GI.crs(getfield(row, :df)) # get the parent of the row view

"""
    setgeometrycolumn!(df::DataFrame, column::Symbol)
    setgeometrycolumn!(df::DataFrame, columns::Tuple{Vararg{Symbol}})

Set the geometry column(s) of a GeoDataFrame `df`. Retrieve them with [`GeoInterface.geometrycolumns(df)`](@ref).
"""
setgeometrycolumn!(df::DataFrame, column::Symbol) =
    metadata!(df, "GEOINTERFACE:geometrycolumns", (column,); style = :note)
setgeometrycolumn!(df::DataFrame, columns::Tuple{Vararg{Symbol}}) =
    metadata!(df, "GEOINTERFACE:geometrycolumns", columns; style = :note)

"""
    setcrs!(df::DataFrame, crs)

Set the coordinate reference system of the geometry column(s) of a GeoDataFrame `df`.
Note that this overrides any existing CRS without transforming the geometries.
For transforming geometries, use [`reproject!(df, target_crs)`](@ref) instead.

`crs` should be one of GeoFormatTypes wrappers, such as `EPSG(code)`.
Retrieve it with [`GeoInterface.crs(df)`](@ref).
"""
setcrs!(df::DataFrame, crs) = metadata!(df, "GEOINTERFACE:crs", crs; style = :note)

"""
    reproject(df::DataFrame, target_crs; [always_xy=true,])

Reproject the geometries in a DataFrame `df` to a new Coordinate Reference System `target_crs`, from the current CRS.
See also [`reproject(df, source_crs, target_crs)`](@ref) and the in place version [`reproject!(df, target_crs)`](@ref).
`always_xy` (`true` by default) can override the default axis mapping strategy of the CRS. If true, input is 
assumed to be in the traditional GIS order (longitude, latitude).
"""
function GO.reproject(
    df::DataFrame,
    target_crs::CRSType;
    always_xy = true,
    kwargs...,
) where {CRSType <: Union{GFT.GeoFormat, Proj.CRS, String}}
    reproject!(copy(df), target_crs; always_xy, kwargs...)
end

"""
    reproject(df::DataFrame, source_crs, target_crs; [always_xy=true])

Reproject the geometries in a DataFrame `df` from the crs `source_crs` to a new crs `target_crs`.
This overrides any current CRS of the Dataframe.
"""
function GO.reproject(
    df::DataFrame,
    source_crs::CRSType,
    target_crs::CRSType;
    always_xy = true,
    kwargs...,
) where {CRSType <: Union{GFT.GeoFormat, Proj.CRS, String}}
    rdf = copy(df)
    columns = Tables.columns(rdf)
    for gc in getgeometrycolumns(rdf)
        gc in Tables.columnnames(columns) || continue
        rdf[!, gc] isa AbstractVector{<:AG.IGeometry} || continue
        rdf[!, gc] = AG.clone.(rdf[!, gc])
    end
    reproject!(rdf, source_crs, target_crs; always_xy, kwargs...)
end

"""
    reproject!(df::DataFrame, target_crs; [always_xy=true])

Reproject the geometries in a DataFrame `df` to a new Coordinate Reference System `target_crs`, from the current CRS, in place.
"""
function reproject!(df::DataFrame, target_crs; always_xy = true, kwargs...)
    reproject!(df, getcrs(df), target_crs; always_xy, kwargs...)
end

"""
    reproject!(df::DataFrame, source_crs, target_crs; [always_xy=true])

Reproject the geometries in a DataFrame `df` from the crs `source_crs` to a new crs `target_crs` in place.
This overrides any current CRS of the Dataframe.
"""
function reproject!(df::DataFrame, source_crs, target_crs; always_xy = true, kwargs...)
    columns = Tables.columns(df)
    for gc in getgeometrycolumns(df)
        gc in Tables.columnnames(columns) || continue
        df[!, gc] = _reproject(df[!, gc], source_crs, target_crs; always_xy, kwargs...)
    end
    metadata!(df, "crs", target_crs; style = :note)
    metadata!(df, "GEOINTERFACE:crs", target_crs; style = :note)
end

function _reproject(sv::AbstractVector, source_crs, target_crs; always_xy = true, kwargs...)
    GO.reproject(sv, source_crs, target_crs; always_xy, kwargs...)
end
function _reproject(
    sv::AbstractVector{<:AG.IGeometry},
    source_crs,
    target_crs;
    always_xy = true,
    kwargs...,
)
    # Note this happens in place
    sv .=
        AG.reproject.(
            sv,
            Ref(source_crs),
            Ref(target_crs);
            order = always_xy ? :trad : :compliant,
            kwargs...,
        )
end

function _isvalidlocal(fn)
    startswith(fn, "/vsi") ||
        startswith(fn, "\\\\") ||
        occursin("://", fn) ||
        isfile(fn) ||
        isdir(fn)
end
