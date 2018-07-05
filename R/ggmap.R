library(ggplot2)
library(dplyr)

gg.usmap <- function(values, fips, borders=NA, extra.polygon.aes=c()) {
    df <- data.frame(values, fips, borders)
    data(county.fips)

    map.county <- map_data('county')
    map.county$polyname <- paste(map.county$region, map.county$subregion, sep=',')
    counties <- map.county %>% left_join(county.fips) %>% left_join(df)

    map.state <- map_data('state')
    
    if (class(borders) == "logical") {
        polygon.aes <- c(aes(fill=values), extra.polygon.aes)
        class(polygon.aes) <- "uneval"
        ggplot(counties, aes(x=long, y=lat, group=group)) +
            geom_polygon(polygon.aes) +
            coord_map() + theme_minimal() + xlab(NULL) + ylab(NULL) +
            geom_polygon(data=map.state, fill="#00000000", colour="#FFFFFF80", size=.3)
    } else {
        polygon.aes <- c(aes(fill=values, colour=borders), extra.polygon.aes)
        class(polygon.aes) <- "uneval"
        ggplot(counties, aes(x=long, y=lat, group=group)) +
            geom_polygon(polygon.aes) +
            coord_map() + theme_minimal() + xlab(NULL) + ylab(NULL) +
            geom_polygon(data=map.state, fill="#00000000", colour="#FFFFFF80", size=.3)
    }
}
