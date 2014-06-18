library("rstan")
library("reshape2")
library("dplyr")
db_spreads1 <- source_env(PROJ$path("R/db_spreads1.R"))

#' Summarize output from db_spreads
DEPENDENCIES <- c(PROJ$dbpath("spreads1")
                  PROJ$path("R/db_spreads1.R"))

main <- function() {
    spreads1 <- PROJ$db[["spreads1"]]
    spreads1_summary <- summary(spreads1)
    prices <-
        mutate(filter(PROJ$db[["prices0"]],
                      date <= END_DATE,
                      date >= START_DATE,
                      src == "Bankers",
                      series %in% SERIES),
               ytm = ytm * 100,
               series = factor(as.character(series), levels = SERIES),
               seriesn = as.integer(series))
    times <-
        mutate(data.frame(date = sort(unique(prices$date))),
               time = seq_along(date))

    theta_summary <-
        (melt(extract(spreads1, "theta")[[1]],
              varnames = c('iterations', 'time', 'factor'))
         %>% group_by(time, factor)
         %>% summarise(value_mean = mean(value),
                       value_sd = sd(value),            
                       value_median = median(value),
                       value_p025 = quantile(value, 0.025),
                       value_p25 = quantile(value, 0.25),
                       value_p75 = quantile(value, 0.75),
                       value_p975 = quantile(value, 0.975)))
    theta_summary <- merge(spreads1_theta_sumamry, times)
    
    list(dates = 

               
