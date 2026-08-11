# Perform a spatial join

Use a GeometryOps predicate in a [FlexiJoins](https://github.com/JuliaAPlavin/FlexiJoins.jl) join to match rows by their
geometries.

FlexiJoins is a separate package. If you installed only GeoDataFrames, install
and load it before following this guide:

```julia
import Pkg; Pkg.add("FlexiJoins")
using FlexiJoins
```

## Join points to polygons

For a point-in-polygon join, put points on the left and use
[`GeometryOps.within`](@extref) against polygons on the right:

```@example spatial-joins
using GeoDataFrames
using FlexiJoins
using NaturalEarth

map_units = select(
    DataFrame(naturalearth("admin_0_map_units", 10)),
    :ADMIN => :country,
    :NAME => :map_unit,
    :geometry,
)
cities = select(
    DataFrame(naturalearth("populated_places", 50)),
    :NAME => :city,
    :geometry,
)

zones = subset(
    map_units,
    :country => ByRow(
        name -> name in ["Belgium", "Luxembourg", "Netherlands"],
    ),
    :map_unit => ByRow(!=("Caribbean Netherlands")),
)
points = subset(
    cities,
    :city => ByRow(
        name -> name in ["Amsterdam", "Berlin", "Brussels", "Luxembourg", "Paris"],
    ),
)

joined = innerjoin((points, zones), by_pred(:geometry, GeometryOps.within, :geometry))
joined
```

The inner join matches Amsterdam, Brussels, and Luxembourg to their countries.
Berlin and Paris do not match a Benelux country.

## Plot joined and unmatched points

Visualize which points joined to at least one polygon and which did not:

```@example spatial-joins
using CairoMakie

matched_cities = unique(joined.city)
matched = subset(points, :city => ByRow(city -> city in matched_cities))
unmatched = subset(points, :city => ByRow(city -> !(city in matched_cities)))

fig = plot(
    zones.geometry;
    color = (:dodgerblue, 0.12),
    strokecolor = :dodgerblue,
    strokewidth = 2,
    axis = (; title = "Cities joined to Benelux countries"),
)
plot!(unmatched.geometry; color = :gray, markersize = 14)
plot!(matched.geometry; color = :tomato, markersize = 14)
fig
```

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
