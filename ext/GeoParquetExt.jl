module GeoParquetExt

using GeoDataFrames: GeoParquetDriver, GeoDataFrames
import GeoInterface as GI
using GeoParquet

function GeoDataFrames.read(::GeoParquetDriver, fname::AbstractString; kwargs...)
    GeoParquet.read(fname; kwargs...)
end

function GeoDataFrames.write(::GeoParquetDriver, fname::AbstractString, data; kwargs...)
    GeoParquet.write(fname, data, GI.geometrycolumns(data); kwargs...)
end
end
