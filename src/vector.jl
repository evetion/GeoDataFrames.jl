"""
    GeometryVector(A[, index])

Wrapper for geometry columns in GeoDataFrames.

`GeometryVector` behaves like a mutable `AbstractVector` and stores one optional
spatial tree in `index`. Supported mutations clear that stored tree.
"""
struct GeometryVector{T,I} <: AbstractArray{T,1}
    A::Vector{T}
    index::Ref{I}
end

GeometryVector(A::Vector, index::I) where {I} = GeometryVector{eltype(A),I}(A, Ref{Union{Nothing,typeof(index)}}((index)))
GeometryVector(A::Vector) = GeometryVector(A, Ref{Any}(nothing))

Base.parent(G::GeometryVector) = G.A
Base.size(G::GeometryVector) = size(parent(G))
Base.length(G::GeometryVector) = length(parent(G))
Base.IndexStyle(::Type{<:GeometryVector}) = IndexLinear()
Base.getindex(G::GeometryVector, i::Int) = getindex(parent(G), i)

function Base.setindex!(G::GeometryVector, v, i::Int)
    setindex!(parent(G), v, i)
    G.index[] = nothing
    return G
end

function Base.deleteat!(G::GeometryVector, i)
    deleteat!(parent(G), i)
    G.index[] = nothing
    return G
end

# https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array
function Base.similar(G::GeometryVector, ::Type{T}, dims::Dims) where {T}
    A = similar(parent(G), T, dims)
    length(dims) == 1 ? GeometryVector(A) : A
end

function spatialtree(G::GeometryVector)
    tree = G.index[]
    tree !== nothing && return tree

    tree = spatialtree(parent(G))
    G.index[] = tree
    return tree
end
