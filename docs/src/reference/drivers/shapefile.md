# Shapefile driver

## Activation

Load `Shapefile` with `using Shapefile` or `import Shapefile` to activate
`ShapefileDriver`.

## Automatic selection

After activation, `.shp` files select `ShapefileDriver` automatically.

## Reading

The native driver reads with `Shapefile.Table` and records the table CRS and
the `:geometry` column.

## Writing

The native driver writes with `Shapefile.write`.

## Keywords

Native reads reject keywords. Native writes accept `force`, `geometrycolumn`,
and `crs`, which are passed to Shapefile.jl. Other write keywords are
rejected.

## Upstream documentation

[Shapefile.jl documentation](https://JuliaGeo.github.io/Shapefile.jl/stable) ·
[Shapefile.jl on GitHub](https://github.com/JuliaGeo/Shapefile.jl)
