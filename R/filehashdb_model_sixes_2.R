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
    X <- data.frame(date = seq(START_DATE, END_DATE, 1))
    X$quote_1881 <- as.integer(X$date == SIXES_1881_START)
    X <- as.matrix(X[ , setdiff(names(X), "date"), drop=FALSE])
    
    battles <- merge(subset(WAR_NEWS[["major_battle_news"]](),
                            ! battle %in% EXCLUDED_BATTLES),
                     subset(ACW_BATTLES()[ , c("battle", "outcome")]))
    battles[battles$battle == "VA046", "outcome"] <- "Union"
    #' Spotsylvania Court House: Much more inconclusive
    battles[battles$battle == "VA048", "outcome"] <- "Confederate"
    #' remove Inconclusive category.
    battles$outcome <- factor(battles$outcome, levels = c("Confederate", "Union"))
    battles$outcome <- as.integer(battles$outcome)
    
    #' Integer battles
    battles$battle <- factor(battles$battle)
    battles$battle <- as.integer(battles$battle)
    battles
}

gen_battle_lags <- function(battles) {
    subset(mutate(ddply(battles, "battle",
                        function(x) {
                            mutate(data.frame(date = seq(x$start_date, x$end_date, by = 1)),
                                   wgt = 1 / length(date))
                        }),
                  battle = as.integer(battle),
                  time = adjust_date(date)),
           date <= END_DATE)
}

standata <- function() {
    battles <- gen_battles()
    battle_lags <- gen_battle_lags(battles)

    within(sixes_1$standata(), {
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
    RDATA[["model_sixes_2"]] <-
        run_stan(STAN_MODEL("model2"),
                 iter = 2^11,
                 chains = 1, #length(init),
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
