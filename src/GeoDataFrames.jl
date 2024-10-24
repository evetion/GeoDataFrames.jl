module GeoDataFrames

import ArchGDAL as AG
using DataFrames
using Tables
import GeoFormatTypes as GFT
import GeoInterface
using DataAPI
using Reexport

@reexport using Extents
@reexport using GeoFormatTypes

include("exports.jl")
include("io.jl")
include("utils.jl")

end  # module
