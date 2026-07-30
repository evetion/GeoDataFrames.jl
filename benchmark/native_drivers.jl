using BenchmarkTools
import CSV
import FlatGeobuf
import GeoArrow
import GeoDataFrames as GDF
import GeoInterface as GI
import GeoJSON
import GeoParquet
import Shapefile
const DATA_DIR = joinpath(@__DIR__, "..", "test", "data")

const read_benchmarks = [
    ("CSV", GDF.CSVDriver(), "test_wkt.csv"),
    ("GeoJSON", GDF.GeoJSONDriver(), "test_points.geojson"),
    ("Shapefile", GDF.ShapefileDriver(), "test_points.shp"),
    ("FlatGeobuf", GDF.FlatGeobufDriver(), "countries.fgb"),
    ("GeoParquet", GDF.GeoParquetDriver(), "example.parquet"),
    ("GeoArrow", GDF.GeoArrowDriver(), "example-multipolygon_z.arrow"),
]

const write_benchmarks = [
    ("CSV", GDF.CSVDriver(), "csv"),
    ("GeoJSON", GDF.GeoJSONDriver(), "geojson"),
    ("Shapefile", GDF.ShapefileDriver(), "shp"),
    ("GeoParquet", GDF.GeoParquetDriver(), "parquet"),
    ("GeoArrow", GDF.GeoArrowDriver(), "arrow"),
]

function median_time(f)
    f()
    return time(median(@benchmark $f() samples = 20 seconds = 2 evals = 1))
end

function print_result(name, operation, native, gdal)
    ratio = gdal / native
    println(
        "| $name | $operation | $(round(native / 1e6; digits = 2)) | $(round(gdal / 1e6; digits = 2)) | $(round(ratio; digits = 2))x |",
    )
    ratio >= 1 / 0.9 && println("FASTER: $name $operation")
end

println("# Native driver performance")
println()
println(
    "Native driver timings use Julia $(VERSION), GeoDataFrames $(pkgversion(GDF)), and the fixtures in `test/data`. Each result is the median of warmed BenchmarkTools samples. Values compare the ArchGDAL median with the native median; values greater than `1.11x` make the native backend at least 10% faster.",
)
println()
println(
    "CSV uses `test_wkt.csv`; GeoJSON uses `test_points.geojson`; Shapefile uses `test_points.shp`; FlatGeobuf uses `countries.fgb`; GeoParquet uses `example.parquet`; and GeoArrow uses `example-multipolygon_z.arrow`. The first write measurement uses a three-point in-memory table. The later measurements use a GeoInterface wrapper around fully materialized nested coordinates, repeated 10,000 times. Each read fixture is written once with its native driver before sampling begins.",
)
println()
println("| Backend | Operation | Native median (ms) | ArchGDAL median (ms) | ArchGDAL/native |")
println("| --- | --- | ---: | ---: | ---: |")

GDF.AG.setconfigoption("OGR_ARROW_ALLOW_ALL_DIMS", "YES")
for (name, driver, filename) in read_benchmarks
    path = joinpath(DATA_DIR, filename)
    native = median_time(() -> GDF.read(driver, path))
    gdal = median_time(() -> GDF.read(GDF.ArchGDALDriver(), path))
    print_result(name, "read", native, gdal)
end

point_table = GDF.DataFrame(
    geom = GI.Point.([(1, 2), (3, 4), (5, 6)]),
    name = ["first", "second", "third"],
)
GDF.setgeometrycolumn!(point_table, :geom)

function benchmark_writes(table, operation)
    mktempdir() do dir
        for (name, driver, extension) in write_benchmarks
            native = median_time(
                () -> GDF.write(driver, tempname(dir) * ".$extension", table),
            )
            gdal = median_time(
                () -> GDF.write(
                    GDF.ArchGDALDriver(),
                    tempname(dir) * ".$extension",
                    table,
                ),
            )
            print_result(name, operation, native, gdal)
        end
    end
end

function benchmark_reads(table, csv_table, operation)
    mktempdir() do dir
        for (name, driver, extension) in write_benchmarks
            path = joinpath(dir, "polygons.$extension")
            write_table = name == "CSV" ? csv_table : table
            GDF.write(driver, path, write_table)
            native = median_time(() -> GDF.read(driver, path))
            gdal = median_time(() -> GDF.read(GDF.ArchGDALDriver(), path))
            print_result(name, operation, native, gdal)
        end
    end
end

materialize_coordinates(coords::Tuple) = map(materialize_coordinates, coords)
materialize_coordinates(coords::AbstractVector) = map(materialize_coordinates, coords)
materialize_coordinates(coord) = coord

benchmark_writes(point_table, "write")

polygon_source = GDF.read(GDF.FlatGeobufDriver(), joinpath(DATA_DIR, "countries.fgb"))
polygon_column = only(GDF.getgeometrycolumns(polygon_source))
polygon = GI.Wrappers.MultiPolygon(
    materialize_coordinates(GI.coordinates(polygon_source[1, polygon_column])),
)
large_polygon_table = GDF.DataFrame(
    geom = fill(polygon, 10_000),
    name = fill("polygon", 10_000),
)
GDF.setgeometrycolumn!(large_polygon_table, :geom)
large_polygon_csv_table = GDF.DataFrame(
    WKT = large_polygon_table.geom,
    name = large_polygon_table.name,
)
GDF.setgeometrycolumn!(large_polygon_csv_table, :WKT)

println()
println("## Write performance for 10,000 polygons")
println()
println("| Backend | Operation | Native median (ms) | ArchGDAL median (ms) | ArchGDAL/native |")
println("| --- | --- | ---: | ---: | ---: |")
benchmark_writes(large_polygon_table, "write")

println()
println("## Read performance for 10,000 polygons")
println()
println("| Backend | Operation | Native median (ms) | ArchGDAL median (ms) | ArchGDAL/native |")
println("| --- | --- | ---: | ---: | ---: |")
benchmark_reads(large_polygon_table, large_polygon_csv_table, "read")
