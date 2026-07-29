# CSV Extension Design

**Goal:** Read local CSV files through CSV.jl when it is loaded, while preserving GeoDataFrames metadata and GDAL-compatible implicit WKT detection.

## Scope

The package will add a `CSVDriver` and a `GeoDataFramesCSVExt` extension. Local paths ending in `.csv` will select `CSVDriver`. When CSV.jl is not loaded, the existing generic-driver fallback will continue to read the file through ArchGDAL.

Loading CSV.jl will activate the extension. The extension will pass its keyword arguments to `CSV.read` and return a `DataFrame`.

## Geometry detection

GDAL's CSV driver implicitly recognizes a column named `WKT`. The extension will implement the same default rule:

- A column named exactly `WKT` is converted from non-missing strings to `GeoFormatTypes.WellKnownText{Geom}` values.
- The result records `(:WKT,)` as its geometry columns and `nothing` as its CRS.
- CSV files without that column record empty geometry columns and a `nothing` CRS.

`WellKnownGeometry` will be a regular dependency. It supplies the GeoInterface implementation that makes the wrapped WKT values usable as geometries without requiring callers to load an additional package.

GDAL's configurable geometry discovery, such as `GEOM_POSSIBLE_NAMES` and coordinate-column options, remains available through an explicit `ArchGDALDriver`. The CSV extension will not reinterpret GDAL's `options` keyword.

## Metadata

The extension will write both GeoInterface metadata keys and their compatibility aliases:

- `"GEOINTERFACE:crs"` and `"crs"` contain `nothing`.
- `"GEOINTERFACE:geometrycolumns"` and `"geometrycolumns"` contain either `(:WKT,)` or `()`.

This makes the returned DataFrame immediately usable with GeoDataFrames' geometry and CRS utilities.

## Validation

Tests will load CSV.jl and verify driver selection, CSV keyword forwarding, WKT conversion, missing WKT handling, geometry metadata, and empty metadata for a non-spatial CSV. Existing ArchGDAL behavior remains covered by current tests and stays available through an explicit driver.
