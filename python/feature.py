## MODIFIED from agmodels

import csv, os, math

class StaticFeature:
    def feature_set_country(self, country_name):
        pass

    # Calls callback with (latitude, longitude, feature, weight, cb_extra)
    def getll_features(self, latitude, longitude, callback, cb_extra=None):
        pass

    def getrect_features(self, swlat, swlon, nelat, nelon, callback, cb_extra=None):
        pass

    def getrect_features_grid(self, swlat, swlon, nelat, nelon, sizex, sizey, callback, cb_extra=None):
        if nelat - swlat < sizey:
            lats = [(nelat + swlat) / 2]
        else:
            #lats = StaticFeature.drange(swlat + sizey/2, nelat, sizey)
            lats = StaticFeature.drange(nelat - sizey/2, swlat, -sizey)
        lats = list(lats)

        if nelon - swlon < sizex:
            lons = [(nelon + swlon) / 2]
        else:
            lons = StaticFeature.drange(swlon + sizex/2, nelon, sizex)
        lons = list(lons)

        for lat in lats: # Go backwards to optimize seeking
            for lon in lons:
                self.getll_features(lat, lon, callback, cb_extra)

    ### Take a full list of .25x.25 grid cell centers from countries.country_points()
    def country_loop(self, resfile, feature_name, weight_name):
        done = [] # countries included
        if os.path.exists(resfile):
            with open(resfile, "r") as resfp:
                reader = csv.reader(resfp)
                for row in reader:
                    if row[0] not in done:
                        done.append(row[0])

        with open(resfile, "a") as resfp:
            resfp.write("country,%s,%s,swlat,swlon,nelat,nelon,latitude,longitude\n" % (feature_name, weight_name))

        country_points = countries.country_points()

        for country in country_points:
            if country in done:
                continue

            self.feature_set_country(country)

            infos = {}
            points = country_points[country]['latlons']
            for pp in range(len(points)):
                print country, pp

                latitude = points[pp][0]
                longitude = points[pp][1]

                swlat = latitude - .25/2
                swlon = longitude - .25/2
                nelat = latitude + .25/2
                nelon = longitude + .25/2

                self.getrect_features(swlat, swlon, nelat, nelon, StaticFeature.append_callback, infos)

            for key in infos:
                info = infos[key]
                if info['weight'] == 0:
                    continue

                lat = info['lats'] / info['weight']
                lon = info['lons'] / info['weight']

                resline = "%s,%s,%f,%f,%f,%f,%f,%f,%f" % (country, str(key), info['weight'], info['swlat'], info['swlon'], info['nelat'], info['nelon'], lat, lon)
                print resline
                with open(resfile, "a") as resfp:
                    resfp.write(resline + "\n")

        self.feature_set_country(None)

    def gridded_loop(self, resfile, feature_name, weight_name, percent):
        done = [] # countries included
        if os.path.exists(resfile):
            with open(resfile, "r") as resfp:
                reader = csv.reader(resfp)
                for row in reader:
                    if row[0] not in done:
                        done.append(row[0])

        if not done:
            with open(resfile, "a") as resfp:
                resfp.write("country,%s,%s,swlat,swlon,nelat,nelon,latitude,longitude\n" % (feature_name, weight_name))

        country_points = countries.country_points()

        for country in country_points:
            if country in done:
                continue

            self.feature_set_country(country)

            infos = {}
            points = country_points[country]['latlons']
            for pp in range(len(points)):
                print country, points[pp]

                latitude = points[pp][0]
                longitude = points[pp][1]

                swlat = latitude - .25/2
                swlon = longitude - .25/2
                nelat = latitude + .25/2
                nelon = longitude + .25/2

                self.getrect_features(swlat, swlon, nelat, nelon, StaticFeature.append_callback, infos)

                infos = StaticFeature.top_filter(infos, percent, swlat, swlon, nelat, nelon, lambda info: info['weight'], lambda info: (info['swlat'], info['swlon'], info['nelat'], info['nelon']))

                for key in infos:
                    info = infos[key]

                    lat = info['lats'] / info['weight']
                    lon = info['lons'] / info['weight']
                    resline = "%s,%s,%f,%f,%f,%f,%f,%f,%f" % (country, str(key), info['weight'], max(info['swlat'], swlat), max(info['swlon'], swlon), min(info['nelat'], nelat), min(info['nelon'], nelon), max(swlat, min(lat, nelat)), max(swlon, min(lon, nelon)))
                    print resline
                    with open(resfile, "a") as resfp:
                        resfp.write(resline + "\n")

        self.feature_set_country(None)

    @staticmethod
    def top_filter(infos, percent, swlat, swlon, nelat, nelon, weightfunc, rectfunc):
        # Select the top [percent] of statics
        keyweights = []
        totalweight = 0

        for key in infos:
            info = infos[key]
            weight = weightfunc(info)
            if weight == 0:
                continue
            rect = rectfunc(info)
            if rect[0] > nelat or rect[1] > nelon or rect[2] < swlat or rect[3] < swlon:
                continue
            totalweight += weight
            keyweights.append({'key': key, 'weight': weight})

        if totalweight == 0:
            return {}

        keyweights = sorted(keyweights, key=lambda sw: sw['weight'], reverse=True)
        usedweight = 0
        numused = 0
        result = {}
        for keyweight in keyweights:
            if usedweight > totalweight * .9:
                break

            result[keyweight['key']] = infos[keyweight['key']]
            numused += 1
            usedweight += keyweight['weight']

        return result

    @staticmethod
    def append_callback(latitude, longitude, feature, weight, infos):
        info = infos.get(feature, {'weight': 0, 'swlat': 90, 'swlon': 180, 'nelat': -90, 'nelon': -180, 'lats': 0, 'lons': 0})
        info['weight'] += weight
        info['lats'] += latitude * weight
        info['lons'] += longitude * weight
        info['swlat'] = min(info['swlat'], latitude)
        info['swlon'] = min(info['swlon'], longitude)
        info['nelat'] = max(info['nelat'], latitude)
        info['nelon'] = max(info['nelon'], longitude)
        infos[feature] = info

    @staticmethod
    def drange(start, stop, step):
        if step > 0:
            r = start
            while r < stop:
                yield r
                r += step
        else:
            r = start
            while r > stop:
                yield r
                r += step

