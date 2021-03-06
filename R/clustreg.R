get.coef <- function(mod) {
  require(sandwich, quietly = TRUE)
  require(lmtest, quietly = TRUE)

  chc <- vcovHC(mod, type="HC")
  cts <- coeftest(mod, chc)
  return(cts[2,])
}

get.coef.clust <- function(mod, cluster, var=NA) {
  require(sandwich, quietly = TRUE)
  require(lmtest, quietly = TRUE)

  not <- attr(mod$model,"na.action")
  if (!is.null(not)) {
    cluster <- as.factor(as.character(cluster[-not]))
  }

  M <- length(unique(cluster))
  N <- length(cluster)
  K <- mod$rank
  dfc <- (M/(M-1))*((N-1)/(N-K))
  uj  <- apply(estfun(mod), 2, function(x) tapply(x, cluster, sum))
  vcovCL <- dfc*sandwich(mod, meat=crossprod(uj)/N)
  cts <- coeftest(mod, vcovCL)

  if (length(var) > 1 || !is.na(var)) {
      return(cts[var,])
  } else {
      return(cts)
  }
}

get.conf.clust <- function(mod, cluster, var, xx, alpha) {
    require(sandwich, quietly = TRUE)
    require(lmtest, quietly = TRUE)

    not <- attr(mod$model,"na.action")
    if (!is.null(not)) {
        cluster <- cluster[-not]
    }

    M <- length(unique(cluster))
    N <- length(cluster)
    K <- mod$rank
    dfc <- (M/(M-1))*((N-1)/(N-K))
    uj  <- apply(estfun(mod), 2, function(x) tapply(x, cluster, sum))
    vcovCL <- dfc*sandwich(mod, meat=crossprod(uj)/N)

    results <- data.frame(yhat=c(), lo=c(), hi=c())
    for (ii in 1:nrow(xx)) {
        myxx <- rep(0, length(mod$coefficients))
        myxx[var] <- as.numeric(xx[ii,])

        yhat <- sum(mod$coefficients * myxx, na.rm=T)
        myxxnn <- myxx[!is.na(mod$coefficients)]
        predscale <- as.numeric(sqrt(t(myxxnn) %*% vcovCL %*% myxxnn))
        hi <- yhat + abs(qt(alpha / 2, N - (K+1))) * predscale
        lo <- yhat - abs(qt(alpha / 2, N - (K+1))) * predscale

        results <- rbind(results, data.frame(yhat=yhat, lo=lo, hi=hi))
    }

    return(results)
}
