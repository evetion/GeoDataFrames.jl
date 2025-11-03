module GeoDataFramesFlatGeobufExt

using FlatGeobuf
using GeoDataFrames: FlatGeobufDriver, ArchGDALDriver, GeoDataFrames

"""
    read(driver::FlatGeobufDriver, fn::AbstractString; kwargs...)

Read `fn` using the FlatGeobufDriver driver.
"""
function GeoDataFrames.read(::FlatGeobufDriver, fname::AbstractString; kwargs...)
    isempty(kwargs) || @error "FlatGeobuf backend does not use keyword arguments."
    table = FlatGeobuf.read(fname; kwargs...)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    crs = GeoDataFrames.GI.crs(table)
    !isnothing(crs) && GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", crs; style = :note)
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

"""
    write(driver::FlatGeobufDriver, fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn` using the FlatGeobufDriver driver.

!!! warning

    This backend cannot write files yet; it will fall back to ArchGDAL.

"""
function GeoDataFrames.write(::FlatGeobufDriver, fname::AbstractString, data; kwargs...)
    # No write support yet
    @warn "FlatGeobuf backend cannot write files yet; falling back to ArchGDAL."
    GeoDataFrames.write(ArchGDALDriver(), fname, data; kwargs...)
end
end
