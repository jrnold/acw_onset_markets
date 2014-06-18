#' Factor model of the probability of war
library("dplyr")
library("rstan")

MODEL_FILE <- PROJ$path("stan/prwar1.stan")
.DEPENDENCIES <- c(PROJ$dbpath("prices0"),
                   PROJ$dbpath("prwar1"),
                   MODEL_FILE)

ITER <- 2^10
WARMUP <- 2^9
SAMPLES <- 2^9
THIN <- 1
CHAINS <- 1
SEED <- 122219

get_data <- function() {
    within(list(), {
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
    })
}

standata <- function(.data) {
    list(n = nrow(.data$times),
         r = .data$nseries,
         y_nobs = nrow(.data$prices),
         y = .data$prices$ytm,
         y_variable = .data$prices$seriesn,
         y_time = .data$prices$time,
         riskfree_mean = .data$yields$logyield_peace,
         riskfree_sd = .data$yields$logyield_peace_sd,
         recovery = .data$yields$price_war / 100
         )
    
}

main <- function() {
    .data <- get_data()
    .standata <- standata(.data)
    mod <- stan_model(MODEL_FILE)
    ret <- sampling(mod,
                    data = .standata,
                    iter = ITER, warmup = WARMUP, thin = THIN,
                    chains = CHAINS, seed = SEED)
    list(samples = ret,
         start_date = .data$start_date,
         end_date = .data$end_date,
         times = .data$times,
         series = .data$SERIES)

}
