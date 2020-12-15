@reexport using ArchGDAL: intersects, equals, disjoint, touches, crosses, within, contains, overlaps
@reexport using ArchGDAL: boundary, convexhull, buffer
@reexport using ArchGDAL: intersection, union, difference, symdifference, distance
@reexport using ArchGDAL: geomlength, geomarea, centroid
@reexport using ArchGDAL: isempty, isvalid, issimple, isring, geomarea, centroid
@reexport using ArchGDAL: createpoint, createlinestring, createlinearring, createpolygon, createmultilinestring, createmultipolygon
@reexport using ArchGDAL: reproject

AG.intersects(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.intersects.(a, b)
AG.equals(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.equals.(a, b)
AG.disjoint(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.disjoint.(a, b)
AG.touches(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.touches.(a, b)
AG.crosses(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.crosses.(a, b)
AG.within(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.within.(a, b)
AG.contains(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.contains.(a, b)
AG.overlaps(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.overlaps.(a, b)
AG.intersection(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.intersection.(a, b)
AG.union(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.union.(a, b)
AG.difference(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.difference.(a, b)
AG.symdifference(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.symdifference.(a, b)
AG.distance(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.distance.(a, b)

AG.boundary(v::Vector{AG.IGeometry}) = AG.boundary.(v)
AG.convexhull(v::Vector{AG.IGeometry}) = AG.convexhull.(v)
AG.buffer(v::Vector{AG.IGeometry}, d) = AG.buffer.(v, d)
AG.transform!(v::Vector{AG.IGeometry}, d) = AG.buffer.(v, d)
AG.geomlength(v::Vector{AG.IGeometry}) = AG.geomlength.(v)
AG.geomarea(v::Vector{AG.IGeometry}) = AG.geomarea.(v)
AG.centroid(v::Vector{AG.IGeometry}) = AG.centroid.(v)
AG.isempty(v::Vector{AG.IGeometry}) = AG.isempty.(v)
AG.isvalid(v::Vector{AG.IGeometry}) = AG.isvalid.(v)
AG.issimple(v::Vector{AG.IGeometry}) = AG.issimple.(v)
AG.isring(v::Vector{AG.IGeometry}) = AG.isring.(v)
