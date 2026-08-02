# FlatGeobuf driver

## Activation

Load `FlatGeobuf` with `using FlatGeobuf` or `import FlatGeobuf` to activate
`FlatGeobufDriver`.

## Automatic selection

After activation, `.fgb` files select `FlatGeobufDriver` automatically.

## Reading

The native driver reads with `FlatGeobuf.read` and records the table CRS and
the `:geometry` column.

## Writing

FlatGeobuf has no native write implementation in this extension. A write
through `FlatGeobufDriver` warns and falls back to `ArchGDALDriver`.

## Keywords

Native reads reject keywords. The write fallback uses
[ArchGDAL](../archgdal.md) keywords rather than FlatGeobuf keywords.

## Upstream documentation

[FlatGeobuf.jl documentation](https://evetion.github.io/FlatGeobuf.jl/stable) ·
[FlatGeobuf.jl on GitHub](https://github.com/evetion/FlatGeobuf.jl)
