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

.DEPENDENCIES <-
    c(STAN_MODEL("model2"),
      DATAFILE("news/data/major_battle_news.csv"),
      file.path(DATA_DIR, "acw_battles", "data", "battles.csv"),
      "R/filehashdb_sixes_1.R")

START_DATE <- sixes_1$START_DATE
END_DATE <- sixes_1$END_DATE
SIXES_1881_START <- sixes_1$SIXES_1881_START
EXCLUDED_BATTLES <- c("SC001", #  Fort Sumter
                      "AL006" # Fort Blakely
                      )

adjust_date <- function(x) as.integer(x - START_DATE) + 1

gen_battles <- function() {
    battles <- subset(ACW_BATTLES(),
                      significance == "A"
                      & ! battle %in% EXCLUDED_BATTLES,
                      c("battle", "battle_name", "outcome"))
    battles[battles$battle == "VA046", "outcome"] <- "Union"
    #' Spotsylvania Court House: Much more inconclusive
    battles[battles$battle == "VA048", "outcome"] <- "Confederate"
    #' remove Inconclusive category.
    battles$outcome <- factor(battles$outcome, levels = c("Confederate", "Union"))
    battles$outcome <- as.integer(battles$outcome)

    #' Integer battles
    battles$btlnum <- as.integer(factor(battles$battle))
    battles
}

gen_battle_lags <- function(battles) {
    mutate(ddply(battles, "battle",
                 function(x) {
                     mutate(data.frame(date = seq(x$start_date, x$end_date, by = 1)),
                            wgt = 1 / length(date))
                 }),
           battle = as.integer(battle),
           time = adjust_date(date))
}

standata <- function() {
    battles <- gen_battles()
    lags <- merge(battles[ , c("battle", "btlnum")],
                  gen_battle_lags(battles),
                  all.x = TRUE)
    
    within(sixes_1$standata(), {
        n_outcomes <- 2
        n_battles <- nrow(battles)
        outcome <- battles$outcome
        n_lag_wgts <- nrow(battle_lags)
        lag_wgts <- lags$wgt
        lag_battle <- as.integer(lags$btlnum)
        lag_times <- as.integer(lags$time)
    })
}

main <- function() {
    RDATA[["model_sixes_2"]] <-
        run_stan(STAN_MODEL("model2"),
                 iter = 2^11,
                 chains = 1, #length(init),
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
