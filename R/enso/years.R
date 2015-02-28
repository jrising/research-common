event.start <- c(1950, 1951, 1955, 1956, 1957,
                 1963, 1964, 1965, 1968, 1969,
                 1970, 1971, 1972, 1973, 1974,
                 1975, 1976, 1977, 1982, 1986,
                 1987, 1988, 1991, 1994, 1997,
                 1989, 2000, 2002, 2004, 2006,
                 2007, 2009, 2010)
event.class <- factor(c("lanina", "traditional", "lanina", "lanina", "modoki",
                        "modoki", "lanina", "modoki", "modoki", "traditional",
                        "lanina", "lanina", "traditional", "lanina", "lanina",
                        "lanina", "traditional", "modoki", "traditional", "modoki",
                        "traditional", "lanina", "modoki", "modoki", "traditional",
                        "lanina", "lanina", "modoki", "modoki", "traditional",
                        "lanina", "traditional", "lanina")) # not sure about these

event.class.two <- as.character(event.class)
event.class.two[event.class == 'traditional' | event.class == 'modoki'] <- "elnino"
event.class.two <- factor(event.class.two)
