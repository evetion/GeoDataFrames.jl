module GeoDataFramesGeoJSONExt

using GeoDataFrames: GeoJSONDriver, GeoDataFrames
using GeoJSON

readkwargs = (:lazyfc, :ndim, :numbertype)

"""
    read(driver::GeoJSONDriver, fn::AbstractString; kwargs...)

Read `fn` using the GeoJSONDriver driver.
"""
function GeoDataFrames.read(::GeoJSONDriver, fname::AbstractString; kwargs...)
    kwargnames = keys(kwargs)
    kwargnames ⊆ readkwargs ||
        @error "GeoJSON backend does not support $(setdiff(kwargnames, readkwargs)) as keyword arguments."
    table = GeoJSON.read(fname; kwargs...)
    df = GeoDataFrames.DataFrame(table; copycols = false)
    GeoDataFrames.metadata!(
        df,
        "GEOINTERFACE:crs",
        GeoDataFrames.GI.crs(table);
        style = :note,
    )
    GeoDataFrames.metadata!(df, "GEOINTERFACE:geometrycolumns", (:geometry,); style = :note)
    return df
end

writekwargs = (:geometrycolumn,)

"""
    write(driver::GeoJSONDriver, fn::AbstractString, table; kwargs...)

Write the provided `table` to `fn` using the GeoJSONDriver driver.
"""
function GeoDataFrames.write(::GeoJSONDriver, fname::AbstractString, data; kwargs...)
    kwargnames = keys(kwargs)
    kwargnames ⊆ writekwargs ||
        @error "GeoJSON backend does not support $(setdiff(kwargnames, writekwargs)) as keyword arguments."
    GeoJSON.write(fname, data)
end

end
