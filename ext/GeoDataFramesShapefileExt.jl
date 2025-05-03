module GeoDataFramesShapefileExt

import GeoDataFrames
using Shapefile

function GeoDataFrames.read(
    ::GeoDataFrames.ShapefileDriver,
    fname::AbstractString;
    kwargs...,
)
    table = Shapefile.Table(fname; kwargs...)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    ncrs = GeoDataFrames.GI.crs(table)
    GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", ncrs; style = :note)
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

function GeoDataFrames.write(
    ::GeoDataFrames.ShapefileDriver,
    fname::AbstractString,
    data;
    kwargs...,
)
    Shapefile.write(fname, data; kwargs...)
end

end
