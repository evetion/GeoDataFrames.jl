const drivers = AG.listdrivers()
const drivermapping = Dict(
    ".shp" => "ESRI Shapefile",
    ".gpkg" => "GPKG",
    ".geojson" => "GeoJSON",
    ".vrt" => "VRT",
    ".csv" => "CSV",
    ".fgb" => "FlatGeobuf",
    ".gml" => "GML",
    ".nc" => "netCDF",
)

# Support "exotic" types, but this needs some piracy
Base.convert(::Type{AG.OGRFieldType}, ft::Type{Bool}) = AG.OFTInteger
Base.convert(::Type{AG.OGRFieldType}, ft::Type{Int16}) = AG.OFTInteger
Base.convert(::Type{AG.OGRFieldType}, ft::Type{Float32}) = AG.OFTReal

function Base.convert(::Type{AG.OGRFieldType}, ft::Type{Int8})
    @warn "Int8 fields will become Int16"
    return AG.OFTInteger
end
function Base.convert(::Type{AG.OGRFieldType}, ft::Type{UInt8})
    @warn "UInt8 fields will become Int16"
    return AG.OFTInteger
end
function Base.convert(::Type{AG.OGRFieldType}, ft::Type{UInt16})
    @warn "UInt16 fields will become Int32"
    return AG.OFTInteger
end
function Base.convert(::Type{AG.OGRFieldType}, ft::Type{UInt32})
    @warn "UInt32 fields will become Int64"
    return AG.OFTInteger64
end

subtypes = Dict(
    Bool => AG.OFSTBoolean,
    Int16 => AG.OFSTInt16,
    Float32 => AG.OFSTFloat32,
    Int8 => AG.OFSTInt16,
    UInt8 => AG.OFSTInt16,
    )


function AG.setfield!(feature::AG.Feature, i::Integer, value::Bool)
    AG.GDAL.ogr_f_setfieldinteger(feature.ptr, i, value)
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::Int16)
    AG.GDAL.ogr_f_setfieldinteger(feature.ptr, i, value)
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::Float32)
    AG.GDAL.ogr_f_setfielddouble(feature.ptr, i, value)
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::Union{UInt8,Int8})
    AG.GDAL.ogr_f_setfielddouble(feature.ptr, i, Int16(value))
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::UInt16)
    AG.GDAL.ogr_f_setfielddouble(feature.ptr, i, Int32(value))
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::UInt32)
    AG.GDAL.ogr_f_setfielddouble(feature.ptr, i, Int64(value))
    return feature
end


function read(fn::AbstractString; kwargs...)
    ds = AG.read(fn; kwargs...)
    if ArchGDAL.nlayer(ds) > 1
        @warn "This file has multiple layers, you only get the first layer by default now."
    end
    read(ds, 0)
end

function read(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)
    ds = AG.read(fn; kwargs...)
    read(ds, layer)
end

function read(ds, layer)
    table = AG.getlayer(ds, layer)
    if table.ptr == C_NULL
        throw(ArgumentError("Given layer id/name doesn't exist. For reference this is the dataset:\n$ds"))
    end
    df = DataFrame(table)
    "" in names(df) && rename!(df, Dict(Symbol("") => :geom, ))  # needed for now
    df
end

function write(fn::AbstractString, table; layer_name::AbstractString="data", geom_column::Symbol=:geom, crs::GFT.GeoFormat=GFT.EPSG(4326), driver::Union{Nothing,AbstractString}=nothing)
    rows = Tables.rows(table)
    sch = Tables.schema(rows)

    # Geom type can't be inferred from here
    geom_type = AG.getgeomtype(rows[1][geom_column])

    # Find driver
    _, extension = splitext(fn)
    if driver !== nothing
        driver = AG.getdriver(driver)
    elseif extension in keys(drivermapping)
        driver = AG.getdriver(drivermapping[extension])
    else
        error("Couldn't determine driver for $extension. Please provide one of $(keys(drivermapping))")
    end

    # Figure out attributes
    fields = Vector{Tuple{Symbol,DataType}}()
    for (name, type) in zip(sch.names, sch.types)
        if type != AG.IGeometry && name != geom_column
            types = Base.uniontypes(type)
            if length(types) == 1
                push!(fields, (Symbol(name), type))
            elseif length(types) == 2 && Missing in types
                push!(fields, (Symbol(name), types[2]))
            else
                error("Can't convert to GDAL type from $type")
            end
        end
    end
    AG.create(
        fn,
        driver=driver
    ) do ds
        AG.createlayer(
            name=layer_name,
            geom=geom_type,
            spatialref=AG.importCRS(crs)
        ) do layer
            for (name, type) in fields
                AG.createfielddefn(String(name), convert(AG.OGRFieldType, type)) do fd
                    AG.setsubtype!(fd, get(subtypes, type, AG.OFSTNone))
                    AG.addfielddefn!(layer, fd)
                end
            end
            for row in rows
                AG.createfeature(layer) do feature
                    AG.setgeom!(feature, getproperty(row, geom_column))
                    for (name, _) in fields
                        field = getproperty(row, name)
                        if !ismissing(field)
                            AG.setfield!(feature, AG.findfieldindex(feature, name), getproperty(row, name))
                        else
                            AG.GDAL.ogr_f_setfieldnull(feature.ptr, AG.findfieldindex(feature, name))
                        end
                    end
                end
            end
            AG.copy(layer, dataset=ds, name=layer_name)
        end
    end
    fn
end
