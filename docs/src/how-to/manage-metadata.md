# Manage geometry metadata

Set the active geometry column and CRS before writing a table whose column
names or coordinate metadata differ from GeoDataFrames' defaults.

## Set metadata on a DataFrame

`setgeometrycolumn!` records which column contains geometries.
`setcrs!` records the coordinate reference system.

```@example manage-metadata
using DataFrames
using GeoDataFrames
using GeoInterface
using GeoDataFrames: setcrs!, setgeometrycolumn!

locations = DataFrame(
    label = ["library"],
    shape = GeoInterface.Point.([(4.8952, 52.3702)]),
)
setgeometrycolumn!(locations, :shape)
setcrs!(locations, EPSG(4326))

(geometrycolumns = GeoInterface.geometrycolumns(locations), crs = GeoInterface.crs(locations))
```

`setcrs!` assigns a CRS label. It does **not** transform coordinate values.
Use [`reproject`](reproject-data.md) when coordinates must change.

## Provide metadata only for one write

When a table cannot store metadata, pass the geometry column and CRS to
`write`:

```@example manage-metadata
anonymous_locations = DataFrame(
    label = ["station"],
    shape = GeoInterface.Point.([(4.9000, 52.3790)]),
)

mktempdir() do directory
    GeoDataFrames.write(
        joinpath(directory, "locations.gpkg"),
        anonymous_locations;
        geometrycolumn = :shape,
        crs = EPSG(4326),
    )
end
```

This write-level metadata does not change `anonymous_locations`. For metadata
formats and retrieval details, see the [metadata reference](../reference/metadata.md)
and [metadata and CRS background](../background/metadata-and-crs.md).
