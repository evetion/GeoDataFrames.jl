# File formats
We currently support the following file formats directly based on the file extension:


| Extension | Driver    |
|-----------|----------------|
| .shp | ESRI Shapefile |
| .gpkg | GPKG          |
| .geojson | GeoJSON |
| .vrt | VRT |
| .sqlite | SQLite |
| .csv | CSV |
| .fgb | FlatGeobuf |
| .pq | Parquet |
| .arrow | Arrow |
| .gml | GML |
| .nc | netCDF |


If you get an error like so:
```julia
GeoDataFrames.write("test.foo", df)
ERROR: ArgumentError: There are no GDAL drivers for the .foo extension
```

You can specifiy the driver using a keyword as follows:
```julia
GeoDataFrames.write("test.foo", df; driver="GeoJSON")
```

The complete list of driver codes are listed in the [GDAL documentation](https://gdal.org/drivers/vector/index.html).


## Package extensions

For several file formats, there now exist native Julia packages that can be used as backends. Before using such a specific file format, you must install and load its corresponding package.

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
# now .arrow and .feather files will be loaded using GeoArrow
read("file.arrow")
```

to override this behaviour and use the default GDAL driver, you can pass the driver option as first argument:

```julia
read(ArchGDALDriver(), "file.arrow")
```
