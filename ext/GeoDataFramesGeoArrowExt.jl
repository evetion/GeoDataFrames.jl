module GeoDataFramesGeoArrowExt

using GeoDataFrames: GeoArrowDriver, GeoDataFrames
import GeoInterface as GI
using GeoArrow

"""
    read(driver::GeoArrowDriver, fn::AbstractString; kwargs...)

Read `fn` using the GeoArrowDriver driver. Any additional keyword arguments are passed to `Arrow.read`.
"""
function GeoDataFrames.read(::GeoArrowDriver, fname::AbstractString; kwargs...)
    GeoArrow.read(fname; kwargs...)
end

"""
    write(driver::GeoArrowDriver, fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn` using the GeoArrowDriver driver. Any additional keyword arguments are passed to `Arrow.write`.
"""
function GeoDataFrames.write(::GeoArrowDriver, fname::AbstractString, data; kwargs...)
    GeoArrow.write(fname, data; kwargs...)
end

end
