module GeoDataFramesGeoParquetExt

using GeoDataFrames: GeoParquetDriver, GeoDataFrames, GeometryVector
import GeoInterface as GI
using GeoParquet

"""
    read(driver::GeoParquetDriver, fn::AbstractString; kwargs...)

Read `fn` using the GeoParquetDriver driver. Any additional keyword arguments are passed to `Parquet2.read`.
"""
function GeoDataFrames.read(
    ::GeoParquetDriver,
    fname::AbstractString;
    create_index::Bool=true,
    kwargs...,
)
    df = GeoParquet.read(fname; kwargs...)
    crs = GeoDataFrames.metadata(df, "GEOINTERFACE:crs", nothing)
    if !isnothing(crs) && (crs.val != "" || crs.val != "null")
        ncrs = GeoDataFrames.GFT.ProjJSON(GeoParquet.JSON3.write(crs.val))
        GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", ncrs; style=:note)
    end
    for geom in GeoDataFrames.getgeometrycolumns(df)
        df[!, geom] = GeometryVector(df[!, geom]; create_index)
    end
    return df
end

"""
    write(driver::GeoParquetDriver, fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn` using the GeoParquetDriver driver. Any additional keyword arguments are passed to `Parquet2.write`.
"""
function GeoDataFrames.write(::GeoParquetDriver, fname::AbstractString, data; kwargs...)
    GeoParquet.write(fname, data; kwargs...)
end

end
