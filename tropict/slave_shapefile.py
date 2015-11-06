import csv
from make_shapefile import *

if __name__ == '__main__':
    import sys
    if len(sys.argv) < 3:
        print "Please provide tsr file, slave shapefile and output shapefile path."
        exit()

    # Path to the shapefile to read in
    # Must by in longitude, latitude
    tsr_file = sys.argv[1]
    slave_shapefile = sys.argv[2]
    output_shapefile = sys.argv[3]

    # Load the shapefile
    fieldnames, fieldtypes, recordshapes = load_shapefile(slave_shapefile)

    # Split into segments
    rightoldworlds, leftoldworlds, newworlds, hawaiis = splitworlds(fieldnames, recordshapes, MAP_SEAM_LONGITUDE)

    with open(tsr_file, 'r') as tsrin:
        reader = csv.reader(tsrin)
        for row in reader:
            if row[0] == "newworld":
                newworlds = shift_all(newworlds, float(row[1]))
            elif row[0] == "leftoldworld":
                leftoldworlds = shift_all(leftoldworlds, float(row[1]))
            elif row[0] == "hawaii":
                hawaiis = shift_all(hawaiis, float(row[1]))

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
