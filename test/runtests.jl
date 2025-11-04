using TestItemRunner

include("data.jl")

@testsnippet Setup begin
    import GeoFormatTypes as GFT
    import GeoInterface as GI
    import GeoDataFrames as GDF
    import ArchGDAL as AG
    import DataAPI
    import GeometryOps as GO
    using Dates

    testdatadir = joinpath(@__DIR__, "data")
    fn = joinpath(testdatadir, "sites.shp")
    coords = zip(rand(10), rand(10))
    coords3 = zip(rand(10), rand(10), rand(10))
    unknown_crs = GFT.WellKnownText(
        GFT.CRS(),
        "GEOGCS[\"Undefined geographic SRS\",DATUM[\"unknown\",SPHEROID[\"unknown\",6378137,298.257223563]],PRIMEM[\"Greenwich\",0],UNIT[\"degree\",0.0174532925199433,AUTHORITY[\"EPSG\",\"9122\"]],AXIS[\"Latitude\",NORTH],AXIS[\"Longitude\",EAST]]",
    )
end

@testitem "Read shapefile" setup = [Setup] begin
    t = GDF.read(fn)
    @test nrow(t) == 42
    @test "ID" in names(t)
end

@testitem "Read non-existent shapefile" setup = [Setup] begin
    fne = "/bla.shp"
    @test_throws ErrorException("Can't find local file /bla.shp.") GDF.read(fne)
end

@testitem "Read shapefile with layer id" setup = [Setup] begin
    t = GDF.read(fn, 0)
    @test nrow(t) == 42
    @test "ID" in names(t)
end

@testitem "Drivers" setup = [Setup] begin
    t = GDF.read(fn, 0)
    GDF.write(joinpath(testdatadir, "test.csv"), t)
    GDF.write(joinpath(testdatadir, "test.arrow"), t)
    GDF.write(joinpath(testdatadir, "test.pdf"), t)
end

@testitem "Read shapefile with layer name" setup = [Setup] begin
    t = GDF.read(fn, "sites")
    @test nrow(t) == 42
    @test "ID" in names(t)
end

@testitem "Read shapefile with non-existing layer name" setup = [Setup] begin
    @test_throws ArgumentError GDF.read(fn, "foo")
end

@testitem "Read shapefile with NULLs" setup = [Setup] begin
    fnn = joinpath(testdatadir, "null.gpkg")
    t = GDF.read(fnn)
    @test nrow(t) == 2
    @test "name" in names(t)
    @test t.name[1] == "test"
    @test ismissing(t.name[2])
end

@testitem "Read self written file" setup = [Setup] begin

    # Save table with a few random points
    table = DataFrame(; geometry = AG.createpoint.(coords), name = "test")
    GDF.write(joinpath(testdatadir, "test_points.shp"), table)
    GDF.write(joinpath(testdatadir, "test_points.gpkg"), table; layer_name = "test_points")
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

@testitem "Write shapefile" setup = [Setup] begin
    t = GDF.read(fn)

    # Save table from reading
    GDF.write(joinpath(testdatadir, "test_read.shp"), t; layer_name = "test_coastline")
    GDF.write(joinpath(testdatadir, "test_read.gpkg"), t; layer_name = "test_coastline")
    GDF.write(joinpath(testdatadir, "test_read.geojson"), t; layer_name = "test_coastline")
end

@testitem "Write shapefile with non-GDAL types" setup = [Setup] begin
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

@testitem "Read shapefile with non-GDAL types" setup = [Setup] begin
    GDF.read(joinpath(testdatadir, "test_exotic.shp"))
    GDF.read(joinpath(testdatadir, "test_exotic.gpkg"))
    GDF.read(joinpath(testdatadir, "test_exotic.geojson"))
end

@testitem "Spatial operations" setup = [Setup] begin
    using LibGEOS
    table =
        DataFrame(; geometry = GDF.GeometryVector(AG.createpoint.(coords)), name = "test")

    # Buffer to also write polygons
    table.geometry = GO.buffer(table.geometry, 10)
    GDF.write(joinpath(testdatadir, "test_polygons.shp"), table)
    GDF.write(joinpath(testdatadir, "test_polygons.gpkg"), table)
    GDF.write(joinpath(testdatadir, "test_polygons.geojson"), table)
