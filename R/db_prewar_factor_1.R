7#' Dataset that combines all available prices of state and U.S. government bonds
#' and greenbacks from Merchants' Magazine, Bankers' Magazine, and Mitchell (1908).
#'
#' The yields, clean prices, and durations are calculated for each bond.
#' For the greenbacks, the yields are calculated assuming 1 year redemption,
#' and the duration is the time to redemption assuming a 5% interest rate.
#' 
#' Returns
#' ----------------
#'
#' ``data.frame`` with prices and yields for bonds and greenbacks.
library("dplyr")

.DEPENDENCIES <- c(PROJ$dbpath("prices0"))

END_DATE <- as.Date("1861-4-15")
START_DATE <- as.Date("1855-3-23")

standata <- function() {
    SERIES <- c(
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

    prices <-
        mutate(filter(PROJ$db[["prices0"]],
                      date <= END_DATE,
                      date >= START_DATE,
                      src == "Bankers",
                      series %in% SERIES),
               ytm = ytm * 100,
               series = factor(as.character(series), labels = SERIES),
               seriesn = as.integer(series))
    nseries <- length(SERIES)
    
    times <-
        mutate(data.frame(date = sort(unique(prices$date))),
               time = seq_along(date))
    ntimes <- nrow(times)
    prices <- merge(prices, times)    

    # Variables
    factor_names <- c("market", "state", "south")
    factor_n <- length(factor_names)
    loadings <- matrix(NA_real_, nrow = nseries, ncol = factor_n)
    rownames(loadings) <- SERIES
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
    
    list(n = nrow(times),
         r = length(SERIES),
         p = nfactors,
         y_nobs = nrow(prices),
         y = prices$ytm,
         y_variable = prices$seriesn,
         y_time = prices$time,
         loadings = loadings,
         theta_init_loc = array(0, nfactors),
         theta_init_scale = array(1e7, nfactors))
    
}

main <- function() {
    .standata <- standata()
    mod <- stan_model(PROJ$path("stan/factor2.stan"))
    system.time(ret <- sampling(mod, data = .standata, iter = 200, chains = 1))
    
}
