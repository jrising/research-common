import math, csv
import numpy as np

class SpatialGrid(object):
    def __init__(self, x0_corner, y0_corner, sizex, sizey, ncols, nrows):
        self.y0_corner = y0_corner
        self.x0_corner = x0_corner
        self.sizex = sizex
        self.sizey = sizey
        self.ncols = ncols
        self.nrows = nrows

    def get_config(self):
        return [self.x0_corner, self.y0_corner, self.sizex, self.sizey, self.ncols, self.nrows]
        
    def rowcol(self, latitude, longitude):
        row = int(math.floor((self.y0_corner - latitude) / self.sizey))
        col = int(math.floor((longitude - self.x0_corner) / self.sizex))
        return (row, col)

    def getll_raw(self, latitude, longitude):
        raise NotImplementedError()

    def get_longitudes(self):
        return np.arange(self.x0_corner + self.sizex / 2, self.x0_corner + self.sizex * self.ncols,
                         step=self.sizex)

    def get_latitudes(self):
        return np.arange(self.y0_corner + self.sizey * self.nrows, self.y0_corner + self.sizey / 2,
                         step=-self.sizey)
    
class NumpyGrid(SpatialGrid):
    def __init__(self, array, x0_corner, y0_corner, sizex, sizey, ncols, nrows):
        super(NumpyGrid, self).__init__(x0_corner, y0_corner, sizex, sizey, ncols, nrows)

        self.array = array

    @staticmethod
    def from_regular_axes(array, latitude, longitude):
        return NumpyGrid(array, min(longitude), max(latitude), abs(np.mean(np.diff(longitude))),
                         -abs(np.mean(np.diff(latitude))), array.shape[1], array.shape[0])
        
    def getll_raw(self, latitude, longitude):
        row = int(math.floor((self.y0_corner - latitude) / self.sizey))
        col = int(math.floor((longitude - self.x0_corner) / self.sizex))

        return self.array[row, col]

    @staticmethod
    def convert(grid, nvals, agfactor=1):
        lons = grid.get_longitudes()
        lats = grid.get_latitudes()
        
        array = np.zeros((len(lats), len(lons), nvals))
        for ii in np.arange(agfactor / 2, len(lons), agfactor):
            for jj in np.arange(agfactor / 2, len(lats), agfactor):
                array[jj, ii, :] = grid.getll_raw(lats[jj], lons[ii])
                
        return NumpyGrid(array, grid.x0_corner, grid.y0_corner, grid.sizex * agfactor, grid.sizey * agfactor, grid.ncols / agfactor, grid.nrows / agfactor)

class DelimitedSpatialGrid(SpatialGrid):
    def __init__(self, fp, x0_corner, y0_corner, sizex, sizey, ncols, nrows, delimiter):
        """Note that delimiter can be None, in which case multiple whitespace characters are the delimiter."""
        super(DelimitedSpatialGrid, self).__init__(x0_corner, y0_corner, sizex, sizey, ncols, nrows)

        if isinstance(fp, np.ndarray):
            self.values = values
        else:
            values = []
            for line in fp:
                values.append(map(float, line.split(delimiter)))

            self.values = np.array(values)

    def getll_raw(self, latitude, longitude):
        row, col = self.rowcol(latitude, longitude)
        if row >= self.values.shape[0] or col >= self.values.shape[1]:
            return np.nan
        return self.values[row, col]

    @staticmethod
    def write(grid, fp, delimiter, nodataval):
        """Write to the file pointer `fp`."""
        writer = csv.writer(fp, delimiter=delimiter)
        for latitude in grid.get_latitudes()[::-1]:
            row = []
            for longitude in grid.get_longitudes():
                value = grid.getll_raw(latitude, longitude)
                if np.isnan(value):
                    row.append(nodataval)
                else:
                    row.append(value)

            writer.writerow(row)
        
class AsciiSpatialGrid(DelimitedSpatialGrid):
    def __init__(self, fp, delimiter):
        count = 0
        for line in fp:
            vals = line.split(delimiter)
            if vals[0] == 'ncols':
                ncols = int(vals[1])
            if vals[0] == 'nrows':
                nrows = int(vals[1])
            if vals[0] == 'xllcorner':
                xllcorner = float(vals[1])
            if vals[0] == 'yllcorner':
                yllcorner = float(vals[1])
            if vals[0] == 'cellsize':
                cellsize = float(vals[1])
            if vals[0] == 'NODATA_value':
                nodata = float(vals[1])
            count += 1
            if count == 6:
                break

        super(AsciiSpatialGrid, self).__init__(fp, xllcorner, yllcorner, cellsize, cellsize, ncols, nrows, delimiter)
        self.values[self.values == nodata] = np.nan

    @staticmethod
    def write(grid, fp, nodataval):
        """Write to the file pointer `fp`."""
        fp.write("ncols\t%d\n" % grid.ncols)
        fp.write("nrows\t%d\n" % grid.nrows)
        
        fp.write("xllcorner\t%f\n" % grid.x0_corner)
        if grid.sizey < 0:
            fp.write("yllcorner\t%f\n" % (grid.y0_corner + grid.sizey * grid.nrows))
        else:
            fp.write("yllcorner\t%f\n" % grid.y0_corner)

        assert np.abs(grid.sizex) == np.abs(grid.sizey)
        fp.write("cellsize\t%f\n" % grid.sizex)
        fp.write("NODATA_value\t%f\n" % nodataval)

        DelimitedSpatialGrid.write(grid, fp, ' ', nodataval)
