var documenterSearchIndex = {"docs":
[{"location":"tutorials/ops/#Operations","page":"Operations","title":"Operations","text":"","category":"section"},{"location":"tutorials/ops/","page":"Operations","title":"Operations","text":"Most operations here are the ArchGDAL operations that are exported again to work on Vectors of geometries as well. Like buffer below, it just calls buffer.(df.geom), note the dot. Hence, if you can't find your preferred ArchGDAL operations, you can still apply them yourself.","category":"page"},{"location":"tutorials/ops/#Geometric-operations","page":"Operations","title":"Geometric operations","text":"","category":"section"},{"location":"tutorials/ops/","page":"Operations","title":"Operations","text":"df.geom = buffer(df.geom, 10);  # points turn into polygons\ndf\n10×2 DataFrame\n Row │ geom                  name\n     │ IGeometr…             String\n─────┼──────────────────────────────\n   1 │ Geometry: wkbPolygon  test\n   2 │ Geometry: wkbPolygon  test\n   3 │ Geometry: wkbPolygon  test\n   4 │ Geometry: wkbPolygon  test\n   5 │ Geometry: wkbPolygon  test\n   6 │ Geometry: wkbPolygon  test\n   7 │ Geometry: wkbPolygon  test\n   8 │ Geometry: wkbPolygon  test\n   9 │ Geometry: wkbPolygon  test\n  10 │ Geometry: wkbPolygon  test","category":"page"},{"location":"tutorials/ops/#Reprojection","page":"Operations","title":"Reprojection","text":"","category":"section"},{"location":"tutorials/ops/","page":"Operations","title":"Operations","text":"import GeoFormatTypes as GFT\ndf.geom = reproject(df.geom, GFT.EPSG(4326), GFT.EPSG(28992))\n10-element Vector{ArchGDAL.IGeometry{ArchGDAL.wkbPolygon}}:\n Geometry: POLYGON ((-472026.042542408 -4406233.59953401,-537 ... 401))\n Geometry: POLYGON ((-417143.506054105 -4395423.99277048,-482 ... 048))\n Geometry: POLYGON ((-450303.142569437 -4301418.89063867,-515 ... 867))\n Geometry: POLYGON ((-434522.645535154 -4351075.81124634,-500 ... 634))\n Geometry: POLYGON ((-443909.665585927 -4412565.43193349,-509 ... 349))\n Geometry: POLYGON ((-438405.666500747 -4299366.23767677,-503 ... 677))\n Geometry: POLYGON ((-400588.951193713 -4365333.532287,-46626 ... 287))\n Geometry: POLYGON ((-409160.489179734 -4388484.98554538,-474 ... 538))\n Geometry: POLYGON ((-453963.150526169 -4408927.89965336,-519 ... 336))\n Geometry: POLYGON ((-498317.413693272 -4321687.31588764,-563 ... 764))","category":"page"},{"location":"tutorials/ops/#Plotting","page":"Operations","title":"Plotting","text":"","category":"section"},{"location":"tutorials/ops/","page":"Operations","title":"Operations","text":"using Plots\nplot(df.geom)","category":"page"},{"location":"tutorials/ops/","page":"Operations","title":"Operations","text":"(Image: image)","category":"page"},{"location":"tutorials/usage/#Usage","page":"Usage","title":"Usage","text":"","category":"section"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"Unlike geopandas, there's no special type here. You just use normal DataFrames and with a Vector of ArchGDAL geometries as a column.","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"using DataFrames\n\ncoords = zip(rand(10), rand(10))\ndf = DataFrame(geom=createpoint.(coords), name=\"test\");","category":"page"},{"location":"tutorials/usage/#Reading","page":"Usage","title":"Reading","text":"","category":"section"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"Reading into a DataFrame is done by the read function. It simply takes a filename.","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"import GeoDataFrames as GDF\ndf = GDF.read(\"test_points.shp\")\n10×2 DataFrame\n Row │ geom                name\n     │ IGeometr…           String\n─────┼────────────────────────────\n   1 │ Geometry: wkbPoint  test\n   2 │ Geometry: wkbPoint  test\n   3 │ Geometry: wkbPoint  test\n   4 │ Geometry: wkbPoint  test\n   5 │ Geometry: wkbPoint  test\n   6 │ Geometry: wkbPoint  test\n   7 │ Geometry: wkbPoint  test\n   8 │ Geometry: wkbPoint  test\n   9 │ Geometry: wkbPoint  test\n  10 │ Geometry: wkbPoint  test","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"You can also specify the layer index or layer name in opening, useful if there are multiple layers:","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"GDF.read(\"test_points.shp\", 0)\nGDF.read(\"test_points.shp\", \"test_points\")","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"Any keywords arguments are passed on to the underlying ArchGDAL read function:","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"GDF.read(\"test.csv\", options=[\"GEOM_POSSIBLE_NAMES=point,linestring\", \"KEEP_GEOM_COLUMNS=NO\"])","category":"page"},{"location":"tutorials/usage/#Writing","page":"Usage","title":"Writing","text":"","category":"section"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"Writing works by passing a filename and a DataFrame with a geometry column to the write function. The name of the column should be :geom, but can be set at write time by the keyword option geom_column.","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"using DataFrames\n\ncoords = zip(rand(10), rand(10))\ndf = DataFrame(geom=createpoint.(coords), name=\"test\");\nGDF.write(\"test_points.shp\", df)","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"You can also set options such as the layer_name, coordinate reference system.","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"import GeoFormatTypes as GFT\nGDF.write(\"test_points.shp\", df; layer_name=\"data\", crs=GFT.EPSG(4326))","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"The most common file extensions are recognized, but you can override this or write uncommon files by setting the driver option. See here for a list of (short) driver names.","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"GDF.write(\"test_points.fgb\", df; driver=\"FlatGeobuf\", options=Dict(\"SPATIAL_INDEX\"=>\"YES\"))","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"The following extensions are automatically recognized:","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"    \".shp\" => \"ESRI Shapefile\"\n    \".gpkg\" => \"GPKG\"\n    \".geojson\" => \"GeoJSON\"\n    \".vrt\" => \"VRT\"\n    \".csv\" => \"CSV\"\n    \".fgb\" => \"FlatGeobuf\"\n    \".gml\" => \"GML\"\n    \".nc\" => \"netCDF\"","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"Note that any Tables.jl compatible table with GeoInterface.jl compatible geometries can be written by GeoDataFrames. You might want to pass which column(s) contain geometries, or by defining GeoInterface.geometrycolumns on your table. Multiple geometry columns, when enabled by the driver, can be provided in this way.","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"table = [(; geom=AG.createpoint(1.0, 2.0), name=\"test\")]\nGDF.write(tfn, table; geom_columns=(:geom),)","category":"page"},{"location":"tutorials/usage/","page":"Usage","title":"Usage","text":"Toggle all file notes Toggle all file annotations","category":"page"},{"location":"background/todo/#TODO","page":"Future plans","title":"TODO","text":"","category":"section"},{"location":"background/todo/","page":"Future plans","title":"Future plans","text":"[ ] Prepared geometry, spatial indices (LibGEOS) (probably can't be done as GDAL OGR is not directly compatible)\n[ ] IGeometry should be IGeometry{WKBType} for easy Schema detection, fix upstream\n[ ] Empty geom column name fix should be moved upstream\n[ ] More drivers selected on extension\n[ ] CRS stored in metadata\n[ ] Work on Geointerface integration\n[ ] Work on spatial joins/filters\n[x] Override showing of WKT geometry on print for performance","category":"page"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"CurrentModule = GeoDataFrames","category":"page"},{"location":"reference/changes/#Changelog","page":"Changelog","title":"Changelog","text":"","category":"section"},{"location":"reference/changes/#v0.2.1","page":"Changelog","title":"v0.2.1","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"Don't export isempty as it clashes with other exports\nCompatability with ArchGDAL v0.8 (adds missing support when reading 🎉)","category":"page"},{"location":"reference/changes/#v0.2.0","page":"Changelog","title":"v0.2.0","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"[breaking] Changed default CRS to nothing instead of WGS84.\nUsers can provide a GDAL driver when writing.","category":"page"},{"location":"reference/changes/#v0.1.6","page":"Changelog","title":"v0.1.6","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"Add support for (U)Int8,UInt16,UInt32 datatypes","category":"page"},{"location":"reference/changes/#v0.1.5","page":"Changelog","title":"v0.1.5","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"Compatability with ArchGDAL v0.7","category":"page"},{"location":"reference/changes/#v0.1.4","page":"Changelog","title":"v0.1.4","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"read now accepts layer keyword\nEnables writing of missing data","category":"page"},{"location":"reference/changes/#v0.1.3","page":"Changelog","title":"v0.1.3","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"Forwards kwargs in the read function to ArchGDAL","category":"page"},{"location":"reference/changes/#v0.1.2","page":"Changelog","title":"v0.1.2","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"Changed write to have keyword arguments","category":"page"},{"location":"reference/changes/#v0.1.1","page":"Changelog","title":"v0.1.1","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"Small internal fixes","category":"page"},{"location":"reference/changes/#v0.1.0","page":"Changelog","title":"v0.1.0","text":"","category":"section"},{"location":"reference/changes/","page":"Changelog","title":"Changelog","text":"First release 🎉","category":"page"},{"location":"reference/api/#API","page":"API","title":"API","text":"","category":"section"},{"location":"reference/api/","page":"API","title":"API","text":"Modules = [GeoDataFrames]\nOrder   = [:function, :type]\nPublic = false","category":"page"},{"location":"reference/api/#GeoDataFrames.read-Tuple{AbstractString}","page":"API","title":"GeoDataFrames.read","text":"read(fn::AbstractString; kwargs...)\nread(fn::AbstractString, layer::Union{Integer,AbstractString}; kwargs...)\n\nRead a file into a DataFrame. Any kwargs are passed onto ArchGDAL here. By default you only get the first layer, unless you specify either the index (0 based) or name (string) of the layer.\n\n\n\n\n\n","category":"method"},{"location":"reference/api/#GeoDataFrames.write-Tuple{AbstractString, Any}","page":"API","title":"GeoDataFrames.write","text":"write(fn::AbstractString, table; layer_name=\"data\", geom_column=:geometry, crs::Union{GFT.GeoFormat,Nothing}=nothing, driver::Union{Nothing,AbstractString}=nothing, options::Vector{AbstractString}=[], geom_columns::Set{Symbol}=(:geometry))\n\nWrite the provided table to fn. The geom_column is expected to hold ArchGDAL geometries.\n\n\n\n\n\n","category":"method"},{"location":"","page":"Home","title":"Home","text":"CurrentModule = GeoDataFrames","category":"page"},{"location":"#GeoDataFrames","page":"Home","title":"GeoDataFrames","text":"","category":"section"},{"location":"","page":"Home","title":"Home","text":"(Image: Stable) (Image: Dev) (Image: Build Status)","category":"page"},{"location":"","page":"Home","title":"Home","text":"Simple geographical vector interaction built on top of ArchGDAL. Inspiration from geopandas.","category":"page"},{"location":"tutorials/installation/#Installation","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"Simply do","category":"page"},{"location":"tutorials/installation/#Installation-2","page":"Installation","title":"Installation","text":"","category":"section"},{"location":"tutorials/installation/","page":"Installation","title":"Installation","text":"]add GeoDataFrames","category":"page"},{"location":"background/geopandas/#Inspiration","page":"Motivation","title":"Inspiration","text":"","category":"section"},{"location":"background/geopandas/","page":"Motivation","title":"Motivation","text":"This package has been inspired by geopandas, the Python package that makes working with geospatial data formats easy. In Julia, while the same functionality is supported by ArchGDAL, reading and writing geospatial vector data is not straightforward and many questions were raised. This package wraps the required ArchGDAL operations into several oneliners.","category":"page"},{"location":"background/geopandas/","page":"Motivation","title":"Motivation","text":"Also see the package announcement at the Julia discourse.","category":"page"}]
}
