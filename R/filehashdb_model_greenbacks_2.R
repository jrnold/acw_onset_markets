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

START_DATE <- as.Date("1862-1-1")
END_DATE <- sixes_1$END_DATE

adjust_date <- function(x) as.integer(x - START_DATE) + 1

datelist <- function() data.frame(date = seq(START_DATE, END_DATE, 1))

gen_greenbacks <- function() {
    mutate(merge(data.frame(date = seq(START_DATE, END_DATE, 1)),
                 subset(RDATA[["prices"]],
                        series == "greenbacks"
                        & date >= START_DATE
                        & date <= END_DATE),
                 all.x = TRUE),
           y = ifelse(is.na(price_gold_clean), 1000, log(price_gold_clean)),
           missing = is.na(price_gold_clean))
}

gen_battles <- function() {
    battles <-
        mutate(subset(merge(sixes_2$gen_battles(),
                            ACW_BATTLES()[ , c("battle", "start_date", "end_date")]),
                      end_date >= as.Date("1862-1-1")),
               btlnum = as.integer(factor(battle)))
}
    
standata <- function() {
    battles <- gen_battles()
    lags <- subset(merge(battles[ , c("battle", "btlnum")],
                         mutate(RDATA[["battle_news_wgts_2"]],
                                time = adjust_date(date)),
                         all.x = TRUE),
                   date >= START_DATE & date <= END_DATE)

    prices <- gen_greenbacks()

    standata <-
        within(list(), {
            N <- nrow(prices)
            y <- prices$y
            missing <- prices$missing

            alpha_loc <- 0
            alpha_scale <- diff(range(prices$y[!prices$missing]))
            
            ## Initial value on Dec 31, 1861 is 100
            m0 <- 0
            C0 <- 0.1^2
            
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
    RDATA[["model_sixes_3"]] <-
        run_stan(STAN_MODEL("model2c"),
                 iter = 2^11,
                 chains = 1, #length(init),
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
