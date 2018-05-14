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

brewer.ramp <- function(palette, n=100) {
    colors <- brewer.pal(9, palette)
    colorRampPalette(colors)(n)
}

val2col.ramp <- function(values, limits, palette, n=100) {
    colors <- brewer.ramp(palette, n)
    brks <- classIntervals(seq(limits[1], limits[2], length.out=n), n=n, style="equal")
    brks <- brks$brks
    colors[findInterval(values, brks, all.inside=TRUE)]
}

# Function to plot color bar
color.bar <- function(lut, min, max=-min, nticks=11, ticks=seq(min, max, len=nticks), title='') {
    scale = (length(lut)-1)/(max-min)

    dev.new(width=1.75, height=5)
    plot(c(0,10), c(min,max), type='n', bty='n', xaxt='n', xlab='', yaxt='n', ylab='', main=title)
    axis(2, ticks, las=1)
    for (i in 1:(length(lut)-1)) {
     y = (i-1)/scale + min
     rect(0,y,10,y+1/scale, col=lut[i], border=NA)
    }
}
