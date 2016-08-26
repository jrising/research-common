library(PBSmapping)

shape <- importShapefile("ne_50m_admin_0_countries/ne_50m_admin_0_countries")
polydata <- attributes(shape)$PolyData

print("Plotting original map, to prepare PBSmapping's operations.")
plotPolys(shape, ylim=c(-30, 30))

## New world
newworld <- unique(shape$PID[shape$X <= -30 & shape$X >= -120 & shape$Y >= -30 & shape$Y <= 30])

## Old world
oldworld <- unique(shape$PID[shape$X > -30 & shape$Y >= -30 & shape$Y <= 30])

polydata$name[newworld[newworld %in% oldworld]]

## France is a problem
francepid <- 73
frances <- calcCentroid(subset(shape, PID == francepid))
newworld <- newworld[newworld != francepid]
oldworld <- oldworld[oldworld != francepid]
newfrance <- frances$SID[frances$X <= -30]
oldfrance <- frances$SID[frances$X > -30]

## Hawaii is too far away
usapid <- which(polydata$name == "United States")
usas <- calcCentroid(subset(shape, PID == usapid))
newworld <- newworld[newworld != usapid]
hawaii <- usas$SID[usas$X < -140 & usas$Y < 25]

## Far east
centroids = calcCentroid(shape[shape$X > 140 & shape$Y >= -30 & shape$Y <= 30,], rollup=1)

fareast <- unique(shape$PID[shape$X > 140 & shape$Y >= -30 & shape$Y <= 30])
fareast <- fareast[!(fareast %in% which(polydata$name %in% c("Australia", "Indonesia", "Japan")))]

oldworld <- oldworld[!(oldworld %in% fareast)]

fareast <- fareast[!(fareast %in% which(polydata$name %in% c("Marshall Is.", "Kiribati", "Micronesia")))] # Produce nothing

## Australia
australia <- which(polydata$name == "Australia")
oldworld <- oldworld[oldworld != australia]

## Create shifted polygons
newshape <- subset(shape, PID %in% newworld | (PID == francepid & SID %in% newfrance) | (PID == usapid & !(SID %in% hawaii)))
oldshape <- subset(shape, PID %in% oldworld | (PID == francepid & SID %in% oldfrance))
farshape <- subset(shape, PID %in% fareast)
ausshape <- subset(shape, PID == australia)
hawshape <- subset(shape, PID == usapid & SID %in% hawaii)

## New world into Africa
shiftright <- newshape
shiftright$X <- shiftright$X + 29

## Far east into South America
shiftleft <- farshape
shiftleft$X[shiftleft$X < 0] <- shiftleft$X[shiftleft$X < 0] + 360 # Fix Fiji
shiftleft$X <- shiftleft$X - 260 + 30

## Split on Pakistan, use Gall-Peters
## For aspect ratio, treat x = radian lon, so width = 260 * pi / 180

## If col is provided to any of the functions below, it must either be
## a single value or have a value for every country ordered by
## `polydata`

## This function helps you do that, passed two vectors of the same
## length
arrange.col <- function(countries, cols) {
    col <- rep(NA, nrow(polydata))
    for (ii in 1:length(countries)) {
        country <- as.character(countries[ii])
        if (country %in% polydata$name)
            col[country == polydata$name] <- cols[ii]
        else
            print(country)
    }

    col
}

get.col <- function(polys, col=NULL) {
    if (is.null(col) || length(col) == 1)
        col
    else
        col[polys$PID[!duplicated(polys$PID)]]
}

## Plot polygons one at a time, so colors match up
addPolysSingly <- function(polys, border, col) {
    if (length(col) == 1) {
        addPolys(polys, border=border, col=col)
    } else {
        pids <- polys$PID[!duplicated(polys$PID)]
        for (ii in 1:length(pids))
            addPolys(subset(polys, PID == pids[ii]), border=border, col=col[ii])
    }
}

