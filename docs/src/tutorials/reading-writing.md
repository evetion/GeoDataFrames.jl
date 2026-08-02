# Reading and writing

This tutorial reads a small, fixed GeoJSON dataset, inspects the resulting
`DataFrame` and its spatial metadata, then writes it to a temporary
GeoPackage.

## Read a dataset

The source is a pinned copy of GDAL's one-point GeoJSON test dataset, so the
example reads the same data every time:

```@example reading-writing
using GeoDataFrames
using GeoInterface

source =
    "https://raw.githubusercontent.com/OSGeo/gdal/decb67c35ec249c1bae55f53238d5a69e7eff153/autotest/ogr/data/geojson/point.geojson"
table = GeoDataFrames.read(source)
table
```

`read` returns an ordinary `DataFrame` with a geometry column. Inspect the
geometry columns and coordinate reference system (CRS) recorded on that table:

```@example reading-writing
GeoInterface.geometrycolumns(table)
```

```@example reading-writing
GeoInterface.crs(table)
```

The GeoJSON dataset has no CRS, so the second expression returns `nothing`.

## Write the dataset

Write the table to a GeoPackage in a temporary directory. The `do` block
removes the directory after the example finishes:

```@example reading-writing
mktempdir() do directory
    path = joinpath(directory, "test_points.gpkg")
    GeoDataFrames.write(path, table)
    isfile(path)
end
```

For layers, URLs, archives, options, and explicit drivers, see
[read and write vector data](../how-to/read-write-data.md).
