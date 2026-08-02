# Apply geometry operations

Apply GeometryOps functions directly to GeoInterface-compatible geometry
columns, then use the result to select or create rows.

## Select geometries that intersect an area

Create an area and broadcast a GeometryOps predicate over the geometry column:

```@example geometry-operations
using DataFrames
using GeoDataFrames
using GeoInterface
using GeometryOps

places = DataFrame(
    name = ["library", "station"],
    geometry = GeoInterface.Point.([(4.8952, 52.3702), (4.9000, 52.3790)]),
)
area = GeoInterface.Polygon([[
    (4.89, 52.36),
    (4.91, 52.36),
    (4.91, 52.39),
    (4.89, 52.39),
    (4.89, 52.36),
]])

selected = places[GeometryOps.intersects.(places.geometry, Ref(area)), :]
selected.name
```

The predicate returns `true` for each geometry that intersects `area`; the
example selects both names. `Ref(area)` keeps the area scalar during
broadcasting.

Use a projected CRS for operations that depend on planar units or distance.
For coordinate transformation, see [reproject data](reproject-data.md). For
the full operation set and its geometric assumptions, see the
[GeometryOps documentation](https://juliageo.org/GeometryOps.jl/stable/).
