module GeoDataFramesDimensionalDataExt

import DimensionalData as DD
import GeoDataFrames as GDF
import DataFrames
using DataFrames: DataFrame
using Extents: Extent

const GI = GDF.GeoInterface

struct _PointGeometry end
struct _CellGeometry end

struct _GeometryColumn{T,M,XD,YD,CI} <: AbstractVector{T}
    mode::M
    xdim::XD
    ydim::YD
    indices::CI
    xpos::Int
    ypos::Int
end

Base.IndexStyle(::Type{<:_GeometryColumn}) = IndexLinear()
Base.size(column::_GeometryColumn) = (length(column.indices),)

function _GeometryColumn(mode, table)
    rowdims = DD.dims(table)
    xdim, ydim = DD.dims(rowdims, (:X, :Y))
    TX = eltype(DD.lookup(xdim))
    TY = eltype(DD.lookup(ydim))
    TX <: Real && TY <: Real ||
        throw(ArgumentError("geometry requires numeric X and Y dimensions"))
    T = _geometrytype(mode, xdim, ydim)
    indices = CartesianIndices(map(length, rowdims))
    return _GeometryColumn{T,typeof(mode),typeof(xdim),typeof(ydim),typeof(indices)}(
        mode,
        xdim,
        ydim,
        indices,
        DD.dimnum(rowdims, :X),
        DD.dimnum(rowdims, :Y),
    )
end

_geometrytype(::_PointGeometry, xdim, ydim) =
    Tuple{eltype(DD.lookup(xdim)), eltype(DD.lookup(ydim))}
function _geometrytype(::_CellGeometry, xdim, ydim)
    XB = Base.promote_op(DD.intervalbounds, typeof(xdim), Int)
    YB = Base.promote_op(DD.intervalbounds, typeof(ydim), Int)
    return Extent{(:X, :Y),Tuple{XB, YB}}
end

@inline function Base.getindex(column::_GeometryColumn, i::Int)
    @boundscheck checkbounds(column, i)
    index = @inbounds column.indices[i]
    return _geometry(
        column.mode,
        column.xdim,
        column.ydim,
        index[column.xpos],
        index[column.ypos],
    )
end

@inline function _geometry(::_PointGeometry, xdim, ydim, xindex, yindex)
    return @inbounds (DD.lookup(xdim)[xindex], DD.lookup(ydim)[yindex])
end
@inline function _geometry(::_CellGeometry, xdim, ydim, xindex, yindex)
    xbounds = minmax(DD.intervalbounds(xdim, xindex)...)
    ybounds = minmax(DD.intervalbounds(ydim, yindex)...)
    return Extent(; X = xbounds, Y = ybounds)
end

function GDF.GeoDataFrame(
    array::DD.AbstractDimArray;
    geometrycolumn::Symbol = :geometry,
    geometry::Symbol = :auto,
    layersfrom = :Band,
)
    _check_spatial_dims(array)
    table = DD.DimTable(array; layersfrom)
    return _GeoDataFrame(table, array, geometrycolumn, geometry)
end

function GDF.GeoDataFrame(
    stack::DD.AbstractDimStack;
    geometrycolumn::Symbol = :geometry,
    geometry::Symbol = :auto,
)
    _check_spatial_dims(stack)
    table = DD.DimTable(stack)
    return _GeoDataFrame(table, stack, geometrycolumn, geometry)
end

function _GeoDataFrame(table, source, geometrycolumn, geometry)
    mode = _geometry_mode(source, geometry)
    rowdims = DD.dims(table)
    xdim, ydim = DD.dims(rowdims, (:X, :Y))
    geometries = _GeometryColumn(mode, table)
    df = DataFrame(table; copycols = false)

    DataFrames.select!(
        df,
        DataFrames.Not([DD.name(xdim), DD.name(ydim)]),
    )
    geometry_position = length(rowdims) - 1
    DataFrames.insertcols!(
        df,
        geometry_position,
        geometrycolumn => geometries;
        copycols = false,
    )

    GDF.setgeometrycolumn!(df, geometrycolumn)
    source_crs = GI.crs(source)
    isnothing(source_crs) || GDF.setcrs!(df, source_crs)
    return df
end

function _check_spatial_dims(source)
    all(dim -> DD.hasdim(source, dim), (:X, :Y)) && return
    throw(ArgumentError("GeoDataFrame requires both X and Y dimensions"))
end

function _geometry_mode(source, geometry)
    geometry in (:auto, :point, :cell) ||
        throw(ArgumentError("geometry must be :auto, :point, or :cell"))
    geometry === :point && return _PointGeometry()

    samplings = map(DD.sampling, DD.dims(source, (:X, :Y)))
    all(sampling -> sampling isa DD.Lookups.Intervals, samplings) &&
        return _CellGeometry()

    if any(sampling -> sampling isa DD.Lookups.Intervals, samplings)
        throw(
            ArgumentError(
                "X and Y must both use interval sampling to create cell geometry",
            ),
        )
    end
    geometry === :cell &&
        throw(ArgumentError("cell geometry requires interval-sampled X and Y dimensions"))
    return _PointGeometry()
end

end
