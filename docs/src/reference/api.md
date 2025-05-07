# API

```@meta
CurrentModule = GeoDataFrames
```

```@docs
read
write
```

## Drivers

The following drivers are provided:

```@docs
GeoJSONDriver
ShapefileDriver
GeoParquetDriver
FlatGeobufDriver
ArchGDALDriver
GeoArrowDriver
```

These can be passed to the [`read`](@ref) and [`write`](@ref) functions as the first argument, but require the corresponding package to be loaded.
You can find the corresponding package to load in the [package extensions](#package-extensions) section.
