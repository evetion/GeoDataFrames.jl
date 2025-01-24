module GeoDataFramesGeoJSONExt

using GeoDataFrames: GeoJSONDriver, GeoDataFrames
using GeoJSON

function GeoDataFrames.read(::GeoJSONDriver, fname::AbstractString; kwargs...)
    GeoDataFrames.DataFrame(GeoJSON.read(fname; kwargs...))
end

function GeoDataFrames.write(::GeoJSONDriver, fname::AbstractString, data; kwargs...)
    GeoJSON.write(fname, data; kwargs...)
end

end
