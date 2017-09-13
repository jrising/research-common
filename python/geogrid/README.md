# GeoGrid: Physical gridded data handling in python

GeoGrid provides a common interface and the code needed to read a
variety of data formats used in physical gridded data research.  It
contains the following classes:

 - `SpatialGrid`: The parent class for all gridded data, defining the
   common interface.

 - `NumpyGrid`: A version of `SpatialGrid` where the data is stored in
   a numpy array.

 - `DelimitedSpatialGrid`: For reading data from CSV and TSV files.

 - `AsciiSpatialGrid`: For reading data from `.asc` files, which
   define their spatial scale at the top of the file.

 - `BinaryGrid`: For reading data stored in simple binary format, as
   used in `.bil` files (for these, use the subclass `BilBinaryGrid`).

 - `BilBinaryGrid`: For reading binary `.bil` files, which are
   packaged with `.blw` and/or `.hdr` files that define the spatial
   scale of the data.

 - `GlobalBinaryGrid`: For reading binary files without the associated
   spatial extend data, but for which the extent is known to be global.

 - `GeotiffGrid`: For reading GeoTIFF files.

The common interface defines the following properties:

 - `y0_corner`: the y-axis or latitude location of the corner of the
   top-most (if `sizey` is positive) or bottom-most row of the grid.

 - `x0_corner`: the x-axis or longitude location of the corner of the
   left-most column of the grid.

 - `sizex` and `sizey`: The width and height of each grid cell.

 - `ncols` and `nrows`: The number of columns and rows in the grid.

And the following functions:

 - `rowcol(latitude, longitude)`: Returns the row and column number of
   the given continuous latitude, longitude (or y, x) point.

 - `get_longitudes()`: Returns a numpy array of all the longitude (or
   x) coordinates of the centers of grid cells, starting with the
   left-most.

 - `get_latitudes()`: Returns a numpy array of all the latitude (or y)
   coordinates of the centers of the grid cells, starting with the
   top-most (if `sizey` is positive) or bottom-most row.

 - `getll_raw(latitude, longitude)`: Return the raw value at a given
   latitude, longitude (or y, x) location.
   