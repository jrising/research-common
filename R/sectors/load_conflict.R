use.interstate <- T

tbl.conflict <- read.delim("Main Conflict Table.csv", sep=",")

dlens <- nchar(as.character(tbl.conflict$StartDate))
dyear <- as.numeric(substr(tbl.conflict$StartDate, dlens-1, dlens))
dpref <- ifelse(dyear < 20, "20", "19")
tbl.conflict$start <- as.Date(paste(substr(tbl.conflict$StartDate, 0, dlens-2), dpref, substr(tbl.conflict$StartDate, dlens-1, dlens), sep=""), "%m/%d/%Y")

dlens <- nchar(as.character(tbl.conflict$StartDate2))
dyear <- as.numeric(substr(tbl.conflict$StartDate2, dlens-1, dlens))
dpref <- ifelse(dyear < 20, "20", "19")
tbl.conflict$start2 <- as.Date(paste(substr(tbl.conflict$StartDate2, 0, dlens-2), dpref, substr(tbl.conflict$StartDate2, dlens-1, dlens), sep=""), "%m/%d/%Y")
tbl.conflict$start2year <- as.numeric(paste(dpref, substr(tbl.conflict$StartDate2, dlens-1, dlens), sep=""))

years = 1961:2008
conflict <- data.frame(year=c(), location=c(), conflict=c())

alllocs <- c()
for (location in unique(tbl.conflict$Location)) {
  locations = strsplit(location, ", ")[[1]]
  if (use.interstate || length(locations) == 1)
    alllocs <- c(alllocs, locations)
}
for (location in unique(alllocs)) {
  croploc <- location
  if (croploc == "United States of America")
    croploc <- "USA"
  if (croploc == "Democratic Republic of Congo (Zaire)")
    croploc <- "Congo"
  if (croploc == "Russia (Soviet Union)")
    croploc <- "USSR"
  if (croploc == "Sri Lanka (Ceylon)")
    croploc <- "Sri Lanka"
  if (croploc == "Zimbabwe (Rhodesia)")
    croploc <- "Zimbabwe"
  if (croploc == "Turkey/Ottoman Empire")
    croploc <- "Turkey"
  if (croploc == "Surinam")
    croploc <- "Suriname"
  if (croploc == "Yugoslavia (Serbia)")
    croploc <- "Yugoslavia"
  for (year in years) {
    if (use.interstate)
      num <- sum(tbl.conflict$YEAR[grep(location, tbl.conflict$Location)] == year)
    else
      num <- sum(tbl.conflict$YEAR[tbl.conflict$Location == location] == year)
    conflict <- rbind(conflict, data.frame(year=year, location=location, croploc=croploc, conflict=num))
  }
}

conflict.by.cy <- function(frm) {
  cyc <- rep(F, nrow(frm))
  for (country in unique(frm$country)) {
    for (year in unique(frm$year)) {
      found <- conflict$croploc == country & conflict$year == year
      if (sum(found) == 1)
        cyc[frm$country == country & frm$year == year] <- conflict$conflict[found] > 0
    }
  }

  return(cyc)
}

cy.delays <- function(frm, delays, predictor) {
  mods <- data.frame(dy=c(), low=c(), high=c(), mean=c())
  for (dy in delays) {
    start <- max(0, dy) + min(frm$year)
    end <- min(0, dy) + max(frm$year)
    dfrm <- data.frame(year=c(), country=c(), conflict=c(), pred=c())
    for (ll in unique(frm$country)) {
      y0 <- max(0, -dy) + min(frm$year)
      for (yy in start:end) {
        if (length(frm$conflict[frm$country == ll & frm$year == y0]) > 0 && length(predictor[frm$country == ll & frm$year == yy]) > 0)
          dfrm <- rbind(dfrm, data.frame(year=c(yy), country=c(ll), conflict=c(frm$conflict[frm$country == ll & frm$year == y0]), pred=c(predictor[frm$country == ll & frm$year == yy])))
        y0 <- y0 + 1
      }
    }
    mod <- glm(conflict ~ pred + factor(country) + factor(year), data=dfrm, family=binomial(link=probit))
    cis <- confint(mod, 2)
    mods <- rbind(mods, data.frame(dy=c(dy), low=c(cis[1]), high=c(cis[2]), mean=c(mod$coefficients[2])))
    print(mods)
  }

  return(mods)
}

# Predictor2 is the control
cy.delays2 <- function(frm, delays, predictor1, predictor2) {
  mods <- data.frame(dy=c(), low=c(), high=c(), mean=c())
  for (dy in delays) {
    start <- max(0, dy) + min(frm$year)
    end <- min(0, dy) + max(frm$year)
    dfrm <- data.frame(year=c(), country=c(), conflict=c(), pred=c())
    for (ll in unique(frm$country)) {
      y0 <- max(0, -dy) + min(frm$year)
      for (yy in start:end) {
        if (length(frm$conflict[frm$country == ll & frm$year == y0]) > 0 && length(predictor1[frm$country == ll & frm$year == yy]) > 0 && length(predictor2[frm$country == ll & frm$year == yy]) > 0)
          dfrm <- rbind(dfrm, data.frame(year=c(yy), country=c(ll), conflict=c(frm$conflict[frm$country == ll & frm$year == y0]), pred1=c(predictor1[frm$country == ll & frm$year == yy]), pred2=c(predictor2[frm$country == ll & frm$year == yy])))
        y0 <- y0 + 1
      }
    }
    mod <- glm(conflict ~ pred1 + pred2 + factor(country) + factor(year), data=dfrm, family=binomial(link=probit))
    cis <- confint(mod, 2)
    mods <- rbind(mods, data.frame(dy=c(dy), low=c(cis[1]), high=c(cis[2]), mean=c(mod$coefficients[2])))
    print(mods)
  }

  return(mods)
}
