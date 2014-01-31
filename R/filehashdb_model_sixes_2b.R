#' Local level model; battle level random effects
#' 
#' Returns
#' -----------
#'
#' ``list`` with elements
#'
#' - ``sfit``: ``stanfit`` object with results.
#' - ``summary``: summary of the ``stanfit`` object.
#' - ``timing``: results of ``system.time``.
sixes_1 <- source_env("R/filehashdb_model_sixes_1.R")
sixes_2 <- source_env("R/filehashdb_model_sixes_2.R")

.DEPENDENCIES <-
    c(STAN_MODEL("model2"),
      DATAFILE("news/data/major_battle_news.csv"),
      file.path(DATA_DIR, "acw_battles", "data", "battles.csv"),
      "R/filehashdb_sixes_1.R")

START_DATE <- sixes_1$START_DATE
END_DATE <- sixes_1$END_DATE

adjust_date <- function(x) as.integer(x - START_DATE) + 1

datelist <- function() data.frame(date = seq(START_DATE, END_DATE, 1))

standata <- function() {
    battles <- sixes_2$gen_battles()
    lags <- subset(merge(battles[ , c("battle", "btlnum")],
                         mutate(RDATA[["battle_news_wgts_2"]],
                                time = adjust_date(date)),
                         all.x = TRUE),
                   date >= START_DATE & date <= END_DATE)

    within(sixes_1$standata(), {
        # Outcome info
        n_outcomes <- 2
        n_battles <- nrow(battles)
        outcome <- battles$outcome
        n_lag_wgts <- nrow(lags)
        # Lag info
        lag_wgts <- lags$wgt2
        lag_battle <- as.integer(lags$btlnum)
        lag_times <- as.integer(lags$time)
    })
}

main <- function() {
    RDATA[["model_sixes_2b"]] <-
        run_stan(STAN_MODEL("model2"),
                 iter = 2^11,
                 chains = 1, #length(init),
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
