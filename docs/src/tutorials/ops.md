# Operations

```@meta
CurrentModule = GeoDataFrames
```

## Spatial operations
GeoDataFrames reuses [GeometryOps.jl](https://juliageo.org/GeometryOps.jl/stable/)
for geometry predicates and operations.

```@example tutorial-ops
using GeoDataFrames
using GeoDataFrames: setcrs!
using NaturalEarth

countries = select(
    DataFrame(naturalearth("admin_0_countries", 50)),
    :NAME,
    :geometry,
)

regions = subset(
    countries,
    :NAME => ByRow(name -> name in ["Greece", "Italy", "Norway"]),
)
hulls = select(
    regions,
    :NAME,
    :geometry => ByRow(GeometryOps.convex_hull) => :geometry,
)
hulls
```

## Metadata
Set geometry and CRS metadata on a DataFrame:

```@example tutorial-ops
table = DataFrame(geom=[GeoInterface.Point(4, 52)], name=["home"])
GeoDataFrames.setgeometrycolumn!(table, :geom)  # set geometry column
GeoDataFrames.setcrs!(table, EPSG(4326))  # set coordinate reference system
(GeoInterface.geometrycolumns(table), GeoInterface.crs(table))
```

## Plotting
```@example tutorial-ops
using CairoMakie

fig = plot(
    regions.geometry;
    color = (:lightgray, 0.35),
    strokecolor = :gray,
    axis = (; title = "Country geometries and their convex hulls"),
)
plot!(hulls.geometry; color = (:tomato, 0.2), strokecolor = :tomato)
fig
```

For advanced workflows (layers and write options, reprojection strategy, spatial
joins, native-driver behavior), use:
- [Read and write vector data](../how-to/read-write-data.md)
- [Reproject data](../how-to/reproject-data.md)
- [Perform a spatial join](../how-to/spatial-joins.md)
- [Use a native driver](../how-to/use-native-drivers.md)
