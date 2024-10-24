
# Usage
Unlike geopandas, there's no special type here. You just use normal `DataFrame`s and with a Vector of ArchGDAL geometries as a column.

```julia
using DataFrames

coords = zip(rand(10), rand(10))
df = DataFrame(geom=createpoint.(coords), name="test");
```

## Reading
Reading into a DataFrame is done by the [`read`](@ref) function. It simply takes a filename.
```julia
import GeoDataFrames as GDF
df = GDF.read("test_points.shp")
10×2 DataFrame
 Row │ geom                name
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
Writing works by passing a filename and a `DataFrame` with a geometry column to the [`write`](@ref) function. The name of the column should be `:geom`, but can be set at write time by the keyword option `geom_column`.

```julia
using DataFrames

coords = zip(rand(10), rand(10))
df = DataFrame(geom=createpoint.(coords), name="test");
GDF.write("test_points.shp", df)
```

You can also set options such as the layer_name, coordinate reference system.
```julia
GDF.write("test_points.shp", df; layer_name="data", crs=EPSG(4326))
```

The most common file extensions are recognized, but you can override this or write uncommon files by setting the driver option. See [here](https://gdal.org/drivers/vector/index.html) for a list of (short) driver names.
```julia
GDF.write("test_points.fgb", df; driver="FlatGeobuf", options=Dict("SPATIAL_INDEX"=>"YES"))
```

The following extensions are automatically recognized:
```julia
    ".shp" => "ESRI Shapefile"
    ".gpkg" => "GPKG"
    ".geojson" => "GeoJSON"
    ".vrt" => "VRT"
    ".csv" => "CSV"
    ".fgb" => "FlatGeobuf"
    ".gml" => "GML"
    ".nc" => "netCDF"
```

Note that any Tables.jl compatible table with GeoInterface.jl compatible geometries can be written by GeoDataFrames. You might want
to pass which column(s) contain geometries, or by defining `GeoInterface.geometrycolumns` on your table. Multiple geometry columns,
when enabled by the driver, can be provided in this way.
```julia
table = [(; geom=AG.createpoint(1.0, 2.0), name="test")]
GDF.write(tfn, table; geom_columns=(:geom),)
```
