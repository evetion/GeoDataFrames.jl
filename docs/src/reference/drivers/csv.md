# CSV driver

## Activation

Load `CSV` with `using CSV` or `import CSV` to activate `CSVDriver`.

## Automatic selection

After activation, `.csv` files select `CSVDriver` automatically.

## Reading

The native driver reads with `CSV.read`. A column named exactly `WKT` is
parsed as a geometry column.

## Writing

The native driver serializes selected geometry columns as WKT, then writes
with `CSV.write`.

## Keywords

`stringtype` defaults to `String` for native reads. GeoDataFrames passes it
and other read keywords to `CSV.read`, and passes write keywords to
`CSV.write`. The complete keyword sets are owned by CSV.jl.

## Upstream documentation

[CSV.jl documentation](https://JuliaData.github.io/CSV.jl/stable) ·
[CSV.jl on GitHub](https://github.com/JuliaData/CSV.jl)
