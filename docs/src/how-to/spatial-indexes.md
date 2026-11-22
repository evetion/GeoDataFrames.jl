# Work with spatial indexes

Use this guide when you need faster repeated spatial filtering or joins.

## Current GeoDataFrames behavior

`GeoDataFrames.read` may store geometry columns in `GeometryVector`, which
caches one GeometryOps spatial tree per column. The first
`GeometryOps.SpatialTreeInterface.spatialtree(column)` call builds that tree,
later calls reuse it, and mutating the column clears it. Reading with
`create_index=true` builds it during the read, which suits columns that are
queried straight away.

For join workflows, [FlexiJoins](https://github.com/JuliaAPlavin/FlexiJoins.jl)
performs candidate filtering with an STR tree on the right-side table before
running the exact geometry predicate.

## Speed up repeated spatial queries

For repeated predicate evaluation over larger datasets, use an index-oriented
package and keep geometries in a table with one consistent CRS:

1. Reproject both datasets to a suitable projected CRS when distance or area
   assumptions matter.
2. Build or reuse the package's index structure once.
3. Use the index to narrow candidates, then apply exact predicates
   (`intersects`, `within`, `contains`) to candidates.

See [perform a spatial join](spatial-joins.md) for table-level join patterns
and [operations and joins background](../background/operations-and-joins.md)
for design rationale.
