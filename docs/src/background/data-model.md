# Data model

GeoDataFrames works with ordinary `DataFrame`s and with
[Tables.jl](https://tables.juliadata.org/stable/)-compatible tables. A spatial
table has one or more columns that contain
[GeoInterface.jl](https://juliageo.github.io/GeoInterface.jl/stable/)-compatible
geometries. The geometry-column names and coordinate reference system are
recorded as table metadata; see [Metadata and CRS](metadata-and-crs.md).

`GeometryVector` is an implementation detail used for geometry columns in
some read results. It is a mutable vector wrapper that can retain a spatial
index. Tables supplied to `write` do not need to use `GeometryVector`.

## Geometry columns and table metadata

The table records which columns contain geometries and its coordinate reference
system as metadata. This keeps spatial context with the table without requiring
each geometry value to carry the same information. See [metadata and
CRS](metadata-and-crs.md) for its rationale and the [metadata
reference](../reference/metadata.md) for the keys and accessors.

## Read-time geometry storage

Reading can place a geometry column in a `GeometryVector`, a mutable wrapper
around an underlying vector, `A`. Its optional `index` field holds a cached
spatial tree. Supported mutations clear that cache, so it cannot describe
stale geometries. `GeometryVector` is an implementation detail of read
results: a table supplied to `write` need only provide
GeoInterface-compatible geometry columns. See [spatial
indexes](../how-to/spatial-indexes.md) for the supported index workflow.

## Interoperability

Because a spatial table is a `DataFrame`, code that accepts a DataFrame can use
it directly. I/O also accepts [Tables.jl](https://tables.juliadata.org/stable/)-
compatible input, so a table need not use a GeoDataFrames-specific container
before it is written. For reading and writing procedures, see [read and write
vector data](../how-to/read-write-data.md).
