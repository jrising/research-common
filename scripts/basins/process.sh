SHAPEFILE=$1
DIRECTORY=$2
OUTLETLON=$3
OUTLETLAT=$4

mkdir "$DIRECTORY"

# Download DEM from
## https://iridl.ldeo.columbia.edu/SOURCES/.NOAA/.NGDC/.GLOBE/.topo/dataselection.html
##  Use GeoTIFF, data image, GIS link
python download_dem.py "$SHAPEFILE" "$DIRECTORY/data.tiff"

# Prepare to run aread8
./TauDEM/pitremove "$DIRECTORY/data.tiff"
./TauDEM/d8flowdir "$DIRECTORY/data.tiff"
./TauDEM/dinfflowdir "$DIRECTORY/data.tiff"
./TauDEM/areadinf "$DIRECTORY/data.tiff"
./TauDEM/slopearea "$DIRECTORY/data.tiff"
./TauDEM/d8flowpathextremeup "$DIRECTORY/data.tiff"
./TauDEM/threshold "$DIRECTORY/data.tiff"

# Create a shp file for outlet (make CSV, open in QGIS, save out shp)
python create_ptshp.py $OUTLETLON $OUTLETLAT "$DIRECTORY/outlet.shp"

./TauDEM/moveoutletstostrm -p "$DIRECTORY/datap.tiff" -src "$DIRECTORY/datasrc.tiff" -o "$DIRECTORY/outlet.shp" -om "$DIRECTORY/outlet2.shp"

./TauDEM/aread8 -p "$DIRECTORY/datap.tiff" -ad8 "$DIRECTORY/dataad8.tiff" -o "$DIRECTORY/outlet2.shp"

# gdal_polygonize.py "$DIRECTORY/dataad8.tiff" -f "ESRI Shapefile" "$DIRECTORY/basin" basin
