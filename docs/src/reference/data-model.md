# Data model

GeoDataFrames works with ordinary `DataFrame`s and with
[Tables.jl](https://tables.juliadata.org/stable/)-compatible tables. A spatial
table has one or more columns that contain
[GeoInterface.jl](https://juliageo.github.io/GeoInterface.jl/stable/)-compatible
geometries. The geometry-column names and coordinate reference system are
recorded as table metadata; see [Metadata and CRS](metadata.md).

`GeometryVector` is an implementation detail used for geometry columns in
some read results. It is a mutable vector wrapper that can retain a spatial
index. Tables supplied to `write` do not need to use `GeometryVector`.
