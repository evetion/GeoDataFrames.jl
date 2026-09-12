"""
    GeometryVector(A[, index]; create_index=false)

Wrapper for geometry columns in GeoDataFrames.

`GeometryVector` behaves like a mutable `AbstractVector` and caches one spatial
tree in `index`. The first `spatialtree(G)` call builds that tree, later calls
return the cached one, and supported mutations clear it. Pass
`create_index=true` to build the tree during construction, or an `index`
directly to supply a prebuilt tree.
"""
struct GeometryVector{T,I} <: AbstractArray{T,1}
    A::Vector{T}
    # Concrete box type, so that reading the cache is inferable; `getindex` on
    # the abstract `Ref{I}` infers as `Any`.
    index::Base.RefValue{I}
end

# Type of the cache slot: `nothing` until a tree is cached, plus the tree that
# `spatialtree` builds for this element type. A tree's extent type follows the
# dimensions of the geometries it indexes, which are unknown before it exists,
# so take the compiler's bound on the return type — sound for whatever tree
# GeometryOps returns, and concrete whenever the element type is.
function _indextype(::Type{T}) where {T}
    I = Base.promote_op(spatialtree, Vector{T})
    return I === Nothing || I === Union{} ? Any : Union{Nothing,I}
end

function GeometryVector(A::AbstractVector; create_index::Bool=false)
    G = GeometryVector(A, nothing)
    # Build through the wrapper, so the tree indexes the stored `Vector{T}` that
    # later queries see, whatever array type `A` came in as.
    create_index && spatialtree(G)
    return G
end

function GeometryVector(A::AbstractVector, index)
    I = Union{_indextype(eltype(A)),typeof(index)}
    GeometryVector{eltype(A),I}(A, Base.RefValue{I}(index))
end

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
