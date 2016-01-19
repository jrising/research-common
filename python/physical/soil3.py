import gzip, csv, math, sys, os, codecs
import datahelp
from bingrid import GlobalBinaryGrid
from feature import StaticFeature

def get_val(filename, index, chkrow, getrow):
    with gzip.open(filename) as f:
        reader = csv.reader(datahelp.astext(f))
        for row in reader:
            if row[chkrow] == index:
                return row[getrow]

def get_dict(filename, chkrow, getrow):
    result = {}
    with gzip.open(filename) as f:
        reader = csv.reader(datahelp.astext(f))
        for row in reader:
            result[row[chkrow]] = row[getrow]

    return result

class HWSDSoil(GlobalBinaryGrid, StaticFeature):
    # Soil Data
    # http://webarchive.iiasa.ac.at/Research/LUC/External-World-soil-database/HTML/HWSD_Data.html?sb=4
    # Reading logic from http://stevendkay.wordpress.com/2010/05/29/parsing-usgs-bil-digital-elevation-models-in-python/

    # from hwsd.hdr
    nrows = 21600
    ncols = 43200
    bytes = 2

    # from hwsd.blw
    #sizex = sizey = 0.00833333333333
    #x0_center = -179.99583333333334
    #y0_center = 89.99583333326137

    # From SOIL.CDE and page 15 of HWSD docs (but correcting 2 and 4 of SOIL.CDE)
    usda_to_dssat = {1: 'C', 2: 'SIC', 3: 'C', 4: 'SICL', 5: 'CL', 6: 'SI', 7: 'SIL', 8: 'SC', 9: 'L', 10: 'SCL', 11: 'SL', 12: 'LS', 13: 'S'}

    def __init__(self):
        hwsd = gzip.open(datahelp.datapath('HWSD_RASTER/hwsd.bil.gz'))
        GlobalBinaryGrid.__init__(self, hwsd, HWSDSoil.nrows, HWSDSoil.ncols, HWSDSoil.bytes, "<h")
        self.soildefs = None
        self.soilnames = None

    def cache_soilinfo(self):
        self.soildefs = {}
        with gzip.open(datahelp.datapath('HWSD/HWSD_DATA.txt.gz')) as f:
            reader = csv.reader(f)
            for row in reader:
                self.soildefs[row[0]] = row

        self.soilnames = {'symbols': get_dict(datahelp.datapath('HWSD/D_SYMBOL85.txt.gz'), 2, 1),
                          'classes': get_dict(datahelp.datapath('HWSD/D_USDA_TEX_CLASS.txt.gz'), 0, 1)}

    def getll(self, latitude, longitude):
        print(latitude, longitude)
        zstr = str(self.getll_raw(latitude, longitude)[0])

        return self.soil_to_vals(zstr)

    def get_ll_plus(self, latitude, longitude, plus=True):
        vals = self.getll(latitude, longitude)
        if plus and vals is None:
            if longitude > -180 + self.sizex:
                vals = self.getll(latitude, longitude - self.sizex)
            if vals is None and longitude < 180 - self.sizex:
                vals = self.getll(latitude, longitude + self.sizex)
            if vals is None and latitude > -90 + self.sizey:
                vals = self.getll(latitude - self.sizey, longitude)
            if vals is None and latitude < 90 - self.sizey:
                vals = self.getll(latitude + self.sizey, longitude)
            if vals is None:
                print("Could not find a neighboring soil")
            else:
                print("Using a neighboring soil")

        return vals

    def get_soilinfo(self, zstr):
        if self.soildefs is None:
            with gzip.open(datahelp.datapath('HWSD/HWSD_DATA.txt.gz')) as f:
                reader = csv.reader(f)
                for row in reader:
                    if row[0] == zstr:
                        return row
        else:
            row = self.soildefs.get(zstr, None)
            if row is not None:
                return row

        print "Soil Error: soil type not found: " + zstr
        return None

    def soil_to_texture(self, zstr):
        row = self.get_soilinfo(zstr)
        if row is None:
            return row

        return dict(top=dict(sand=float(row[24]), silt=float(row[25]), clay=float(row[26]), carb=float(row[30])),
                    bot=dict(sand=float(row[41]), silt=float(row[42]), clay=float(row[43]), carb=float(row[47])))

    def soil_to_vals(self, zstr):
        row = self.get_soilinfo(zstr)
        if row is None:
            return row

        return self.get_properties(row)

    def get_properties(self, row):
        soilsym = row[9]
        topnum = row[27]
        botnum = row[44]
        # Calculations from http://research.eeescience.utoledo.edu/lees/papers_PDF/Saxton_1986_SSSAJ.htm
        # Ksat calculation from http://www.pedosphere.ca/resources/texture/worktable_us.cfm (cm/hr)
        try:
            sat_top = 0.332 + -7.251e-4 * float(row[24]) + 0.1276 * math.log10(float(row[26]))
            fc_top = 0.2576 + -0.0020 * float(row[24]) + 0.0036 * float(row[26]) + 0.0299 * float(row[30])
            wp_top = 0.0260 + 0.0050 * float(row[26]) + 0.0158 * float(row[30])
            ksat_top = 2.778e-6 * math.exp(12.012 - 0.0755 * float(row[24]) + (-3.895 + 0.03671 * float(row[24]) - 0.1103 * float(row[26]) + 8.7546e-4 * float(row[26])*float(row[26])) / sat_top)
            sat_bot = 0.332 + -7.251e-4 * float(row[41]) + 0.1276 * math.log10(float(row[43]))
            fc_bot = 0.2576 + -0.0020 * float(row[41]) + 0.0036 * float(row[43]) + 0.0299 * float(row[47])
            wp_bot = 0.0260 + 0.0050 * float(row[43]) + 0.0158 * float(row[47])
            ksat_bot = 2.778e-6 * math.exp(12.012 - 0.0755 * float(row[41]) + (-3.895 + 0.03671 * float(row[41]) - 0.1103 * float(row[43]) + 8.7546e-4 * float(row[43])*float(row[43])) / sat_bot)
        except NameError as e:
            raise e
        except:
            print("Soil Error:", sys.exc_info())
            return None

        # Sometimes sat_top can be less, so fix this
        sat_top = max(sat_top, fc_top)
        sat_bot = max(sat_bot, fc_bot)

        if self.soilnames is None:
            soilname = get_val(datahelp.datapath('HWSD/D_SYMBOL85.txt.gz'), soilsym, 2, 1)
            topname = get_val(datahelp.datapath('HWSD/D_USDA_TEX_CLASS.txt.gz'), topnum, 0, 1)
            botname = get_val(datahelp.datapath('HWSD/D_USDA_TEX_CLASS.txt.gz'), botnum, 0, 1)
        else:
            soilname = self.soilnames['symbols'].get(soilsym, None)
            topname = self.soilnames['classes'].get(topnum, None)
            botname = self.soilnames['classes'].get(botnum, None)

        return dict(soilname=soilname, top=dict(name=topname, usda=int(topnum), sat=sat_top, ssks=ksat_top, ksat=ksat_top * 864e5, fc=fc_top, wp=wp_top),
                    bot=dict(name=botname, usda=int(botnum), sat=sat_bot, ssks=ksat_bot, ksat=ksat_bot * 864e5, fc=fc_bot, wp=wp_bot))

    # StaticFeature functions
    def getll_features(self, latitude, longitude, callback, cb_extras=None):
        callback(latitude, longitude, self.getll_raw(latitude, longitude)[0], 1, cb_extras)

    # Only do at 9x9 per .25x.25 resolution (even though have better)
    def getrect_features(self, swlat, swlon, nelat, nelon, callback, cb_extra=None):
        self.getrect_features_grid(swlat, swlon, nelat, nelon, .25/3, .25/3, callback, cb_extra)

