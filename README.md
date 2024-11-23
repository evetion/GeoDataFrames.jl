# GeoDataFrames

[![Stable](https://img.shields.io/badge/docs-stable-blue.svg)](https://evetion.github.io/GeoDataFrames.jl/stable)
[![Dev](https://img.shields.io/badge/docs-dev-blue.svg)](https://evetion.github.io/GeoDataFrames.jl/dev)
[![CI](https://github.com/evetion/GeoDataFrames.jl/actions/workflows/ci.yml/badge.svg)](https://github.com/evetion/GeoDataFrames.jl/actions/workflows/ci.yml)
[![codecov](https://codecov.io/gh/evetion/GeoDataFrames.jl/branch/master/graph/badge.svg?token=38QJAX7H9I)](https://codecov.io/gh/evetion/GeoDataFrames.jl)

Simple geographical vector interaction built on top of [ArchGDAL](https://github.com/yeesian/ArchGDAL.jl/). Inspiration from [geopandas](https://geopandas.org/en/stable/).

Some basic examples without explanation follow here, for a complete overview, please check the [documentation](https://evetion.github.io/GeoDataFrames.jl/stable).

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

```julia
using DataFrames

coords = zip(rand(10), rand(10))
df = DataFrame(geometry=createpoint.(coords), name="test");
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
table = [(; geom=AG.createpoint(1.0, 2.0), name="test")]
GDF.write(tfn, table; geom_columns=(:geom,),)
```

## Operations
The supported operations are the ArchGDAL operations that are exported again to work on Vectors of geometries as well.
Hence, if you can apply all the [ArchGDAL operations](https://yeesian.com/ArchGDAL.jl/stable/geometries/) yourself.

```julia
df.geom = buffer(df.geom, 10);  # points turn into polygons
df
10×2 DataFrame
 Row │ geometry              name
     │ IGeometr…             String
─────┼──────────────────────────────
   1 │ Geometry: wkbPolygon  test
   2 │ Geometry: wkbPolygon  test
   3 │ Geometry: wkbPolygon  test
   4 │ Geometry: wkbPolygon  test
   5 │ Geometry: wkbPolygon  test
   6 │ Geometry: wkbPolygon  test
   7 │ Geometry: wkbPolygon  test
   8 │ Geometry: wkbPolygon  test
   9 │ Geometry: wkbPolygon  test
  10 │ Geometry: wkbPolygon  test
```

### Reprojection
```julia
#Either reproject the whole dataframe (which will set the correct metadata):
dfr = reproject(df, EPSG(4326), EPSG(28992))

# Or reproject the individual geometries only:
df.geometry = reproject(df.geometry, EPSG(4326), EPSG(28992))
10-element Vector{ArchGDAL.IGeometry{ArchGDAL.wkbPolygon}}:
 Geometry: POLYGON ((-472026.042542408 -4406233.59953401,-537 ... 401))
 Geometry: POLYGON ((-417143.506054105 -4395423.99277048,-482 ... 048))
 Geometry: POLYGON ((-450303.142569437 -4301418.89063867,-515 ... 867))
 Geometry: POLYGON ((-434522.645535154 -4351075.81124634,-500 ... 634))
 Geometry: POLYGON ((-443909.665585927 -4412565.43193349,-509 ... 349))
 Geometry: POLYGON ((-438405.666500747 -4299366.23767677,-503 ... 677))
 Geometry: POLYGON ((-400588.951193713 -4365333.532287,-46626 ... 287))
 Geometry: POLYGON ((-409160.489179734 -4388484.98554538,-474 ... 538))
 Geometry: POLYGON ((-453963.150526169 -4408927.89965336,-519 ... 336))
 Geometry: POLYGON ((-498317.413693272 -4321687.31588764,-563 ... 764))
```

## Plotting
```julia
using Plots
plot(df.geometry)
```
![image](img/plot_points.png)
