using GeoDataFrames
using Documenter
using DocumenterVitepress
using CairoMakie
CairoMakie.activate!(; type = "png")

DocMeta.setdocmeta!(GeoDataFrames, :DocTestSetup, :(using GeoDataFrames); recursive = true)

img = joinpath(@__DIR__, "src/plot_points.png")
isfile(img) || cp(joinpath(@__DIR__, "../img/plot_points.png"), img)

makedocs(;
    modules = [GeoDataFrames],
    authors = "Maarten Pronk <git@evetion.nl> and contributors",
    repo = Remotes.GitHub("evetion", "GeoDataFrames.jl"),
    sitename = "GeoDataFrames.jl",
    format = MarkdownVitepress(;
        repo = "https://github.com/evetion/GeoDataFrames.jl",
        devbranch = "master",
        devurl = "dev",
        deploy_url = "www.evetion.nl/GeoDataFrames.jl",
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => Any[
            "Installation" => "tutorials/installation.md",
            "Usage" => "tutorials/usage.md",
            "Operations" => "tutorials/ops.md",
            "File formats" => "tutorials/formats.md",
        ],
        "Background" => Any[
            "Motivation" => "background/geopandas.md",
            "Future plans" => "background/todo.md",
        ],
        "Reference" => Any[
            "API" => "reference/api.md"
            "Changelog" => "reference/changes.md"
        ],
    ],
    warnonly = [:missing_docs, :cross_references],
)

DocumenterVitepress.deploydocs(;
    repo = "github.com/evetion/GeoDataFrames.jl",
    target = joinpath(@__DIR__, "build"),
    devbranch = "master",
    branch = "gh-pages",
    push_preview = true,
)
