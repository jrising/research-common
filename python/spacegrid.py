import numpy as np
import math

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

class DelimitedSpatialGrid(SpatialGrid):
    def __init__(self, fp, x0_corner, y0_corner, sizex, sizey, ncols, nrows, delimiter):
        """Note that delimiter can be None, in which case multiple whitespace characters are the delimiter."""
        super(DelimitedSpatialGrid, self).__init__(x0_corner, y0_corner, sizex, sizey, ncols, nrows)
        
        values = []
        for line in fp:
            values.append(map(float, line.split(delimiter)))

        self.values = np.array(values)

    def getll_raw(self, latitude, longitude):
        row, col = self.rowcol(latitude, longitude)
        if row >= self.values.shape[0] or col >= self.values.shape[1]:
            return np.nan
        return self.values[row, col]

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