plotMap <- function(border, col=NULL) {
    par(mar=rep(0, 4))

    oldshape.gp <- oldshape
    oldshape.gp$X <- oldshape.gp$X - 1.5
    oldshape.gp$X <- oldshape.gp$X * pi / 180
    oldshape.gp$Y <- 2 * sin(oldshape.gp$Y * pi / 180)
    oldshape.gp$Y[oldshape.gp$Y > 0] <- oldshape.gp$Y[oldshape.gp$Y > 0] - .05 * sin(oldshape.gp$Y[oldshape.gp$Y > 0] * pi)
    oldshape.gp$Y[oldshape.gp$Y > -.25 & oldshape.gp$Y < .25] <- oldshape.gp$Y[oldshape.gp$Y > -.25 & oldshape.gp$Y < .25] - .015 * sin((oldshape.gp$Y[oldshape.gp$Y > -.25 & oldshape.gp$Y < .25] + .25) * 2 * pi)

    plotPolys(oldshape.gp, ylim=c(-1, 1), xlim=c(-165, 65) * pi / 180, border="#00000000")
    addPolysSingly(oldshape.gp, border=border, col=get.col(oldshape.gp, col))

    addMap2(border, col=col)
}

addMap <- function(border, col="#00000000") {
    oldshape.gp <- oldshape
    oldshape.gp$X <- oldshape.gp$X - 1.5
    oldshape.gp$X <- oldshape.gp$X * pi / 180
    oldshape.gp$Y <- 2 * sin(oldshape.gp$Y * pi / 180)
    oldshape.gp$Y[oldshape.gp$Y > 0] <- oldshape.gp$Y[oldshape.gp$Y > 0] - .05 * sin(oldshape.gp$Y[oldshape.gp$Y > 0] * pi)
    oldshape.gp$Y[oldshape.gp$Y > -.25 & oldshape.gp$Y < .25] <- oldshape.gp$Y[oldshape.gp$Y > -.25 & oldshape.gp$Y < .25] - .015 * sin((oldshape.gp$Y[oldshape.gp$Y > -.25 & oldshape.gp$Y < .25] + .25) * 2 * pi)

    addPolysSingly(oldshape.gp, border=border, col=get.col(oldshape.gp, col))

    addMap2(border, col=col)
}

