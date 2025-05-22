# GeoDataFrames
[<img align="right" src="docs/src/assets/logo.png" alt="Your Logo" width="200">](https://evetion.github.io/GeoDataFrames.jl/stable)

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://evetion.github.io/GeoDataFrames.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://evetion.github.io/GeoDataFrames.jl/dev)
[![CI](https://github.com/evetion/GeoDataFrames.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/evetion/GeoDataFrames.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/evetion/GeoDataFrames.jl/branch/master/graph/badge.svg?token=38QJAX7H9I)](https://codecov.io/gh/evetion/GeoDataFrames.jl)


GeoDataFrames provides a simple and efficient way to work with geospatial vector data in Julia. By combining the power of DataFrames with [ArchGDAL](https://github.com/yeesian/ArchGDAL.jl/) and native Julia packages such as [GeometryOps](https://juliageo.org/GeometryOps.jl/stable/), it offers a familiar interface for handling geographical data while maintaining Julia's performance advantages. The package supports reading and writing various geospatial formats, making it easy to integrate into your data analysis workflows. GeoDataFrames takes its inspiration from Python's [GeoPandas](https://geopandas.org/en/stable/).

Basic examples without explanation follow here, for a complete overview, please check the [documentation](https://evetion.github.io/GeoDataFrames.jl/stable).

# Installation
```julia
]add GeoDataFrames
```

# Usage
There's no special type here. You just use normal `DataFrame`s with a `Vector` of ArchGDAL geometries as a column.

## Reading
```julia
import GeoDataFrames as GDF
df = GDF.read("test_points.shp")
10×2 DataFrame
 Row │ geometry            name
     │ IGeometr…           String
─────┼────────────────────────────
   1 │ Geometry: wkbPoint  test
   2 │ Geometry: wkbPoint  test
   3 │ Geometry: wkbPoint  test
   4 │ Geometry: wkbPoint  test
   5 │ Geometry: wkbPoint  test
   6 │ Geometry: wkbPoint  test
   7 │ Geometry: wkbPoint  test
   8 │ Geometry: wkbPoint  test
   9 │ Geometry: wkbPoint  test
  10 │ Geometry: wkbPoint  test
```

You can also specify the layer index or layer name in opening, useful if there are multiple layers:
```julia
GDF.read("test_points.shp", 0)
GDF.read("test_points.shp", "test_points")
```

Any keywords arguments are passed on to the underlying ArchGDAL [`read`](https://yeesian.com/ArchGDAL.jl/dev/reference/#ArchGDAL.read-Tuple%7BAbstractString%7D) function:
```julia
GDF.read("test.csv", options=["GEOM_POSSIBLE_NAMES=point,linestring", "KEEP_GEOM_COLUMNS=NO"])
```

## Writing
Here we create a vector of points (i.e. tuples of x,y coordinates), place them into a DataFrame, and write to a shapefile
```julia
using DataFrames

coords = tuple.(rand(10), rand(10))  
df = DataFrame(geometry=coords, name="test");
GDF.write("test_points.shp", df)
```

You can also set options such as the layer_name, coordinate reference system, the [driver](https://gdal.org/drivers/vector/) and its options:
```julia
GDF.write("test_points.shp", df; layer_name="data", crs=EPSG(4326), driver="FlatGeoBuf", options=Dict("SPATIAL_INDEX"=>"YES"))
```

Note that any Tables.jl compatible table with GeoInterface.jl compatible geometries can be written by GeoDataFrames. You might want
to pass which column(s) contain geometries, or by defining `GeoInterface.geometrycolumns` on your table. Multiple geometry columns,
when enabled by the driver, can be provided in this way.
```julia
table = [(; geometry=(118.17, 34.20), name="test")]
GDF.write("test_points.shp", table)
```
