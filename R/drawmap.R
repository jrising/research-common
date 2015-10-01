library(maptools)
library(maps)

library(RColorBrewer)
library(classInt)

draw.map <- function(database, names, values, colorscheme="RdYlGn", position=NA, add=F, digits=0, ylim=c(-90, 90), intervalStyle="quantile") {
    if (colorscheme == "GnYlRd")
        colors <- rev(brewer.pal(9, "RdYlGn"))
    else
        colors <- brewer.pal(9, colorscheme)

    brks <- classIntervals(values, n=9, style=intervalStyle)
    brks <- brks$brks

    map(database, names, col=colors[findInterval(values, brks, all.inside=TRUE)], fill=T, mar=c(1, 2, 3, 0), add=add, ylim=ylim)

    if (!is.na(position))
        legend(position, legend=leglabs(round(brks, digits=digits)), fill=colors, bty="n", cex=.5)
}
