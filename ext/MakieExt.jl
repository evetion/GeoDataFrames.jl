module MakieExt

using GeoDataFrames
using Makie, GeoMakie

import GeoDataFrames.DataFrame
import GeoMakie.GeoInterface as GI
using GeoMakie.GeometryBasics


"""
    plot(gdf::DataFrame)

Plot geometries from first column found to hold geometry data.

# Arguments
- `gdf` : GeoDataFrame
"""
function GeoDataFrames.plot(gdf::DataFrame)
    col = try
        first(GI.geometrycolumns(gdf))
    catch err
        rethrow(err)
    end

    return GeoDataFrames.plot(gdf, col)
end

"""
    plot(gdf::DataFrame, geom_col::Symbol)

# Arguments
- `gdf` : GeoDataFrame
- `geom_col` : Column holding geometries to display
"""
function GeoDataFrames.plot(gdf::DataFrame, geom_col::Symbol)
    f = Figure(; size=(600, 900))
    ga = GeoAxis(
        f[1,1];
        dest="+proj=latlong +datum=WGS84",
        xlabel="Longitude",
        ylabel="Latitude",
        xticklabelpad=15,
        yticklabelpad=40,
        xticklabelsize=10,
        yticklabelsize=10,
        aspect=AxisAspect(0.75)
    )

    trait = GI.trait(gdf[1, geom_col])
    if trait == GI.PointTrait()
        _plot!(ga, GeoMakie.geo2basic(gdf[!, geom_col]))
    else
        # Try plotting as multipolygon
        _plot!(ga, GeoMakie.to_multipoly(gdf[!, geom_col]))
    end

    xlims!(ga)
    ylims!(ga)

    return f
end

function _plot!(ga::GeoAxis, data::Vector{<:GeometryBasics.Point})::Nothing
    scatter!(ga, data)

    return nothing
end
function _plot!(ga::GeoAxis, data::Vector{<:Vector{<:T}})::Nothing where {T<:GeometryBasics.MultiPolygon}
    poly!(ga, data)

    return nothing
end
function _plot!(ga::GeoAxis, data::Vector{<:T})::Nothing where {T<:GeometryBasics.MultiPolygon}
    poly!(ga, data)

    return nothing
end

end
