const drivers = AG.listdrivers()
const drivermapping = Dict(
    ".shp" => "ESRI Shapefile",
    ".gpkg" => "GPKG",
    ".geojson" => "GeoJSON",
    ".vrt" => "VRT",
    ".sqlite" => "SQLite",
    ".csv" => "CSV",
    ".fgb" => "FlatGeobuf",
    ".pq" => "Parquet",
    ".arrow" => "Arrow",
    ".gml" => "GML",
    ".nc" => "netCDF",
)

function find_driver(fn::AbstractString)
    _, ext = splitext(fn)
    if ext in keys(drivermapping)
        return drivermapping[ext]
    end
    AG.extensiondriver(fn)
end

const lookup_type = Dict{Tuple{DataType,Int},AG.OGRwkbGeometryType}(
    (AG.GeoInterface.PointTrait, 2) => AG.wkbPoint,
    (AG.GeoInterface.PointTrait, 3) => AG.wkbPoint25D,
    (AG.GeoInterface.PointTrait, 4) => AG.wkbPointZM,
    (AG.GeoInterface.MultiPointTrait, 2) => AG.wkbMultiPoint,
    (AG.GeoInterface.MultiPointTrait, 3) => AG.wkbMultiPoint25D,
    (AG.GeoInterface.MultiPointTrait, 4) => AG.wkbMultiPointZM,
    (AG.GeoInterface.LineStringTrait, 2) => AG.wkbLineString,
    (AG.GeoInterface.LineStringTrait, 3) => AG.wkbLineString25D,
    (AG.GeoInterface.LineStringTrait, 4) => AG.wkbLineStringZM,
    (AG.GeoInterface.MultiLineStringTrait, 2) => AG.wkbMultiLineString,
    (AG.GeoInterface.MultiLineStringTrait, 3) => AG.wkbMultiLineString25D,
    (AG.GeoInterface.MultiLineStringTrait, 4) => AG.wkbMultiLineStringZM,
    (AG.GeoInterface.PolygonTrait, 2) => AG.wkbPolygon,
    (AG.GeoInterface.PolygonTrait, 3) => AG.wkbPolygon25D,
    (AG.GeoInterface.PolygonTrait, 4) => AG.wkbPolygonZM,
    (AG.GeoInterface.MultiPolygonTrait, 2) => AG.wkbMultiPolygon,
    (AG.GeoInterface.MultiPolygonTrait, 3) => AG.wkbMultiPolygon25D,
    (AG.GeoInterface.MultiPolygonTrait, 4) => AG.wkbMultiPolygonZM,
)


"""
    read(fn::AbstractString; kwargs...)
    read(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)

Read a file into a DataFrame. Any kwargs are passed onto ArchGDAL [here](https://yeesian.com/ArchGDAL.jl/stable/reference/#ArchGDAL.read-Tuple{AbstractString}).
By default you only get the first layer, unless you specify either the index (0 based) or name (string) of the layer.
"""
function read(fn::AbstractString; kwargs...)
    startswith(fn, "/vsi") || occursin(":", fn) || isfile(fn) || error("File not found.")
    t = AG.read(fn; kwargs...) do ds
        if AG.nlayer(ds) > 1
            @warn "This file has multiple layers, you only get the first layer by default now."
        end
        return read(ds, 0)
    end
    return t
end

function read(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)
    startswith(fn, "/vsi") || occursin(":", fn) || isfile(fn) || error("File not found.")
    t = AG.read(fn; kwargs...) do ds
        return read(ds, layer)
    end
    return t
end

