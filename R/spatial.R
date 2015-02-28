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

oneOrMoreEventsWithin <- function(events, polys) {
    eids <- findPolys(events, polys, maxRows=6e5)$EID

    if (length(eids) == 0) {
        centroid <- calcCentroid(polys, rollup=1)

        ## Consider all points in grid
        dists <- sqrt((events$X - centroid$X)^2 + (events$Y - centroid$Y)^2)

        eids <- which.min(dists)
    }

    eids
}

get.as.indexed <- function(grid, rows, cols) {
    grid[(cols - 1) * nrow(grid) + rows]
}

spaceTimeRasterAverage <- function(events, lonlattimeraster, polys) {
    eids <- oneOrMoreEventsWithin(events, polys)
    
    numtimes <- dim(lonlattimeraster)[3]
    averages <- rep(NA, numtimes)
    for (tt in 1:numtimes)
        averages[tt] <- mean(get.as.indexed(lonlattimeraster[, , tt], events$col[eids], events$row[eids]))

    averages
}

spatialIntegral <- function(density, polys) {
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

