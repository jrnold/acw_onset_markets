#' Local level model of the log gold prices of Sixes.
#'
#' Returns
#' -----------
#'
#' ``list`` with elements
#'
#' - ``sfit``: ``stanfit`` object with results.
#' - ``summary``: summary of the ``stanfit`` object.
#' - ``timing``: results of ``system.time``.
source("R/constants.R")

.DEPENDENCIES <-
    c(filehashdb_path("sixes_meas_err"),
      filehashdb_path("sixes"),
      STAN_MODEL("model0"),
      "R/constants.R")

START_DATE <- DATE_SIXES_WAR_FIRST
END_DATE <- DATE_SIXES_WAR_END

gen_sixes <- function() {
    sixes <- merge(data.frame(date = seq(START_DATE, END_DATE, 1)),
                   mutate(ddply(subset(RDATA[["prices"]],
                                       series %in% c("US_6pct_1868", "US_6pct_1881")
                                       & date >= START_DATE
                                       & date <= END_DATE),
                                "date",
                                summarise,
                                logprice = mean(log(price_gold_clean))),
                          time = as.integer(date - START_DATE) + 1,
                          diff = c(1, as.integer(diff(date)))),
                   all.x = TRUE)
    mutate(sixes,
           y = ifelse(is.na(logprice), 1000, logprice),
           missing = is.na(logprice))
}

standata <- function() {
    sixes <- gen_sixes()
    sixes_meas_err <- RDATA[["sixes_meas_err"]]

    standata <-
        within(list(), {
            N <- nrow(sixes)
            y <- sixes$y
            missing <- sixes$missing
            
            m0 <- y[1]
            C0 <- 0.05^2
            
            xi_loc <- sixes_meas_err$log_mean
            xi_scale <- sixes_meas_err$log_sd * 1.5
        })
}

main <- function() {
    RDATA[["model_sixes_0"]] <- 
        run_stan(STAN_MODEL("model0"),
                 iter = 2^11,
                 chains = 1,
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
