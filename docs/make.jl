using GeoDataFrames
using Shapefile
using GeoJSON
using FlatGeobuf
using GeoParquet
using GeoArrow

using Documenter
using DocumenterVitepress
using DocumenterInterLinks

using CairoMakie
CairoMakie.activate!(; type = "png")

DocMeta.setdocmeta!(
    GeoDataFrames,
    :DocTestSetup,
    :(using GeoDataFrames, GeoInterface);
    recursive = true,
)

links = InterLinks(
    # "GeoInterface" => ("https://juliageo.org/GeoInterface.jl/stable/",),
    "GeometryOps" => (
        "https://juliageo.org/GeometryOps.jl/stable/",
        "https://juliageo.org/GeometryOps.jl/stable/objects.inv",
    ),
    # "ArchGDAL" => ("https://yeesian.com/ArchGDAL.jl/stable/",),
    "GeoFormatTypes" => (
        "https://juliageo.org/GeoFormatTypes.jl/stable/",
        "https://juliageo.org/GeoFormatTypes.jl/stable/objects.inv",
    ),
);

img = joinpath(@__DIR__, "src/plot_points.png")
isfile(img) || cp(joinpath(@__DIR__, "../img/plot_points.png"), img)

makedocs(;
    modules = [
        GeoDataFrames,
        Base.get_extension(GeoDataFrames, :GeoDataFramesFlatGeobufExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesGeoArrowExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesGeoJSONExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesGeoParquetExt),
        Base.get_extension(GeoDataFrames, :GeoDataFramesShapefileExt),
    ],
    authors = "Maarten Pronk <git@evetion.nl> and contributors",
    repo = Remotes.GitHub("evetion", "GeoDataFrames.jl"),
    sitename = "GeoDataFrames.jl",
    format = MarkdownVitepress(;
        repo = "https://github.com/evetion/GeoDataFrames.jl",
        devbranch = "master",
        devurl = "dev",
        # deploy_url = "https://www.evetion.nl/GeoDataFrames.jl",
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => Any[
            "Installation" => "tutorials/installation.md",
            "Usage" => "tutorials/usage.md",
            "Operations" => "tutorials/ops.md",
            "File formats" => "tutorials/formats.md",
            "Examples" => "tutorials/examples.md",
        ],
        "Background" => Any[
            "Motivation" => "background/geopandas.md",
            "Future plans" => "background/todo.md",
        ],
        "Reference" => Any[
            "API" => "reference/api.md"
            "Changelog" => "reference/changes.md"
            "Migration Guide" => "reference/migration.md"
        ],
    ],
    warnonly = [:missing_docs, :cross_references],
    plugins = [links],
)

DocumenterVitepress.deploydocs(;
    repo = "github.com/evetion/GeoDataFrames.jl",
    target = joinpath(@__DIR__, "build"),
    devbranch = "master",
    branch = "gh-pages",
    push_preview = true,
)
