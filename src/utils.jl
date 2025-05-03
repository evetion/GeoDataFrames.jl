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
# feature interface, for use in generic code.  And dispatch can always
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
    reproject(df::DataFrame, to_crs; [always_xy=false])

Reproject the geometries in a DataFrame `df` to a new Coordinate Reference System `to_crs`, from the current CRS.
See also [`reproject(df, from_crs, to_crs)`](@ref) and the in place version [`reproject!(df, to_crs)`](@ref).
`always_xy` (`false` by default) can override the default axis mapping strategy of the CRS. If true, input is 
assumed to be in the traditional GIS order (longitude, latitude).
"""
function reproject(df::DataFrame, to_crs; always_xy = false)
    reproject!(copy(df), to_crs; always_xy)
end

"""
    reproject(df::DataFrame, from_crs, to_crs; [always_xy=false])

Reproject the geometries in a DataFrame `df` from the crs `from_crs` to a new crs `to_crs`.
This overrides any current CRS of the Dataframe.
"""
function reproject(df::DataFrame, from_crs, to_crs; always_xy = false)
    reproject!(copy(df), from_crs, to_crs; always_xy)
end

"""
    reproject!(df::DataFrame, to_crs; [always_xy=false])

Reproject the geometries in a DataFrame `df` to a new Coordinate Reference System `to_crs`, from the current CRS, in place.
"""
function reproject!(df::DataFrame, to_crs; always_xy = false)
    reproject!(df, getcrs(df), to_crs; always_xy)
end

"""
    reproject!(df::DataFrame, from_crs, to_crs; [always_xy=false])

Reproject the geometries in a DataFrame `df` from the crs `from_crs` to a new crs `to_crs` in place.
This overrides any current CRS of the Dataframe.
"""
function reproject!(df::DataFrame, from_crs, to_crs; always_xy = false)
    columns = Tables.columns(df)
    for gc in getgeometrycolumns(df)
        gc in Tables.columnnames(columns) || continue
        df[!, gc] = GeometryVector(reproject(df[!, gc], from_crs, to_crs; always_xy))
    end
    metadata!(df, "crs", to_crs; style = :note)
    metadata!(df, "GEOINTERFACE:crs", to_crs; style = :note)
end

function reproject(sv::GeometryVector, from_crs, to_crs; always_xy = false)
    GO.reproject.(sv, Ref(from_crs), Ref(to_crs); always_xy)
end
function reproject(sv::AbstractVector{<:AG.IGeometry}, from_crs, to_crs; always_xy = false)
    AG.reproject.(sv, Ref(from_crs), Ref(to_crs); order = always_xy ? :trad : :compliant)
end

function _isvalidlocal(fn)
    startswith(fn, "/vsi") || occursin(":", fn) || isfile(fn) || isdir(fn)
end