function read(ds, layer)
    df, gnames, sr = AG.getlayer(ds, layer) do table
        if table.ptr == C_NULL
            throw(ArgumentError("Given layer id/name doesn't exist. For reference this is the dataset:\n$ds"))
        end
        names, _ = AG.schema_names(AG.getfeaturedefn(first(table)))
        sr = AG.getspatialref(table)
        return DataFrame(table), names, sr
    end
    if "" in names(df)
        rename!(df, Symbol("") => :geometry)
        replace!(gnames, Symbol("") => :geometry)
    end
    crs = sr.ptr == C_NULL ? nothing : GFT.WellKnownText(GFT.CRS(), AG.toWKT(sr))
    geometrycolumns = Tuple(gnames)
    metadata!(df, "crs", crs, style=:default)
    metadata!(df, "geometrycolumns", geometrycolumns, style=:default)

    # Also add the GEOINTERFACE:property as a namespaced thing
    metadata!(df, "GEOINTERFACE:crs", crs, style=:default)
    metadata!(df, "GEOINTERFACE:geometrycolumns", geometrycolumns, style=:default)
    return df
end

"""
    write(fn::AbstractString, table; layer_name="data", crs::Union{GFT.GeoFormat,Nothing}=crs(table), driver::Union{Nothing,AbstractString}=nothing, options::Vector{AbstractString}=[], geom_columns::Set{Symbol}=(:geometry))

Write the provided `table` to `fn`. The `geom_column` is expected to hold ArchGDAL geometries. 

Experimental: Fast chunked writes can be enabled by setting `use_gdal_copy=true` and `chunksize` to the desired value (default 20000). 
"""
function write(
    fn::AbstractString,
    table;
    layer_name::AbstractString="data",
    crs::Union{GFT.GeoFormat,Nothing}=getcrs(table),
    driver::Union{Nothing,AbstractString}=nothing,
    options::Dict{String,String}=Dict{String,String}(),
    geom_columns=getgeometrycolumns(table),
    use_gdal_copy = true,
    chunksize = 20000,
    kwargs...)
    rows = Tables.rows(table)
    sch = Tables.schema(rows)

    # Determine geometry columns
    isnothing(geom_columns) && error("Please set `geom_columns` kw or define `GeoInterface.geometrycolumns` for $(typeof(table))")
    if :geom_column in keys(kwargs)  # backwards compatible
        geom_columns = (kwargs[:geom_column],)
    end

    geom_types = []
    for geom_column in geom_columns
        trait = AG.GeoInterface.geomtrait(getproperty(first(rows), geom_column))
        ndim = AG.GeoInterface.ncoord(getproperty(first(rows), geom_column))
        geom_type = get(lookup_type, (typeof(trait), ndim), nothing)
        isnothing(geom_type) && throw(ArgumentError("Can't convert $trait with $ndim dimensions of column $geom_column to ArchGDAL yet."))
        push!(geom_types, geom_type)
    end

    # Set geometry name in options
    if !("geometry_name" in keys(options))
        options["geometry_name"] = String(first(geom_columns))
    end

    # Find driver
    if driver !== nothing
        driver = AG.getdriver(driver)
    else
        driver = AG.getdriver(find_driver(fn))
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
                            AG.setgeom!(feature, i - 1, GeoInterface.convert(AG.IGeometry, getproperty(row, geom_column)))
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
                end # for

                if use_gdal_copy
                    AG.copy(
                        layer;
                        dataset = ds,
                        name = layer_name,
                        options = stringlist(options),
                    )
                else
                    AG.createlayer(;
                        name = layer_name,
                        dataset = ds,
                        geom = AG.getgeomtype(layer),
                        spatialref = AG.getspatialref(layer),
                        options = stringlist(options),
                    ) do targetlayer
                        # add field definitions
                        sourcelayerdef = AG.layerdefn(layer)
                        for fieldidx in 0:(AG.nfield(layer)-1)
                            AG.addfielddefn!(
                                targetlayer,
                                AG.getfielddefn(sourcelayerdef, fieldidx),
                            )
                        end
        
                        # iterate over features in chunks to get better speed than gdaldatasetcopylayer
                        for chunk in Iterators.partition(layer, chunksize)
                            GDAL.ogr_l_starttransaction(targetlayer)
                            for feature in chunk
                                AG.addfeature!(targetlayer, feature)
                            end
                            GDAL.ogr_l_committransaction(targetlayer)
                        end
                    end # createlayer
                end # if use_gdal_copy
            end # layer
        end
    end
    fn
end
