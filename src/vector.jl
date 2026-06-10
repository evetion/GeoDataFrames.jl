"""
    GeometryVector(A::Vector)

A thin wrapper around a `Vector` of geometries, used as the geometry column type in
GeoDataFrames. It behaves like a regular `AbstractVector` (indexing, mutation, `similar`),
and exists as a distinct type so geometry-specific behaviour (such as a future spatial index)
can be attached. Geometry columns returned by [`read`](@ref) are wrapped in a `GeometryVector`.

# Example
```jldoctest
julia> gv = GeoDataFrames.GeometryVector([GeoInterface.Point(1.0, 2.0), GeoInterface.Point(3.0, 4.0)]);

julia> length(gv)
2
```
"""
struct GeometryVector{T} <: AbstractArray{T, 1}
    A::Vector{T}
    # TODO Add spatial index
    # TODO Add crs
end

Base.parent(G::GeometryVector) = G.A
Base.size(G::GeometryVector) = size(parent(G))
Base.length(G::GeometryVector) = length(parent(G))
Base.IndexStyle(::Type{<:GeometryVector}) = IndexLinear()
# TODO Invalidate spatial index
Base.getindex(G::GeometryVector, i::Int) = getindex(parent(G), i)
Base.setindex!(G::GeometryVector, v, i::Int) = setindex!(parent(G), v, i)

# https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array
Base.similar(G::GeometryVector, ::Type{T}, dims::Dims) where {T} = GeometryVector(similar(parent(G), T, dims))

# Mutable array interface
# TODO Invalidate spatial index on mutations
Base.deleteat!(G::GeometryVector, i) = (deleteat!(parent(G), i); G)
