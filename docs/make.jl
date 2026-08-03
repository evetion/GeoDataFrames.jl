using GeoDataFrames
using CSV
using Shapefile
using GeoJSON
using FlatGeobuf
using GeoParquet
using GeoArrow

using Documenter
using DocumenterVitepress
using DocumenterInterLinks

using CairoMakie
CairoMakie.activate!(; type="png")

DocMeta.setdocmeta!(
    GeoDataFrames,
    :DocTestSetup,
    :(using GeoDataFrames, GeoInterface);
    recursive=true,
)

links = InterLinks(
    "GeoInterface" => (
        "https://juliageo.org/GeoInterface.jl/stable/",
        "https://juliageo.org/GeoInterface.jl/stable/objects.inv",
    ),
    "GeometryOps" => (
        "https://juliageo.org/GeometryOps.jl/stable/",
        "https://juliageo.org/GeometryOps.jl/stable/objects.inv",
    ),
    # "ArchGDAL" => (
    #     "https://yeesian.com/ArchGDAL.jl/stable/",
    #     "https://yeesian.com/ArchGDAL.jl/stable/objects.inv",
    # ),
    "GeoFormatTypes" => (
        "https://juliageo.org/GeoFormatTypes.jl/stable/",
        "https://juliageo.org/GeoFormatTypes.jl/stable/objects.inv",
    ),
    "CSV" => (
        "https://csv.juliadata.org/stable/",
        "https://csv.juliadata.org/stable/objects.inv",
    ),
    # "FlatGeobuf" => (
    # "https://juliageo.org/FlatGeobuf.jl/stable/",
    # "https://juliageo.org/FlatGeobuf.jl/stable/objects.inv",
    # ),
    # "GeoArrow" => (
    # "https://juliageo.org/GeoArrow.jl/stable/",
    # "https://juliageo.org/GeoArrow.jl/stable/objects.inv",
    # ),
    "GeoParquet" => (
        "https://juliageo.org/GeoParquet.jl/stable/",
        "https://juliageo.org/GeoParquet.jl/stable/objects.inv",
    ),
    "Shapefile" => (
        "https://juliageo.org/Shapefile.jl/stable/",
        "https://juliageo.org/Shapefile.jl/stable/objects.inv",
    ),
    "GeoJSON" => (
        "https://juliageo.org/GeoJSON.jl/stable/",
        "https://juliageo.org/GeoJSON.jl/stable/objects.inv",
    ),
);

img = joinpath(@__DIR__, "src/plot_points.png")
isfile(img) || cp(joinpath(@__DIR__, "../img/plot_points.png"), img)

makedocs(;
    modules=[
        GeoDataFrames,
        Base.get_extension(GeoDataFrames, :GeoDataFramesFlatGeobufExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesCSVExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesGeoArrowExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesGeoJSONExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesGeoParquetExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesShapefileExt),
    ],
    authors="Maarten Pronk <git@evetion.nl> and contributors",
    repo=Remotes.GitHub("evetion", "GeoDataFrames.jl"),
    sitename="GeoDataFrames.jl",
    format=MarkdownVitepress(;
        repo="https://github.com/evetion/GeoDataFrames.jl",
        devbranch="master",
        devurl="dev",
        # deploy_url = "https://www.evetion.nl/GeoDataFrames.jl",
    ),
    pages=[
        "Home" => "index.md",
        "Tutorials" => Any[
            "Installation"=>"tutorials/installation.md",
            "Quick start"=>"tutorials/usage.md",
            "From scratch"=>"tutorials/first-spatial-data.md",
            "Operations"=>"tutorials/ops.md",
        ],
        "Guides" => Any[
            "Reading and writing"=>"how-to/read-write-data.md",
            "Native drivers"=>"how-to/use-native-drivers.md",
            "Metadata"=>"how-to/manage-metadata.md",
            "Reprojection"=>"how-to/reproject-data.md",
            "Operations"=>"how-to/geometry-operations.md",
            "Spatial joins"=>"how-to/spatial-joins.md",
            # "Spatial indexes"=>"how-to/spatial-indexes.md",
            "Plotting"=>"how-to/plot-geometries.md",],
        "Background" => Any[
            "Data model"=>"background/data-model.md",
            "Metadata and CRS"=>"background/metadata-and-crs.md",
            "Driver selection"=>"background/drivers.md",
            "Operations and joins"=>"background/operations-and-joins.md",
            "Native driver performance"=>"background/performance.md",
            "Future plans"=>"background/future-plans.md",
        ],
        "Reference" => Any[
            "IO"=>"reference/io.md",
            "Metadata"=>"reference/metadata.md",
            "Default Driver"=>"reference/archgdal.md",
            "Native Drivers"=>"reference/native-drivers.md",
            "Extensions"=>Any[
                "CSV driver"=>"reference/drivers/csv.md",
                "FlatGeobuf driver"=>"reference/drivers/flatgeobuf.md",
                "GeoArrow driver"=>"reference/drivers/geoarrow.md",
                "GeoJSON driver"=>"reference/drivers/geojson.md",
                "GeoParquet driver"=>"reference/drivers/geoparquet.md",
                "Shapefile driver"=>"reference/drivers/shapefile.md"],
            "Changelog"=>"reference/changes.md",
            "Migration Guide"=>"reference/migration.md",
            "API"=>"reference/api.md",
        ],
    ],
    warnonly=[:missing_docs, :cross_references],
    plugins=[links],
)

DocumenterVitepress.deploydocs(;
    repo="github.com/evetion/GeoDataFrames.jl",
    target=joinpath(@__DIR__, "build"),
    devbranch="master",
    branch="gh-pages",
    push_preview=true,
)
