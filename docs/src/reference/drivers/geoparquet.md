# GeoParquet driver

## Activation

Load `GeoParquet` with `using GeoParquet` or `import GeoParquet` to activate
`GeoParquetDriver`.

## Automatic selection

After activation, `.parquet` and `.pq` files select `GeoParquetDriver`
automatically.

## Reading

The native driver reads with `GeoParquet.read` and derives CRS metadata from
the GeoParquet metadata.

## Writing

The native driver writes with `GeoParquet.write`.

## Keywords

Additional keywords are delegated to GeoParquet and its Parquet2 backend for
both reading and writing. Consult their documentation for the package-owned
keyword sets.

## Upstream documentation

[GeoParquet.jl documentation](https://JuliaGeo.github.io/GeoParquet.jl/stable) ·
[GeoParquet.jl on GitHub](https://github.com/JuliaGeo/GeoParquet.jl)
