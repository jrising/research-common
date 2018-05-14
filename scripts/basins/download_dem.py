import sys, urllib
import shapefile

region = sys.argv[1]
if ',' in region: # A bounding box
    bbox = map(float, region.split(','))
else:
    shp = shapefile.Reader(region)
    bbox = shp.shapes()[0].bbox
outpath = sys.argv[2]

lon0, lat0, lon1, lat1 = tuple(bbox)

url = "https://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NGDC/.GLOBE/.topo/X/%%28%f%%29%%28%f%%29RANGEEDGES/Y/%%28%f%%29%%28%f%%29RANGEEDGES/Y/%f/%f/RANGEEDGES/%%5BX/Y/%%5D/data.tiff?filename=data.tiff" % (lon0, lon1, lat0, lat1, lat0, lat1)
webfp = urllib.urlopen(url)
locfp = open(outpath, 'w')
locfp.write(webfp.read())
webfp.close()
locfp.close()
