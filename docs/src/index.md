```@raw html
---
# https://vitepress.dev/reference/default-theme-home-page
layout: home

hero:
  name: "GeoDataFrames.jl"
  tagline: "Simple geographical vector data interaction"
  image:
    src: assets/julia-dots-table.svg
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
  - title: Reading and writing
    details: Defines common methods for reading, writing and manipulating geospatial vector data, as one-liners, and as fast as possible.
    link: /tutorials/usage
  - title: Supported data formats
    details: Works out of the box with Shapefiles, GeoPackages, GeoJSON, and more recent formats as GeoParquet and GeoArrow. It uses native Julia drivers where possible.
    link: /background/formats
  - title: Seamless integration
    details: GeoDataFrames.jl is fully compatible with the Tables.jl and GeoInterface.jl ecosystems. This enables plotting, operations and analysis using the full power of the Julia ecosystem.


---
```

```@meta
CurrentModule = GeoDataFrames
```

Simple geographical vector interaction built on top of [ArchGDAL](https://github.com/yeesian/ArchGDAL.jl/). Inspiration taken from [geopandas](https://geopandas.org). See [Rasters.jl](https://rafaqz.github.io/Rasters.jl/) for raster data interaction, and [GeometryOps.jl](https://juliageo.org/GeometryOps.jl) for further geometry operations.
