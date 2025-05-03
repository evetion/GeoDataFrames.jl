module GeoDataFramesFlatGeobufExt

using FlatGeobuf
using GeoDataFrames: FlatGeobufDriver, ArchGDALDriver, GeoDataFrames

function GeoDataFrames.read(::FlatGeobufDriver, fname::AbstractString; kwargs...)
    table = FlatGeobuf.read_file(fname; kwargs...)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    GeoDataFrames.rename!(df, :geom => :geometry)
    GeoDataFrames.metadata!(
        df,
        "GEOINTERFACE:crs",
        GeoDataFrames.GFT.EPSG(table.header.crs.code);
        style = :note,
    )
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

function GeoDataFrames.write(::FlatGeobufDriver, fname::AbstractString, data; kwargs...)
    # No write support yet
    GeoDataFrames.write(ArchGDALDriver(), fname, data; kwargs...)
end
end
