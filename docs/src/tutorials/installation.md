# Installation

```@meta
CurrentModule = GeoDataFrames
```

Since `GeoDataFrames.jl` is registered in the Julia General registry, you can simply run the following
command in the Julia REPL:

```julia
julia> using Pkg
julia> Pkg.add("GeoDataFrames.jl")
# or
julia> ] # ']' should be pressed
pkg> add GeoDataFrames
```

If you want to use the latest unreleased version, you can run the following command:

```julia
pkg> add GeoDataFrames#main
```


## Extensions

GeoDataFrames depends on (Arch)GDAL to load and save data by default. However, for several file formats, there now exist native Julia packages that can be used as backends. Before using the native backend for specific file format, you must install and load its corresponding package.


> [!IMPORTANT]
> Keyword arguments passed to `read` and `write` when using these native backends differ from those when using the ArchGDAL backend. Please refer to the documentation of the corresponding package for details.

::: code-group

```julia [ GeoJSON ]
using Pkg
Pkg.add("GeoJSON")
```

```julia [ GeoArrow ]
using Pkg
Pkg.add("GeoArrow")
```

```julia [ GeoParquet ]
using Pkg
Pkg.add("GeoParquet")
```

```julia [ Shapefile ]
using Pkg
Pkg.add("Shapefile")
```

```julia [ FlatGeobuf ]
using Pkg
Pkg.add("FlatGeobuf")
```

:::

See the [File formats](@ref) section for more details on the supported file formats and their corresponding native backends.
