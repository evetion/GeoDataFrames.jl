function stringlist(dict::Dict{String,String})
    sv = Vector{String}()
    for (k, v) in pairs(dict)
        push!(sv, uppercase(string(k)) * "=" * string(v))
    end
    return sv
end

function getgeometrycolumns(table)
    if GeoInterface.isfeaturecollection(table)
        return GeoInterface.geometrycolumns(table)
    elseif first(DataAPI.metadatasupport(typeof(table)))
        gc = DataAPI.metadata(table, "GEOINTERFACE:geometrycolumns", nothing)
        if isnothing(gc) # fall back to searching for "geometrycolumns" as a string
            gc = DataAPI.metadata(table, "geometrycolumns", (:geometry,))
        end
        return crs
    else
        return (:geometry,)
    end
end

function getcrs(table)
    if GeoInterface.isfeaturecollection(table)
        return GeoInterface.crs(table)
    elseif first(DataAPI.metadatasupport(typeof(table)))
        crs = DataAPI.metadata(table, "GEOINTERFACE:crs", nothing)
        if isnothing(crs) # fall back to searching for "crs" as a string
            crs = DataAPI.metadata(table, "crs", nothing)
        end
        return crs
    else
        return nothing
    end
end

# Override some GeoInterface functions specifically for DataFrames

# These are the basic metadata definitions from which all else follows.

function GeoInterface.crs(table::DataFrame)
    crs = DataAPI.metadata(table, "GEOINTERFACE:crs", nothing)
    if isnothing(crs) # fall back to searching for "crs" as a string
        crs = DataAPI.metadata(table, "crs", nothing)
    end
    return crs
end

function GeoInterface.geometrycolumns(table::DataFrame)
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

# Here, we define a feature as a DataFrame row.
function GeoInterface.getfeature(df::DataFrame, i::Integer)
    return view(df, i, :)
end
# This is simply an optimized method, since we know what we have to do already.
GeoInterface.getfeature(df::DataFrame) = eachrow(df)

# The geometry is defined as the first of the geometry columns.
# TODO: how should we choose between the geometry columns?
function GeoInterface.geometry(row::DataFrameRow)
    return row[first(GeoInterface.geometrycolumns(row))]
end

# The properties are all other columns.
function GeoInterface.properties(row::DataFrameRow)
    return row[DataFrames.Not(first(GeoInterface.geometrycolumns(row)))]
end

# Since `DataFrameRow` is simply a view of a DataFrame, we can reach back 
# to the original DataFrame to get the metadata.
GeoInterface.geometrycolumns(row::DataFrameRow) = GeoInterface.geometrycolumns(getfield(row, :df)) # get the parent of the row view
GeoInterface.crs(row::DataFrameRow) = GeoInterface.crs(getfield(row, :df)) # get the parent of the row view
