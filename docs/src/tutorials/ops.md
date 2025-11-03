# Operations

## Spatial operations
For spatial operations we use the native Julia package [GeometryOps.jl](https://juliageo.org/GeometryOps.jl/stable/), which is imported automatically.
It has operations such as `intersects`, `contains`, `within`, `buffer`, `convexhull`, `union`, `intersection`, and other tools such as `simplify` and `reproject`. One can apply these operations directly on the geometry column of a GeoDataFrame.

```julia
GeometryOps.intersects.(df.geometry, df.geometry[1]);
10-element BitVector:
 1  # self-intersection
 0
 0
 0
 0
 0
 0
 0
 0
 0
```

To get the pre v0.4 behaviour for ArchGDAL geometries and operations, you can use the GeoInterface operation (also imported automatically), which uses the (Arch)GDAL operations under the hood. You need to read the file with `read(GeoDataFrames.ArchGDALDriver(), fn; kwargs)`, or convert the geometry as described below in [Conversion](@ref). Note that this will not work for files loaded from GeoJSON, GeoParquet, or FlatGeobuf, as they are not supported by ArchGDAL.

```julia
df.geometry = GeoInterface.buffer.(df.geometry, 10)  # points turn into polygons
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

## Metadata

You can get and set the coordinate reference system (CRS) and geometry column of a GeoDataFrame using the utility functions [`crs`](@ref), [`setcrs!`](@ref), [`geometrycolumn`](@ref), and [`geometrycolumn!`](@ref).

```julia
table = DataFrame(geom=GeoInterface.Point(4, 52), name="home")
GeoDataFrames.setgeometrycolumn!(table, :geom)  # set geometry column
GeoDataFrames.setcrs!(table, EPSG(4326))  # set coordinate reference system
GeoDataFrames.write("home.gpkg", table)
```

If your table doesn't include metadata, or you want to override it, most drivers accept the `crs` and `geometrycolumn` keyword arguments in the [`write`](@ref) function.

## Conversion
You can convert between GeoInterface and ArchGDAL geometries using `GeoInterface.convert`:

```julia
table = DataFrame(; geometry = GeoInterface.Point.(rand(10), rand(10)), name = "test")

using ArchGDAL
table.geometry = GeoInterface.convert.(Ref(ArchGDAL), table.geometry)
```

## Reprojection

Reproject uses GeometryOps, except for ArchGDAL geometries, to reproject geometries. We use [GeoFormatTypes.jl](https://juliageo.org/GeoFormatTypes.jl/stable/) to specify the coordinate reference system (CRS) of the geometries. The CRS can be specified in several ways, including EPSG codes, PROJ strings, and WKT strings. Note that we always assume coordinates to be in (x,y) order, so (longitude,latitude) for geographic CRS. You can override this by setting `always_xy=false` in [`reproject`](@ref).

```julia
dfr = GeometryOps.reproject(df, EPSG(4326), EPSG(28992))
10×2 DataFrame
 Row │ geometry                  name
     │ Tuple…                    String
─────┼──────────────────────────────────
   1 │ (-5.85314e5, -5.70947e6)  test
   2 │ (-4.93872e5, -5.63219e6)  test
   3 │ (-4.90248e5, -5.60829e6)  test
   4 │ (-5.83703e5, -5.65952e6)  test
   5 │ (-5.64684e5, -5.67049e6)  test
   6 │ (-5.23958e5, -5.6656e6)   test
   7 │ (-5.10669e5, -5.69072e6)  test
   8 │ (-5.44627e5, -5.71647e6)  test
   9 │ (-4.53527e5, -5.72909e6)  test
  10 │ (-458280.0, -5.72039e6)   test
```

Note that by using GeometryOps, point geometries are reproject to a tuple of coordinates, which is treated as a valid Point geometry.

## Plotting

Plotting will work out of the box with Plots and Makie.

### Plots.jl
```@setup plots
using GeoDataFrames
using Plots
table = DataFrame(; geometry = GeoInterface.Point.(rand(10), rand(10)), name = "test")
GeoDataFrames.write("test_points.shp", table; force=true)
df = GeoDataFrames.read("test_points.shp")
```

```@example plots
using Plots
plot(df.geometry)
```

### Makie
```@setup plots2
using GeoDataFrames
using CairoMakie
df = GeoDataFrames.read("test_points.shp")
```

```@example plots2
using CairoMakie
plot(df.geometry)
```
