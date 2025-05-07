module GeoDataFramesFlatGeobufExt

using FlatGeobuf
using GeoDataFrames: FlatGeobufDriver, ArchGDALDriver, GeoDataFrames

function GeoDataFrames.read(::FlatGeobufDriver, fname::AbstractString; kwargs...)
    table = FlatGeobuf.read(fname; kwargs...)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    crs = GeoDataFrames.GI.crs(table)
    !isnothing(crs) && GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", crs; style = :note)
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

function GeoDataFrames.write(::FlatGeobufDriver, fname::AbstractString, data; kwargs...)
    # No write support yet
    GeoDataFrames.write(ArchGDALDriver(), fname, data; kwargs...)
end
end
