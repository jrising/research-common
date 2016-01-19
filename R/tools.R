matching.indices <- function(master, many) {
    indices <- c()
    for (ii in 1:length(master)) {
        index <- which(many == master[ii])
        if (length(index) > 1)
            print(c(master[ii], index))
        if (length(index) == 0)
            indices <- c(indices, NA)
        else
            indices <- c(indices, index)
    }

    indices
}
