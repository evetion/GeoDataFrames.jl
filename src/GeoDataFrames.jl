module GeoDataFrames

import ArchGDAL as AG
using DataFrames
using Tables
import GeoFormatTypes as GFT
import GeoInterface as GI
using DataAPI
using Reexport
import GeometryOps as GO
import Proj  # For GO reproject

include("vector.jl")
include("exports.jl")
include("drivers.jl")
include("io.jl")
include("utils.jl")

export reproject, reproject!

end  # module