end

@testitem "Reproject" setup = [Setup] begin
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
    GDF.write(joinpath(testdatadir, "test_reprojection.gpkg"), table; crs = GFT.EPSG(28992))
end

@testitem "Kwargs" setup = [Setup] begin
    table = DataFrame(; foo = AG.createpoint.([[0, 0, 0]]), name = "test")
    GDF.write(joinpath(testdatadir, "test_options1.gpkg"), table; geometrycolumn = :foo)
    GDF.write(joinpath(testdatadir, "test_options2.gpkg"), table; geom_columns = (:foo,))

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

@testitem "GeoInterface" setup = [Setup] begin
    tfn = joinpath(testdatadir, "test_geointerface.gpkg")
    table = [(; foo = AG.createpoint(1.0, 2.0), name = "test")]
    @test_throws Exception GDF.write(tfn, table)
    GI.isfeaturecollection(::Vector{<:NamedTuple}) = true
    GI.geomtrait(::Vector{<:NamedTuple}) = GI.FeatureCollectionTrait()  # TODO Make issue GeoInterface.jl
    GI.crs(::GI.FeatureCollectionTrait, ::Vector{<:NamedTuple}) = nothing
    GI.geometrycolumns(::Vector{<:NamedTuple}) = (:foo,)
    @test isfile(GDF.write(tfn, table))
end

@testitem "Metadata" setup = [Setup] begin
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

@testitem "Read geodatabase (folder)" setup = [Setup] begin
    table = DataFrame(; geom = AG.createpoint(1.0, 2.0), name = "test")
    gdbdir = joinpath(testdatadir, "test_options.gdb")
    isdir(gdbdir) && rm(gdbdir; recursive = true)
    GDF.write(gdbdir, table; driver = "OpenFileGDB", geometrycolumn = :geom)
    @test isdir(gdbdir)
    table = GDF.read(gdbdir)
    @test nrow(table) == 1
end

@testitem "Non-spatial columns #77" setup = [Setup] begin
    df = DataFrame(; geometry = vec(reinterpret(Tuple{Float64, Float64}, rand(2, 100))))
    df.area_km2 = [rand(10) for i in 1:100]
    GDF.write("test.gpkg", df)
end

@testitem "Non existing Windows path #78" setup = [Setup] begin
    wfn = "C:\\non_existing_folder\\non_existing_file.shp"
    @test_throws ErrorException("Unable to open $wfn.") GDF.read(wfn)
end

@testitem "Shapefile" setup = [Setup] begin
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

@testitem "GeoJSON" setup = [Setup] begin
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

@testitem "FlatGeobuf" setup = [Setup] begin
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

# Skip on Windows. See GDAL.jl#146
@testitem "GeoParquet" setup = [Setup] tags = [:nowindows] begin
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

@testitem "GeoArrow" setup = [Setup] begin
    using GeoArrow
    fn = joinpath(testdatadir, "example-multipolygon_z.arrow")
    df = GDF.read(fn)
    AG.setconfigoption("OGR_ARROW_ALLOW_ALL_DIMS", "YES")
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

