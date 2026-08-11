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
Pkg.add(["GeoDataFrames"])

using GeoDataFrames
```

We can `read` a dataset by passing a filename, or an url.
The source is a pinned copy of GDAL's one-point GeoJSON test dataset.

```@example reading-writing
using GeoDataFrames

source = "https://raw.githubusercontent.com/OSGeo/gdal/decb67c35ec249c1bae55f53238d5a69e7eff153/autotest/ogr/data/geojson/point.geojson"
table = GeoDataFrames.read(source)
table
```

`read` returns an ordinary `DataFrame` with a geometry column, and specific metadata on the geometrycolumns and crs.


## Write the dataset

`write` the table to a GeoPackage:

```@example reading-writing
fn = GeoDataFrames.write("test.gpkg", table)
isfile(fn)
```

Continue with [Installation](tutorials/installation.md), [Quick start tutorial](tutorials/usage.md), and [How-to guides](how-to/read-write-data.md).
