import GeoDataFrames as GDF
using DataFrames
using Dates
using Pkg.PlatformEngines
using Test
import ArchGDAL as AG
import GeoFormatTypes as GFT
import GeoInterface as GI
import DataAPI
import LibGEOS
import GeometryOps as GO

# Use ArchGDAL datasets to test with
const testdatadir = joinpath(@__DIR__, "data")
isdir(testdatadir) || mkdir(testdatadir)
REPO_URL = "https://github.com/yeesian/ArchGDALDatasets/blob/master/"

remotefiles = [
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/sites.dbf",
        "7df95edea06c46418287ae3430887f44f9116b29715783f7d1a11b2b931d6e7d",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/sites.prj",
        "81fb1a246728609a446b25b0df9ede41c3e7b6a133ce78f10edbd2647fc38ce1",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/sites.sbn",
        "198d9d695f3e7a0a0ac0ebfd6afbe044b78db3e685fffd241a32396e8b341ed3",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/sites.sbx",
        "49bbe1942b899d52cf1d1b01ea10bd481ec40bdc4c94ff866aece5e81f2261f6",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/sites.shp",
        "69af5a6184053f0b71f266dc54c944f1ec02013fb66dbb33412d8b1976d5ea2b",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/sites.shx",
        "1f3da459ccb151958743171e41e6a01810b2a007305d55666e01d680da7bbf08",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/example.parquet",
        "3dc1a3df76290cc62aa6d7aa6aa00d0988b3157ee77a042167b3f8302d05aa6c",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/example-multipolygon_z.arrow",
        "0cd4d7c5611581a5ae30fbbacc6f733a7da2ae78ac02ef8cffeb1e2d4f39b91c",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/nz-buildings-outlines.parquet",
        "b64389237b9879c275aec4e47f0e6be8fdd5d64437a05aef10839f574efc5dbc",
    ),
    (
        "https://github.com/evetion/GeoDataFrames.jl/releases/download/v0.1.0/countries.fgb",
        "d8dc3baf855320d10c6a662bf1171273849dd8a0935066b5b7b8dd83b3484cb3",
    ),
]
for (url, sha) in remotefiles
    localfn = joinpath(testdatadir, basename(replace(url, "?raw=true" => "")))
    PlatformEngines.download_verify(url, sha, localfn; force = true, quiet_download = false)
end

unknown_crs = GFT.WellKnownText(
    GFT.CRS(),
    "GEOGCS[\"Undefined geographic SRS\",DATUM[\"unknown\",SPHEROID[\"unknown\",6378137,298.257223563]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST]]",
)

