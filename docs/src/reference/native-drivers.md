# Native drivers

Load the listed package to activate its native extension. Without that import,
automatic selection falls back to `ArchGDALDriver()`.

| GeoDataFrames driver type | Package to load | Recognized extensions | Native read | Native write | Reference |
| --- | --- | --- | --- | --- | --- |
| `CSVDriver` | `CSV` | `.csv` | yes | yes | [CSV](drivers/csv.md) |
| `FlatGeobufDriver` | `FlatGeobuf` | `.fgb` | yes | falls back | [FlatGeobuf](drivers/flatgeobuf.md) |
| `GeoArrowDriver` | `GeoArrow` | `.arrow`, `.feather` | yes | yes | [GeoArrow](drivers/geoarrow.md) |
| `GeoJSONDriver` | `GeoJSON` | `.json`, `.geojson` | yes | yes | [GeoJSON](drivers/geojson.md) |
| `GeoParquetDriver` | `GeoParquet` | `.parquet`, `.pq` | yes | yes | [GeoParquet](drivers/geoparquet.md) |
| `ShapefileDriver` | `Shapefile` | `.shp` | yes | yes | [Shapefile](drivers/shapefile.md) |

Native-driver keywords are delegated to the owning package. They can differ
from each other and from [ArchGDAL](archgdal.md) keywords.
