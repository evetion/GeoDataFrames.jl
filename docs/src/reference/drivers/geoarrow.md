# GeoArrow driver

## Activation

Load `GeoArrow` with `using GeoArrow` or `import GeoArrow` to activate
`GeoArrowDriver`.

## Automatic selection

After activation, `.arrow` and `.feather` files select `GeoArrowDriver`
automatically.

## Reading

The native driver reads with `GeoArrow.read`, preserves the reported geometry
columns, and collects each geometry column.

## Writing

The native driver writes with `GeoArrow.write`.

## Keywords

Additional keywords are delegated to GeoArrow and its Arrow backend for both
reading and writing. Consult their documentation for the package-owned
keyword sets.

## Upstream documentation

[GeoArrow.jl documentation](https://juliageo.github.io/GeoArrow.jl/stable) ·
[GeoArrow.jl on GitHub](https://github.com/JuliaGeo/GeoArrow.jl)
