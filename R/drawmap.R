library(maptools)
library(maps)

library(RColorBrewer)
library(classInt)

namefixes <- list("United States"="USA", "Korea, North"="North Korea",
                  "Korea, South"="South Korea",
                  "Congo (Brazzaville)"="Democratic Republic of the Congo",
                  "Congo (Kinshasa)"="Republic of Congo",
                  "Cote d'Ivoire"="Ivory Coast", "United Kingdom"="UK",
                  "Burma"="Myanmar", "Bolivia (Plurinational State of)"="Bolivia",
                  "Bosnia Herzegovina"="Bosnia", "Brunei Darussalam"="Brunei",
                  "China, Hong Kong SAR"="China:Hong Kong", "Rep. of Moldova"="Moldova",
                  "Russian Federation"="Russia", "TFYR of Macedonia"="Macedonia",
                  "United Rep. of Tanzania"="Tanzania") #"EU-27"="germany|france|spain|portugal|belgium|italy|greece|austria|slovenia|croatia") # XXX: Need more of these!

val2colors <- function(values, colorscheme="RdYlGn", intervalStyle="quantile") {
    if (colorscheme == "GnYlRd")
        colors <- rev(brewer.pal(9, "RdYlGn"))
    else
        colors <- brewer.pal(9, colorscheme)

    brks <- classIntervals(values, n=9, style=intervalStyle)
    brks <- brks$brks

    colors[findInterval(values, brks, all.inside=TRUE)]
}

val2legend <- function(position, values, colorscheme="RdYlGn", intervalStyle="quantile", digits=0, cex=.5) {
    if (colorscheme == "GnYlRd")
        colors <- rev(brewer.pal(9, "RdYlGn"))
    else
        colors <- brewer.pal(9, colorscheme)

    brks <- classIntervals(values, n=9, style=intervalStyle)
    brks <- brks$brks

    legend(position, legend=leglabs(round(brks, digits=digits)), fill=colors, bty="n", cex=cex)
}

draw.map <- function(database, names, values, colorscheme="RdYlGn", position=NA, add=F, digits=0, xlim=NULL, ylim=c(-90, 90), intervalStyle="quantile") {
    if (colorscheme == "GnYlRd")
        colors <- rev(brewer.pal(9, "RdYlGn"))
    else
        colors <- brewer.pal(9, colorscheme)

    brks <- classIntervals(values, n=9, style=intervalStyle)
    brks <- brks$brks

    map(database, names, col=colors[findInterval(values, brks, all.inside=TRUE)], fill=T, mar=c(1, 2, 3, 0), add=add, xlim=xlim, ylim=ylim)

    if (!is.na(position))
        legend(position, legend=leglabs(round(brks, digits=digits)), fill=colors, bty="n", cex=.5)
}

draw.map.careful <- function(database, names, values, borders="#000000", colorscheme="RdYlGn", position=NA, add=F, digits=0, xlim=NULL, ylim=c(-90, 90), intervalStyle="quantile", brks=NULL) {
    if (colorscheme == "GnYlRd")
        colors <- rev(brewer.pal(9, "RdYlGn"))
    else
        colors <- brewer.pal(9, colorscheme)

    if (is.null(brks)) {
        brks <- classIntervals(values, n=9, style=intervalStyle)
        brks <- brks$brks
    }

    names <- as.character(names)
    if (!add)
        map(database, xlim=xlim, ylim=ylim)
    for (ii in 1:length(names)) {
        if (!is.na(names[ii]))
            if (names[ii] %in% names(namefixes))
                names[ii] <- namefixes[[names[ii]]]
            tryCatch({
                map(database, names[ii], col=colors[findInterval(values[ii], brks, all.inside=TRUE)], border=borders[min(length(borders), ii)], fill=T, mar=c(1, 2, 3, 0), add=T)
            }, error=function(e) {
                print(names[ii])
            })
    }

    if (!is.na(position))
        legend(position, legend=leglabs(round(brks, digits=digits)), fill=colors, bty="n", cex=.5)
}

fips2names <- function(fips) {
    sapply(fips, function(fip) {
        names <- county.fips$polyname[county.fips$fips == fip]
        if (length(names) > 1)
            gsub(":.+", "", names[1])
        else if (length(names) == 0)
            NA
        else
            as.character(names)
    })
}
