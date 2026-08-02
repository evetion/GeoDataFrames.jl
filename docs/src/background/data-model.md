# Data model

GeoPandas provides dedicated GeoDataFrame and GeoSeries types. GeoDataFrames
keeps spatial data in an ordinary `DataFrame`: a spatial table has one or more
columns of [GeoInterface.jl](https://juliageo.github.io/GeoInterface.jl/stable/)-
compatible geometries.

This design leaves the table in Julia's usual tabular ecosystem. Index,
select, group, join, and combine it with DataFrames operations; the geometry
column is data alongside the other columns. GeoDataFrames does not introduce a
separate table type or a special selection API.

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
