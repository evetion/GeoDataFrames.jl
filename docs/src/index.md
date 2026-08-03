```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "GeoDataFrames.jl"
  text: "Spatial vector data with DataFrames"
  image:
    src: logo.svg
    alt: GeoDataFrames
  actions:
    - theme: brand
      text: Get Started
      link: /tutorials/usage.md
    - theme: alt
      text: View on Github
      link: https://github.com/evetion/GeoDataFrames.jl
    - theme: alt
      text: API Reference
      link: /reference/api.md

features:
  - title: ⚙️ Reading and writing
    details: Read and write common vector formats using one API with explicit control when needed.
    link: /how-to/read-write-data.md
  - title: 🗂️🌐 Data Formats
    details: Works with GeoPackage, Shapefile, GeoJSON, GeoParquet, GeoArrow, FlatGeobuf, CSV, and more.
    link: /reference/native-drivers.md
  - title: 🧩⚡ Seamless integration
    details: Uses ordinary DataFrames with GeoInterface geometries, so it composes naturally with Julia packages.
    link: /background/data-model.md


---
```

```@meta
CurrentModule = GeoDataFrames
```

GeoDataFrames.jl provides geospatial I/O, metadata handling, and geometry workflows on top of ordinary `DataFrame`s.
Use [Rasters.jl](https://rafaqz.github.io/Rasters.jl/) for raster data and
[GeometryOps.jl](https://juliageo.org/GeometryOps.jl) for the operation set.

## Quick start

Install and load:

```julia
using Pkg
Pkg.add(["GeoDataFrames", "NaturalEarth", "CairoMakie"])

using GeoDataFrames
```

Load real country and city geometries, classify cities by intersection with a
country, and write the result:

```@example home-quickstart
using GeoDataFrames  # hide
using NaturalEarth

map_units = select(
    DataFrame(naturalearth("admin_0_map_units", 10)),
    :NAME,
    :geometry,
)
cities = select(
    DataFrame(naturalearth("populated_places", 50)),
    :NAME,
    :geometry,
)

netherlands = subset(map_units, :NAME => ByRow(==("Netherlands")))
nearby_cities = subset(
    cities,
    :NAME => ByRow(name -> name in ["Amsterdam", "Brussels", "Paris"]),
)
country = only(netherlands.geometry)
result = transform(
    nearby_cities,
    :geometry => ByRow(geometry -> intersects(geometry, country)) => :intersects_netherlands,
)
selected = subset(result, :intersects_netherlands)

written_rows = mktempdir() do directory
    path = joinpath(directory, "quickstart.gpkg")
    GeoDataFrames.write(path, result)
    nrow(GeoDataFrames.read(path))
end

(cities = result.NAME, intersects = result.intersects_netherlands, rows_written = written_rows)
```

```@example home-quickstart
using CairoMakie

fig = plot(
    netherlands.geometry;
    color = :dodgerblue,
    strokecolor = :dodgerblue,
    strokewidth = 2,
    axis = (; title = "Cities intersecting the Netherlands"),
)
plot!(result.geometry; color = :lightgray, markersize = 14)
plot!(selected.geometry; color = :tomato, markersize = 14)
fig
```

Continue with [Installation](tutorials/installation.md), [Quick start tutorial](tutorials/usage.md), and [How-to guides](how-to/read-write-data.md).
