import sys, os
sys.path.append(os.path.join(os.path.dirname(__file__), ".."))

import numpy as np
import shapefile, csv
from shapely import geometry, affinity, ops
import geoshapes

# Record information, used to extract Hawaii
CHECK_HAWAII_IN_RECORD = True # If false, only uses HAWAII_BOX
SHAPEFILE_REGION_FIELD = "name"
SHAPEFILE_HAWAII_REGION = "United States"
# Rectangle containing Hawaii
HAWAII_REGION = geometry.box(-165, 15, -150, 25)

# Regions to drop (small islands)
DROP_REGIONS = [
    geometry.box(-16, -17, -4, -7), # Small Atlantic Islands
    #geometry.box(-169, -30, -95, 0), # Pacific Islands east of American Somoa
    geometry.box(-179, -30, -95, 0), # Pacific Islands east of Fiji
    geometry.box(-160, 1, -156, 5), # A couple more Pacific Islands
    geometry.box(160, -3, 180, 13), # And more
    geometry.box(141, 26, 143, 27)
]

# Longitudinal configuration of the map
MAP_SEAM_LONGITUDE = 65 # Location of the wrapping seam on the map
# The spacings are between bounding boxes, so negative values allow the continents to nestle into each other.
NEW_OLD_SPACING = 5 # Spacing between the east of the new world and the west of the old world in degrees longitude
OLD_NEW_SPACING = 5 # Spacing between the west of the new world and the east of the old world in degrees longitude
HAWAII_NEW_SPACING = 10 # Spacing between the west of the new world and the east of Hawaii in degrees longitude

def load_shapefile(shapepath):
    """Returns the field names, field types, and list of tuples of (record, shape), as returned by shapefile.Reader."""
    sf = shapefile.Reader(shapepath)

    recordshapes = []
    shapes = sf.iterShapes()
    for record in sf.iterRecords():
        shape = shapes.next()
        recordshapes.append((record, shape))

    fieldnames = [field[0] for field in sf.fields]
    fieldtypes = [field[1] for field in sf.fields]

    return fieldnames, fieldtypes, recordshapes

def in_newworld(lon, lat):
    """Return True if this point is part of the New World continent."""
    assert lat <= 30 and lat >= -30
    return (lon < -50 and lon > -120) if lat >= 10 else (lon < -30 and lon > -100)

def splitworlds_shape(shape, seam_longitude):
    """Returns three MultiPolygons: western old world, eastern old world, and new world."""

    # Construct MultiPolygon to perform intersections
    multi = geoshapes.shape2multi(shape).buffer(0)
    multi = multi.intersection(geometry.box(multi.bounds[0], -30, multi.bounds[2], 30))

    # Drop the drop boxes
    for region in DROP_REGIONS:
        multi = multi.difference(region)

    # Pull out the list, in case it wasn't a list
    geoms = [poly for poly in geoshapes.polygons(multi)]

    in_newworlds = []
    for geom in geoms:
        minnew = in_newworld(*geom.bounds[:2])
        maxnew = in_newworld(*geom.bounds[2:])
        assert minnew == maxnew
        in_newworlds.append(minnew)

    newworld = geometry.MultiPolygon([geoms[ii] for ii in range(len(geoms)) if in_newworlds[ii]])
    if np.all(in_newworlds):
        return geometry.MultiPolygon(), geometry.MultiPolygon(), newworld

    # If some old world, construct unions and re-seam
    oldworld = []
    for ii in range(len(geoms)):
        if in_newworlds[ii]:
            continue

        # Move everything west of new world to the far east
        if geoms[ii].bounds[0] < -65:
            oldworld.append(affinity.translate(geoms[ii], 360))
        else:
            oldworld.append(geoms[ii])

    oldworld = ops.cascaded_union(geometry.MultiPolygon(oldworld))
    rightoldworld = oldworld.intersection(geometry.box(-65, -30, seam_longitude, 30))
    leftoldworld = affinity.translate(oldworld.intersection(geometry.box(seam_longitude, -30, oldworld.bounds[2], 30)), -360)

    return rightoldworld, leftoldworld, newworld

