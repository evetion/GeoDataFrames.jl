# Operations and joins

GeoDataFrames supplies spatial tables, geometry-column metadata, and I/O. It
does not define a second geometry-operation system. Geometry values implement
GeoInterface, and [GeometryOps.jl](https://juliageo.org/GeometryOps.jl/stable/)
provides predicates and geometry operations for those values. Use the
[geometry-operations guide](../how-to/geometry-operations.md) for a table
workflow and the GeometryOps documentation for the supported operation set and
its assumptions.

Spatial joins combine that geometry work with tabular join semantics.
[FlexiJoins.jl](https://github.com/JuliaAPlavin/FlexiJoins.jl) composes a
GeometryOps predicate into a join condition and returns the matching rows.
GeoDataFrames has no GeoPandas-style `sjoin` method; use FlexiJoins and choose
the join shape that fits the rows to retain. The [spatial-joins
guide](../how-to/spatial-joins.md) shows that composition and its candidate
filtering.

This separation keeps table handling, geometric logic, and join policy
independent. Before operations or joins that compare coordinates, make both
tables use the appropriate CRS; see [reproject
data](../how-to/reproject-data.md).
