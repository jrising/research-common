library(ggplot2)
library(dplyr)

gg.usmap <- function(values, fips, borders=NA) {
    df <- data.frame(values, fips, borders)
    data(county.fips)

    map.county <- map_data('county')
    map.county$polyname <- paste(map.county$region, map.county$subregion, sep=',')
    counties <- map.county %>% left_join(county.fips) %>% left_join(df)

    if (class(borders) == "logical")
        ggplot(counties, aes(x=long, y=lat, group=group, fill=values)) +
            geom_polygon() + coord_map() + theme_minimal() + xlab(NULL) + ylab(NULL)
    else
        ggplot(counties, aes(x=long, y=lat, group=group, fill=values, colour=borders)) +
            geom_polygon() + coord_map() + theme_minimal() + xlab(NULL) + ylab(NULL)
}
