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
        return metadata(table, "geometrycolumns", (:geometry,))
    else
        return (:geometry,)
    end
end

function getcrs(table)
    if GeoInterface.isfeaturecollection(table)
        return GeoInterface.crs(table)
    elseif first(DataAPI.metadatasupport(typeof(table)))
        return metadata(table, "crs", nothing)
    else
        return nothing
    end
end
