from spacegrid import SpatialGrid
import struct, math, os
    
class BinaryGrid(SpatialGrid):
    def __init__(self, fp, x0_corner, y0_corner, sizex, sizey, ncols, nrows, bytes, fmt):
        super(BinaryGrid, self).__init__(x0_corner, y0_corner, sizex, sizey, ncols, nrows)

        self.fp = fp
        self.bytes = bytes
        self.fmt = fmt

        assert struct.calcsize(fmt) == bytes, "Format does not match byte count"

        seeked = False
        try:
            # Check file size
            fp.seek(0, 2)
            seeked = True
        except:
            # Seek from end not supported
            pass

        if seeked:
            assert fp.tell() == self.ncols * self.nrows * self.bytes, "File size does not match map size"

    def __del__(self):
        self.fp.close()

    def getll_raw(self, latitude, longitude):
        row = int(math.floor((self.y0_corner - latitude) / self.sizey))
        col = int(math.floor((longitude - self.x0_corner) / self.sizex))

        self.fp.seek((row*self.ncols + col)*self.bytes)
        value = self.fp.read(self.bytes)

        # unpack binary data into a flat tuple z
        if value == '':
            return float('nan')
        z = struct.unpack(self.fmt, value)

        return z[0]

class BilBinaryGrid(BinaryGrid):
    def __init__(self, bilfp, prefix, flipy=True):
        if os.path.exists(os.path.join(prefix + ".blw")):
            with open(os.path.join(prefix + ".blw")) as blwfp:
                sizex = float(blwfp.next().strip())
                rot1 = float(blwfp.next().strip())
                rot2 = float(blwfp.next().strip())
                sizey = float(blwfp.next().strip())
                upperleft_x = float(blwfp.next().strip())
                upperleft_y = float(blwfp.next().strip())

                assert rot1 == 0 and rot2 == 0, "Rotations are not supported"
                assert sizey < 0, "Latitude steps currently must be negative"

        with open(os.path.join(prefix + ".hdr")) as hdrfp:
            for line in hdrfp:
                vals = line.split()
                if len(vals) < 2:
                    continue

                if vals[0] == 'BYTEORDER':
                    byteorder = vals[1]
                if vals[0] == 'LAYOUT':
                    layout = vals[1]
                if vals[0] == 'NROWS':
                    nrows = int(vals[1])
                if vals[0] == 'NCOLS':
                    ncols = int(vals[1])
                if vals[0] == 'NBANDS':
                    nbands = int(vals[1])
                if vals[0] == 'NBITS':
                    nbits = int(vals[1])
                if vals[0] == 'BANDROWBYTES':
                    bandrowbytes = int(vals[1])
                if vals[0] == 'TOTALROWBYTES':
                    totalrowbytes = int(vals[1])
                if vals[0] == 'BANDGAPBYTES':
                    bandgapbytes = int(vals[1])
                if vals[0] == 'XDIM':
                    sizex = float(vals[1])
                if vals[0] == 'YDIM':
                    sizey = float(vals[1])
                if vals[0] == 'ULXMAP':
                    upperleft_x = float(vals[1])
                if vals[0] == 'ULYMAP':
                    upperleft_y = float(vals[1])

            assert layout == 'BIL', "Only the BIL format is supported."
            assert nbands == 1, "Only single band files are supported."
            assert nbits == 32 or nbits == 16, "Only 16- or 32-bit value files are supported."

            if byteorder == 'M':
                fmt = '>' + ('i' if nbits == 32 else 'h')
            else:
                fmt = '<' + ('i' if nbits == 32 else 'h')

        if flipy:
            sizey = -sizey

        super(BilBinaryGrid, self).__init__(bilfp, upperleft_x, upperleft_y, sizex, sizey, ncols, nrows, nbits / 8, fmt)


class GlobalBinaryGrid(BinaryGrid):
    def __init__(self, fp, nrows, ncols, bytes, fmt, uneven_cells=False):
        sizex = 360.0 / ncols
        sizey = 180.0 / nrows
        if not uneven_cells:
            assert ncols > nrows, "Fewer columns than rows, without uneven_cells set."

        super(GlobalBinaryGrid, self).__init__(fp, -180, 90, sizex, sizey, ncols, nrows, bytes, fmt)
