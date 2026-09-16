"""
    GeometryVector(A; crs=nothing, create_index=true)
    GeometryVector(A, index; manifold=Planar())

Wrapper for geometry columns in GeoDataFrames.

`GeometryVector` behaves like a mutable `AbstractVector` and stores one optional
spatial tree in `index`. Supported mutations clear that stored tree.
The tree is built on the sphere when `crs` is geographic, and on the plane otherwise;
only that `manifold` is stored, so the tree can be rebuilt after a mutation.
"""
struct GeometryVector{T,I} <: AbstractArray{T,1}
    A::Vector{T}
    index::Ref{I}
    manifold::GO.Manifold
end

function GeometryVector(A::AbstractVector; crs=nothing, create_index::Bool=true)
    manifold = _manifold(crs)
    return GeometryVector(A, create_index ? spatialtree(manifold, A) : nothing; manifold)
end
GeometryVector(A::AbstractVector, index::I; manifold::GO.Manifold=GO.Planar()) where {I} =
    GeometryVector{eltype(A),Union{Nothing,I}}(A, Ref{Union{Nothing,I}}(index), manifold)
GeometryVector(A::Vector{T}, index::Ref{I}; manifold::GO.Manifold=GO.Planar()) where {T,I} =
    GeometryVector{T,I}(A, index, manifold)

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
    length(dims) == 1 ? GeometryVector(A, nothing; G.manifold) : A
end

_crstrait(::Nothing) = GI.UnknownTrait()
_crstrait(crs) = _crstrait(convert(Proj.CRS, crs))
_crstrait(crs::AbstractString) = _crstrait(Proj.CRS(crs))
function _crstrait(crs::Proj.CRS)
    Proj.is_geographic(crs) && return GI.GeographicTrait()
    Proj.is_projected(crs) && return GI.ProjectedTrait()
    return GI.UnknownTrait()
end

# Geographic coordinates are (longitude, latitude) in degrees, which only the sphere
# bounds correctly across the antimeridian and poles. Without a CRS, stay planar.
_manifold(::Nothing) = GO.Planar()
_manifold(crs) = _manifold(_crstrait(crs))
_manifold(::GI.AbstractGeographicTrait) = GO.Spherical()
_manifold(::GI.AbstractCRSTrait) = GO.Planar()

function spatialtree(G::GeometryVector)
    tree = G.index[]
    tree !== nothing && return tree

    tree = spatialtree(G.manifold, parent(G))
    G.index[] = tree
    return tree
end