class StaticFeatureCombo(StaticFeature):
    def __init__(self, feature1, feature2):
        self.feature1 = feature1
        self.feature2 = feature2

    def feature_set_country(self, country_name):
        self.feature1.feature_set_country(country_name)
        self.feature2.feature_set_country(country_name)

    def getll_features(self, latitude, longitude, callback, cb_extra=None):
        self.feature1.getll_features(latitude, longitude, StaticFeatureCombo.combo_getll_callback1, (self, callback, cb_extra))

    @staticmethod
    def combo_getll_callback1(latitude, longitude, feature, weight, extras):
        (self, callback, cb_extra) = extras
        if feature is not None:
            self.feature2.getll_features(latitude, longitude, StaticFeatureCombo.combo_getll_callback2, (feature, weight, callback, cb_extra))

    @staticmethod
    def combo_getll_callback2(latitude, longitude, feature, weight, extras):
        (feature1, weight1, callback, cb_extra) = extras
        callback(latitude, longitude, str(feature1) + ":" + str(feature), weight1*weight, cb_extra)

    def getrect_features(self, swlat, swlon, nelat, nelon, callback, cb_extra=None):
        self.feature1.getrect_features(swlat, swlon, nelat, nelon, StaticFeatureCombo.combo_getll_callback1, (self, callback, cb_extra))

class StaticFeatureCached(StaticFeature):
    def __init__(self, feature, featfile, weight, sizex, sizey):
        self.feature = feature
        self.featfile = featfile
        self.weight = weight
        self.sizex = sizex
        self.sizey = sizey
        self.country_name = None

    def feature_set_country(self, country_name):
        self.country_name = country_name

    def getll_features(self, latitude, longitude, callback, cb_extra=None):
        if self.country_name:
            if self.country_name in self.featfile.countries:
                features = self.featfile.potential_contains(self.country_name, latitude, longitude)
                if len(features) == 1:
                    for feature in features:
                        callback(latitude, longitude, feature, self.weight, cb_extra)
                        return

        self.feature.getll_features(latitude, longitude, callback, cb_extra)

    def getrect_features(self, swlat, swlon, nelat, nelon, callback, cb_extra=None):
        self.getrect_features_grid(swlat, swlon, nelat, nelon, self.sizex, self.sizey, callback, cb_extra)

    @staticmethod
    def print_callback(latitude, longitude, feature, weight, extra=None):
        (callback, cb_extra) = extra
        print latitude, longitude, feature, weight
        callback(latitude, longitude, feature, weight, cb_extra)

