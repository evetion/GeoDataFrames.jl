module GeoDataFramesGeoParquetExt

using GeoDataFrames: GeoParquetDriver, GeoDataFrames
import GeoInterface as GI
using GeoParquet

function GeoDataFrames.read(::GeoParquetDriver, fname::AbstractString; kwargs...)
    df = GeoParquet.read(fname; kwargs...)
    crs = GeoDataFrames.metadata(df, "GEOINTERFACE:crs", nothing)
    if !isnothing(crs) && (crs.val != "" || crs.val != "null")
        ncrs = GeoDataFrames.GFT.ProjJSON(GeoParquet.JSON3.write(crs.val))
        GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", ncrs; style = :note)
    end
    df
end

function GeoDataFrames.write(::GeoParquetDriver, fname::AbstractString, data; kwargs...)
    GeoParquet.write(fname, data, GI.geometrycolumns(data); kwargs...)
end

end
