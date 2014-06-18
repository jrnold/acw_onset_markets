#' Model of South-North spreads
library("dplyr")
library("rstan")

MODEL_FILE <- PROJ$path("stan/spreads1.stan")
.DEPENDENCIES <- c(PROJ$dbpath("prices0"),
                   MODEL_FILE)

END_DATE <- as.Date("1861-4-15")
START_DATE <- as.Date("1855-3-23")

SERIES <- c(
    "Ohio 6s, 1875",
    "Ohio 6s, 1886", 
    "Pennsylvania 5s",
    "Indiana 5s",
    "Georgia 6s",
    "Louisiana 6s", 
    "North Carolina 6s",
    "Tennessee 6s",
    "Virginia 6s"
    )

ITER <- 2^10
WARMUP <- 2^9
SAMPLES <- 2^8
THIN <- 1
CHAINS <- 1
SEED <- 359736

get_data <- function() {
    prices <-
        mutate(filter(PROJ$db[["prices0"]],
                      date <= END_DATE,
                      date >= START_DATE,
                      src == "Bankers",
                      series %in% SERIES),
               ytm = ytm * 100,
               series = factor(as.character(series), levels = SERIES),
               seriesn = as.integer(series))
    nseries <- length(SERIES)

    times <-
        mutate(data.frame(date = sort(unique(prices$date))),
               time = seq_along(date))
    ntimes <- nrow(times)
    prices <- merge(prices, times)

    # Variables
    factor_names <- c("market", "south")
    loadings <- matrix(NA_real_, nrow = nseries, ncol = length(factor_names))
    rownames(loadings) <- SERIES
    colnames(loadings) <- factor_names
    for (j in  c("Ohio 6s, 1875", "Ohio 6s, 1886",
                 "Pennsylvania 5s", "Indiana 5s")) {
        loadings[j, ] <- c(1, 0)
    }
    for (j in c("Georgia 6s",
                "Louisiana 6s", 
                "North Carolina 6s",
                "Tennessee 6s",
                "Virginia 6s")) {
        loadings[j, ] <- c(1, 1)
    }
    list(times = times,
         loadings = loadings,
         prices = prices)
}

standata <- function(.data) {
    list(n = nrow(.data$times),
         r = length(SERIES),
         p = ncol(.data$loadings),
         y_nobs = nrow(.data$prices),
         y = .data$prices$ytm,
         y_variable = .data$prices$seriesn,
         y_time = .data$prices$time,
         loadings = .data$loadings,
         theta_init_loc = c(6, 0),
         theta_init_scale = c(1, 1),
         tau_scale = c(1, 1)
         )
}

main <- function() {
    .data <- get_data()
    .standata <- standata(.data)
    mod <- stan_model(MODEL_FILE)
    samples <- sampling(mod,
                        data = .standata,
                        iter = ITER, warmup = WARMUP, thin = THIN,
                        chains = CHAINS, seed = SEED)
    list(samples = samples,
         dates = .data$times$dates,
         series = SERIES)
    
}
