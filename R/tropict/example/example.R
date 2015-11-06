source("../draw_map.R", chdir=T)

## Just draw the map
plotMap("#000080")
addSeams(col="#00000040")

## Draw a splicer image with the map on top of it
library(ncdf4)
library(RColorBrewer)

database <- nc_open("bio-2b.nc4")
map <- ncvar_get(database, "change")
conf <- ncvar_get(database, "confidence")

maxmap <- max(abs(map), na.rm=T)

colors <- rev(brewer.pal(11,"RdYlBu"))
breaks <- seq(-maxmap, maxmap, length.out=12)

dev.new(width=8, height=5.2)
splicerImage(map, colors, breaks=breaks)
splicerImage(conf, rgb(1, 1, 1, seq(.5, 0, by=-.1)), add=T)
addMap(border="#00000060")
addSeams(col="#00000040")

