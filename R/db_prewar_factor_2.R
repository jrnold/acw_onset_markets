#' Factor model of the probability of war
library("dplyr")
library("rstan")

.DEPENDENCIES <- c(PROJ$dbpath("prices0"),
                   PROJ$dbpath("prwar1"))

standata <- function() {
    yields <- PROJ$db[["prwar1"]][["yields"]]
    SERIES <- yields$series
    nseries <- nrow(yields)
    rownames(yields) <- SERIES

    start_date <- min(PROJ$db[["prwar1"]][["prwar"]]$date)
    end_date <- max(PROJ$db[["prwar1"]][["prwar"]]$date)    
    
    prices <-
        mutate(filter(PROJ$db[["prices0"]],
                      date >= start_date,
                      date <= end_date,
                      src == "Bankers",
                      series %in% SERIES),
               series = factor(as.character(series), levels = SERIES),
               seriesn = as.integer(series))
    times <-
        mutate(data.frame(date = sort(unique(prices$date))),
               time = seq_along(date))
    ntimes <- nrow(times)
    prices <- merge(prices, times)    
    list(n = nrow(times),
         r = nseries,
         y_nobs = nrow(prices),
         y = prices$ytm,
         y_variable = prices$seriesn,
         y_time = prices$time,
         riskfree_mean = yields$logyield_peace,
         riskfree_sd = yields$logyield_peace_sd,
         recovery = yields$price_war / 100
         )
    
}

main <- function() {
    .standata <- standata()
    mod <- stan_model(PROJ$path("stan/factor3.stan"))
    system.time(ret <- sampling(mod, data = .standata, iter = 1000, chains = 1))
}
