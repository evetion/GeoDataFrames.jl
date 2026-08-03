# Read and write vector data

Use the file extension to select a driver, or select ArchGDAL explicitly when
you need GDAL layers, virtual filesystems, or creation options.

## Read a named layer

ArchGDAL reads the first layer by default. Specify an integer layer index
(zero-based) or a layer name when a dataset contains several layers:

```julia
districts = GeoDataFrames.read(
    GeoDataFrames.ArchGDALDriver(),
    "city.gpkg";
    layer = "districts",
)
```

## Add or replace a GeoPackage layer

Pass `update = true` to open an existing dataset for updates. The layer name
must be new unless the driver receives its `OVERWRITE=YES` layer option.

```@example read-write-layers
using DataFrames
using GeoDataFrames
using GeoInterface

sites = DataFrame(
    name = ["library"],
    geometry = GeoInterface.Point.([(4.8952, 52.3702)]),
)
stops = DataFrame(
    name = ["station"],
    geometry = GeoInterface.Point.([(4.9000, 52.3790)]),
)

stops_from_layer = mktempdir() do directory
    path = joinpath(directory, "city.gpkg")
    GeoDataFrames.write(path, sites; layer_name = "sites")
    GeoDataFrames.write(path, stops; layer_name = "stops", update = true)
    GeoDataFrames.write(
        path,
        stops;
        layer_name = "stops",
        update = true,
        options = Dict("OVERWRITE" => "YES"),
    )
    GeoDataFrames.read(path; layer = "stops")
end

stops_from_layer.name
```

`layer_name`, `update`, `driver`, and `options` in this procedure are
ArchGDAL-driver keywords. See the [ArchGDAL reference](../reference/archgdal.md)
for their complete interface and driver-specific option values.

## Read remote files and archives

`GeoDataFrames.read` rewrites HTTP, HTTPS, and FTP URLs to GDAL's
`/vsicurl/` filesystem. It rewrites recognized archive paths such as `.zip`
to a matching GDAL virtual filesystem; an HTTPS ZIP therefore becomes a
chained `/vsizip//vsicurl/...` path. Cloud URLs with `s3`, `gs`, `az`, `oss`,
or `swift` schemes receive their matching GDAL filesystem prefix.

```julia
remote = GeoDataFrames.read("https://example.org/data.gpkg")
archived = GeoDataFrames.read("https://example.org/boundaries.zip")
explicit = GeoDataFrames.read("/vsizip//vsicurl/https://example.org/boundaries.zip")
```

An explicit path beginning with `/vsi` is left unchanged. These paths use
ArchGDAL because native drivers do not handle GDAL virtual filesystem paths.

## Choose a driver or pass options

Use `driver` to choose a GDAL vector driver when the extension is insufficient,
and use `options` for that driver's creation options:

```julia
GeoDataFrames.write(
    "observations.fgb",
    stops;
    driver = "FlatGeobuf",
    options = Dict("SPATIAL_INDEX" => "YES"),
)
```

Use a native extension guide when an imported package handles the extension:
[use a native driver](use-native-drivers.md).

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

You can specify the GDAL driver using a keyword as follows:
```julia
GeoDataFrames.write("test.foo", df; driver="GeoJSON")
```

The complete list of GDAL driver codes are listed in the [GDAL documentation](https://gdal.org/drivers/vector/index.html).


## Package extensions

For several file formats, there now exist native Julia packages that can be used as backends. Before using a backend, you must install and load its corresponding package.

::: code-group

```julia [ GeoJSON ]
using Pkg
Pkg.add("GeoJSON")
```

```julia [ CSV ]
using Pkg
Pkg.add("CSV")
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
Pkg.add("FlatGeobuf")  # no write support yet
```

:::

CSV.jl reads and writes geometry columns as WKT. A native read recognizes a column named exactly `WKT`.

and as an example, to use the GeoArrow backend and download files, you will need to do:

```julia
using GeoDataFrames, GeoArrow  
# now .arrow and .feather files will be read/written using GeoArrow
GeoDataFrames.read("file.arrow")
GeoDataFrames.write("file.arrow", df)
```

to override this behaviour and use the default GDAL driver, you can pass the driver option as first argument:

```julia
GeoDataFrames.read(GeoDataFrames.ArchGDALDriver(), "file.arrow")
GeoDataFrames.write(GeoDataFrames.ArchGDALDriver(), "file.arrow", df)
```

Any keywords arguments to the `read` and `write` are passed on to the underlying package.
