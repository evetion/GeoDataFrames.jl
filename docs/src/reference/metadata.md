# Metadata and CRS

For `DataFrame`s, GeoDataFrames stores spatial table metadata under these
keys:

| Key | Value |
| --- | --- |
| `"GEOINTERFACE:geometrycolumns"` | A tuple of geometry-column symbols |
| `"GEOINTERFACE:crs"` | The coordinate reference system, or `nothing` |

Use `GeoInterface.geometrycolumns(table)` to retrieve the geometry columns and
`GeoInterface.crs(table)` to retrieve the CRS. For a `DataFrame`, set the
values with:

```julia
setgeometrycolumn!(df, :geometry)
setgeometrycolumn!(df, (:geometry, :centroid))
setcrs!(df, crs)
```

`setcrs!` assigns metadata; it does not transform coordinates. Use
`reproject!` when coordinates must be transformed.

## Writing

`ArchGDALDriver` obtains its default `geometrycolumn` and `crs` values from
this metadata. Its explicit `geometrycolumn` and `crs` keywords override those
defaults. Other drivers support different write keywords; consult the
[native-driver reference](native-drivers.md) or the
[ArchGDAL driver reference](archgdal.md).

For the rationale for this metadata representation, see
[Metadata and CRS background](../background/metadata-and-crs.md).