class WiseSoil:
    def __init__(self, solpath):
        soils = {}

        with open(solpath) as solfp:
            solid = None
            line2 = None
            for line in solfp:
                if line[0] == '*':
                    solid = line[1:11]
                elif solid and line2 is None:
                    line2 = line
                elif solid and line2:
                    soils[solid] = (float(line[25:33]), float(line[34:42]))
                    solid = None
                    line2 = None

        self.soils = soils

    def nearest_within(self, rect, latitude, longitude):
        nearest = None
        neardist = None
        for solid in self.soils:
            if rect.contains(self.soils[solid][0], self.soils[solid][1]):
                dist = math.sqrt((self.soils[solid][0] - latitude)**2 + (self.soils[solid][1] - longitude)**2)
                if nearest is None or dist < neardist:
                    nearest = solid
                    neardist = dist

        return nearest

    def nearest_info(self, latitude, longitude):
        nearest = None
        neardist = None
        for solid in self.soils:
            dist = math.sqrt((self.soils[solid][0] - latitude)**2 + (self.soils[solid][1] - longitude)**2)
            if nearest is None or dist < neardist:
                nearest = (solid, dist, self.soils[solid])
                neardist = dist

        return nearest

class HWSDPreprocessedSoil:
    def __init__(self, soilpath, x0_corner, y0_corner, sizex, sizey):
        rows = []
        with open(soilpath) as fp:
            reader = csv.reader(fp, delimiter=',')
            for row in reader:
                rows.append(row)

        self.rows = rows
        self.x0_corner = x0_corner
        self.y0_corner = y0_corner
        self.sizex = sizex
        self.sizey = sizey
        self.cached = {}

    def getll(self, latitude, longitude):
        row = int(math.floor((self.y0_corner - latitude) / self.sizey))
        col = int(math.floor((longitude - self.x0_corner) / self.sizex))

        soil = self.rows[row][col]
        vals = self.cached.get(soil, False)
        if vals is not False:
            return vals

        vals = HWSDSoil.soil_to_vals(soil)
        self.cached[soil] = vals
        return vals

    def getij_raw(self, row, col):
        return self.rows[row][col]

if __name__ == "__main__":
    soil = WiseSoil("../data/wise/WI.SOL")

