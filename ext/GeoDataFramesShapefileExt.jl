module GeoDataFramesShapefileExt

import GeoDataFrames
using Shapefile

function GeoDataFrames.read(
    ::GeoDataFrames.ShapefileDriver,
    fname::AbstractString;
    kwargs...,
)
    isempty(kwargs) || @error "Shapefile backend does not support keyword arguments."
    table = Shapefile.Table(fname)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    ncrs = GeoDataFrames.GI.crs(table)
    GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", ncrs; style = :note)
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

writekwargs = (:force,)

function GeoDataFrames.write(
    ::GeoDataFrames.ShapefileDriver,
    fname::AbstractString,
    data;
    kwargs...,
)
    kwargnames = keys(kwargs)
    kwargnames ⊆ writekwargs ||
        @error "Shapefile backend does not support $(setdiff(kwargnames, writekwargs)) as keyword arguments."
    Shapefile.write(fname, data; kwargs...)
    fname
end

end
