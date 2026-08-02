# Your first spatial dataset

This lesson creates two Amsterdam locations, records their coordinate reference
system (CRS), saves and reloads them, projects them for mapping, performs a
spatial test, and draws the result.

## Install the packages

Start Julia's package manager and install the packages used directly in this
lesson:

```julia
using Pkg
Pkg.add(["CairoMakie", "DataFrames", "GeoDataFrames", "GeoInterface"])
```

## Create locations and declare their CRS

The coordinates below use longitude, latitude order in WGS 84. `setcrs!`
records that fact as table metadata; it does not change any coordinates.

```@example first-spatial-data
using CairoMakie
using DataFrames
using GeoDataFrames
using GeoInterface
using GeoDataFrames: setcrs!

places = DataFrame(
    name = ["library", "station"],
    geometry = GeoInterface.Point.([(4.8952, 52.3702), (4.9000, 52.3790)]),
)
setcrs!(places, EPSG(4326))
```

Julia displays a two-row table. Its `:geometry` column contains points, and
its CRS is now EPSG:4326. For other geometry columns or CRS metadata, see
[manage geometry metadata](../how-to/manage-metadata.md).

## Save and load the table

Write a GeoPackage in a temporary directory, then read it back. The `do` block
removes the directory after the read completes.

```@example first-spatial-data
stored_places = mktempdir() do directory
    path = joinpath(directory, "places.gpkg")
    GeoDataFrames.write(path, places)
    GeoDataFrames.read(path)
end

(names = names(stored_places), crs = GeoInterface.crs(stored_places))
```

The result lists `name` and `geometry`, with the stored CRS. For layers,
drivers, remote paths, and file options, see [read and write vector
data](../how-to/read-write-data.md).

## Project coordinates for a map

Web Mercator uses metre-like projected coordinates. `reproject` returns a new
table, leaving `stored_places` in EPSG:4326.

```@example first-spatial-data
projected_places = reproject(stored_places, EPSG(3857))

(original_crs = GeoInterface.crs(stored_places), projected_crs = GeoInterface.crs(projected_places))
```

The result reports EPSG:4326 for the original table and EPSG:3857 for the new
one. See [reproject data](../how-to/reproject-data.md) before transforming
larger datasets.

## Apply a geometry operation

GeometryOps predicates work on the GeoInterface geometries in the column. This
one finds the point that intersects the library point.

```@example first-spatial-data
selected = projected_places[
    GeometryOps.intersects.(projected_places.geometry, Ref(projected_places.geometry[1])),
    :,
]

selected.name
```

The selected name is `"library"`. See [apply geometry
operations](../how-to/geometry-operations.md) for predicates and
transformations on areas and other geometry types.

## Plot the points

Makie recognizes GeoInterface geometries. The final expression creates a
CairoMakie figure containing the two projected points.

```@example first-spatial-data
plot(projected_places.geometry)
```

For axes, colours, labels, and other presentation choices, start with [plot
geometries](../how-to/plot-geometries.md) and then consult
[Makie's documentation](https://docs.makie.org/stable/).
