import gdal
from spacegrid import SpatialGrid

class GeotiffGrid(SpatialGrid):
    def __init__(self, filepath):
        ds = gdal.Open(filepath)
        x0_corner, sizex, zero1, y0_corner, zero2, sizey = ds.GetGeoTransform()
        band = ds.GetRasterBand(1)
        array = band.ReadAsArray()

        self.array = array
        super(BinaryGrid, self).__init__(x0_corner, y0_corner, sizex, sizey, array.shape[2], array.shape[1])

    def getll_raw(self, latitude, longitude):
        return self.array[self.rowcol(latitude, longitude)]
