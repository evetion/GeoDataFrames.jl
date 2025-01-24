module GeoDataFramesGeoArrowExt

using GeoDataFrames: GeoArrowDriver, GeoDataFrames
import GeoInterface as GI
using GeoArrow

function GeoDataFrames.read(::GeoArrowDriver, fname::AbstractString; kwargs...)
    GeoArrow.read(fname; kwargs...)
end

function GeoDataFrames.write(::GeoArrowDriver, fname::AbstractString, data; kwargs...)
    GeoArrow.write(fname, data; kwargs...)
end

end