@testset "GeoDataFrames.jl" begin
    fn = joinpath(testdatadir, "sites.shp")
    coords = zip(rand(10), rand(10))
    coords3 = zip(rand(10), rand(10), rand(10))

    @testset "Read shapefile" begin
        t = GDF.read(fn)
        @test nrow(t) == 42
        @test "ID" in names(t)
    end

    @testset "Read non-existent shapefile" begin
        fne = "/bla.shp"
        @test_throws ErrorException("File not found.") GDF.read(fne)
    end

    @testset "Read shapefile with layer id" begin
        t = GDF.read(fn, 0)
        @test nrow(t) == 42
        @test "ID" in names(t)
    end

    @testset "Drivers" begin
        t = GDF.read(fn, 0)
        GDF.write(joinpath(testdatadir, "test.csv"), t)
        GDF.write(joinpath(testdatadir, "test.arrow"), t)
        GDF.write(joinpath(testdatadir, "test.pdf"), t)
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
        table = DataFrame(; geometry = AG.createpoint.(coords), name = "test")
        GDF.write(joinpath(testdatadir, "test_points.shp"), table)
        GDF.write(
            joinpath(testdatadir, "test_points.gpkg"),
            table;
            layer_name = "test_points",
        )
        GDF.write(
            joinpath(testdatadir, "test_points.geojson"),
            table;
            layer_name = "test_points",
        )

        ntable = GDF.read(joinpath(testdatadir, "test_points.shp"))
        @test nrow(ntable) == 10
        ntable = GDF.read(joinpath(testdatadir, "test_points.gpkg"))
        @test nrow(ntable) == 10
        ntable = GDF.read(joinpath(testdatadir, "test_points.geojson"))
        @test nrow(ntable) == 10

        tablez = DataFrame(; geometry = AG.createpoint.(coords3), name = "test")
        GDF.write(
            joinpath(testdatadir, "test_pointsz.gpkg"),
            tablez;
            layer_name = "test_points",
        )
        ntable = GDF.read(joinpath(testdatadir, "test_pointsz.gpkg"))
        @test GI.ncoord(ntable.geometry[1]) == 3
    end

    @testset "Write shapefile" begin
        t = GDF.read(fn)

        # Save table from reading
        GDF.write(joinpath(testdatadir, "test_read.shp"), t; layer_name = "test_coastline")
        GDF.write(joinpath(testdatadir, "test_read.gpkg"), t; layer_name = "test_coastline")
        GDF.write(
            joinpath(testdatadir, "test_read.geojson"),
            t;
            layer_name = "test_coastline",
        )
    end

    @testset "Write shapefile with non-GDAL types" begin
        coords = collect(zip(rand(Float32, 2), rand(Float32, 2)))
        t = DataFrame(;
            geometry = AG.createpoint.(coords),
            name = ["test", "test2"],
            flag = UInt8[typemin(UInt8), typemax(UInt8)],
            ex1 = Int16[typemin(Int8), typemax(Int8)],
            ex2 = Int32[typemin(UInt16), typemax(UInt16)],
            ex3 = Int64[typemin(UInt32), typemax(UInt32)],
            check = [false, true],
            z = Float32[Float32(8), Float32(-1)],
            y = Float16[Float16(8), Float16(-1)],
            odd = [1, missing],
            date = [DateTime("2022-03-31T15:38:41"), DateTime("2022-03-31T15:38:41")],
        )
        GDF.write(joinpath(testdatadir, "test_exotic.shp"), t)
        GDF.write(joinpath(testdatadir, "test_exotic.gpkg"), t)
        GDF.write(joinpath(testdatadir, "test_exotic.geojson"), t)
        tt = GDF.read(joinpath(testdatadir, "test_exotic.gpkg"))
        @test AG.getx.(tt.geometry, 0) == AG.getx.(t.geometry, 0)
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
        GDF.read(joinpath(testdatadir, "test_exotic.shp"))
        GDF.read(joinpath(testdatadir, "test_exotic.gpkg"))
        GDF.read(joinpath(testdatadir, "test_exotic.geojson"))
    end

    @testset "Spatial operations" begin
        table = DataFrame(;
            geometry = GDF.GeometryVector(AG.createpoint.(coords)),
            name = "test",
        )

        # Buffer to also write polygons
        table.geometry = GO.buffer(table.geometry, 10)
        GDF.write(joinpath(testdatadir, "test_polygons.shp"), table)
        GDF.write(joinpath(testdatadir, "test_polygons.gpkg"), table)
        GDF.write(joinpath(testdatadir, "test_polygons.geojson"), table)
    end

    @testset "Reproject" begin
        table = DataFrame(; geometry = AG.createpoint.([[52, 4, 0]]), name = "test")
        geoms = GDF._reproject(
            AG.clone.(table.geometry),
            GFT.EPSG(4326),
            GFT.EPSG(28992);
            always_xy = false,
        )
        ntable = GDF.reproject(table, GFT.EPSG(4326), GFT.EPSG(28992); always_xy = false)
        @test GDF.GI.getcoord(table.geometry[1], 1) == 52
        @test GDF.GI.getcoord(geoms[1], 1) ≈ 59742.01980968987
        @test GDF.GI.getcoord(ntable.geometry[1], 1) ≈ 59742.01980968987

        table = DataFrame(; geometry = AG.createpoint.([[4, 52, 0]]), name = "test")
        ntable = GDF.reproject(table, GFT.EPSG(4326), GFT.EPSG(28992); always_xy = true)
        @test GDF.GI.getcoord(table.geometry[1], 1) == 4
        @test GDF.GI.getcoord(ntable.geometry[1], 1) ≈ 59742.01980968987
        GDF.write(
            joinpath(testdatadir, "test_reprojection.gpkg"),
            table;
            crs = GFT.EPSG(28992),
        )
    end

    @testset "Kwargs" begin
        table = DataFrame(; foo = AG.createpoint.([[0, 0, 0]]), name = "test")
        GDF.write(joinpath(testdatadir, "test_options1.gpkg"), table; geometrycolumn = :foo)
        GDF.write(
            joinpath(testdatadir, "test_options2.gpkg"),
            table;
            geom_columns = (:foo,),
        )

        table = DataFrame(;
            foo = AG.createpoint.([[0, 0, 0]]),
            bar = AG.createpoint.([[0, 0, 0]]),
            name = "test",
        )
        @test_throws Exception GDF.write(
            joinpath(testdatadir, "test_options3.gpkg"),
            table;
            geometrycolumn = :foo,
        )  # wrong argument
        @test_throws AG.GDAL.GDALError GDF.write(
            joinpath(testdatadir, "test_options3.gpkg"),
            table;
            geom_columns = (:foo, :bar),
        )  # two geometry columns

        table = DataFrame(; foo = AG.createpoint.([[0, 0, 0]]), name = "test")
        GDF.write(
            joinpath(testdatadir, "test_options4.gpkg"),
            table;
            options = Dict(
                "GEOMETRY_NAME" => "bar",
                "DESCRIPTION" => "Written by GeoDataFrames.jl",
            ),
            geometrycolumn = :foo,
        )
    end

    @testset "GeoInterface" begin
        tfn = joinpath(testdatadir, "test_geointerface.gpkg")
        table = [(; foo = AG.createpoint(1.0, 2.0), name = "test")]
        @test_throws Exception GDF.write(tfn, table)
        GI.isfeaturecollection(::Vector{<:NamedTuple}) = true
        GI.geomtrait(::Vector{<:NamedTuple}) = GI.FeatureCollectionTrait()  # TODO Make issue GeoInterface.jl
        GI.crs(::GI.FeatureCollectionTrait, ::Vector{<:NamedTuple}) = nothing
        GI.isfeaturecollection(::Vector{<:NamedTuple}) = true
        GI.geometrycolumns(::Vector{<:NamedTuple}) = (:foo,)
        @test isfile(GDF.write(tfn, table))
    end

    @testset "Metadata" begin
        tfn = joinpath(testdatadir, "test_meta.gpkg")
        table = DataFrame(; bar = AG.createpoint(1.0, 2.0), name = "test")
        @test_throws Exception GDF.write(tfn, table)
        meta = Dict{String, Any}("crs" => nothing, "geometrycolumns" => (:bar,))
        for pair in meta
            metadata!(table, pair.first, pair.second; style = :default)
        end
        @test isfile(GDF.write(tfn, table))
        t = GDF.read(tfn)
        meta = DataAPI.metadata(t)
        # @test meta["crs"] == meta["GEOINTERFACE:crs"] == unknown_crs  # GDAL will always return a CRS
        @test meta["GEOINTERFACE:geometrycolumns"] == meta["geometrycolumns"] == (:bar,)
        @test isempty(setdiff(keys(meta), metadatakeys(t)))
    end

    @testset "Read geodatabase (folder)" begin
        table = DataFrame(; geom = AG.createpoint(1.0, 2.0), name = "test")
        gdbdir = joinpath(testdatadir, "test_options.gdb")
        isdir(gdbdir) && rm(gdbdir; recursive = true)
        GDF.write(gdbdir, table; driver = "OpenFileGDB", geometrycolumn = :geom)
        @test isdir(gdbdir)
        table = GDF.read(gdbdir)
        @test nrow(table) == 1
    end

    @testset "Non-spatial columns #77" begin
        df = DataFrame(; geometry = vec(reinterpret(Tuple{Float64, Float64}, rand(2, 100))))
        df.area_km2 = [rand(10) for i in 1:100]
        GDF.write("test.gpkg", df)
    end

    @testset "Non existing Windows path #78" begin
        wfn = "C:\\non_existing_folder\\non_existing_file.shp"
        @test_throws ErrorException("Unable to open $wfn.") GDF.read(wfn)
    end

    @testset "Shapefile" begin
        using Shapefile
        fn = joinpath(testdatadir, "sites.shp")
        df = GDF.read(fn)
        df2 = GDF.read(GDF.ArchGDALDriver(), fn)
        @test names(df) == names(df2)
        @test nrow(df) == nrow(df2)
        @test GI.trait(df.geometry[1]) == GI.trait(df2.geometry[1])
        @test GI.coordinates(df.geometry[1]) == GI.coordinates(df2.geometry[1])

        ntable = GDF.reproject(df, GFT.EPSG(4326); always_xy = false)
        @test GDF.GI.x(ntable.geometry[1]) ≈ 41.927107

        @test !isnothing(GI.crs(df))

        GDF.write("test_native.shp", df; force = true)
        GDF.write(GDF.ArchGDALDriver(), "test.shp", df; force = true)
    end
    @testset "GeoJSON" begin
        using GeoJSON
        fn = joinpath(testdatadir, "test_polygons.geojson")
        df = GDF.read(fn)
        df2 = GDF.read(GDF.ArchGDALDriver(), fn)
        @test names(df) == names(df2)
        @test nrow(df) == nrow(df2)
        @test GI.trait(df.geometry[1]) == GI.trait(df2.geometry[1])
        @test all(
            isapprox.(
                collect.(GI.coordinates(df.geometry[1])[1]),
                GI.coordinates(df2.geometry[1])[1],
            ),
        )

        @test !isnothing(GI.crs(df))

        GDF.write("test_native.geojson", df)
        GDF.write(GDF.ArchGDALDriver(), "test.geojson", df)
    end
    @testset "FlatGeobuf" begin
        using FlatGeobuf
        fn = joinpath(testdatadir, "countries.fgb")
        df = GDF.read(fn)
        df2 = GDF.read(GDF.ArchGDALDriver(), fn)
        @test sort(names(df)) == sort(names(df2))
        @test nrow(df) == nrow(df2)
        @test GI.trait(df.geometry[1]) == GI.trait(df2.geometry[1])
        for i in eachindex(df.geometry)
            GI.coordinates(df.geometry[i]) == GI.coordinates(df2.geometry[i])
        end

        @test !isnothing(GI.crs(df))

        # GDF.write("test_native.fgb", df)  # Can't convert FlatGeobuf to ArchGDAL
        GDF.write("test_native.fgb", df2)
        GDF.write(GDF.ArchGDALDriver(), "test.fgb", df2)
    end
    @testset "GeoParquet" begin
        Sys.iswindows() && return  # Skip on Windows. See GDAL.jl#146
        using GeoParquet
        fn = joinpath(testdatadir, "example.parquet")
        df = GDF.read(fn)
        df2 = GDF.read(GDF.ArchGDALDriver(), fn)
        @test sort(names(df)) == sort(names(df2))
        @test nrow(df) == nrow(df2)
        @test GI.trait(df.geometry[1]) == GI.trait(df2.geometry[1])
        @test GI.coordinates(df.geometry[1]) == GI.coordinates(df2.geometry[1])

        @test !isnothing(GI.crs(df))

        GDF.write("test_native.parquet", df)
        GDF.write(GDF.ArchGDALDriver(), "test.parquet", df)
    end
    @testset "GeoArrow" begin
        using GeoArrow
        fn = joinpath(testdatadir, "example-multipolygon_z.arrow")
        df = GDF.read(fn)
        ENV["OGR_ARROW_ALLOW_ALL_DIMS"] = "YES"
        df2 = GDF.read(GDF.ArchGDALDriver(), fn)
        @test sort(names(df)) == sort(names(df2))
        @test nrow(df) == nrow(df2)
        @test GI.trait(df.geometry[1]) == GI.trait(df2.geometry[1])
        @test GI.coordinates(df.geometry[1]) == GI.coordinates(df2.geometry[1])

        # @test !isnothing(GI.crs(df))  # file has no crs
        @test "GEOINTERFACE:geometrycolumns" in keys(GDF.metadata(df))

        GDF.write("test_native.arrow", df)
        GDF.write(GDF.ArchGDALDriver(), "test.arrow", df)
    end

    @testset "Combination of drivers" begin
        drivers = [
            (GDF.ArchGDALDriver(), "test.gpkg", true, (;))
            (GDF.GeoJSONDriver(), "test.geojson", true, (;))
            (GDF.ShapefileDriver(), "test.shp", false, (; force = true))
            (GDF.FlatGeobufDriver(), "test.fgb", false, (;))  # No write support yet
            (GDF.GeoParquetDriver(), "test_native.parquet", true, (;))
        ]
        for ((driver, fn, can_write), (driver_b, fn_b, can_write_b, kwargs)) in
            Iterators.product(drivers, drivers)
            can_write_b || continue
            @debug "Testing $driver with $driver_b"
            df = GDF.read(driver, fn)
            GDF.write(driver_b, "temp" * fn_b, df; kwargs...)
        end
    end

    @testset "Writing crs of geometry" begin
        geom = GI.Wrappers.Point(0, 0; crs = GFT.EPSG(4326))
        df = DataFrame(; geometry = [geom])
        @test isnothing(GI.crs(df))
        GDF.write("test_geom_crs.gpkg", df)
        df = GDF.read("test_geom_crs.gpkg")
        @test GI.crs(df) == GFT.WellKnownText{GFT.CRS}(
            GFT.CRS(),
            "GEOGCS[\"WGS 84\",DATUM[\"WGS_1984\",SPHEROID[\"WGS 84\",6378137,298.257223563,AUTHORITY[\"EPSG\",\"7030\"]],AUTHORITY[\"EPSG\",\"6326\"]],PRIMEM[\"Greenwich\",0,AUTHORITY[\"EPSG\",\"8901\"]],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST],AUTHORITY[\"EPSG\",\"4326\"]]",
        )
    end
    @testset "Update geopackage" begin
        t = DataFrame(; geometry = AG.createpoint.(coords), name = ["test", "test2"])
        GDF.write(joinpath(testdatadir, "test_update.gpkg"), t; layer_name = "test")
        GDF.write(
            joinpath(testdatadir, "test_update.gpkg"),
            t;
            layer_name = "test2",
            update = true,
        )
        @test GDF.read(joinpath(testdatadir, "test_update.gpkg"); layer = "test") ==
              GDF.read(joinpath(testdatadir, "test_update.gpkg"); layer = "test2")
        @test_throws AG.GDAL.GDALError GDF.write(
            joinpath(testdatadir, "test_update.gpkg"),
            t;
            layer_name = "test2",
            update = true,
        )
        @test_throws ErrorException("Can't update non-existent file.") GDF.write(
            joinpath(testdatadir, "test_update2.gpkg"),
            t;
            update = true,
        )
    end
end
