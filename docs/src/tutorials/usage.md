```@meta
CurrentModule = GeoDataFrames
```

# Quick start
Use ordinary `DataFrame`s with one or more columns of
GeoInterface-compatible geometries.

```@example julia
using GeoDataFrames

points = GeoInterface.Point.([(4.89, 52.37), (4.90, 52.38)])  # point geometry
df = DataFrame(geometry=points, name="test");
```

> [!NOTE]
> Unlike geopandas, there's no special GeoDataFrame type here. `GeoDataFrame`
> is a constructor function that returns a normal `DataFrame`.

## Converting dimensional data

When DimensionalData.jl is loaded, [`GeoDataFrame`](@ref) converts dimensional
arrays and stacks with `X` and `Y` dimensions to a `DataFrame`. Rasters are
dimensional arrays, so the same method handles them. A `Band` dimension becomes
one value column per band:

```julia
using GeoDataFrames, Rasters

raster = Raster(
    reshape(1:12, 2, 2, 3),
    (X(10.0:10.0:20.0), Y(1.0:1.0:2.0), Band([:red, :green, :blue]));
    name=:value,
    crs=EPSG(4326),
)
df = GeoDataFrame(raster)
```

With the default `geometry=:auto`, `Points` sampling produces point geometry and
`Intervals` sampling produces `Extent` rectangles from each cell's interval bounds. Rasters
maps GeoTIFF `AREA_OR_POINT=Point` to `Points` and `Area` (the default) to
`Intervals`, so GeoTIFF semantics are preserved without reading driver-specific
metadata here. Use `geometry=:point` to use the native `X`/`Y` lookup points for
interval-sampled data instead.

Geometry and value columns are lazy views rather than full copies. For an unchanged
single-layer table whose rows remain in raster storage order, the reverse conversion
can also reuse the value column:

```julia
roundtrip = Raster(df, dims(raster); name=:value, crs=GeoInterface.crs(df))
```

The dimensions are required because geometries alone do not preserve all raster
information, such as lookup order or sampling locus.
After filtering or reordering rows, reconstruct a grid explicitly instead of using
this reshape-based fast path.

## Read and inspect
Read a vector file into a DataFrame by providing a filename or url:

```@example julia
df = GeoDataFrames.read("https://github.com/yeesian/ArchGDALDatasets/raw/refs/heads/master/ospy/data1/sites.shp")
(rows=nrow(df), geometrycolumns=GeoInterface.geometrycolumns(df), crs=GeoInterface.crs(df))
```

## Basic operation with lines and polygons
Geometry operations apply to GeoInterface geometries in your table.

```@example julia
using NaturalEarth
using GeoDataFrames: setcrs!

countries = select(
    DataFrame(naturalearth("admin_0_countries", 50)),
    :NAME,
    :geometry,
)
rivers = select(
    DataFrame(naturalearth("rivers_lake_centerlines", 50)),
    :name_en,
    :geometry,
)

candidate_countries = subset(
    countries,
    :NAME => ByRow(
        name -> name in ["Austria", "Germany", "Hungary", "Poland", "Romania"],
    ),
)
danube = subset(rivers, :name_en => ByRow(isequal("Danube")))

selected = subset(
    candidate_countries,
    :geometry => ByRow(
        country -> any(
            river -> intersects(country, river),
            danube.geometry,
        ),
    ),
)
selected.NAME
```

## Plot geometries

```@example julia
using CairoMakie

fig = plot(
    candidate_countries.geometry;
    color = (:lightgray, 0.35),
    strokecolor = :gray,
    axis = (; title = "Countries intersected by the Danube"),
)
plot!(selected.geometry; color = (:tomato, 0.5), strokecolor = :tomato)
plot!(danube.geometry; color = :dodgerblue, linewidth = 3)
fig
```

## Write
Write any Tables.jl-compatible table that has geometry metadata (or pass
`geometrycolumn`/`crs` keywords when needed):

```@example julia
tmp = mktempdir()
path = joinpath(tmp, "zones.gpkg")
GeoDataFrames.write(path, candidate_countries)
isfile(path)
```

For layers, advanced ArchGDAL options, native-driver behavior, metadata
management, reprojection, spatial joins, and performance trade-offs, use the
[how-to guides](../how-to/read-write-data.md) and [reference](../reference/io.md).
