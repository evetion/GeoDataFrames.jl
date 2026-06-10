"""
    GeoDataFrames

Work with geospatial vector data (points, lines, polygons and their attributes)
using the familiar `DataFrame` from [DataFrames.jl](https://dataframes.juliadata.org/).

A GeoDataFrame is just a regular `DataFrame` with one or more columns of
[GeoInterface.jl](https://juliageo.org/GeoInterface.jl/) compatible geometries;
there is no dedicated type. The package provides:

- [`read`](@ref) and [`write`](@ref) for the most common vector file formats
  (GeoPackage, Shapefile, GeoJSON, FlatGeobuf, GeoParquet, Arrow, ...).
- Coordinate reference system helpers such as [`setcrs!`](@ref),
  [`reproject`](@ref) and [`reproject!`](@ref).
- Re-exports of `DataFrames`, `GeoInterface`, `GeometryOps` and `Extents` so that
  `using GeoDataFrames` is usually all you need.

```julia
using GeoDataFrames
df = DataFrame(geometry = GeoInterface.Point.(rand(10), rand(10)), name = "test")
GeoDataFrames.write("points.gpkg", df)
```
"""
module GeoDataFrames

import ArchGDAL as AG
using DataFrames: DataFrames, DataFrame, DataFrameRow, metadata, metadata!, rename!
using Tables: Tables
import GeoFormatTypes as GFT
import GeoInterface as GI
using GeoInterface: GeoInterface
using Extents: Extents
using DataAPI: DataAPI
using Reexport: Reexport, @reexport
import GeometryOps as GO
using GeometryOps: GeometryOps
import Proj  # For GO reproject

include("vector.jl")
include("exports.jl")
include("drivers.jl")
include("io.jl")
include("utils.jl")

end  # module
