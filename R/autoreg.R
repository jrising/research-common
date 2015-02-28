make.formula <- function(yvar, preds, include.intercept=T) {
  if (include.intercept)
    formula <- paste(yvar, "~", "1")
  else
    formula <- paste(yvar, "~", "0")
    
  for (name in names(preds))
    formula <- paste(formula, "+", name)

  return(as.formula(formula))
}

delay.data <- function(data, groups, times) {
  if (class(data) == "data.frame") {
    delays = data
    delays[1:dim(delays)[1], 1:dim(delays)[2]] <- NA

    for (ii in 1:nrow(data)) {
      values <- data[times == times[ii] + 1 & groups == groups[ii],]
      if (nrow(values) == 1)
        delays[ii,] <- values
      else if (nrow(values) > 1)
        print(paste("Multiple values for group", groups[ii], "and time", times[ii] + 1))
    }
  } else {
    delays <- rep(NA, length(data)) # the next error (if there is one) within each group

    for (ii in 1:length(data)) {
      values <- data[times == times[ii] + 1 & groups == groups[ii]]
      if (length(values) == 1)
        delays[ii] <- values
      else if (length(values) > 1)
        print(paste("Multiple values for group", groups[ii], "and time", times[ii] + 1))
    }
  }

  return(delays)
}

autoreg <- function(yy, preds, groups, times, include.intercept=T, iterations=10) {
  formula <- make.formula("yy", preds, include.intercept)
  mod <- lm(formula, data=preds)

  for (ii in 1:iterations) {
    error <- mod$residuals
    posts <- delay.data(error, groups, times) # the next error (if there is one) within each group
      
    alpha <- lm(posts ~ 0 + error)$coeff[1]
    print(paste("Iteration", ii, ":", as.numeric(alpha)))

    yya <- delay.data(yy, groups, times) - alpha * yy
    predsa <- delay.data(preds, groups, times) - alpha * preds

    formula <- make.formula("yya", predsa, include.intercept)
    predsa$yya <- yya
    mod <- lm(formula, data=predsa)
  }

  return(mod$coeff / (1 - alpha))
}
