const drivers = AG.listdrivers()
const drivermapping = Dict(
    ".shp" => "ESRI Shapefile",
    ".gpkg" => "GPKG",
    ".geojson" => "GeoJSON",
)
const fieldmapping = Dict(v => k for (k, v) in AG._FIELDTYPE)




function read(fn::AbstractString, layer::Union{Integer,AbstractString}=0)
    ds = AG.read(fn)
    layer = AG.getlayer(ds, layer)
    table = AG.Table(layer)
    df = DataFrame(table)
    "" in names(df) && rename!(df, Dict(Symbol("") => "geom", ))  # needed for now
    df
end

function write(fn::AbstractString, table, layer_name::AbstractString="data", geom_column::Symbol=Symbol("geom"), crs::GFT.GeoFormat=GFT.EPSG(4326), driver::Union{Nothing,AbstractString}=nothing)
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
    fields = Vector{Tuple{AbstractString,DataType}}()
    for (name, type) in zip(sch.names, sch.types)
        if type != AG.IGeometry && name != geom_column
            push!(fields, (String(name), type))
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
                AG.addfielddefn!(layer, name, fieldmapping[type])
            end
            for row in rows
                AG.createfeature(layer) do feature
                    AG.setgeom!(feature, row[geom_column])
                    for (name, type) in fields
                        AG.setfield!(feature, AG.findfieldindex(feature, name), row[name])
                    end
                end
            end
            AG.copy(layer, dataset=ds, name=layer_name)
        end
    end
    fn
end
