abstract type AbstractDriver end

struct GeoJSONDriver <: AbstractDriver end
struct ShapefileDriver <: AbstractDriver end
struct GeoParquetDriver <: AbstractDriver end
struct FlatGeobufDriver <: AbstractDriver end
struct ArchGDALDriver <: AbstractDriver end
struct GeoArrowDriver <: AbstractDriver end

function driver(ext::AbstractString)
    if ext in (".json", ".geojson")
        return GeoJSONDriver()
    elseif ext == ".shp"
        return ShapefileDriver()
    elseif ext in (".parquet", ".pq")
        return GeoParquetDriver()
    elseif ext == (".arrow", ".feather")
        return GeoArrowDriver()
    elseif ext == ".fgb"
        return FlatGeobufDriver()
    else
        return ArchGDALDriver()
    end
end

package(::GeoJSONDriver) = :GeoJSON
package(::ShapefileDriver) = :Shapefile
package(::GeoParquetDriver) = :GeoParquet
package(::FlatGeobufDriver) = :FlatGeobuf
package(::ArchGDALDriver) = :ArchGDAL
package(::GeoArrowDriver) = :GeoArrow

uuid(::GeoJSONDriver) = "61d90e0f-e114-555e-ac52-39dfb47a3ef9"
uuid(::ShapefileDriver) = "8e980c4a-a4fe-5da2-b3a7-4b4b0353a2f4"
uuid(::GeoParquetDriver) = "e99870d8-ce00-4fdd-aeee-e09192881159"
uuid(::FlatGeobufDriver) = "d985ece1-97de-4d33-914c-38fb84042e15"
uuid(::ArchGDALDriver) = "c9ce4bd3-c3d5-55b8-8973-c0e20141b8c3"
uuid(::GeoArrowDriver) = "5bc3a8d9-1bfb-4624-ba94-a391279174d6"
