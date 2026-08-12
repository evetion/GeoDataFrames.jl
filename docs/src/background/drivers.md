# Driver selection

GeoDataFrames selects an I/O driver from a filename extension. Importing a
native format package activates its extension, so the same `read` or `write`
call can dispatch to that package's native implementation in the current
session. Without an active native extension, automatic selection uses
ArchGDAL.

`ArchGDALDriver()` remains available as an explicit fallback. Select it when a
native extension is unavailable or when an ArchGDAL/GDAL workflow is required,
even if a native package has been imported.

Each native package owns its read and write interface. Its keyword arguments
may differ in name, meaning, and availability from ArchGDAL's and from those
of other native packages. GeoDataFrames therefore delegates those keywords
rather than presenting an unsafe unified keyword vocabulary.

For the selection procedure, see [use a native
driver](../how-to/use-native-drivers.md). The [native-driver
reference](../reference/native-drivers.md) lists available extensions, and
the [ArchGDAL reference](../reference/archgdal.md) describes the fallback
driver.
