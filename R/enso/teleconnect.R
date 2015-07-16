source("~/projects/research-common/R/enso/years.R")

library(splines)
library(car)

mod.teleconnected <- function(years, series, yrdf=5) {
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

  lm(series ~ 0 + el0 + el1 + la0 + la1 + ns(years, df=yrdf), data=frm)
}

is.teleconnected <- function(years, series, yrdf=5, alpha=NA) {
    res <- tryCatch({
        mod <- mod.teleconnected(years, series, yrdf)
        res <- linearHypothesis(mod, c("el0", "el1", "la0", "la1"))
        if (is.na(alpha))
          coeffs <- mod$coeff[1:4]
        else {
          cis <- confint(mod, alpha=alpha)
          issig <- sign(cis[1:4,1]) == sign(cis[1:4,2])
          coeffs <- mod$coeff[1:4] * issig
        }
        c(res[2,"Pr(>F)"], coeffs)
    }, error=function(cond) {
      rep(NA, 5)
    })

    return(res)
}

