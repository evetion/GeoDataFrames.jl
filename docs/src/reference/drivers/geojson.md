# GeoJSON driver

## Activation

Load `GeoJSON` with `using GeoJSON` or `import GeoJSON` to activate
`GeoJSONDriver`.

## Automatic selection

After activation, `.json` and `.geojson` files select `GeoJSONDriver`
automatically.

## Reading

The native driver reads with `GeoJSON.read` and records its CRS and
`:geometry` column metadata.

## Writing

The native driver writes with `GeoJSON.write`.

## Keywords

Native reads accept `lazyfc`, `ndim`, and `numbertype`, which are passed to
GeoJSON.jl. Native writes accept `geometrycolumn`, which is passed to
GeoJSON.jl. Other keywords are rejected.

## Upstream documentation

[GeoJSON.jl documentation](https://JuliaGeo.github.io/GeoJSON.jl/stable) ·
[GeoJSON.jl on GitHub](https://github.com/JuliaGeo/GeoJSON.jl)
