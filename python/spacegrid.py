class SpatialGrid(object):
    def __init__(self, x0_corner, y0_corner, sizex, sizey, ncols, nrows):
        self.y0_corner = y0_corner
        self.x0_corner = x0_corner
        self.sizex = sizex
        self.sizey = sizey
        self.ncols = ncols
        self.nrows = nrows

    def rowcol(self, latitude, longitude):
        row = int(math.floor((self.y0_corner - latitude) / self.sizey))
        col = int(math.floor((longitude - self.x0_corner) / self.sizex))
        return (row, col)
    
    def getll_raw(self, latitude, longitude):
        raise NotImplementedError()

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
        return values[row, col]
