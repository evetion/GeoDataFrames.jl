using GeoDataFrames
using Documenter
using DocumenterVitepress

DocMeta.setdocmeta!(GeoDataFrames, :DocTestSetup, :(using GeoDataFrames); recursive = true)

img = joinpath(@__DIR__, "src/plot_points.png")
isfile(img) || cp(joinpath(@__DIR__, "../img/plot_points.png"), img)

makedocs(;
    modules = [GeoDataFrames],
    authors = "Maarten Pronk <git@evetion.nl> and contributors",
    repo = "https://github.com/evetion/GeoDataFrames.jl/blob/{commit}{path}#L{line}",
    sitename = "GeoDataFrames.jl",
    format = MarkdownVitepress(;
        repo = "github.com/evetion/GeoDataFrames.jl",
    ),
    pages = [
        "Home" => "index.md",
        "Tutorials" => Any[
            "Installation" => "tutorials/installation.md",
            "Usage" => "tutorials/usage.md",
            "Operations" => "tutorials/ops.md",
        ],
        "Background" => Any[
            "Motivation" => "background/geopandas.md",
            "Future plans" => "background/todo.md",
            "File formats" => "background/formats.md",
        ],
        "Reference" => Any[
            "API" => "reference/api.md"
            "Changelog" => "reference/changes.md"
        ],
    ],
    warnonly = [:missing_docs, :cross_references],
)

deploydocs(;
    repo = "github.com/evetion/GeoDataFrames.jl",
    target = "build",
    devbranch = "main",
    branch = "gh-pages",
    push_preview = true,
)
