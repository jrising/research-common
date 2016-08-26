### Use a sinusoidal approximation to estimate the number of Growing
### Degree-Days above a given threshold, using daily minimum and
### maximum temperatures.
above.threshold <- function(mins, maxs, threshold) {
    ## Determine crossing points, as a fraction of the day
    plus.over.2 = (mins + maxs)/2
    minus.over.2 = (maxs - mins)/2
    two.pi = 2*pi
    ## d0s is the times of crossing above; d1s is when cross below
    d0s = asin((threshold - plus.over.2) / minus.over.2) / two.pi
    d1s = .5 - d0s

    ## If always above or below threshold, set crossings accordingly
    aboves = mins > threshold
    belows = maxs < threshold

    d0s[aboves] = 0
    d1s[aboves] = 1
    d0s[belows] = 0
    d1s[belows] = 0

    ## Calculate integral
    F1s = -minus.over.2 * cos(2*pi*d1s) / two.pi + plus.over.2 * d1s
    F0s = -minus.over.2 * cos(2*pi*d0s) / two.pi + plus.over.2 * d0s
    return(sum(F1s - F0s - threshold * (d1s - d0s)))
}

### Get the Growing Degree-Days, as degree-days between gdd.start and
### kdd.start, and Killing Degree-Days, as the degree-days above
### kdd.start.
get.gddkdd <- function(mins, maxs, gdd.start, kdd.start) {
    dd.lowup = above.threshold(mins, maxs, gdd.start)
    dd.above = above.threshold(mins, maxs, kdd.start)
    dd.lower = dd.lowup - dd.above

    return(c(dd.lower, dd.above))
}

### Determine the portion of each day above the threshold
### This is not a degree-day: each day can contribute at most 1.0.
above.portion <- function(mins, maxs, threshold) {
    knowns <- rep(NA, length(mins))

    ## If always above or below threshold, set crossings accordingly
    knowns[mins > threshold] <- 1
    knowns[maxs < threshold] <- 0

    namins <- mins[is.na(knowns)]
    namaxs <- maxs[is.na(knowns)]
    knowns[is.na(knowns)] <- acos((2 * threshold - namins - namaxs) / (namaxs - namins)) / pi

    sum(knowns)
}
