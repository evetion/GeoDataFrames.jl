```@meta
CurrentModule = GeoDataFrames
```

# Usage
One uses normal `DataFrame`s and with a Vector of GeoInterface.jl compatible geometries as a column.

```julia
using GeoDataFrames

points = GeoInterface.Point.(rand(10), rand(10))  # point geometry
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

## Reading
Reading into a DataFrame is done by the [`read`](@ref) function. It simply takes a filename.
```julia
df = GeoDataFrames.read("test_points.shp")
10×2 DataFrame
 Row │ geometr                name
     │ IGeometr…           String
─────┼────────────────────────────
   1 │ Geometry: wkbPoint  test
   2 │ Geometry: wkbPoint  test
   3 │ Geometry: wkbPoint  test
   4 │ Geometry: wkbPoint  test
   5 │ Geometry: wkbPoint  test
   6 │ Geometry: wkbPoint  test
   7 │ Geometry: wkbPoint  test
   8 │ Geometry: wkbPoint  test
   9 │ Geometry: wkbPoint  test
  10 │ Geometry: wkbPoint  test
```

### Using ArchGDAL
When using the default ArchGDAL driver, you can also specify the layer index or layer name in opening, useful if there are multiple layers:
```julia
GeoDataFrames.read("test_points.shp"; layer=0)
GeoDataFrames.read("test_points.shp"; layer="test_points")
```

Any keywords arguments are passed on to the underlying (possibly native) driver. For reading with ArchGDAL, that corresponds to the [`read`](https://yeesian.com/ArchGDAL.jl/dev/reference/#ArchGDAL.read-Tuple%7BAbstractString%7D) function:
```julia
GeoDataFrames.read("test.csv", options=["GEOM_POSSIBLE_NAMES=point,linestring", "KEEP_GEOM_COLUMNS=NO"])
```

### Native Extensions

> [!WARNING]
> As soon as you import a native driver extension package, it will override the default ArchGDAL driver for reading/writing files of the corresponding format. You can get the old behaviour back by explicitly using the `ArchGDALDriver` when reading/writing files like so: `read(GeoDataFrames.ArchGDALDriver(), fn; kwargs)`. 



## Writing
Writing a DataFrame is done by the [`write`](@ref) function. It simply takes a filename, and a DataFrame with a geometry column.

```julia
points = GeoInterface.Point.(rand(10), rand(10))
df = DataFrame(geometry=points, name="test");
setcrs!(df, EPSG(4326))  # optional: set coordinate reference system
GeoDataFrames.write("test_points.gpkg", df)
```

Note that any Tables.jl compatible table with GeoInterface.jl compatible geometries can be written by GeoDataFrames.
If you have geometry column(s) named other than `geometry`, you can pass so at `write`, setting it with `setgeometrycolumn` if the table supports metadata, or by defining `GeoInterface.geometrycolumns` on your table. Multiple geometry columns, when enabled by the driver, can be provided in this way.
```julia
table = DataFrame(geom=GeoInterface.Point.(rand(10), rand(10)), name="test")
GeoDataFrames.setgeometrycolumn!(table, :geom)  # set geometry column
GeoDataFrames.write("custom.gpkg", table)
# OR
table = [(; geom=GeoInterface.Point(1.0, 2.0), name="test")]  # Also a valid table, but no metadata
GeoDataFrames.write("custom.gpkg", table; geometrycolumn=:geom)
```

In the same way, if your geometry doesn't contain a CRS, and the table supports metadata, you can set the CRS using `setcrs!`, or by defining `GeoInterface.crs` on your table. Otherwise, you can pass the `crs` keyword at `write`. Define the coordinate reference system with [GeoFormatTypes.jl](https://juliageo.org/GeoFormatTypes.jl/stable/):
```julia
table = DataFrame(geometry=GeoInterface.Point.(rand(10), rand(10)), name="test")
GeoDataFrames.setcrs!(table, EPSG(4326))  # set coordinate reference system
GeoDataFrames.write("with_crs.gpkg", table)
# OR
table = [(; geometry=GeoInterface.Point(1.0, 2.0), name="test")]  # Also a valid table, but no metadata
GeoDataFrames.write("with_crs.gpkg", table; crs=EPSG(4326))
```

### Using ArchGDAL (default)
When using the default ArchGDAL driver, you can also set options such as the layer_name.
```julia
GeoDataFrames.write("test_points.shp", df; layer_name="data", crs=EPSG(4326))
```

You can update existing geopackage files by adding new layers. Set the `update=true` option and provide a unique `layer_name`:
```julia
GeoDataFrames.write("test.gpkg", df; layer_name="foo", update=true)
```

To overwrite an existing layer, either use a new layer name or pass `"OVERWRITE"=>"YES"` in the options:
```julia
GeoDataFrames.write("test.gpkg", df; layer_name="existing_layer", update=true, options=Dict("OVERWRITE"=>"YES"))
```

The most common file extensions are recognized, but you can override this or write uncommon files by setting the driver option. See [here](https://gdal.org/drivers/vector/index.html) for a list of (short) driver names.
```julia
GeoDataFrames.write("test_points.fgb", df; driver="FlatGeobuf", options=Dict("SPATIAL_INDEX"=>"YES"))
```

The following file extensions are automatically recognized in the ArchGDAL driver:
```julia
    ".shp" => "ESRI Shapefile",
    ".gpkg" => "GPKG",
    ".geojson" => "GeoJSON",
    ".vrt" => "VRT",
    ".sqlite" => "SQLite",
    ".csv" => "CSV",
    ".fgb" => "FlatGeobuf",
    ".pq" => "Parquet",
    ".arrow" => "Arrow",
    ".gml" => "GML",
    ".nc" => "netCDF",
```


### Using Extensions

> [!WARNING]
> As soon as you import a native driver extension package, it will override the default ArchGDAL driver for reading/writing files of the corresponding format. You can get the old behaviour back by explicitly using the `ArchGDALDriver` when reading/writing files like so: `write(GeoDataFrames.ArchGDALDriver(), fn, table; kwargs)`. 
