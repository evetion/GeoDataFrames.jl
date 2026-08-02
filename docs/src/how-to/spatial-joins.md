# Perform a spatial join

Use a GeometryOps predicate in a FlexiJoins join to match rows by their
geometries.

FlexiJoins is a separate package. If you installed only GeoDataFrames, install
and load it before following this guide:

```julia
import Pkg; Pkg.add("FlexiJoins")
using FlexiJoins
```

## Join points to polygons

For a point-in-polygon join, put points on the left and use `within` against
polygons on the right:

```@example spatial-joins
using DataFrames
using GeoDataFrames
using GeoInterface
using FlexiJoins
using GeometryOps

square(x0, y0, x1, y1) = GeoInterface.Polygon([[
    (x0, y0),
    (x1, y0),
    (x1, y1),
    (x0, y1),
    (x0, y0),
]])

points = DataFrame(
    site = ["A", "B", "C"],
    geometry = GeoInterface.Point.([(0.75, 0.75), (2.5, 2.5), (5.0, 5.0)]),
)
zones = DataFrame(
    zone = ["north", "south"],
    geometry = [square(0.0, 0.0, 2.0, 2.0), square(0.5, 0.5, 3.0, 3.0)],
)

innerjoin((points, zones), by_pred(:geometry, GeometryOps.within, :geometry))
```

The inner join returns a row for every matching pair. Site `A` appears twice
because it lies in both polygons.

## Keep unmatched rows

Choose the join shape according to the rows you need to retain:

```@example spatial-joins
leftjoin((points, zones), by_pred(:geometry, GeometryOps.within, :geometry))
```

`leftjoin` keeps every point and fills the right-side fields with `missing`
when no zone matches. The same condition also supports:

```@example spatial-joins
rightjoin((points, zones), by_pred(:geometry, GeometryOps.within, :geometry))
outerjoin((points, zones), by_pred(:geometry, GeometryOps.within, :geometry))
```

`rightjoin` keeps every zone; `outerjoin` keeps rows from both inputs.

## Check CRS and candidate filtering

Reproject both tables to the same CRS before joining. GeometryOps and
FlexiJoins interpret coordinates as planar x/y values, even when a table
records a geographic CRS.

FlexiJoins indexes the second, usually more complex, table with an STR tree.
Bounding boxes filter candidate pairs before the exact predicate runs. This
reduces candidate checks but does not replace the predicate, and
GeoDataFrames' `GeometryVector` cache is not consumed by current FlexiJoins
joins. For join-condition variants, consult the
[FlexiJoins documentation](https://github.com/JuliaAPlavin/FlexiJoins.jl).
