source("../names.R")
source("../global-merge.R")

download.file("http://github.org/jrising/national-data/master/faostat/coffee-green.tsv", "coffee-green.tsv")
download.file("http://github.org/jrising/national-data/master/nationalearth/ne_110m_admin_0_countries/centroids.csv", "centroids.csv")

frm1 <- read.delim("faostat-green.tsv")
names1 <- unique(as.character(frm1[, 1]))

frm2 <- read.csv("centroids.csv")
names2 <- frm2$admin

names1.as.names2 <- sapply(sapply(names1, any2canonical), canonical2naturalearth)

matches <- match.global(names1, 'country', names2, 'country')

satisfied <- rep(F, length(names1))
for (ii in 1:length(matches)) {
    if (is.null(matches[[ii]][[1]]) || is.null(matches[[ii]][[2]]))
        next

    if (length(matches[[ii]][[1]]) > 1 || length(matches[[ii]][[2]]) > 2)
        next

    item <- which(names1 == matches[[ii]][1])[1]
    if (names1.as.names2[item] == matches[[ii]][2])
        satisfied[item] <- T
}

