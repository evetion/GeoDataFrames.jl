# Native driver performance

Native driver timings use Julia 1.12.6, GeoDataFrames 0.4.3, and the fixtures
in `test/data`. Each result is the median of 20 warmed BenchmarkTools samples.
Values compare the ArchGDAL median with the native median; values greater than
`1.11x` make the native backend at least 10% faster.

CSV uses `test_wkt.csv`; GeoJSON uses `test_points.geojson`; Shapefile uses
`test_points.shp`; FlatGeobuf uses `countries.fgb`; GeoParquet uses
`example.parquet`; and GeoArrow uses `example-multipolygon_z.arrow`. Write
measurements first use the same three-point in-memory table for every backend.

| Backend | Operation | Native median (ms) | ArchGDAL median (ms) | ArchGDAL/native |
| --- | --- | ---: | ---: | ---: |
| CSV | read | 0.19 | 0.53 | 2.85x |
| GeoJSON | read | 0.26 | 0.54 | 2.09x |
| Shapefile | read | 0.67 | 1.18 | 1.75x |
| FlatGeobuf | read | 11.60 | 1.00 | 0.09x |
| GeoParquet | read | 0.73 | 12.07 | 16.55x |
| GeoArrow | read | 0.44 | 0.54 | 1.21x |
| CSV | write | 0.10 | 0.20 | 2.00x |
| GeoJSON | write | 0.11 | 0.21 | 2.02x |
| Shapefile | write | 0.42 | 0.48 | 1.14x |
| GeoParquet | write | 0.14 | 0.50 | 3.49x |
| GeoArrow | write | 0.29 | 0.30 | 1.03x |

## Write performance for 10,000 polygons

This workload repeats a `GeoInterface.Wrappers.MultiPolygon` 10,000 times. The
polygon is backed by fully materialized nested coordinate vectors, avoiding
backend-specific geometry representations. It measures serialization and output
costs at a more representative scale.

| Backend | Operation | Native median (ms) | ArchGDAL median (ms) | ArchGDAL/native |
| --- | --- | ---: | ---: | ---: |
| CSV | write | 783.88 | 1078.82 | 1.38x |
| GeoJSON | write | 882.10 | 10837.51 | 12.29x |
| Shapefile | write | 768.96 | 1888.29 | 2.46x |
| GeoParquet | write | 337.04 | 1187.14 | 3.52x |
| GeoArrow | write | 1001.60 | 1238.35 | 1.24x |

## Read performance for 10,000 polygons

Each format is written once from the same native GeoInterface wrapper, then
read repeatedly from that unchanged file. The write step is outside the timed
region. CSV uses a `WKT` geometry column so its native reader parses the
geometries.

| Backend | Operation | Native median (ms) | ArchGDAL median (ms) | ArchGDAL/native |
| --- | --- | ---: | ---: | ---: |
| CSV | read | 143.94 | 2432.79 | 16.90x |
| GeoJSON | read | 384.71 | 2971.83 | 7.72x |
| Shapefile | read | 40.59 | 130.61 | 3.22x |
| GeoParquet | read | 26.11 | 98.00 | 3.75x |
| GeoArrow | read | 0.76 | 95.06 | 125.63x |
