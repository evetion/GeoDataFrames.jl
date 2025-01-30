"""
    GeometryVector(A)

A vector of geometries, as used in GeoDataFrames.
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
