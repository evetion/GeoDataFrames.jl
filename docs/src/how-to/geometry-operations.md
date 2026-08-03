# Apply geometry operations

Apply GeometryOps functions directly to GeoInterface-compatible geometry
columns, then use the result to select or create rows.

## Select countries intersected by a river

Load country and river geometries, retain a focused set of South American
countries, and broadcast a GeometryOps predicate over the geometry column:

```@example geometry-operations
using DataFrames
using GeoDataFrames
using GeoDataFrames: setcrs!
using GeometryOps
using CairoMakie
using NaturalEarth

countries = select(
    DataFrame(naturalearth("admin_0_countries", 50)),
    :NAME,
    :geometry,
)
rivers = select(
    DataFrame(naturalearth("rivers_lake_centerlines", 50)),
    :name_en,
    :geometry,
)

candidate_countries = subset(
    countries,
    :NAME => ByRow(
        name -> name in ["Argentina", "Bolivia", "Brazil", "Colombia", "Peru"],
    ),
)
amazon = subset(
    rivers,
    :name_en => ByRow(
        name -> !ismissing(name) && startswith(name, "Amazon"),
    ),
)

selected = subset(
    candidate_countries,
    :geometry => ByRow(
        country -> any(
            river -> GeometryOps.intersects(country, river),
            amazon.geometry,
        ),
    ),
)
selected.NAME
```

The result contains Brazil, Colombia, and Peru. Argentina and Bolivia remain
in `candidate_countries` as non-intersecting cases.

```@example geometry-operations
fig = plot(
    candidate_countries.geometry;
    color = (:lightgray, 0.35),
    strokecolor = :gray,
    strokewidth = 2,
    axis = (; title = "Countries intersected by the Amazon"),
)
plot!(selected.geometry; color = (:tomato, 0.5), strokecolor = :tomato)
plot!(amazon.geometry; color = :dodgerblue, linewidth = 3)
fig
```

Use a projected CRS for operations that depend on planar units or distance.
For coordinate transformation, see [reproject data](reproject-data.md). For
the full operation set and its geometric assumptions, see the
[GeometryOps documentation](https://juliageo.org/GeometryOps.jl/stable/).
