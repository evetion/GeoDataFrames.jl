module GeoDataFramesGeoArrowExt

using GeoDataFrames: GeoArrowDriver, GeoDataFrames, GeometryVector
import GeoInterface as GI
using GeoArrow

"""
    read(driver::GeoArrowDriver, fn::AbstractString; kwargs...)

Read `fn` using the GeoArrowDriver driver. Any additional keyword arguments are passed to `Arrow.read`.
"""
function GeoDataFrames.read(
    ::GeoArrowDriver,
    fname::AbstractString;
    create_index::Bool=true,
    kwargs...,
)
    df = GeoArrow.read(fname; kwargs...)
    GeoDataFrames.metadata!(
        df,
        "GEOINTERFACE:geometrycolumns",
        GeoDataFrames.getgeometrycolumns(df);
        style=:note,
    )
    # Replacing a column below resets the `:default`-style metadata of *every*
    # column in the DataFrame (not just the one being replaced), so snapshot
    # all colmetadata upfront and restore it once all mutations are done.
    allcolmeta = Dict(col => GeoDataFrames.colmetadata(df, col) for col in names(df))
    for geom in GeoDataFrames.getgeometrycolumns(df)
        df[!, geom] = GeometryVector(collect(df[!, geom]); create_index)
    end
    for (col, colmeta) in allcolmeta
        for (k, v) in colmeta
            GeoDataFrames.colmetadata!(df, col, k, v)
        end
    end
    return df
end

"""
    write(driver::GeoArrowDriver, fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn` using the GeoArrowDriver driver. Any additional keyword arguments are passed to `Arrow.write`.
"""
function GeoDataFrames.write(::GeoArrowDriver, fname::AbstractString, table; kwargs...)
    GeoArrow.write(fname, table; kwargs...)
end

end
