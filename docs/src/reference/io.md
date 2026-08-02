# I/O

GeoDataFrames provides these entry points:

```julia
read(fn::AbstractString; kwargs...)
read(driver::AbstractDriver, fn::AbstractString; kwargs...)

write(fn::AbstractString, table; kwargs...)
write(driver::AbstractDriver, fn::AbstractString, table; kwargs...)
```

`read(fn; kwargs...)` returns a `DataFrame`. `write(fn, table; kwargs...)`
writes `table` and returns `fn`. The overloads that take a driver select that
driver explicitly.

## Automatic driver selection

The filename extension selects a driver. Native Julia implementations are
used only after their extension package has been imported in the current
session. Without an active native extension, the selected driver delegates to
[`ArchGDALDriver`](archgdal.md). Passing `ArchGDALDriver()` explicitly always
selects that backend.

Keyword arguments are passed to the selected driver. Native-driver keyword
sets belong to their packages and differ from ArchGDAL's keywords. See the
[CSV](drivers/csv.md), [FlatGeobuf](drivers/flatgeobuf.md),
[GeoArrow](drivers/geoarrow.md), [GeoJSON](drivers/geojson.md),
[GeoParquet](drivers/geoparquet.md), and [Shapefile](drivers/shapefile.md)
driver references.
