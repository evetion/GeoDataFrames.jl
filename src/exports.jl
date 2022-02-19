# Taken from https://github.com/simonster/Reexport.jl/blob/master/src/Reexport.jl by https://github.com/simonster
# As no release has been made yet: https://github.com/simonster/Reexport.jl/pull/23
macro reexport(ex)
    isa(ex, Expr) && (ex.head == :module ||
                      ex.head == :using ||
                      (ex.head == :toplevel &&
                       all(e -> isa(e, Expr) && e.head == :using, ex.args))) ||
        error("@reexport: syntax error")

    if ex.head == :module
        modules = Any[ex.args[2]]
        ex = Expr(:toplevel, ex, :(using .$(ex.args[2])))
    elseif ex.head == :using && all(e -> isa(e, Symbol), ex.args)
        modules = Any[ex.args[end]]
    elseif ex.head == :using && ex.args[1].head == :(:)
        symbols = [e.args[end] for e in ex.args[1].args[2:end]]
        return esc(Expr(:toplevel, ex, :(eval(Expr(:export, $symbols...)))))
    else
        modules = Any[e.args[end] for e in ex.args]
    end

    esc(Expr(:toplevel, ex,
        [:(eval(Expr(:export, names($mod)...))) for mod in modules]...))
end


@reexport using ArchGDAL: intersects, equals, disjoint, touches, crosses, within, contains, overlaps
@reexport using ArchGDAL: boundary, convexhull, buffer
@reexport using ArchGDAL: intersection, union, difference, symdifference, distance
@reexport using ArchGDAL: geomlength, geomarea, centroid
@reexport using ArchGDAL: isvalid, issimple, isring, geomarea, centroid
@reexport using ArchGDAL: createpoint, createlinestring, createlinearring, createpolygon, createmultilinestring, createmultipolygon
@reexport using ArchGDAL: reproject

AG.intersects(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.intersects.(a, b)
AG.equals(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.equals.(a, b)
AG.disjoint(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.disjoint.(a, b)
AG.touches(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.touches.(a, b)
AG.crosses(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.crosses.(a, b)
AG.within(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.within.(a, b)
AG.contains(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.contains.(a, b)
AG.overlaps(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.overlaps.(a, b)
AG.intersection(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.intersection.(a, b)
AG.union(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.union.(a, b)
AG.difference(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.difference.(a, b)
AG.symdifference(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.symdifference.(a, b)
AG.distance(a::Vector{AG.IGeometry{T}}, b::Vector{AG.IGeometry{X}}) where {X,T} = AG.distance.(a, b)

AG.boundary(v::Vector{AG.IGeometry{T}}) where {T} = AG.boundary.(v)
AG.convexhull(v::Vector{AG.IGeometry{T}}) where {T} = AG.convexhull.(v)
AG.buffer(v::Vector{AG.IGeometry{T}}, d) where {T} = AG.buffer.(v, d)
AG.transform!(v::Vector{AG.IGeometry{T}}, d) where {T} = AG.buffer.(v, d)
AG.geomlength(v::Vector{AG.IGeometry{T}}) where {T} = AG.geomlength.(v)
AG.geomarea(v::Vector{AG.IGeometry{T}}) where {T} = AG.geomarea.(v)
AG.centroid(v::Vector{AG.IGeometry{T}}) where {T} = AG.centroid.(v)
AG.isempty(v::Vector{AG.IGeometry{T}}) where {T} = AG.isempty.(v)
AG.isvalid(v::Vector{AG.IGeometry{T}}) where {T} = AG.isvalid.(v)
AG.issimple(v::Vector{AG.IGeometry{T}}) where {T} = AG.issimple.(v)
AG.isring(v::Vector{AG.IGeometry{T}}) where {T} = AG.isring.(v)
