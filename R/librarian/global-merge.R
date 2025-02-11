match.global <- function(names1, type1, names2, type2) {
    ## Returns a list of four kinds of items:
    ##   list(string, string): Exact match
    ##   list(vector, string) or list(string, vector): Combined group matches other
    ##   list(vector, vector): Combined groups match eachother
    ##   list(NULL, vector) or list(vector, NULL): Missing in other
    ## Matches everything that is certain, to the most specific
    ## type1 and type2 should be one of 'country', 'sovereign', 'landmass', 'unknown'

    names1 <- unique(names1)
    names2 <- unique(names2)

    results <- list()

    if (type1 == type2 && type1 != 'unknown') {
        for (name1 in names1) {
            if (name1 %in% names2)
                results <- c(results, list(name1, name1))
            else
                results <- c(results, list(name1, NULL))
        }
        for (name2 in names2) {
            if (!(name2 %in% names1))
                results <- c(results, list(NULL, name2))
        }
    }

    results
}

