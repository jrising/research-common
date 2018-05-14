import sys
import shapefile

longitude = float(sys.argv[1])
latitude = float(sys.argv[2])
outpath = sys.argv[3]

writer = shapefile.Writer(shapefile.POINT)
writer.field('label')
writer.point(longitude, latitude)
writer.record('singleton')
writer.save(outpath)
