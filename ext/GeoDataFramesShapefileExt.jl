module GeoDataFramesShapefileExt

using GeoDataFrames: ShapefileDriver, GeoDataFrames
using Shapefile

function GeoDataFrames.read(::ShapefileDriver, fname::AbstractString; kwargs...)
    GeoDataFrames.DataFrame(Shapefile.Table(fname; kwargs...); copycols = false)
end

function GeoDataFrames.write(::ShapefileDriver, fname::AbstractString, data; kwargs...)
    Shapefile.write(fname, data; kwargs...)
end

end
