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

const lookup_type = Dict{DataType,AG.OGRwkbGeometryType}(
    AG.GeoInterface.PointTrait => AG.wkbPoint,
    AG.GeoInterface.MultiPointTrait => AG.wkbMultiPoint,
    AG.GeoInterface.LineStringTrait => AG.wkbLineString,
    AG.GeoInterface.LinearRingTrait => AG.wkbMultiLineString,
    AG.GeoInterface.MultiLineStringTrait => AG.wkbMultiLineString,
    AG.GeoInterface.PolygonTrait => AG.wkbPolygon,
    AG.GeoInterface.MultiPolygonTrait => AG.wkbMultiPolygon,
)


"""
    read(fn::AbstractString; kwargs...)
    read(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)

Read a file into a DataFrame. Any kwargs are passed onto ArchGDAL [here](https://yeesian.com/ArchGDAL.jl/stable/reference/#ArchGDAL.read-Tuple{AbstractString}).
By default you only get the first layer, unless you specify either the index (0 based) or name (string) of the layer.
"""
function read(fn::AbstractString; kwargs...)
    t = AG.read(fn; kwargs...) do ds
        if AG.nlayer(ds) > 1
            @warn "This file has multiple layers, you only get the first layer by default now."
        end
        return read(ds, 0)
    end
    return t
end

function read(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)
    t = AG.read(fn; kwargs...) do ds
        return read(ds, layer)
    end
    return t
end

function read(ds, layer)
    df = AG.getlayer(ds, layer) do table
        if table.ptr == C_NULL
            throw(ArgumentError("Given layer id/name doesn't exist. For reference this is the dataset:\n$ds"))
        end
        return DataFrame(table)
    end
    "" in names(df) && rename!(df, Dict(Symbol("") => :geometry,))  # needed for now
    return df
end

"""
    write(fn::AbstractString, table; layer_name="data", geom_column=:geometry, crs::Union{GFT.GeoFormat,Nothing}=nothing, driver::Union{Nothing,AbstractString}=nothing, options::Vector{AbstractString}=[], geom_columns::Set{Symbol}=(:geometry))

Write the provided `table` to `fn`. The `geom_column` is expected to hold ArchGDAL geometries.
"""
function write(fn::AbstractString, table; layer_name::AbstractString="data", crs::Union{GFT.GeoFormat,Nothing}=nothing, driver::Union{Nothing,AbstractString}=nothing, options::Dict{String,String}=Dict{String,String}(), geom_columns=GeoInterface.geometrycolumns(table), kwargs...)
    rows = Tables.rows(table)
    sch = Tables.schema(rows)

    # Determine geometry columns
    if :geom_column in keys(kwargs)  # backwards compatible
        geom_columns = (kwargs[:geom_column],)
    end

    geom_types = []
    for geom_column in geom_columns
        trait = AG.GeoInterface.geomtrait(getproperty(first(rows), geom_column))
        geom_type = get(lookup_type, typeof(trait), nothing)
        isnothing(geom_type) && throw(ArgumentError("Can't convert $trait of column $geom_column to ArchGDAL yet."))
        push!(geom_types, geom_type)
    end

    # Set geometry name in options
    if !("geometry_name" in keys(options))
        options["geometry_name"] = "geometry"
    end

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
        if !(name in geom_columns)
            AG.GeoInterface.isgeometry(type) && error("Did you mean to use the `geom_columns` argument to specify $name is a geometry?")
            types = Base.uniontypes(type)
            if length(types) == 1
                push!(fields, (Symbol(name), type))
            elseif length(types) == 2 && Missing in types
                push!(fields, (Symbol(name), types[2]))
            else
                error("Can't convert to GDAL type from $type. Please file an issue.")
            end
        end
    end
    AG.create(
        fn,
        driver=driver
    ) do ds
        AG.newspatialref() do spatialref
            crs !== nothing && AG.importCRS!(spatialref, crs)
            AG.createlayer(
                name=layer_name,
                geom=first(geom_types),  # how to set the name though?
                spatialref=spatialref,
                options=stringlist(options)
            ) do layer
                for (i, (geom_column, geom_type)) in enumerate(zip(geom_columns, geom_types))
                    if i > 1
                        AG.writegeomdefn!(layer, string(geom_column), geom_type)
                    end
                end
                for (name, type) in fields
                    AG.createfielddefn(String(name), convert(AG.OGRFieldType, type)) do fd
                        AG.setsubtype!(fd, convert(AG.OGRFieldSubType, type))
                        AG.addfielddefn!(layer, fd)
                    end
                end
                for row in rows
                    AG.createfeature(layer) do feature
                        for (i, (geom_column)) in enumerate(geom_columns)
                            AG.setgeom!(feature, i - 1, convert(AG.IGeometry, getproperty(row, geom_column)))
                        end
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
                AG.copy(layer, dataset=ds, name=layer_name, options=stringlist(options))
            end
        end
    end
    fn
end
