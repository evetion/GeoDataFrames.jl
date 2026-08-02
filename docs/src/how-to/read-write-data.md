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