class StaticFeatureFile:
    def __init__(self, file=None):
        if file is None:
            self.countries = {}
            return

        countries = {}
        reader = csv.reader(file, delimiter=',')
        reader.next()
        for row in reader:
            if row[0] not in countries:
                countries[row[0]] = {}
            countries[row[0]][row[1]] = map(float, row[2:])

        # Add on portion represents of total
        for name in countries:
            country = countries[name]
            total = 0
            for feature in country:
                total += country[feature][0]

            for feature in country:
                country[feature].append(country[feature][0] / total)

        self.countries = countries

    # Returns {feature: my-weight}
    def potential_contains(self, country_name, latitude, longitude):
        country = self.countries[country_name]

        potentials = {}
        for feature in country:
            if FeatureRectangle.contains(FeatureRectangle(country[feature]), latitude, longitude):
                potentials[feature] = country[feature][0]

        return potentials

    # Returns {feature: my-weight}
    def potential_intersects(self, country_name, rect):
        country = self.countries[country_name]

        potentials = {}
        for feature in country:
            both = FeatureRectangle.intersect(rect, FeatureRectangle(country[feature]))
            if both.is_proper():
                potentials[feature] = country[feature][0]

        return potentials

    @staticmethod
    def intersect(featrow1, featrow2, featval1, featval2, feature1, feature2):
        rect1 = FeatureRectangle(featrow1)
        rect2 = FeatureRectangle(featrow2)
        both = FeatureRectangle.intersect(rect1, rect2)

        # if one is contained in other, weight is smaller portion
        #if both == rect1:
        #   return [featrow1[-1]] + featrow1[2:-1]
        #if both == rect2:
        #    return [featrow2[-1]] + featrow2[2:-1]

        # Look over intersection
        infos = {}
        feature1.getrect_features(both.swlat, both.swlon, both.nelat, both.nelon, StaticFeatureFile.intersect_callback, (featval1, featval2, feature2, infos))

        info = None
        if featval2 in infos:
            info = infos[featval2]
        try:
            if float(featval2) in infos:
                info = infos[float(featval2)]
        except:
            pass

        if info:
            sumweight = sum([infos[key]['weight'] for key in infos])

            # weight is new value / original value for feature2
            return [float(info['weight']) / sumweight, info['swlat'], info['swlon'], info['nelat'], info['nelon'], info['lats'] / info['weight'], info['lons'] / info['weight']]

        return [0, both.swlat, both.swlon, both.nelat, both.nelon, (both.swlat + both.nelat)/2, (both.swlon + both.nelon)/2]

    @staticmethod
    def intersect_callback(latitude, longitude, feature, weight, extras):
        (featval1, featval2, feature2, infos) = extras
        if ((isinstance(feature, tuple) and tuple(map(str, feature)) == featval1) or str(feature) == featval1) and weight > 0:
            feature2.getll_features(latitude, longitude, StaticFeatureFile.scaled_append_callback, (featval2, weight, infos))
        #elif weight == 0:
        #    print "No0"
        else:
            print "No1:" , latitude, longitude, feature, featval1

    @staticmethod
    def scaled_append_callback(latitude, longitude, feature, weight, extras):
        (featval2, weight1, infos) = extras
        #if str(feature) == featval2: # Remove this later
        #    print "Yes:", latitude, longitude
        #else:
        #    print "No2:" , latitude, longitude

        StaticFeature.append_callback(latitude, longitude, feature, weight1*weight, infos)

    @staticmethod
    def all_intersects(country_name, featfile1, featfile2, feature1, feature2):
        combo = StaticFeatureFile()
        combo.countries[country_name] = {}

        country1 = featfile1.countries[country_name]
        for featval1 in country1:
            featrow1 = country1[featval1]
            rect1 = FeatureRectangle(featrow1)

            featval2s = featfile2.potential_intersects(country_name, rect1)
            for featval2 in featval2s:
                print featval1, featval2
                featrow2 = featfile2.countries[country_name][featval2]
                bothrow = StaticFeatureFile.intersect(featrow1, featrow2, featval1, featval2, feature1, feature2)
                if bothrow[0] > 0:
                    combo.countries[country_name][(featval1, featval2)] = bothrow

        return combo

class FeatureRectangle:
    def __init__(self, row):
        self.swlat = row[1]
        self.swlon = row[2]
        self.nelat = row[3]
        self.nelon = row[4]

    def __eq__(self, other):
        return self.swlat == other.swlat and self.swlon == other.swlon and self.nelat == other.nelat and self.nelon == other.nelon

    def is_proper(self):
        return self.swlat < self.nelat and self.swlon < self.nelon

    @staticmethod
    def intersect(rect1, rect2):
        return FeatureRectangle([None, max(rect1.swlat, rect2.swlat), max(rect1.swlon, rect2.swlon),
                                 min(rect1.nelat, rect2.nelat), min(rect1.nelon, rect2.nelon)])

    def contains(rect, latitude, longitude):
        return latitude > rect.swlat and latitude < rect.nelat and longitude > rect.swlon and longitude < rect.nelon

class StaticFeatureGrid(StaticFeature):
    def __init__(self, lat0, dlat, lon0, dlon):
        self.lat0 = lat0
        self.dlat = dlat
        self.lon0 = lon0
        self.dlon = dlon

    def getll_features(self, latitude, longitude, callback, cb_extra=None):
        lat = math.floor((latitude - self.lat0) / self.dlat) * self.dlat + self.lat0
        lon = math.floor((longitude - self.lon0) / self.dlon) * self.dlon + self.lon0
        callback(latitude, longitude, str(lat) + ":" + str(lon), 1, cb_extra)

    def getrect_features(self, swlat, swlon, nelat, nelon, callback, cb_extra=None):
        self.getrect_feature_grid(swlat, swlon, nelat, nelon, self.dlon, self.dlat, callback, cb_extra)

def country_points():
    print "Reading GIS data..."
    countries = {}

    with open("~/data/political/countries-0.25x0.25.pts") as fp:
        reader = csv.reader(fp)
        reader.next() # ignore header
        for row in reader:
            country = countries.get(row[1], {'latlons': []})
            country['latlons'].append((float(row[3]), float(row[2])))
            countries[row[1]] = country

    return countries
