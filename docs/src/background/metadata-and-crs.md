# Metadata and CRS

Spatial tables need two kinds of context: which columns contain geometries and
which coordinate reference system (CRS) describes their coordinates.
GeoDataFrames stores both as table metadata. That keeps an ordinary DataFrame
interoperable while giving readers and writers a single source for spatial
defaults.

Assigning a CRS records the meaning of coordinates already in a table.
`setcrs!` changes that label only; it does not alter any coordinates. Use it
when the coordinates already use a known CRS but the table lacks that
information.

Transforming a CRS changes coordinate values to express the same locations in
another system. `reproject` returns a transformed copy, and `reproject!`
replaces the geometry coordinates in place. The source CRS must be correct
before either transformation can be meaningful.

The [metadata reference](../reference/metadata.md) specifies the stored
metadata and its accessors. Use [manage geometry
metadata](../how-to/manage-metadata.md) to assign geometry metadata and
[reproject data](../how-to/reproject-data.md) to transform coordinates.