@testitem "Combination of drivers" setup = [Setup] begin
    broken_combos = [
        (GDF.GeoParquetDriver(), GDF.ShapefileDriver()),  # ArgumentError: Shapefiles can only contain geometries of the same type
        (GDF.GeoParquetDriver(), GDF.FlatGeobufDriver()),  # ICreateFeature: Mismatched geometry type. Feature geometry type is Polygon, expected layer geometry type is Multi Polygon
        (GDF.GeoArrowDriver(), GDF.ArchGDALDriver()),  # BoundsError: attempt to access @NamedTuple{x::Union{Missing, Float64}, y::Union{Missing, Float64}, z::Union{Missing, Float64}} at index [4]
        (GDF.GeoArrowDriver(), GDF.GeoJSONDriver()),  # ArgumentError: reducing over an empty collection is not allowed; consider supplying `init` to the reducer
        (GDF.GeoArrowDriver(), GDF.ShapefileDriver()),  # BoundsError: attempt to access @NamedTuple{x::Union{Missing, Float64}, y::Union{Missing, Float64}, z::Union{Missing, Float64}} at index [4]
        (GDF.GeoArrowDriver(), GDF.FlatGeobufDriver()),  # BoundsError: attempt to access @NamedTuple{x::Union{Missing, Float64}, y::Union{Missing, Float64}, z::Union{Missing, Float64}} at index [4]
        (GDF.GeoArrowDriver(), GDF.GeoArrowDriver()),  # BoundsError: attempt to access @NamedTuple{x::Union{Missing, Float64}, y::Union{Missing, Float64}, z::Union{Missing, Float64}} at index [4]
        (GDF.GeoArrowDriver(), GDF.GeoParquetDriver()),  # UndefVarError: `wkbZM` not defined in `WellKnownGeometry`
        (GDF.ArchGDALDriver(), GDF.GeoArrowDriver()),  # exception = TypeError: in Vararg, in count, expected Int64, got a value of type Int32
    ]
    if Sys.iswindows()
        # GDAL.jl#146, GeoParquet on Windows is broken
        push!(broken_combos, (GDF.ArchGDALDriver(), GDF.GeoParquetDriver()))
        push!(broken_combos, (GDF.ShapefileDriver(), GDF.GeoParquetDriver()))
        push!(broken_combos, (GDF.GeoJSONDriver(), GDF.GeoParquetDriver()))
        push!(broken_combos, (GDF.FlatGeobufDriver(), GDF.GeoParquetDriver()))
        push!(broken_combos, (GDF.GeoParquetDriver(), GDF.ArchGDALDriver()))  # not sure why this one fails
        push!(broken_combos, (GDF.GeoParquetDriver(), GDF.ShapefileDriver()))  # not sure why this one fails
        push!(broken_combos, (GDF.GeoParquetDriver(), GDF.GeoJSONDriver()))  # not sure why this one fails
        push!(broken_combos, (GDF.GeoParquetDriver(), GDF.FlatGeobufDriver()))  # not sure why this one fails
    end

    drivers = [
        (GDF.ArchGDALDriver(), "test.gpkg", (;))
        (GDF.GeoJSONDriver(), "test.geojson", (;))
        (GDF.ShapefileDriver(), joinpath(testdatadir, "sites.shp"), (; force = true))
        (GDF.FlatGeobufDriver(), joinpath(testdatadir, "countries.fgb"), (;))  # No write support yet
        (GDF.GeoParquetDriver(), joinpath(testdatadir, "example.parquet"), (;))
        (GDF.GeoArrowDriver(), joinpath(testdatadir, "example-multipolygon_z.arrow"), (;))  # Broken
    ]
    for ((driver_in, fn_in), (driver_out, fn_out, kwargs)) in
        Iterators.product(drivers, drivers)
        (driver_in, driver_out) in broken_combos && continue
        @info "Testing reading with $driver_in and writing with $driver_out."
        df = GDF.read(driver_in, fn_in)
        GDF.write(driver_out, "temp" * basename(fn_out), df; kwargs...)
    end
end

@testitem "Writing crs of geometry" setup = [Setup] begin
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

@testitem "Update geopackage" setup = [Setup] begin
    coords = collect(zip(rand(Float32, 2), rand(Float32, 2)))
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

@testitem "setcrs!" setup = [Setup] begin
    fn = joinpath(testdatadir, "sites.shp")
    t = GDF.read(fn)
    @test GI.crs(t) != GFT.EPSG(4326)
    GDF.setcrs!(t, GFT.EPSG(4326))
    @test GI.crs(t) == GFT.EPSG(4326)
end

@testitem "setgeometrycolumn" setup = [Setup] begin
    fn = joinpath(testdatadir, "sites.shp")
    t = GDF.read(fn)
    @test GI.geometrycolumns(t) == (:geometry,)
    rename!(t, :geometry => :geom)
    GDF.setgeometrycolumn!(t, :geom)
    @test GI.geometrycolumns(t) == (:geom,)
end

filter(ti) = !(:nowindows in ti.tags && Sys.iswindows())

@run_package_tests filter = filter
