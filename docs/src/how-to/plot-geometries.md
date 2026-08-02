# Plot geometries

Pass a GeoInterface geometry column to CairoMakie to make a quick spatial
plot.

## Plot a deterministic table

```@example plot-geometries
using CairoMakie
using DataFrames
using GeoDataFrames
using GeoInterface

places = DataFrame(
    name = ["library", "station"],
    geometry = GeoInterface.Point.([(4.8952, 52.3702), (4.9000, 52.3790)]),
)

plot(places.geometry)
```

The result is a CairoMakie figure with the two points. Reproject first when
the map needs a projected CRS; see [reproject data](reproject-data.md).

GeoInterface supplies the geometry integration. For layouts, axes, themes,
colour scales, interactivity, and output formats, use the
[Makie documentation](https://docs.makie.org/stable/).
