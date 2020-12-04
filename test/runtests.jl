using GeoDataFrames; const GDF = GeoDataFrames
using Test
using DataFrames
using ArchGDAL; const AG = ArchGDAL

@testset "GeoDataFrames.jl" begin
    # Read large file
    fn = "/Users/evetion/Downloads/ne_10m_coastline/ne_10m_coastline.shp"
    t = GDF.read(fn)

    # Save table with a few random points
    Lon = -44 .+ rand(5); Lat = -23 .+ rand(5)
    table = DataFrame(geom=AG.createpoint.(zip(Lon, Lat)), name="test")
    GDF.write("test_points.shp", table, "test_points")
    GDF.write("test_points.gpkg", table, "test_points")
    GDF.write("test_points.geojson", table, "test_points")


    # Save table from reading
    GDF.write("test_read.shp", t, "test_coastline", Symbol(""))
    GDF.write("test_read.gpkg", t, "test_coastline", Symbol(""))
    GDF.write("test_read.geojson", t, "test_coastline", Symbol(""))

    table.geom = buffer(table.geom, 10)
    GDF.write("test_polygons.shp", table)
    GDF.write("test_polygons.gpkg", table)
    GDF.write("test_polygons.geojson", table)

end