def splitworlds(fieldnames, recordshapes, seam_longitude):
    """Splits the recordshapes into the western old world, eastern old world, new world, and Hawaii.  All are dictionaries of MultiPolygons, keyed by the index in recordshapes."""
    rightoldworlds = {}
    leftoldworlds = {}
    newworlds = {}
    hawaiis = {}
    for ii in range(len(recordshapes)):
        record, shape = recordshapes[ii]

        rightoldworld, leftoldworld, newworld = splitworlds_shape(shape, seam_longitude)

        # Do we need to remove Hawaii?
        if CHECK_HAWAII_IN_RECORD:
            if record[fieldnames.index(SHAPEFILE_REGION_FIELD)] == SHAPEFILE_HAWAII_REGION:
                # Combine both sides, in case seam runs through Hawaii
                hawaii = rightoldworld.intersection(HAWAII_REGION).union(leftoldworld.intersection(HAWAII_REGION))
                rightoldworld = rightoldworld.difference(HAWAII_REGION)
                leftoldworld = leftoldworld.difference(HAWAII_REGION)

                hawaiis[ii] = hawaii
            elif HAWAII_REGION.intersects(leftoldworld):
                hawaii = leftoldworld.intersection(HAWAII_REGION)
                leftoldworld = leftoldworld.difference(HAWAII_REGION)

                hawaiis[ii] = hawaii

        # Add any non-empty polygons to our lists
        if not rightoldworld.is_empty:
            rightoldworlds[ii] = rightoldworld
        if not leftoldworld.is_empty:
            leftoldworlds[ii] = leftoldworld
        if not newworld.is_empty:
            newworlds[ii] = newworld

    return rightoldworlds, leftoldworlds, newworlds, hawaiis

def extreme_longitudes(polydict, latmin=-30, latmax=30):
    minlon = np.inf
    maxlon = -np.inf

    if latmin == -30 and latmax == 30:
        for polygon in polydict.values():
            minlon = min(minlon, polygon.bounds[0])
            maxlon = max(maxlon, polygon.bounds[2])
    else:
        for multi in polydict.values():
            if multi.bounds[1] > latmax or multi.bounds[3] < latmin:
                continue
            for polygon in geoshapes.polygons(multi):
                if polygon.bounds[1] > latmax or polygon.bounds[3] < latmin:
                    continue
                alllon = [point[0] for point in polygon.exterior.coords if point[1] >= latmin and point[1] <= latmax and np.isfinite(point[0])]
                if len(alllon) == 0:
                    continue
                minlon = min(minlon, min(alllon))
                maxlon = max(maxlon, max(alllon))

    return minlon, maxlon

def minimum_longitude_gap(polydict1, polydict2):
    # Take the
    mingap = np.inf
    for latitude in range(-30, 30):
        leftmin, leftmax = extreme_longitudes(polydict1, latitude, latitude+1)
        rightmin, rightmax = extreme_longitudes(polydict2, latitude, latitude+1)

        mingap = min(mingap, rightmin - leftmax)
        #if rightmin - leftmax == mingap:
        #    print rightmin, leftmax

    return mingap

def shift_all(polydict, dlon):
    shifted = {}
    for ii in polydict:
        shifted[ii] = affinity.translate(polydict[ii], dlon)

    return shifted

def all_polygons(polydicts, index):
    polygons = [polydict[index] for polydict in polydicts if index in polydict]
    polygons = filter(lambda polygon: not isinstance(polygon, geometry.Point), polygons)

    if len(polygons) == 0:
        return None
    if len(polygons) == 1:
        return polygons[0]
    if len(polygons) == 2:
        return polygons[0].union(polygons[1])

    return ops.cascaded_union(polygons)

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 2:
        print "Please provide input shapefile and output shapefile path."
        exit()

    # Path to the shapefile to read in
    # Must by in longitude, latitude
    input_shapefile = sys.argv[1]
    output_shapefile = sys.argv[2]

    # Load the shapefile
    fieldnames, fieldtypes, recordshapes = load_shapefile(input_shapefile)

    # Split into segments
    rightoldworlds, leftoldworlds, newworlds, hawaiis = splitworlds(fieldnames, recordshapes, MAP_SEAM_LONGITUDE)

    # Decide where to shift everything
    new_old = minimum_longitude_gap(newworlds, rightoldworlds)
    newworlds = shift_all(newworlds, new_old - NEW_OLD_SPACING)
    old_new = minimum_longitude_gap(leftoldworlds, newworlds)
    print old_new
    leftoldworlds = shift_all(leftoldworlds, old_new - OLD_NEW_SPACING)
    hawaii_new = minimum_longitude_gap(hawaiis, newworlds)
    print hawaii_new
    hawaiis = shift_all(hawaiis, hawaii_new - HAWAII_NEW_SPACING)

    allpolydicts = [rightoldworlds, leftoldworlds, newworlds, hawaiis]

    # Write out the new shapefile
    writer = shapefile.Writer(shapefile.POLYGON)
    writer.autoBalance = 1
    for ii in range(len(fieldnames)):
        writer.field(fieldnames[ii], fieldType=fieldtypes[ii])

    for ii in range(len(recordshapes)):
        polygons = all_polygons(allpolydicts, ii)
        if polygons is not None:
            geoshapes.write_polys(writer, polygons, recordshapes[ii][0])

    writer.save(output_shapefile)

    with open(output_shapefile + '.tsr', 'w') as tsrout:
        writer = csv.writer(tsrout)
        writer.writerow(["region", "shift"])
        writer.writerow(["newworld", new_old - NEW_OLD_SPACING])
        writer.writerow(["leftoldworld", old_new - OLD_NEW_SPACING])
        writer.writerow(["hawaii", hawaii_new - HAWAII_NEW_SPACING])

