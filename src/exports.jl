@reexport using GeoInterface:
    intersects, equals, disjoint, touches, crosses, within, contains, overlaps
@reexport using GeoInterface: boundary, convexhull, buffer
@reexport using GeoInterface: intersection, union, difference, symdifference, distance
@reexport using GeoInterface: area, centroid
@reexport using GeoInterface: isvalid, issimple, isring, geomarea, centroid
# @reexport using GeoInterface:
#     createpoint,
#     createlinestring,
#     createlinearring,
#     createpolygon,
#     createmultilinestring,
#     createmultipolygon

@reexport using Extents
@reexport using GeoInterface: crs

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

GI.boundary(v::GeometryVector) = GI.boundary.(v)
GI.convexhull(v::GeometryVector) = GI.convexhull.(v)
GI.buffer(v::GeometryVector, d) = GI.buffer.(v, d)
GI.length(v::GeometryVector) = GI.geomlength.(v)
GI.area(v::GeometryVector) = GI.area.(v)
GI.centroid(v::GeometryVector) = GI.centroid.(v)
GI.isempty(v::GeometryVector) = GI.isempty.(v)
GI.isvalid(v::GeometryVector) = GI.isvalid.(v)
GI.issimple(v::GeometryVector) = GI.issimple.(v)
GI.isring(v::GeometryVector) = GI.isring.(v)
