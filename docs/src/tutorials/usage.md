```@meta
CurrentModule = GeoDataFrames
```

# Usage
One uses normal `DataFrame`s and with a Vector of GeoInterface.jl compatible geometries as a column.

```julia
using GeoDataFrames

points = GeoInterface.Point.(rand(10), rand(10))  # point geometry
df = DataFrame(geom=points, name="test");
```

> [!NOTE]
> Unlike geopandas, there's no special GeoDataFrame type here. 

## Reading
Reading into a DataFrame is done by the [`read`](@ref) function. It simply takes a filename.
```julia
df = GeoDataFrames.read("test_points.shp")
10×2 DataFrame
 Row │ geometr                name
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
GeoDataFrames.read("test_points.shp"; layer=0)
GeoDataFrames.read("test_points.shp"; layer="test_points")
```

Any keywords arguments are passed on to the underlying driver, by default the ArchGDAL [`read`](https://yeesian.com/ArchGDAL.jl/dev/reference/#ArchGDAL.read-Tuple%7BAbstractString%7D) function:
```julia
GeoDataFrames.read("test.csv", options=["GEOM_POSSIBLE_NAMES=point,linestring", "KEEP_GEOM_COLUMNS=NO"])
```


## Writing
Writing works by passing a filename and a `DataFrame` with a geometry column to the [`write`](@ref) function. The name of the column should be `:geometry`, but can be set at write time by the keyword option `geometrycolumn`.

```julia
points = GeoInterface.Point.(rand(10), rand(10))
df = DataFrame(customgeomcolumn=points, name="test");
GeoDataFrames.write("test_points.shp", df; geometrycolumn=:customgeomcolumn)
```

You can also set options such as the layer_name, or the coordinate reference system by using [GeoFormatTypes.jl](https://juliageo.org/GeoFormatTypes.jl/stable/):
```julia
GeoDataFrames.write("test_points.shp", df; layer_name="data", crs=EPSG(4326))
```

You can also update existing geopackage files by adding new layers. Set the `update=true` option and provide a unique `layer_name`:
```julia
GeoDataFrames.write("test.gpkg", df; layer_name="foo", update=true)
```

To overwrite an existing layer, either use a new layer name or pass `"OVERWRITE"=>"YES"` in the options:
```julia
GeoDataFrames.write("test.gpkg", df; layer_name="existing_layer", update=true, options=Dict("OVERWRITE"=>"YES"))
```

The most common file extensions are recognized, but you can override this or write uncommon files by setting the driver option. See [here](https://gdal.org/drivers/vector/index.html) for a list of (short) driver names.
```julia
GeoDataFrames.write("test_points.fgb", df; driver="FlatGeobuf", options=Dict("SPATIAL_INDEX"=>"YES"))
```

The following extensions are automatically recognized:
```julia
    ".shp" => "ESRI Shapefile",
    ".gpkg" => "GPKG",
    ".geojson" => "GeoJSON",
    ".vrt" => "VRT",
    ".sqlite" => "SQLite",
    ".csv" => "CSV",
    ".fgb" => "FlatGeobuf",
    ".pq" => "Parquet",
    ".arrow" => "Arrow",
    ".gml" => "GML",
    ".nc" => "netCDF",
```

Note that any Tables.jl compatible table with GeoInterface.jl compatible geometries can be written by GeoDataFrames. You might want
to pass which column(s) contain geometries, or by defining `GeoInterface.geometrycolumns` on your table. Multiple geometry columns,
when enabled by the driver, can be provided in this way.
```julia
table = [(; geom=GeoInterface.Point(1.0, 2.0), name="test")]  # Also a valid table
GeoDataFrames.write("custom.gpkg", table; geometrycolumn=:geom)
```
