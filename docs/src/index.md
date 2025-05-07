```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "GeoDataFrames.jl"
  text: "Manipulating spatial data"
  tagline: "simplifies the handling of spatial vector data in Julia."
  image:
    src: logo.svg
    alt: GeoDataFrames
  actions:
    - theme: brand
      text: Get Started
      link: /tutorials/installation.md
    - theme: alt
      text: View on Github
      link: https://github.com/evetion/GeoDataFrames.jl
    - theme: alt
      text: API Reference
      link: /reference/api

features:
  - title: ⚙️ Reading and writing
    details: Defines common methods for reading, writing and manipulating geospatial vector data, as one-liners, and as fast as possible.
    link: /tutorials/usage
  - title: 🗂️🌐 Data Formats
    details: Works out of the box with Shapefiles, GeoPackages, GeoJSON, and more recent formats as GeoParquet and GeoArrow. It uses native Julia drivers where possible.
    link: /tutorials/formats
  - title: 🧩⚡ Seamless integration
    details: GeoDataFrames.jl is fully compatible with the Tables.jl and GeoInterface.jl ecosystems. This enables plotting, operations and analysis using the full power of the Julia ecosystem.


---
```

```@meta
CurrentModule = GeoDataFrames
```

Simple geographical vector interaction built on top of [ArchGDAL](https://github.com/yeesian/ArchGDAL.jl/). Inspiration taken from [geopandas](https://geopandas.org). See [Rasters.jl](https://rafaqz.github.io/Rasters.jl/) for raster data interaction, and [GeometryOps.jl](https://juliageo.org/GeometryOps.jl) for further geometry operations.


## How to Install GeoDataFrames.jl?

Since `GeoDataFrames.jl` is registered in the Julia General registry, you can simply run the following
command in the Julia REPL:

```julia
julia> using Pkg
julia> Pkg.add("GeoDataFrames.jl")
# or
julia> ] # ']' should be pressed
pkg> add GeoDataFrames
```

If you want to use the latest unreleased version, you can run the following command:

```julia
pkg> add GeoDataFrames#main
```


## Package extensions

GeoDataFrames depends on GDAL to load and save data by default. However, for several file formats, there now exist native Julia packages that can be used as backends. Before using such a specific file format, you must install and load its corresponding package.

::: code-group

```julia [ GeoJSON ]
using Pkg
Pkg.add("GeoJSON")
```

```julia [ GeoArrow ]
using Pkg
Pkg.add("GeoArrow")
```

```julia [ GeoParquet ]
using Pkg
Pkg.add("GeoParquet")
```

```julia [ Shapefile ]
using Pkg
Pkg.add("Shapefile")
```

```julia [ FlatGeobuf ]
using Pkg
Pkg.add("FlatGeobuf")
```

:::

and as an example, to use the GeoArrow backend and download files, you will need to do:

```julia
using GeoDataFrames, GeoArrow
```  
  

## 🐞📌  Bugs

::: info Bugs, errors and making issues for GeoDataFrames.jl

Because there are so many vector file types and variations of them, most of the time we need the `exact file` that caused your problem to know how to fix it, and be sure that we have actually fixed it when we are done. So fixing a GeoDataFrames.jl bug nearly always involves downloading some file and running some code that breaks with it (if you can trigger the bug without a file, that's great! but its not always possible).

To make an issue we can fix quickly (or at all) there are three key steps:
1. Include the file in an accessible place on web `without authentication` or any other work on our part, so we can just get it and find your bug. You can put it on a file hosting platform (e.g. google drive, drop box, whatever you use) and share the url.
  
2. Add a [`minimum working example`](https://discourse.julialang.org/t/please-read-make-it-easier-to-help-you/14757) to the issue template that first downloads the file, then runs the function that triggers the bug.
  
3. Paste the `complete stack trace` of the error it produces, right to the bottom, into the issue template. Then we can be sure we reproduced the same problem.
  

Good issues are really appreciated, but they do take just a little extra effort with GeoDataFrames.jl because of this need for files.

:::
