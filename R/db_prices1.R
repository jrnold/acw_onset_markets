#'
#' Another price data set.
#'
#' ``list`` with the following elements:
#'
#' - ``data``: ``data.frame`` with data for prices
#' - ``prior_sd``: ``list`` with prior standard deviation of each variable
#' - ``prior_mean``: ``list`` with prior mean of each variable
#'
library("dplyr")

PRE_WAR_START <- as.Date("1861-4-1")
POST_WAR_START <- as.Date("1861-4-27")
END_WAR <- as.Date("1865-4-13")
SD_MULT <- 5/3

MERCHANTS_FILE <- "submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv"
BANKERS_FILE <- "submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv"
GREENBACKS_FILE <- "submodules/civil_war_era_findata/data/greenbacks.csv"

.DEPENDENCIES <- c(MERCHANTS_FILE,
                   BANKERS_FILE,
                   GREENBACKS_FILE)

## sd2 <- function(x) {
##     if (length(x) > 1) {
##         sd(x)
##     } else {
##         0
##     }
## }

## bonds <- function() {
##     bonds <-
##         rbind(filter(read.csv(BANKERS_FILE),
##                      series %in% c("US_6pct_1881", "US_6pct_1868", "US_5pct_1874")
##                      & ! is.na(price_gold_dirty)),
##               mutate(filter(read.csv(MERCHANTS_FILE),
##                             series %in% c("sixes_1881_coup", "fives_1874",
##                                           "ten_forty", "five_twenty_coup"),
##                             ! is.na(price_gold_dirty)),
##                      series = revalue(series,
##                      c("sixes_1881_coup" = "US_6pct_1881",
##                        "fives_1874" = "US_5pct_1874",
##                        "ten_forty" = "US_ten_forty",
##                        "five_twenty_coup" = "US_five_twenty"))))
    
##     bonds_summary <- 
##         ddply(bonds,
##               c("series", "date"),
##               function(x) {
##                   with(x,
##                        data.frame(
##                            yield = weighted.mean(yield, wgt),
##                            yield_sd = sd2(yield),
##                            price = min(price_gold_clean),
##                            price_sd = sd2(price_gold_clean),
##                            log_yield = weighted.mean(log(yield), wgt),
##                            log_yield_sd = sd2(log(yield)),
##                            log_price = min(log(price_gold_clean)),
##                            log_price_sd = sd2(log(price_gold_clean)),
##                            maturity = weighted.mean(maturity, wgt),
##                            maturity_min = min(maturity),
##                            maturity_max = max(maturity),                       
##                            duration = weighted.mean(duration, wgt),
##                            duration_sd = sd2(duration)
##                            ))
##               })
## }

## greenbacks <- function() {
##     foo <- mutate(filter(GREENBACKS_FILE, ! is.na(low)),
##                   price = (low + high) / 2,
##                   price_sd = (high - low) / sqrt(12),
##                   log_price = (log(low) + log(high)) / 2,
##                   log_price_sd = (log(high) - log(low)) / sqrt(12),
##                   yield = -log(price / 100),
##                   yield_high = -log(low / 100),
##                   yield_low = -log(high / 100),
##                   yield_sd = (yield_high - yield_low) / sqrt(12),
##                   log_yield = 0.5 * (log(yield_high) + log(yield_low)),
##                   log_yield_sd = (log(yield_high) - log(yield_low)) / sqrt(12))
##     for (i in c("high", "low", "comment", "mean", "yield_high", "yield_low")) {
##         foo[[i]] <- NULL
##     }
##     foo[["series"]] <- "greenback"
##     foo
## }


## main <- function() {
##     bonddata <- bonds()
##     greenbackdata <- greenbacks()
##     prices <- mutate(rbind.fill(bonddata, greenbackdata),
##                      date = as.Date(date))

##     prior_sd <- 
##            summarise(filer(bonddata,
##                            date >= as.Date("1861-4-1"),
##                            date <= as.Date("1861-5-1")),
##                      yield = sd(yield) * SD_MULT,
##                      log_yield = sd(log_yield) * SD_MULT,
##                      price = sd(price) * SD_MULT,
##                      log_price = sd(log_price) * SD_MULT)

##     prior_mean <-
##         summarise(filter(bonddata, date == POST_WAR_START),
##                   yield = mean(yield),
##                   log_yield = mean(log_yield),
##                   price = mean(price),
##                   log_price = mean(log_price))
    
##     RDATA[["prices2"]] <- list(data = prices,
##                                prior_sd = as.list(prior_sd),
##                                prior_mean = as.list(prior_mean))
## }

main <- function() NULL
