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

GeometryVector(A::AbstractVector; create_index::Bool=true) =
    GeometryVector(A, create_index ? spatialtree(A) : nothing)
GeometryVector(A::AbstractVector, index::I) where {I} =
    GeometryVector{eltype(A),Union{Nothing,I}}(A, Ref{Union{Nothing,I}}(index))

Base.parent(G::GeometryVector) = G.A
Base.size(G::GeometryVector) = size(parent(G))
Base.length(G::GeometryVector) = length(parent(G))
Base.IndexStyle(::Type{<:GeometryVector}) = IndexLinear()
Base.getindex(G::GeometryVector, i::Int) = getindex(parent(G), i)

function _invalidate!(G::GeometryVector)
    G.index[] = nothing
    return G
end

function Base.setindex!(G::GeometryVector, v, i::Int)
    setindex!(parent(G), v, i)
    return _invalidate!(G)
end

function Base.push!(G::GeometryVector, item)
    push!(parent(G), item)
    return _invalidate!(G)
end

function Base.deleteat!(G::GeometryVector, i)
    deleteat!(parent(G), i)
    return _invalidate!(G)
end

function Base.copyto!(dest::GeometryVector, src::GeometryVector)
    dest === src && return dest
    _invalidate!(dest)
    copyto!(parent(dest), parent(src))
    return dest
end

# https://docs.julialang.org/en/v1/manual/interfaces/#man-interface-array
function Base.similar(G::GeometryVector, ::Type{T}, dims::Dims) where {T}
    A = similar(parent(G), T, dims)
    length(dims) == 1 ? GeometryVector(A, nothing) : A
end

function spatialtree(G::GeometryVector)
    tree = G.index[]
    tree !== nothing && return tree

    tree = spatialtree(parent(G))
    G.index[] = tree
    return tree
end
