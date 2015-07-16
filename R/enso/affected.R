source("~/projects/research-common/R/enso/years.R")

library(splines)
library(car)

is.affected.noreg <- function(years, series, yrdf=5) {
    frm <- data.frame(series=series, years=years)

    ## Setup the ENSO years
    frm$el0 <- 0
    frm$el1 <- 0
    frm$la0 <- 0
    frm$la1 <- 0
        
    for (ei in 1:length(event.start)) {
        if (event.class.two[ei] == "elnino") {
            frm$el0[frm$years == event.start[ei]] <- 1
            frm$el1[frm$years == event.start[ei] + 1] <- 1
        } else {
            frm$la0[frm$years == event.start[ei]] <- 1
            frm$la1[frm$years == event.start[ei] + 1] <- 1
        }
    }

    return(lm(series ~ 0 + el0 + el1 + la0 + la1 + ns(years, df=yrdf), data=frm))
}


is.affected <- function(region, years, series, yrdf=5) {
    frm <- data.frame(region, series=series, years=years)

    ## Setup the ENSO years
    frm$el0 <- 0
    frm$el1 <- 0
    frm$la0 <- 0
    frm$la1 <- 0
        
    for (ei in 1:length(event.start)) {
        if (event.class.two[ei] == "elnino") {
            frm$el0[frm$years == event.start[ei]] <- 1
            frm$el1[frm$years == event.start[ei] + 1] <- 1
        } else {
            frm$la0[frm$years == event.start[ei]] <- 1
            frm$la1[frm$years == event.start[ei] + 1] <- 1
        }
    }

    return(lm(series ~ 0 + el0 + el1 + la0 + la1 + region * ns(years, df=yrdf), data=frm))
}

