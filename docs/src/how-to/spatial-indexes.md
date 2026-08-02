# Use spatial indexes

GeoDataFrames does not export a manual spatial-index construction or query
API. Do not call internal caches or rely on a `build_spatialindex`,
`spatialindex`, or `query_spatialindex` workflow.

Reading data creates geometry-column indexes by default. Pass
`create_index = false` when reading if that eager work is unnecessary:

```julia
table = GeoDataFrames.read("observations.gpkg"; create_index = false)
```

Use [geometry operations](geometry-operations.md) for spatial selection and
[spatial joins](spatial-joins.md) for matching table rows. Those public
interfaces choose their own candidate filtering and exact predicates.

The cached index held by a read-time `GeometryVector` is an implementation
detail. Supported mutations invalidate it; it is not an index to query
directly. See the [data model](../background/data-model.md) for that storage
detail.
