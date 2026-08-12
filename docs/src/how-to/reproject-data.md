# Reproject data

Transform all registered geometry columns after you know the source CRS and
need coordinates in another CRS.

## Create a projected copy

[`reproject`](@ref) returns a new DataFrame. The input table retains its
coordinates and CRS.

```@example reproject-data
using GeoDataFrames
using GeoDataFrames: reproject!
using CairoMakie
using NaturalEarth

countries = select(
    DataFrame(naturalearth("admin_0_countries", 50)),
    :NAME,
    :CONTINENT,
    :geometry,
)

netherlands = subset(countries, :NAME => ByRow(==("Netherlands")))
web_mercator = reproject(netherlands, EPSG(3857))

(original = GeoInterface.crs(netherlands), projected = GeoInterface.crs(web_mercator))
```

The result reports EPSG:4326 for `netherlands` and EPSG:3857 for
`web_mercator`.

## Compare CRS side by side

Plot the same world geometries in geographic and projected CRS to show both
the coordinate scale and the shape change:

```@example reproject-data
world = subset(countries, :CONTINENT => ByRow(!=("Antarctica")))
world_3857 = reproject(world, EPSG(3857))

fig = Figure(size = (780, 360))
ax1 = Axis(fig[1, 1], title = "EPSG:4326 (lon/lat)")
plot!(
    ax1,
    world.geometry;
    color = :lightgray,
    strokecolor = :gray,
)

ax2 = Axis(fig[1, 2], title = "EPSG:3857 (meters)")
plot!(
    ax2,
    world_3857.geometry;
    color = :lightgray,
    strokecolor = :gray,
)
fig
```

## Transform in place

Use [`reproject!`](@ref) when replacing the table's coordinates is intentional:

```@example reproject-data
reproject!(netherlands, EPSG(3857))
GeoInterface.crs(netherlands)
```

The result is EPSG:3857, and `netherlands.geometry` now contains projected
coordinates.

## Keep GIS coordinate ordering

`always_xy = true` is the default. It interprets geographic coordinates in
traditional GIS order: x, y, or longitude, latitude. Set
`always_xy = false` only when the CRS's authority-compliant axis order is
required:

```julia
authority_order_places = DataFrame(
    geometry = GeoInterface.Point.([(52.3702, 4.8952)]),
)
authority_order = reproject(
    authority_order_places,
    EPSG(4326),
    EPSG(28992);
    always_xy = false,
)
```

Confirm the source CRS before transforming; assigning a CRS label is not a
transformation. See [`setcrs!`](@ref), [manage geometry metadata](manage-metadata.md), the
[metadata reference](../reference/metadata.md), and the [metadata and CRS
background](../background/metadata-and-crs.md).
