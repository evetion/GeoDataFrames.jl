module GeoDataFrames

import ArchGDAL as AG
using DataFrames: DataFrames, DataFrame, DataFrameRow, metadata, metadata!, rename!
using Tables: Tables
import GeoFormatTypes as GFT
import GeoInterface as GI
using GeoInterface: GeoInterface
using Extents: Extents
using DataAPI: DataAPI
using Reexport: Reexport, @reexport
import GeometryOps as GO
import GeometryOps.SpatialTreeInterface: spatialtree
using GeometryOps: GeometryOps
import Proj  # For GO reproject
import WellKnownGeometry

include("vector.jl")
include("exports.jl")
include("drivers.jl")
include("utils.jl")
include("io.jl")

end  # module
