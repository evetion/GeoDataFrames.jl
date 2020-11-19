using GeoDataFrames
using Documenter

makedocs(;
    modules=[GeoDataFrames],
    authors="Maarten Pronk <git@evetion.nl> and contributors",
    repo="https://github.com/evetion/GeoDataFrames.jl/blob/{commit}{path}#L{line}",
    sitename="GeoDataFrames.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://evetion.github.io/GeoDataFrames.jl",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/evetion/GeoDataFrames.jl",
)
