using Pkg.PlatformEngines

const testdatadir = joinpath(@__DIR__, "data")
isdir(testdatadir) || mkdir(testdatadir)
REPO_URL = "https://github.com/yeesian/ArchGDALDatasets/blob/master/"

# Use ArchGDAL datasets to test with
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
