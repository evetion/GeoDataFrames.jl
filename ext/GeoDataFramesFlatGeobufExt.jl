module GeoDataFramesFlatGeobufExt

using FlatGeobuf
using GeoDataFrames: FlatGeobufDriver, ArchGDALDriver, GeoDataFrames

function GeoDataFrames.read(::FlatGeobufDriver, fname::AbstractString; kwargs...)
    df = GeoDataFrames.DataFrame(FlatGeobuf.read_file(fname; kwargs...))
    GeoDataFrames.rename!(df, :geom => :geometry)
    return df
end

function GeoDataFrames.write(::FlatGeobufDriver, fname::AbstractString, data; kwargs...)
    # No write support yet
    GeoDataFrames.write(ArchGDALDriver(), fname, data; kwargs...)
end
end
