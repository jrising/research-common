#================================================================
## Conley Standard Errors
## Date: August 21, 2017
## Vectorized Code using Rcpp
#================================================================

pkgs <- c("data.table", "lfe", "geosphere", "Rcpp", "RcppArmadillo")
invisible(sapply(pkgs, require, character.only = TRUE))
sourceCpp("cpp-functions.cpp")

#' Returns conley SEs corrected for spatial autocorrelation
#'
#' @param reg a regression-like object
#' @param unit character indicating unit
#' @param time character indicating time
#' @param lat character indicating latitude
#' @param lon character indicating longitude
#' @param kernel kernel for weights. defualts to bartlett
#' @param dist_fn distance function. defaults to haversine
#' @param dist_cutoff distance for cutoff. defaults to 500
#' @param lag_cutoff lag of cutoff. defaults to 5
#' @param lat_scale scale. defaults to 111
#' @param verbose verbose output. defaults to FALSE
#' @param cores number of cores to use. defaults to 1
#' @param balanced_pnl logical for whether balanced panel. defaults to FALSE
#'
#'
#' @examples
#' ConleySEs()
#'
#' @export
ConleySEs <- function(reg, df,
    unit, time, lat, lon,
    kernel = "bartlett", dist_fn = "Haversine",
    dist_cutoff = 500, lag_cutoff = 5,
    lat_scale = 111, verbose = FALSE, cores = 1, balanced_pnl = FALSE) {

    crossprod.inverse <- function(X) {
        if(require(corpcor)) {
            inv <- corpcor::pseudoinverse(crossprod(X))
        } else if(require(MASS)) {
            inv <- MASS::ginv(X)
        } else {
            inv <- tryCatch(solve(crossprod(X)), error = function(e) e)
            if(class(inv) == "error") {
                stop("Matrix is computationally singular. Please install packages 'MASS' or 'corpcor' for pseudoinverse calculations.")
            }
        }

        ## Keep column names if they exist
        if(is.null(colnames(inv)) & !is.null(colnames(X))) {
            colnames(inv) <- colnames(X)
            rownames(inv) <- colnames(X)
        }
        inv
    }

    #' Iterates over objects
    #'
    #' @export
    iterateObs <- function(sub_index, type, cutoff, ...) {
        if(type == "spatial" & balanced_pnl) {

            sub_dt <- dt[time == sub_index]
            n1 <- nrow(sub_dt)
            if(n1 > 1000 & verbose){message(paste("Starting on sub index:", sub_index))}

            X <- as.matrix(sub_dt[, eval(Xvars), with = FALSE])
            e <- sub_dt[, e]

            XeeXhs <- Bal_XeeXhC(d, X, e, n1, k)

        } else if(type == "spatial" & !balanced_pnl) {

            sub_dt <- dt[time == sub_index]
            n1 <- nrow(sub_dt)
            if(n1 > 1000 & verbose){message(paste("Starting on sub index:", sub_index))}

            X <- as.matrix(sub_dt[, eval(Xvars), with = FALSE])
            e <- sub_dt[, e]
            lat <- sub_dt[, lat]; lon <- sub_dt[, lon]

            ## If n1 >= 50k obs, then avoiding construction of distance matrix.
            ## This requires more operations, but is less memory intensive.
            if(n1 < 5 * 10^4) {
                XeeXhs <- XeeXhC(cbind(lat, lon), cutoff, X, e, n1, k,
                                 kernel, dist_fn)
            } else {
                XeeXhs <- XeeXhC_Lg(cbind(lat, lon), cutoff, X, e, n1, k,
                                    kernel, dist_fn)
            }

        } else if(type == "serial") {
            sub_dt <- dt[unit == sub_index]
            n1 <- nrow(sub_dt)
            if(n1 > 1000 & verbose){message(paste("Starting on sub index:", sub_index))}

            X <- as.matrix(sub_dt[, eval(Xvars), with = FALSE] )
            e <- sub_dt[, e]
            times <- sub_dt[, time]

            XeeXhs <- TimeDist(times, cutoff, X, e, n1, k)
        }

        XeeXhs
    }

    if(cores > 1) {invisible(library(parallel))}

    if(class(reg) == "felm") {
        Xvars <- rownames(reg$coefficients)
        dt = data.table(reg$cY, reg$cX,
                        unit=df[, unit], time=df[, time], lat=df[, lat], lon=df[, lon])
        dt = dt[, e := as.numeric(reg$residuals)]

    } else {
        message("Model class not recognized.")
        break
    }

    n <- nrow(dt)
    k <- length(Xvars)

    # Empty Matrix:
    XeeX <- matrix(nrow = k, ncol = k, 0)

    #================================================================
    # Correct for spatial correlation:
    timeUnique <- unique(dt[, time])
    Ntime <- length(timeUnique)
    setkey(dt, time)

    if(verbose){message("Starting to loop over time periods...")}

    if(balanced_pnl){
        sub_dt <- dt[time == timeUnique[1]]
        lat <- sub_dt[, lat]; lon <- sub_dt[, lon]; rm(sub_dt)

        if(balanced_pnl & verbose){message("Computing Distance Matrix...")}

        d <- DistMat(cbind(lat, lon), cutoff = dist_cutoff, kernel, dist_fn)
        rm(list = c("lat", "lon"))
    }

    if(cores == 1) {
        XeeXhs <- lapply(timeUnique, function(t) iterateObs(sub_index = t,
            type = "spatial", cutoff = dist_cutoff))
    } else {
        XeeXhs <- mclapply(timeUnique, function(t) iterateObs(sub_index = t,
            type = "spatial", cutoff = dist_cutoff), mc.cores = cores)
    }

    if(balanced_pnl){rm(d)}

    # First Reduce:
	XeeX <- Reduce("+",  XeeXhs)

    # Generate VCE for only cross-sectional spatial correlation:
    X <- as.matrix(dt[, eval(Xvars), with = FALSE])
    invXX <- crossprod.inverse(X) * n

    V_spatial <- invXX %*% (XeeX / n) %*% invXX / n

    V_spatial <- (V_spatial + t(V_spatial)) / 2

    if(verbose) {message("Computed Spatial VCOV.")}

    #================================================================
    # Correct for serial correlation:
    panelUnique <- unique(dt[, unit])
    Npanel <- length(panelUnique)
    setkey(dt, unit)

    if(verbose){message("Starting to loop over units...")}

    if(cores == 1) {
        XeeXhs <- lapply(panelUnique, function(t) iterateObs(sub_index = t,
            type = "serial", cutoff = lag_cutoff))
    } else {
        XeeXhs <- mclapply(panelUnique,function(t) iterateObs(sub_index = t,
            type = "serial", cutoff = lag_cutoff), mc.cores = cores)
    }

	XeeX_serial <- Reduce("+",  XeeXhs)

	XeeX <- XeeX + XeeX_serial

    V_spatial_HAC <- invXX %*% (XeeX / n) %*% invXX / n
    V_spatial_HAC <- (V_spatial_HAC + t(V_spatial_HAC)) / 2

    return_list <- list(
        "OLS" = reg$vcv,
        "Spatial" = V_spatial,
        "Spatial_HAC" = V_spatial_HAC)
    return(return_list)
}
