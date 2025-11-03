# Migration Guide

## Version 0.4.0
This version saw two big changes, the possibility of using native Julia packages as backends for reading and writing geospatial data, and the switch to GeometryOps.jl for geometry operations.

### Native Julia Backends
When a native Julia package for a specific geospatial format is installed and imported (e.g. also loading Shapefile.jl), GeoDataFrames.jl will automatically use it as the backend for reading and writing files of that format (e.g. .shp files). This allows for faster and more efficient handling of geospatial data without relying on ArchGDAL. See [File formats](@ref) for all native drivers and formats.

This means that the keyword arguments for `read` and `write` may differ from those when using the default (and pre v0.4.0) ArchGDAL backend. Please refer to the documentation of the corresponding package for details.

You can get the old behaviour back by explicitly using the `ArchGDALDriver` when reading/writing files like so: 
- `read(GeoDataFrames.ArchGDALDriver(), fn; kwargs)` 
- `write(GeoDataFrames.ArchGDALDriver(), fn, df; kwargs)`.

### Geometry operations
With native drivers, as discussed above, geometries may no longer be of ArchGDAL types, but native Julia geometries. While this might speed up your code, most of these native driver packages do not implement geometry operations (e.g. `intersects`). Using GeoInterface operations on them will then lead to a `MethodError`, as it only is implemented by and for ArchGDAL.jl. Therefore, GeoDataFrames.jl now depends on GeometryOps.jl and exports its methods for geometry operations. GeometryOps operations will also work for the default ArchGDAL geometries.

To get the old behaviour back, you can still use GeoInterface operations but need to use the `read/write(ArchGDALDriver(),...)` discussed above.
