#' Another price data set.
#'
#' ``list`` with the following elements:
#'
#' - ``data``: ``data.frame`` with data for prices
#' - ``prior_sd``: ``list`` with prior standard deviation of each variable
#' - ``prior_mean``: ``list`` with prior mean of each variable
#'
library("dplyr")

.DEPENDENCIES <- PROJ$dbpath("prices0")

exp_log_mean <- function(x, ...) exp(mean(log(x), ...))

main <- function() {
  prices0 <- PROJ$db[["prices0"]]
  (group_by(prices0, date, series)
   %>% summarise(n = length(date),
                 group = group[1],
                 ytm_mean = mean(ytm_gold),
                 ytm_sd = sd(ytm_gold),
                 current_yield_mean = mean(current_yield_gold),
                 current_yield_sd = sd(current_yield_gold),
                 price_mean = exp_log_mean(price),
                 price_logsd = sd(log(price)),
                 price_clean_mean = exp_log_mean(price_clean),
                 price_clean_logsd = sd(log(price_clean)),
                 maturity = mean(maturity),
                 duration = mean(duration_gold),
                 accrued_interest = mean(accrued_interest),
                 gold_rate = mean(gold_rate))     
  )
}
