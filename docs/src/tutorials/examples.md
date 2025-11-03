# Examples

## Reading a CSV
Some data is distributed as CSV files with WKT geometries in a custom column such as `wkt`. Something like
```csv
wkt,name
"POINT (30 10)","point1"
```
You can read such files as follows:

```julia
using GeoDataFrames
# Tell GDAL where to find the geometry column and not to keep it as a regular column (otherwise DataFrames will fail to parse it)
df =
GeoDataFrames.read("test.csv", options=["GEOM_POSSIBLE_NAMES=wkt", "KEEP_GEOM_COLUMNS=NO"])
```

The same can be achieved natively using the CSV.jl package. We need to wrap the WKT geometries using GeoFormatTypes.jl, 
so WellKnownGeometry can parse them automatically when needed later on.

```julia
using CSV
using WellKnownGeometry  # to parse GeoFormatTypes WKT geometries later on
using GeoFormatTypes

df = CSV.read("test.csv", DataFrame)
df.wkt =
    GeoFormatTypes.WellKnownText.((GeoFormatTypes.Geom(),), df.wkt)
GeoDataFrames.setgeometrycolumn!(df, :wkt)
```

Note that in both cases, we don't know the CRS, so it will be `nothing` by default.
You can set it using [`setcrs!`](@ref) if you know it, but ideally we use better spatial file formats (such as Geopackage) that store the CRS natively.
