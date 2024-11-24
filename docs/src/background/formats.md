# File formats
We currently support the following file formats directly based on the file extension:


| Extension | Driver    |
|-----------|----------------|
| .shp | ESRI Shapefile |
| .gpkg | GPKG          |
| .geojson | GeoJSON |
| .vrt | VRT |
| .sqlite | SQLite |
| .csv | CSV |
| .fgb | FlatGeobuf |
| .pq | Parquet |
| .arrow | Arrow |
| .gml | GML |
| .nc | netCDF |


If you get an error like so:
```julia
GeoDataFrames.write("test.foo", df)
ERROR: ArgumentError: There are no GDAL drivers for the .foo extension
```

You can specifiy the driver using a keyword as follows:
```julia
GeoDataFrames.write("test.foo", df; driver="GeoJSON")
```

The complete list of driver codes are listed in the [GDAL documentation](https://gdal.org/drivers/vector/index.html).

