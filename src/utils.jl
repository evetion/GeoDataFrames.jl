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
