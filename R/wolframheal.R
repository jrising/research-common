## starts centers are vectors of either NA (exclude series) or the index to start from and to line up with '0', respectively
## group and yys are the same length; group consists of numbers from 1:length(centers)
plot.wolframheal <- function(yys, group, starts, centers, ylim=c(-1, 8), xlim=c(-25, 25), main="Wolfram Plot", ylab="Y", xlab="X", normfunc=function(yy) sd(yy, na.rm=T), yintercept=0) {
    par(fig=c(0, 1, .25, 1), xaxt='n', mar=c(0, 4, 2, 2))

    ## Number of observations at value x
    count <- rep(0, diff(xlim))
    ## The actual observations
    vals <- list()
    for (ll in 1:(diff(xlim) + 1))
        vals[[ll]] <- -999 # Special 'empty' case

    obs <- data.frame(ii=c(), yy=c(), vals=c())

    ## Set up the plot
    plot(c(xlim[1], 0, 0, 0, xlim[2]), c(0, 0, ylim[2], 0, 0), type="n", ylim=ylim, col=4, xaxs="i", main=main, ylab=ylab)
    for (ii in 1:length(centers)) {
        if (is.na(centers[ii]))
            next

        yy <- yys[group == ii]
        yy <- yy[starts[ii]:length(yy)]
        xx <- (-(centers[ii] - starts[ii] + 1) + 1):(length(yy) - centers[ii] + starts[ii] - 1)

        norm <- normfunc(yy[1:(centers[ii] - starts[ii])])
        if (is.na(norm) || norm < 0)
            next

        print(c(ii, length(xx), length(yy)))
        lines(xx, yy / norm, col="#808080")
        valid <- xx >= xlim[1] & xx <= xlim[2] & !is.na(yy)
        count[xx[valid] - xlim[1] + 1] <- count[xx[valid] - xlim[1] + 1] + 1

        for (ll in xx[valid] - xlim[1] + 1) {
            if (length(vals[[ll]]) == 1 && vals[[ll]] == -999) {
                vals[[ll]] <- yy[valid][ll - min(xx[valid] - xlim[1] + 1) + 1] / norm
            } else {
                vals[[ll]] <- c(vals[[ll]], yy[valid][ll - min(xx[valid] - xlim[1] + 1) + 1] / norm)
            }
        }
        obs <- rbind(obs, data.frame(ii=rep(ii, length(xx)), xx=xx, vals=yy / norm))
    }

    lines(xlim, rep(yintercept, 2), col=3, lty=2)

    means <- c()
    for (ll in 1:(diff(xlim) + 1)) {
        if (length(vals) > 1 || vals[[ll]] != -999) {
            means <- c(means, mean(vals[[ll]], na.rm=T))
        }
    }
    lines(xlim[1]:xlim[2], means, col=2)

    ##medians <- c()
    ##for (ll in 1:(diff(xlim) + 1)) {
    ##  if (length(vals) > 1 || vals[[ll]] != -999) {
    ##    medians <- c(medians, median(vals[[ll]], na.rm=T))
    ##  }
    ##}
    ##lines(xlim[1]:xlim[2], medians, col=4)

    print(nrow(obs))
    obs$post <- obs$xx > 0
    obs$post.trend <- (obs$xx > 0) * obs$xx
    mod <- lm(vals ~ xx + post + post.trend, data=obs)

    xxnew <- xlim[1]:xlim[2]
    valsnew <- predict(mod, data.frame(xx=xxnew, post=xxnew > 0, post.trend=(xxnew > 0) * xxnew), interval = "confidence")
    lines(xxnew, valsnew[,1], col=4)
    lines(xxnew, valsnew[,2], col=4, lty=2)
    lines(xxnew, valsnew[,3], col=4, lty=2)

    par(xaxt='s')
    axis(1, pos=c(-2.7, 0))
    mtext(xlab, side=1, line=4)

    par(fig=c(0, 1, .07, .24), new=T, mar=c(2, 4, 0, 2), xaxt='s')
    barplot(count, xaxs="i")
}
