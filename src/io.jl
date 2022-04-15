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

"""
    read(fn::AbstractString; kwargs...)
    read(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)

Read a file into a DataFrame. Any kwargs are passed onto ArchGDAL [here](https://yeesian.com/ArchGDAL.jl/stable/reference/#ArchGDAL.read-Tuple{AbstractString}).
By default you only get the first layer, unless you specify either the index (0 based) or name (string) of the layer.
"""
function read(fn::AbstractString; kwargs...)
    ds = AG.read(fn; kwargs...)
    if AG.nlayer(ds) > 1
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
    "" in names(df) && rename!(df, Dict(Symbol("") => :geom,))  # needed for now
    df
end

"""
    write(fn::AbstractString, table; layer_name="data", geom_column=:geom, crs::Union{GFT.GeoFormat,Nothing}=nothing, driver::Union{Nothing,AbstractString}=nothing)

Write the provided `table` to `fn`. The `geom_column` is expected to hold ArchGDAL geometries.
"""
function write(fn::AbstractString, table; layer_name::AbstractString="data", geom_column::Symbol=:geom, crs::Union{GFT.GeoFormat,Nothing}=nothing, driver::Union{Nothing,AbstractString}=nothing)
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
        spatialref = crs === nothing ? AG.SpatialRef() : AG.importCRS(crs)
        AG.createlayer(
            name=layer_name,
            geom=geom_type,
            spatialref=spatialref
        ) do layer
            for (name, type) in fields
                AG.createfielddefn(String(name), convert(AG.OGRFieldType, type)) do fd
                    AG.setsubtype!(fd, convert(AG.OGRFieldSubType, type))
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
