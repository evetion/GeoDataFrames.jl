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

## GDAL layer metadata

`ArchGDALDriver` also passes a layer's GDAL metadata through as table metadata,
on read and on write:

| GDAL metadata domain | Table metadata |
| --- | --- |
| The default domain (`""`) | One key per `KEY=VALUE` item |
| A named domain, e.g. `"SHAPEFILE"` | The domain name, with a `Dict` of its items |
| A `json:` or `xml:` domain, e.g. `"json:metadata"` | The domain name, with the document as a `String` |

`json:` and `xml:` domains hold a single document instead of `KEY=VALUE` items
(see GDAL's [metadata model](https://gdal.org/en/stable/user/raster_data_model.html#metadata)).
The OGC API Features driver, for example, puts each collection's JSON
description in `json:metadata`. GDAL may reformat an XML document.

For the rationale for this metadata representation, see
[Metadata and CRS background](../background/metadata-and-crs.md).
