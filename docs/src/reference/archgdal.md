# ArchGDAL driver

`ArchGDALDriver()` is the default driver. It is always available and does not
require an additional package import.

## Extension mappings

GeoDataFrames maps these extensions to ArchGDAL/GDAL driver names:

| Extension | GDAL driver |
| --- | --- |
| `.shp` | `ESRI Shapefile` |
| `.gpkg` | `GPKG` |
| `.geojson` | `GeoJSON` |
| `.vrt` | `VRT` |
| `.sqlite` | `SQLite` |
| `.csv` | `CSV` |
| `.fgb` | `FlatGeobuf` |
| `.pq` | `Parquet` |
| `.arrow` | `Arrow` |
| `.gml` | `GML` |
| `.nc` | `netCDF` |

For other extensions, ArchGDAL performs extension-based driver detection.

## Reading

`read(ArchGDALDriver(), fn; layer, kwargs...)` reads the first layer by
default. Set `layer` to a zero-based layer index or a layer name to select a
different layer. Other keywords are passed to
[ArchGDAL.read](https://yeesian.com/ArchGDAL.jl/stable/reference/#ArchGDAL.read-Tuple{AbstractString});
use `options` for GDAL open options.

## Writing

`write(ArchGDALDriver(), fn, table; kwargs...)` accepts these driver keywords:

| Keyword | Effect |
| --- | --- |
| `layer_name` | Name of the output layer; defaults to `"data"`. |
| `crs` | Output CRS; defaults to the table CRS. |
| `driver` | GDAL driver name, overriding selection from the filename. |
| `options` | `Dict{String,String}` of GDAL layer-creation options. |
| `geometrycolumn` | A geometry-column symbol or tuple; defaults to the table geometry columns. |
| `update` | Opens an existing dataset for update instead of creating one. |

The [ArchGDAL reference](https://yeesian.com/ArchGDAL.jl/stable/reference/)
and [GDAL vector-driver index](https://gdal.org/en/stable/drivers/vector/index.html)
describe the supported GDAL drivers and their options.


## Examples

### Reading a CSV
Some data is distributed as CSV files with WKT geometries in a custom column such as `wkt`. Something like
```csv
wkt,name
"POINT (30 10)","point1"
```
You can read such files as follows:

```julia
using GeoDataFrames
# Tell GDAL where to find the geometry column and not to keep it as a regular column (otherwise DataFrames will fail to parse it)
df =
GeoDataFrames.read("test.csv", options=["GEOM_POSSIBLE_NAMES=wkt", "KEEP_GEOM_COLUMNS=NO"])
```

We don't know the CRS, so it will be `nothing` by default.
You can set it using [`setcrs!`](@ref) if you know it, but ideally we use better spatial file formats (such as Geopackage) that store the CRS natively.
