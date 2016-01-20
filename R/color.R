library(RColorBrewer)
library(classInt)

val2col <- function(values, colorscheme, intervalStyle="pretty") {
    if (colorscheme == "GnYlRd")
        colors <- rev(brewer.pal(9, "RdYlGn"))
    else
        colors <- brewer.pal(9, colorscheme)

    brks <- classIntervals(values, n=9, style=intervalStyle)$brks

    colors[findInterval(values, brks, all.inside=TRUE)]
}

