@reexport using GeoInterface
@reexport using Extents
@reexport using DataFrames
@reexport using GeometryOps

# `flatten` and `union` are exported by both GeometryOps and DataFrames/Base.
# Resolve the conflict explicitly in favor of GeometryOps' geometry operations.
using GeometryOps: flatten, union
export flatten, union

using GeoFormatTypes:
    AbstractWellKnownText,
    CoordSys,
    CoordinateReferenceSystemFormat,
    EPSG,
    ESRIWellKnownText,
    GML,
    GeoFormat,
    GeoFormatTypes,
    GeometryFormat,
    KML,
    MixedFormat,
    ProjJSON,
    ProjString,
    WellKnownBinary,
    WellKnownText,
    WellKnownText2 #=GeoJSON,=#
export AbstractWellKnownText,
    CoordSys,
    CoordinateReferenceSystemFormat,
    EPSG,
    ESRIWellKnownText,
    GML,
    GeoFormat,
    GeoFormatTypes,
    GeometryFormat,
    KML,
    MixedFormat,
    ProjJSON,
    ProjString,
    WellKnownBinary,
    WellKnownText,
    WellKnownText2 #=GeoJSON,=#
