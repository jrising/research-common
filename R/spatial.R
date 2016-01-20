## Requires source("distance.R")

prepareEvents <- function(lons, lats, proj.abbr) {
    pts <- expand.grid(x=lons, y=lats)
    events <- data.frame(EID=1:nrow(pts), X=pts$x, Y=pts$y)
    events <- as.EventData(events, projection=proj.abbr)

    ## Add rows and columns
    events$row <- NA
    for (ii in 1:length(lats))
        events$row[events$Y == lats[ii]] <- ii

    events$col <- NA
    for (ii in 1:length(lons))
        events$col[events$X == lons[ii]] <- ii

    events
}

prepareChunkEvents <- function(lons, lats, polys) {
    inlons <- lons >= min(polys$X) & lons <= max(polys$X)
    inlats <- lats >= min(polys$Y) & lats <= max(polys$Y)

    pts <- expand.grid(x=lons[inlons], y=lats[inlats])
    events <- data.frame(EID=1:nrow(pts), X=pts$x, Y=pts$y)
    events <- as.EventData(events, projection=attributes(polys)$projection)

    ## Add rows and columns
    events$row <- NA
    for (ii in which(inlats))
        events$row[events$Y == lats[ii]] <- ii

    events$col <- NA
    for (ii in which(inlons))
        events$col[events$X == lons[ii]] <- ii

    events
}

getClosest <- function(one.lon, one.lat, many.lon, many.lat) {
    dists <- gcd.slc(one.lon, one.lat, many.lon, many.lat)
    which.min(dists)
}

get.closest.indices <- function(master.lon, master.lat, many.lon, many.lat) {
    indexes <- c()
    for (ii in 1:length(master.lon)) {
        dists <- gcd.slc(master.lon[ii], master.lat[ii], many.lon, many.lat)
        indexes <- c(indexes, which.min(dists))
    }

    indexes
}

oneOrMoreEventsWithin <- function(events, polys) {
    eids <- findPolys(events, polys, maxRows=6e5)$EID

    if (length(eids) == 0) {
        centroid <- calcCentroid(polys, rollup=1)

        ## Consider all points in grid
        eids <- getClosest(centroid$X, centroid$Y, events$X, events$Y)
    }

    eids
}

get.as.indexed <- function(grid, rows, cols) {
    grid[(cols - 1) * nrow(grid) + rows]
}

get.index <- function(grid, rows, cols) {
    (cols - 1) * nrow(grid) + rows
}

spaceTimeRasterAverage <- function(events, lonlattimeraster, polys) {
    eids <- oneOrMoreEventsWithin(events, polys)

    ## Iterate through all times
    numtimes <- dim(lonlattimeraster)[3]
    averages <- rep(NA, numtimes)
    for (tt in 1:numtimes)
        averages[tt] <- mean(get.as.indexed(lonlattimeraster[, , tt], events$col[eids], events$row[eids]), na.rm=T)

    averages
}

transformToIndex <- function(from.range.values, to.range) {
    ## Assumes that to.range is in increasing order and approximately evenly spaced
    indices <- round(length(to.range) * (from.range.values - to.range[1]) / (to.range[length(to.range)] - to.range[1])) + 1
    indices[indices < 1] <- NA
    indices[indices > length(to.range)] <- NA
    indices
}

spaceTimeWeightedRasterAverage <- function(events, lonlattimeraster, polys, weights, weights.lon, weights.lat) {
    ## Identify the points within the polygon
    eids <- oneOrMoreEventsWithin(events, polys)

    ## Weigh each point by its closest available weight
    eid.weights <- get.as.indexed(weights, transformToIndex(events$X[eids], weights.lon), transformToIndex(events$Y[eids], weights.lat))

    valid.weights <- !is.na(eid.weights)

    eids <- eids[valid.weights]
    eid.weights <- eid.weights[valid.weights]

    ## Iterate through all times
    numtimes <- dim(lonlattimeraster)[3]
    averages <- rep(NA, numtimes)
    for (tt in 1:numtimes)
        averages[tt] <- weighted.mean(get.as.indexed(lonlattimeraster[, , tt], events$col[eids], events$row[eids]), eid.weights, na.rm=T)

    averages
}

spatialIntegral.old <- function(density, polys) {
  events <- data.frame(EID=1:nrow(density), X=density$Center.Long, Y=density$Center.Lat)
  events <- as.EventData(events, projection=proj.abbr)

  eids <- findPolys(events, polys, maxRows=6e5)$EID

  if (length(eids) == 0) {
    centroid <- calcCentroid(polys, rollup=1)

    # Consider all points in grid
    lons <- seq(-179.75, 179.75, by=.5)
    lats <- seq(-89.75, 89.75, by=.5)
    pts <- expand.grid(x=lons, y=lats)

    dists <- sqrt((pts$x - centroid$X)^2 + (pts$y - centroid$Y)^2)
    closest <- which.min(dists)[1]
    matching = pts$x[closest] == events$X & pts$y[closest] == events$Y
    if (sum(matching) > 0)
      return(density$Overall.Probability[matching])
    else
      return(0)
  }

  return(sum(density$Overall.Probability[eids]))
}

spatialIntegral <- function(events, density, polys) {
    eids <- oneOrMoreEventsWithin(events, polys)
    sum(get.as.indexed(density, events$row[eids], events$col[eids]))
}
