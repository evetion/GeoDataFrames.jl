module GeoDataFrames

import ArchGDAL as AG
using DataFrames
using Tables
import GeoFormatTypes as GFT
import GeoInterface
using DataAPI

include("exports.jl")
include("io.jl")
include("utils.jl")

end  # module
