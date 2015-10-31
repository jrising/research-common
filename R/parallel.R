under.lock <- function(name, callback) {
    write("Attempting to get lock", stderr())
    system(paste0("lockfile ", name, ".lock"))

    result <- callback()

    write("Releasing lock", stderr())
    remove.file(paste0(name, ".lock"))

    result
}

read.csv.locked <- function(filename) {
    under.lock(filename, function() {
                   if (file.exists(filename)) {
                       read.csv(filename)
                   } else {
                       data.frame()
                   }
               })
}

append.csv.locked <- function(filename, line) {
    under.lock(filename, function() {
                   if (file.exists(filename)) {
                       tbl <- read.csv(filename)
                       tbl <- rbind(tbl, line)
                       write.csv(tbl, file=filename, row.names=F)
                       return(tbl)
                   } else {
                       write.csv(line, file=filename, row.names=F)
                       return(line)
                   }
               })
}

