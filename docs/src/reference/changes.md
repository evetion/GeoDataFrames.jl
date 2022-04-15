```@meta
CurrentModule = GeoDataFrames
```

# Changelog

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
