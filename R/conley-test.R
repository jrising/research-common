## Try the test function

source("~/projects/research-common/R/conley-orig.R", chdir=T)

library(foreign)
dta_file <- "~/projects/research-common/stata/new_testspatial.dta"
DTA <- data.table(read.dta(dta_file))

setnames(DTA, c("latitude", "longitude"), c("lat", "lon"))

m <- felm(EmpClean00 ~ HDD + CDD | year + FIPS | 0 | lat + lon, data = DTA[!is.na(EmpClean00)], keepCX = TRUE)

SE <- ConleySEs(reg=m,
    unit = "FIPS",
    time = "year",
    lat = "lat", lon = "lon",
    dist_fn = "SH", dist_cutoff = 500,
    lag_cutoff = 5,
    cores = 1,
    verbose = FALSE)

sapply(SE, function(x) diag(sqrt(x))) # Matches Stata (but not what's reported in blog post).

## Try the same with my code

source("~/projects/research-common/R/conley.R", chdir=T)

dta_file <- "~/projects/research-common/stata/new_testspatial.dta"
DTA <- read.dta(dta_file)

m <- felm(EmpClean00 ~ HDD + CDD | year + FIPS, data = DTA[!is.na(DTA$EmpClean00),], keepCX = TRUE)

SE <- ConleySEs(m, DTA,
    unit = "FIPS",
    time = "year",
    lat = "latitude", lon = "longitude",
    dist_fn = "SH", dist_cutoff = 500,
    lag_cutoff = 5,
    cores = 1,
    verbose = FALSE)

sapply(SE, function(x) diag(sqrt(x))) # Matches Stata (but not what's reported in blog post).
