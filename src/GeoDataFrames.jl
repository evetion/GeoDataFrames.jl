module GeoDataFrames
# Write your package code here.
using Reexport
using ArchGDAL; const AG = ArchGDAL
using DataFrames
using Tables
using GeoFormatTypes; const GFT = GeoFormatTypes

@reexport using ArchGDAL: intersects, equals, disjoint, touches, crosses, within, contains, overlaps
@reexport using ArchGDAL: boundary, convexhull, buffer
@reexport using ArchGDAL: intersection, union, difference, symdifference, distance
@reexport using ArchGDAL: geomlength, geomarea, centroid
@reexport using ArchGDAL: isempty, isvalid, issimple, isring, geomarea, centroid
@reexport using ArchGDAL: createpoint, createlinestring, createlinearring, createpolygon, createmultilinestring, createmultipolygon
@reexport using ArchGDAL: reproject

AG.intersects(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.intersects.(a, b)
AG.equals(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.equals.(a, b)
AG.disjoint(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.disjoint.(a, b)
AG.touches(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.touches.(a, b)
AG.crosses(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.crosses.(a, b)
AG.within(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.within.(a, b)
AG.contains(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.contains.(a, b)
AG.overlaps(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.overlaps.(a, b)
AG.intersection(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.intersection.(a, b)
AG.union(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.union.(a, b)
AG.difference(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.difference.(a, b)
AG.symdifference(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.symdifference.(a, b)
AG.distance(a::Vector{AG.IGeometry}, b::Vector{AG.IGeometry}) = AG.distance.(a, b)

AG.boundary(v::Vector{AG.IGeometry}) = AG.boundary.(v)
AG.convexhull(v::Vector{AG.IGeometry}) = AG.convexhull.(v)
AG.buffer(v::Vector{AG.IGeometry}, d) = AG.buffer.(v, d)
AG.transform!(v::Vector{AG.IGeometry}, d) = AG.buffer.(v, d)
AG.geomlength(v::Vector{AG.IGeometry}) = AG.geomlength.(v)
AG.geomarea(v::Vector{AG.IGeometry}) = AG.geomarea.(v)
AG.centroid(v::Vector{AG.IGeometry}) = AG.centroid.(v)
AG.isempty(v::Vector{AG.IGeometry}) = AG.isempty.(v)
AG.isvalid(v::Vector{AG.IGeometry}) = AG.isvalid.(v)
AG.issimple(v::Vector{AG.IGeometry}) = AG.issimple.(v)
AG.isring(v::Vector{AG.IGeometry}) = AG.isring.(v)

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
    rename!(df, Dict(Symbol("") => "geom", ))  # needed for now
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

end  # module
