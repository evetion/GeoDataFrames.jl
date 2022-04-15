using DataFrames
using Dates
using Pkg.PlatformEngines
using Test
import ArchGDAL as AG
import GeoDataFrames as GDF
import GeoFormatTypes as GFT

# Use ArchGDAL datasets to test with
const testdatadir = joinpath(@__DIR__, "data")
isdir(testdatadir) || mkdir(testdatadir)
REPO_URL = "https://github.com/yeesian/ArchGDALDatasets/blob/master/"

remotefiles = [
    ("ospy/data1/sites.dbf", "7df95edea06c46418287ae3430887f44f9116b29715783f7d1a11b2b931d6e7d"),
    ("ospy/data1/sites.prj", "81fb1a246728609a446b25b0df9ede41c3e7b6a133ce78f10edbd2647fc38ce1"),
    ("ospy/data1/sites.sbn", "198d9d695f3e7a0a0ac0ebfd6afbe044b78db3e685fffd241a32396e8b341ed3"),
    ("ospy/data1/sites.sbx", "49bbe1942b899d52cf1d1b01ea10bd481ec40bdc4c94ff866aece5e81f2261f6"),
    ("ospy/data1/sites.shp", "69af5a6184053f0b71f266dc54c944f1ec02013fb66dbb33412d8b1976d5ea2b"),
    ("ospy/data1/sites.shx", "1f3da459ccb151958743171e41e6a01810b2a007305d55666e01d680da7bbf08"),
]
@info "Downloading test files..."
for (f, sha) in remotefiles
    localfn = joinpath(testdatadir, basename(f))
    url = REPO_URL * f * "?raw=true"
    PlatformEngines.download_verify(url, sha, localfn; force=true)
end


@testset "GeoDataFrames.jl" begin
    fn = joinpath(testdatadir, "sites.shp")
    coords = zip(rand(10), rand(10))

    @testset "Read shapefile" begin
        t = GDF.read(fn)
        @test nrow(t) == 42
        @test "ID" in names(t)
    end

    @testset "Read shapefile with layer id" begin
        t = GDF.read(fn, 0)
        @test nrow(t) == 42
        @test "ID" in names(t)
    end

    @testset "Read shapefile with layer name" begin
        t = GDF.read(fn, "sites")
        @test nrow(t) == 42
        @test "ID" in names(t)
    end

    @testset "Read shapefile with non-existing layer name" begin
        @test_throws ArgumentError GDF.read(fn, "foo")
    end

    @testset "Read shapefile with NULLs" begin
        fnn = joinpath(testdatadir, "null.gpkg")
        t = GDF.read(fnn)
        @test nrow(t) == 2
        @test "name" in names(t)
        @test t.name[1] == "test"
        @test ismissing(t.name[2])
    end

    @testset "Read self written file" begin
        # Save table with a few random points
        table = DataFrame(geom=AG.createpoint.(coords), name="test")
        GDF.write("test_points.shp", table)
        GDF.write("test_points.gpkg", table, layer_name="test_points")
        GDF.write("test_points.geojson", table, layer_name="test_points")

        ntable = GDF.read("test_points.shp")
        @test nrow(ntable) == 10
        ntable = GDF.read("test_points.gpkg")
        @test nrow(ntable) == 10
        ntable = GDF.read("test_points.geojson")
        @test nrow(ntable) == 10
    end

    @testset "Write shapefile" begin

        t = GDF.read(fn)

        # Save table from reading
        GDF.write("test_read.shp", t, layer_name="test_coastline")
        GDF.write("test_read.gpkg", t, layer_name="test_coastline")
        GDF.write("test_read.geojson", t, layer_name="test_coastline")

    end

    @testset "Write shapefile with non-GDAL types" begin
        coords = collect(zip(rand(Float32, 2), rand(Float32, 2)))
        t = DataFrame(
            geom=AG.createpoint.(coords),
            name=["test", "test2"],
            flag=UInt8[typemin(UInt8), typemax(UInt8)],
            ex1=Int16[typemin(Int8), typemax(Int8)],
            ex2=Int32[typemin(UInt16), typemax(UInt16)],
            ex3=Int64[typemin(UInt32), typemax(UInt32)],
            check=[false, true],
            z=Float32[Float32(8), Float32(-1)],
            y=Float16[Float16(8), Float16(-1)],
            odd=[1, missing],
            date=[DateTime("2022-03-31T15:38:41"), DateTime("2022-03-31T15:38:41")]
        )
        GDF.write("test_exotic.shp", t)
        GDF.write("test_exotic.gpkg", t)
        GDF.write("test_exotic.geojson", t)
        tt = GDF.read("test_exotic.gpkg")
        @test AG.getx.(tt.geom, 0) == AG.getx.(t.geom, 0)
        @test tt.flag == t.flag
        @test tt.ex1 == t.ex1
        @test tt.ex2 == t.ex2
        @test tt.ex3 == t.ex3
        @test tt.check == t.check
        @test tt.z == t.z
        @test tt.y == t.y
        @test ismissing.(tt.odd) == ismissing.(t.odd)
        @test tt.date == t.date
    end

    @testset "Read shapefile with non-GDAL types" begin
        GDF.read("test_exotic.shp")
        GDF.read("test_exotic.gpkg")
        GDF.read("test_exotic.geojson")
    end

    @testset "Spatial operations" begin
        table = DataFrame(geom=AG.createpoint.(coords), name="test")

        # Buffer to also write polygons
        table.geom = AG.buffer(table.geom, 10)
        GDF.write("test_polygons.shp", table)
        GDF.write("test_polygons.gpkg", table)
        GDF.write("test_polygons.geojson", table)
    end

    @testset "Reproject" begin
        table = DataFrame(geom=AG.createpoint.([[0, 0, 0]]), name="test")
        AG.reproject(table.geom, GFT.EPSG(4326), GFT.EPSG(28992))
        @test GDF.AG.getpoint(table.geom[1], 0)[1] ≈ -587791.596556932
        GDF.write("test_reprojection.gpkg", table, crs=GFT.EPSG(28992))
    end
end
