using GeoDataFrames
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(GeoDataFrames, :DocTestSetup, :(using GeoDataFrames); recursive = true)

img = joinpath(@__DIR__, "src/plot_points.png")
isfile(img) || cp(joinpath(@__DIR__, "../img/plot_points.png"), img)

makedocs(;
    modules = [GeoDataFrames],
    authors = "Maarten Pronk <git@evetion.nl> and contributors",
    sitename = "GeoDataFrames.jl",
    format = MarkdownVitepress(;
        repo = "github.com/evetion/GeoDataFrames.jl",
        deploy_url = "https://www.evetion.nl/GeoDataFrames.jl"
        ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => [
            "Installation" => "tutorials/installation.md",
            "Usage" => "tutorials/usage.md",
            "Operations" => "tutorials/ops.md",
        ],
        "Background" => [
            "Motivation" => "background/geopandas.md",
            "Future plans" => "background/todo.md",
            "File formats" => "background/formats.md",
        ],
        "Reference" => [
            "API" => "reference/api.md"
            "Changelog" => "reference/changes.md"
        ],
    ],
    warnonly = [:missing_docs, :cross_references],
)

deploydocs(;
    repo = "github.com/evetion/GeoDataFrames.jl",
    target = "build",
    devbranch = "master",
    branch = "gh-pages",
    push_preview = true,
)
