module GeoDataFramesCSVExt

using CSV
using WellKnownGeometry
using WellKnownGeometry: getwkt
using GeoDataFrames: CSVDriver, GeoDataFrames

as_wkt(value) = ismissing(value) ? missing : getwkt(value).val

function GeoDataFrames.read(::CSVDriver, fname::AbstractString; stringtype=String, kwargs...)
    df = CSV.read(fname, GeoDataFrames.DataFrame; stringtype, kwargs...)
    geometrycolumns = if :WKT in propertynames(df)
        df[!, :WKT] = Vector(map(df[!, :WKT]) do value
            ismissing(value) ? missing :
            GeoDataFrames.GFT.WellKnownText(GeoDataFrames.GFT.Geom(), String(value))
        end)
        (:WKT,)
    else
        ()
    end

    GeoDataFrames.metadata!(df, "GEOINTERFACE:crs", nothing; style=:note)
    GeoDataFrames.metadata!(
        df,
        "GEOINTERFACE:geometrycolumns",
        geometrycolumns;
        style=:note,
    )
    return df
end

function GeoDataFrames.write(
    ::CSVDriver,
    fname::AbstractString,
    table;
    geometrycolumn=GeoDataFrames.getgeometrycolumns(table),
    kwargs...,
)
    geometrycolumns = GeoDataFrames.geometry_columns(geometrycolumn)
    df = GeoDataFrames.DataFrame(table; copycols=false)

    for column in geometrycolumns
        column in propertynames(df) || throw(
            ArgumentError("geometrycolumn $column is not a column of the table."),
        )
        df[!, column] = map(as_wkt, df[!, column])
    end

    CSV.write(fname, df; kwargs...)
    return fname
end

end
