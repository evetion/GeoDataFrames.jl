module MakieExt

using GeoDataFrames
using Makie, GeoMakie

import GeoDataFrames.DataFrame


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

    plottable = GeoMakie.geo2basic(gdf[!, geom_col])
    poly!(ga, plottable)

    xlims!(ga)
    ylims!(ga)

    # display(f)

    return f
end

end