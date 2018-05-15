library(ggplot2)
library(dplyr)

gg.usmap <- function(values, fips) {
    df <- data.frame(values, fips)
    data(county.fips)

    map.county <- map_data('county')
    map.county$polyname <- paste(map.county$region, map.county$subregion, sep=',')
    counties <- map.county %>% left_join(county.fips) %>% left_join(df)

    ggplot(counties, aes(x=long, y=lat, group=group, fill=values)) +
        geom_polygon() + coord_map() + theme_minimal() + xlab(NULL) + ylab(NULL)
}
