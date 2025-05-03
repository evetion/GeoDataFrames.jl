module GeoDataFramesGeoJSONExt

using GeoDataFrames: GeoJSONDriver, GeoDataFrames
using GeoJSON

function GeoDataFrames.read(::GeoJSONDriver, fname::AbstractString; kwargs...)
    table = GeoJSON.read(fname; kwargs...)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    GeoDataFrames.metadata!(
        df,
        "GEOINTERFACE:crs",
        GeoDataFrames.GI.crs(table);
        style = :note,
    )
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

function GeoDataFrames.write(::GeoJSONDriver, fname::AbstractString, data; kwargs...)
    GeoJSON.write(fname, data; kwargs...)
end

end
