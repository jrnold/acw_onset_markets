#' Local level model of sixes **yields** with battle level random effects
#' 
#' Returns
#' -----------
#'
#' ``list`` with elements
#'
#' - ``sfit``: ``stanfit`` object with results.
#' - ``summary``: summary of the ``stanfit`` object.
#' - ``timing``: results of ``system.time``.
library("reshape2")

.DEPENDENCIES <- c()

START_DATE <- as.Date("1861-4-27")
END_DATE <- as.Date("1865-4-13")

standata <- function() {
    yvars <-
        merge(data.frame(date = seq(START_DATE, END_DATE, by = 1)),
              dcast(subset(RDATA[["prices2"]]$data,
                           date >= START_DATE & date <= END_DATE
                           & series %in% c("US_5pct_1874", "US_6pct_1868",
                                           "US_6pct_1881", "greenback")),
                    date ~ series, value.var = "yield"),
              all.x = TRUE)

    y <- as.matrix(yvars[ , -1])
    missing <- as.integer(is.na(y))
    dim(missing) <- dim(y)
    y[is.na(y)] <- 1e6

    N <- nrow(y)
    r <- ncol(y)

    m0 <- RDATA[["prices2"]]$prior_mean$yield
    C0 <- RDATA[["prices2"]]$prior_sd$yield ^ 2
    
    ret <- sixes2$standata()
    ret$N <- nrow(sixes)
    ret$y <- sixes$y
    ret$missing <- sixes$missing
    ret$m0 <- sixes$y[1]
    ret$C0 <- 0.05^2
    ret$alpha_loc <- 0
    ret$alpha_scale <- diff(range(sixes$y[!sixes$missing]))
    
    within(ret, {
        n_outcomes <- 2
        n_battles <- nrow(battles)
        outcome <- battles$outcome
        n_lag_wgts <- nrow(battle_lags)
        lag_wgts <- battle_lags$wgt
        lag_battle <- as.integer(battle_lags$battle)
        lag_times <- as.integer(battle_lags$time)
    })
}

main <- function() {
    RDATA[["model_sixes_3"]] <-
        run_stan(STAN_MODEL("model2"),
                 iter = 2^12,
                 chains = 1, #length(init),
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
