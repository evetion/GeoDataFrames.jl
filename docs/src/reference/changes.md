```@meta
CurrentModule = GeoDataFrames
```

# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## v0.4.0

## Added
- Updated documentation, now using VitePress.
- Add new driver framework to read files using native drivers.
- Added native driver package extensions on GeoJSON, ShapeFile, GeoParquet, GeoArrow and FlatGeobuf.
- Geometry columns are now wrapped in a GeometryVector, allowing for future improvements.

### Changed
- Now exports GeometryOps and GeoInterface methods instead of ArchGDAL methods for geometry operation.
- The `geom_columns` keyword for `write` is now `geometrycolumn`, and also accepts a single Symbol.

### Removed
- Removed automatic broadcast implementations of operations like buffer.

## v0.3.13
- Support updating/appending to existing files, by specifying `update=true` in the `write` function.

## v0.3.12
- Add `always_xy` keyword to `reproject`.

## v0.3.11
- Changed `reproject` to work on a DataFrame, correctly setting the (crs) metadata
- Handle empty layers
- Re-export GeoFormatTypes and Extents, making things like `CRS` and `Extent` available
- Warn on possible geometry column instead of throwing an error.
- Improve error message when file is not found.

## v0.3.10
- Changed DataFrame metadata style to `:note`, preserving crs after DataFrame operations.

## v0.3.9
- Implemented GeoInterface methods on DataFrame(Rows).
- Implements transaction support on writing, notably improving writing performance.

## v0.3.8
- Retrieve CRS from layer, instead of dataset, preventing some `nothing` crs.

## v0.3.7
- Correctly write 3d geometries (which were previously flattened to 2d).

## v0.3.6
- Use GDAL to identify drivers, instead of relying only on file extension.

## v0.3.5
- Drop support for ArchGDAL 0.9.

## v0.3.4
- Use GeoInterface to convert geometries.

## v0.3.3
- Update to ArchGDAL 0.10
- Change default geometry column name to `geometry` (was `geom`).

## v0.3.2
- Use metadata to store/retrieve CRS and geometry column information.

## v0.3.1
- Error out early on non existent files.

## v0.3.0
- Change `geom_column` to `geom_columns`, defaulting to using GeoInterface.jl.
- Added options keyword to pass configuration to the GDAL driver.
- Allow any GeoInterface.jl compatible geometry to be written (was only ArchGDAL geometries).

## v0.2.4
- Upgrade GeoFormatTypes to v0.4


## v0.2.3
- Update ArchGDAL compat to v0.9

## v0.2.2
- Expanded documentation
- Free GDAL structures as soon as possible

## v0.2.1
- Don't export `isempty` as it clashes with other exports
- Compatability with ArchGDAL v0.8 (adds missing support when reading 🎉)

## v0.2.0
- [breaking] Changed default CRS to `nothing` instead of WGS84.
- Users can provide a GDAL driver when writing.

## v0.1.6
- Add support for (U)Int8,UInt16,UInt32 datatypes

## v0.1.5
- Compatability with ArchGDAL v0.7

## v0.1.4
- [`read`](@ref) now accepts layer keyword
- Enables writing of missing data

## v0.1.3
- Forwards kwargs in the [`read`](@ref) function to ArchGDAL

## v0.1.2
- Changed [`write`](@ref) to have keyword arguments

## v0.1.1
- Small internal fixes

## v0.1.0
- First release 🎉
