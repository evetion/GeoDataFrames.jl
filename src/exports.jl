@reexport using GeoInterface
# @reexport using GeoInterface:
#     createpoint,
#     createlinestring,
#     createlinearring,
#     createpolygon,
#     createmultilinestring,
#     createmultipolygon

@reexport using Extents
@reexport using GeoInterface: crs
@reexport using DataFrames
@reexport using GeometryOps:
    intersects,
    equals,
    disjoint,
    touches,
    crosses,
    within,
    contains,
    overlaps,
    intersection,
    union,
    difference,
    symdifference,
    distance,
    buffer,
    area,
    centroid
using GeoInterface: boundary, convexhull

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
