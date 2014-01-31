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
sixes2 <- source_env("R/filehashdb_model_sixes_2.R")

.DEPENDENCIES <-
    c(STAN_MODEL("model2"),
      "R/filehashdb_sixes_2.R")

START_DATE <- sixes_1$START_DATE
END_DATE <- sixes_1$END_DATE
SIXES_1881_START <- sixes_1$SIXES_1881_START

gen_sixes <- function() {
    sixes <- merge(data.frame(date = seq(START_DATE, END_DATE, 1)),
                   mutate(ddply(subset(RDATA[["sixes"]],
                                       date >= START_DATE
                                       & date <= END_DATE),
                                "date",
                                summarise,
                                logyield = mean(yield)),
                          time = as.integer(date - START_DATE) + 1,
                          diff = c(1, as.integer(diff(date)))),
                   all.x = TRUE)
    mutate(sixes,
           y = ifelse(is.na(logyield), 1000, logyield),
           missing = is.na(logyield))
}

standata <- function() {
    battles <- sixes2$gen_battles()
    battle_lags <- sixes2$gen_battle_lags(battles)

    sixes <- gen_sixes()
    sixes_meas_err <- RDATA[["sixes_meas_err"]]

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