addMap2 <- function(border, col="#00000000") {
    oldshape2.gp <- oldshape
    oldshape2.gp$X <- oldshape2.gp$X - 265 + 30 + 1
    oldshape2.gp$X <- oldshape2.gp$X * pi / 180
    oldshape2.gp$Y <- 2 * sin(oldshape2.gp$Y * pi / 180)
    oldshape2.gp$Y[oldshape2.gp$Y > 0] <- oldshape2.gp$Y[oldshape2.gp$Y > 0] - .05 * sin(oldshape2.gp$Y[oldshape2.gp$Y > 0] * pi)
    oldshape2.gp$Y[oldshape2.gp$Y > -.25 & oldshape2.gp$Y < .25] <- oldshape2.gp$Y[oldshape2.gp$Y > -.25 & oldshape2.gp$Y < .25] - .015 * sin((oldshape2.gp$Y[oldshape2.gp$Y > -.25 & oldshape2.gp$Y < .25] + .25) * 2 * pi)
    addPolysSingly(oldshape2.gp, border=border, col=get.col(oldshape2.gp, col))

    aussie.gp <- ausshape
    aussie.gp$X <- aussie.gp$X - 265 + 30 + 1
    aussie.gp$X <- aussie.gp$X * pi / 180
    aussie.gp$Y <- 2 * sin(aussie.gp$Y * pi / 180)
    aussie.gp$Y[aussie.gp$Y > 0] <- aussie.gp$Y[aussie.gp$Y > 0] - .05 * sin(aussie.gp$Y[aussie.gp$Y > 0] * pi)
    aussie.gp$Y[aussie.gp$Y > -.25 & aussie.gp$Y < .25] <- aussie.gp$Y[aussie.gp$Y > -.25 & aussie.gp$Y < .25] - .015 * sin((aussie.gp$Y[aussie.gp$Y > -.25 & aussie.gp$Y < .25] + .25) * 2 * pi)
    addPolysSingly(aussie.gp, border=border, col=get.col(aussie.gp, col))

    shiftright.gp <- shiftright
    shiftright.gp$X <- shiftright.gp$X + .15
    shiftright.gp$X <- shiftright.gp$X * pi / 180
    shiftright.gp$Y <- 2 * sin(shiftright.gp$Y * pi / 180)
    shiftright.gp$Y[shiftright.gp$Y > 0] <- shiftright.gp$Y[shiftright.gp$Y > 0] - .05 * sin(shiftright.gp$Y[shiftright.gp$Y > 0] * pi)
    shiftright.gp$Y[shiftright.gp$Y > -.25 & shiftright.gp$Y < .25] <- shiftright.gp$Y[shiftright.gp$Y > -.25 & shiftright.gp$Y < .25] - .015 * sin((shiftright.gp$Y[shiftright.gp$Y > -.25 & shiftright.gp$Y < .25] + .25) * 2 * pi)
    addPolysSingly(shiftright.gp, border=border, col=get.col(shiftright.gp, col))

    shiftleft.gp <- shiftleft
    shiftleft.gp$X <- shiftleft.gp$X - 5 + 1
    shiftleft.gp$X <- shiftleft.gp$X * pi / 180
    shiftleft.gp$Y <- 2 * sin(shiftleft.gp$Y * pi / 180)
    shiftleft.gp$Y[shiftleft.gp$Y > 0] <- shiftleft.gp$Y[shiftleft.gp$Y > 0] - .05 * sin(shiftleft.gp$Y[shiftleft.gp$Y > 0] * pi)
    shiftleft.gp$Y[shiftleft.gp$Y > -.25 & shiftleft.gp$Y < .25] <- shiftleft.gp$Y[shiftleft.gp$Y > -.25 & shiftleft.gp$Y < .25] - .015 * sin((shiftleft.gp$Y[shiftleft.gp$Y > -.25 & shiftleft.gp$Y < .25] + .25) * 2 * pi)
    addPolysSingly(shiftleft.gp, border=border, col=get.col(shiftleft.gp, col))

    hawaii.gp <- hawshape
    hawaii.gp$X <- hawaii.gp$X + 63
    hawaii.gp$X <- hawaii.gp$X * pi / 180
    hawaii.gp$Y <- hawaii.gp$Y + .7
    hawaii.gp$Y <- 2 * sin((hawaii.gp$Y - 2) * pi / 180)
    addPolysSingly(hawaii.gp, border=border, col=get.col(hawaii.gp, col))
}

addSeams <- function(col) {
    ## Left old to New
    lines(c(-1.65, -.8, -.8), c(1, -.75, -1), col=col)
    ## New to right old
    lines(c(-.5, -.5, 0, 0), c(1, .4, -.25, -1), col=col)
    ## Hawaii
    lines(c(-1.552, -1.752, -1.752, -1.552, -1.552), c(.58, .58, .8, .8, .58), col=col)
}

splicerImage <- function(array, colors, breaks=NULL, add=F) {
    if (is.null(breaks)) {
        image(seq(-169.5, 61.5, length.out=dim(map)[1]) * pi / 180, seq(-1.035, 1.0, length.out=dim(map)[2]),
              array, col=colors, asp=1, ylim=c(-1, 1), xlim=c(-2.95, 1.05), add=add, xaxt="n", yaxt="n", xlab="", ylab="")
    } else {
        image(seq(-169.5, 61.5, length.out=dim(map)[1]) * pi / 180, seq(-1.035, 1.0, length.out=dim(map)[2]),
              array, col=colors, breaks=breaks, asp=1, ylim=c(-1, 1), xlim=c(-2.95, 1.05), add=add, xaxt="n", yaxt="n", xlab="", ylab="")
    }
}
