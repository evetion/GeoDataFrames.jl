# Reproject data

Transform all registered geometry columns after you know the source CRS and
need coordinates in another CRS.

## Create a projected copy

`reproject` returns a new DataFrame. The input table retains its coordinates
and CRS.

```@example reproject-data
using DataFrames
using GeoDataFrames
using GeoInterface
using GeoDataFrames: setcrs!, reproject!

places = DataFrame(
    name = ["library"],
    geometry = GeoInterface.Point.([(4.8952, 52.3702)]),
)
setcrs!(places, EPSG(4326))

web_mercator = reproject(places, EPSG(3857))

(original = GeoInterface.crs(places), projected = GeoInterface.crs(web_mercator))
```

The result reports EPSG:4326 for `places` and EPSG:3857 for `web_mercator`.

## Transform in place

Use `reproject!` when replacing the table's coordinates is intentional:

```@example reproject-data
reproject!(places, EPSG(3857))
GeoInterface.crs(places)
```

The result is EPSG:3857, and `places.geometry` now contains projected
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
transformation. See [manage geometry metadata](manage-metadata.md), the
[metadata reference](../reference/metadata.md), and the [metadata and CRS
background](../background/metadata-and-crs.md).
