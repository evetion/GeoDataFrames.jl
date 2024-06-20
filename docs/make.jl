using GeoDataFrames
using Documenter

img = joinpath(@__DIR__, "src/plot_points.png")
isfile(img) || cp(joinpath(@__DIR__, "../img/plot_points.png"), img)

makedocs(;
    modules=[GeoDataFrames],
    authors="Maarten Pronk <git@evetion.nl> and contributors",
    repo="https://github.com/evetion/GeoDataFrames.jl/blob/{commit}{path}#L{line}",
    sitename="GeoDataFrames.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://evetion.github.io/GeoDataFrames.jl",
        assets=String[]
    ),
    pages=[
        "Home" => "index.md",
        "Tutorials" => Any[
            "Installation"=>"tutorials/installation.md",
            "Usage"=>"tutorials/usage.md",
            "Operations"=>"tutorials/ops.md",
        ],
        "Background" => Any[
            "Motivation"=>"background/geopandas.md",
            "Future plans"=>"background/todo.md",
        ],
        "Reference" => Any[
            "API" => "reference/api.md"
            "Changelog" => "reference/changes.md"
        ],
    ]
)

deploydocs(;
    repo="github.com/evetion/GeoDataFrames.jl"
)
