# Use a native driver

Load a format's extension package to select its native driver automatically.
This guide assumes GeoDataFrames is already installed.

## Activate the GeoArrow driver

Install GeoArrow in the active environment once, then load it before reading
or writing Arrow data:

```julia
using Pkg
Pkg.add("GeoArrow")
```

```@example native-geoarrow
using DataFrames
using GeoDataFrames
using GeoInterface
using GeoArrow

table = DataFrame(
    name = ["library"],
    geometry = GeoInterface.Point.([(4.8952, 52.3702)]),
)

read_back = mktempdir() do directory
    path = joinpath(directory, "observations.arrow")
    GeoDataFrames.write(path, table)
    GeoDataFrames.read(path)
end

read_back.name
```

Importing `GeoArrow` activates GeoDataFrames' extension. `.arrow` files then
dispatch to GeoArrow rather than the default ArchGDAL driver.

## Select ArchGDAL explicitly

Use `ArchGDALDriver()` when a loaded native extension should not handle a
file:

```julia
table = GeoDataFrames.read(
    GeoDataFrames.ArchGDALDriver(),
    "observations.arrow",
)
GeoDataFrames.write(
    GeoDataFrames.ArchGDALDriver(),
    "observations-copy.arrow",
    table,
)
```

Use only keywords accepted by the selected backend. GeoArrow passes additional
read and write keywords to its corresponding read and write calls; ArchGDAL
uses its own keyword interface. Consult the [native-driver
reference](../reference/native-drivers.md) and [ArchGDAL
reference](../reference/archgdal.md) for supported keywords.
