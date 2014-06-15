library("dplyr")
library("reshape2")

.DEPENDENCIES <- c(PROJ$dbpath("prices0"))

END_DATE <- as.Date("1861-4-14")
START_DATE <- as.Date("1855-3-23")

standata <- function() {
    prices <-
        mutate(filter(PROJ$db[["prices0"]],
                      date <= END_DATE,
                      date >= START_DATE,
                      src == "Bankers",
                      ! grepl("California", series)))

    y <- acast(prices, date ~ series, value.var = "ytm")
    series <- c(
        "U.S. 6s, 1868", 
        "U.S. 5s, 1874",
        "Ohio 6s, 1875",
        "Ohio 6s, 1886", 
        "Pennsylvania 5s",
        "Indiana 5s",
        "Georgia 6s",
        "Louisiana 6s", 
        "North Carolina 6s",
        "Tennessee 6s",
        "Virginia 6s",
        "Kentucky 6s",
        "Missouri 6s"
        )
    dates <- rownames(y)
    y <- y[ , ycols] * 100
    observed <- ! is.na(y)
    mode(observed) <- "integer"
    y[is.na(y)] <- 0

    factor_names <- c("Market", "States", "South")
    factor_n <- length(factor_names)

    loadings <- matrix(NA_real_, nrow = length(series), ncol = factor_n)
    rownames(loadings) <- series
    colnames(loadings) <- factor_names
    for (j in  c("U.S. 6s, 1868", "U.S. 5s, 1874")) {
        loadings[j, ] <- c(1, 0, 0)
    }
    for (j in  c("Ohio 6s, 1875", "Ohio 6s, 1886",
                 "Pennsylvania 5s", "Indiana 5s")) {
        loadings[j, ] <- c(1, 1, 0)
    }
    for (j in c("Georgia 6s",
                "Louisiana 6s", 
                "North Carolina 6s",
                "Tennessee 6s",
                "Virginia 6s")) {
        loadings[j, ] <- c(1, 1, 1)        
    }
    #' Treat Kentucky as Northern
    loadings["Kentucky 6s", ] <- c(1, 1, 0)
    #' Treat Missouri as Southern 
    loadings["Missouri 6s", ] <- c(1, 1, 1)

    list(y = y,
         observed = observed,
         n = nrow(y),
         r = ncol(y),
         p = factor_n,
         F = loadings,
         m0 = rep(0, factor_n),
         C0 = diag(rep(1e7, factor_n)),
         g = array(0, factor_n),
         G = diag(factor_n),
         b = array(0, ncol(y)),
         Qfill = 1e7)
}


main <- function() {
    .standata <- standata()
    mod <- stan_model(PROJ$path("stan/factor1.stan"))
    system.time(ret <- sampling(mod, data = .standata, iter = 200, chains = 1))
}
