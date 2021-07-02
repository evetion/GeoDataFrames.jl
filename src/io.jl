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
const fieldmapping = Dict(v => k for (k, v) in AG._FIELDTYPE)

# Support "exotic" types, but this needs some piracy
fieldmapping[Float32] = fieldmapping[Float64]
fieldmapping[Int16] = fieldmapping[Int32]
fieldmapping[Bool] = fieldmapping[Int32]

subtypes = Dict(
    Bool => AG.GDAL.OFSTBoolean,
    Int16 => AG.GDAL.OFSTInt16,
    Float32 => AG.GDAL.OFSTFloat32,
    )

function AG.setfield!(feature::AG.Feature, i::Integer, value::Int16)
    AG.GDAL.ogr_f_setfieldinteger(feature.ptr, i, value)
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::Bool)
    AG.GDAL.ogr_f_setfieldinteger(feature.ptr, i, value)
    return feature
end

function AG.setfield!(feature::AG.Feature, i::Integer, value::Float32)
    AG.GDAL.ogr_f_setfielddouble(feature.ptr, i, value)
    return feature
end

function read(fn::AbstractString, layer::Union{Integer,AbstractString}=0; kwargs...)
    ds = AG.read(fn; kwargs...)
    layer = AG.getlayer(ds, layer)
    table = AG.Table(layer)
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
    if extension in keys(drivermapping)
        driver = AG.getdriver(drivermapping[extension])
    elseif driver !== nothing
        driver = AG.getdriver(driver)
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
                AG.createfielddefn(String(name), fieldmapping[type]) do fd
                    AG.setsubtype!(fd, get(subtypes, type, AG.GDAL.OFSTNone))
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
