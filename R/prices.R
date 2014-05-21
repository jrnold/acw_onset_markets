PRE_WAR_START <- as.Date("1861-4-13")
POST_WAR_START <- as.Date("1861-4-20")
END_WAR <- as.Date("1865-4-13")

BANKERS_FILE <- 

sd2 <- function(x) {
    if (length(x) > 1) {
        sd(x)
    } else {
        0
    }
}

bonds <- function() {
    bonds <-
        rbind(subset(FINDATA[["bankers_magazine_govt_state_loans_yields"]](),
                     series %in% c("US_6pct_1881", "US_6pct_1868", "US_5pct_1874")
                     & ! is.na(price_gold_dirty)),
              mutate(subset(FINDATA[["merchants_magazine_us_paper_yields"]](),
                            series %in% c("sixes_1881_coup", "fives_1874",
                                          "ten_forty", "five_twenty_coup")
                            & ! is.na(price_gold_dirty)),
                     series = revalue(series,
                     c("sixes_1881_coup" = "US_6pct_1881",
                       "fives_1874" = "US_5pct_1874",
                       "ten_forty" = "US_ten_forty",
                       "five_twenty_coup" = "US_five_twenty"))))
    
    bonds_summary <- 
        ddply(bonds,
              c("series", "date"),
              function(x) {
                  with(x,
                       data.frame(
                           yield = weighted.mean(yield, wgt),
                           yield_sd = sd2(yield),
                           price = min(price_gold_clean),
                           price_sd = sd2(price_gold_clean),
                           log_yield = weighted.mean(log(yield), wgt),
                           log_yield_sd = sd2(log(yield)),
                           log_price = min(log(price_gold_clean)),
                           log_price_sd = sd2(log(price_gold_clean)),
                           maturity = weighted.mean(maturity, wgt),
                           maturity_min = min(maturity),
                           maturity_max = max(maturity),                       
                           duration = weighted.mean(duration, wgt),
                           duration_sd = sd2(duration)
                           ))
              })
}

greenbacks <- function() {
    foo <- mutate(subset(FINDATA[["greenbacks"]](),
                         ! is.na(low)),
                  price = (low + high) / 2,
                  price_sd = (high - low) / sqrt(12),
                  log_price = (log(low) + log(high)) / 2,
                  log_price_sd = (log(high) - log(low)) / sqrt(12),
                  yield = -log(price / 100),
                  yield_high = -log(low / 100),
                  yield_low = -log(high / 100),
                  yield_sd = (yield_high - yield_low) / sqrt(12),
                  log_yield = 0.5 * (log(yield_high) + log(yield_low)),
                  log_yield_sd = (log(yield_high) - log(yield_low)) / sqrt(12))
    for (i in c("high", "low", "comment", "mean", "yield_high", "yield_low")) {
        foo[[i]] <- NULL
    }
    foo[["series"]] <- "greenback"
    foo
}


main <- function() {
    bonddata <- bonds()
    greenbackdata <- greenbacks()
    prices <- subset(bonddata, greenbackdata)

    prior_sd <- 
        summarise(subset(bonddata,
                         series == "US_6pct_1868"
                         & date %in% c(PRE_WAR_START, POST_WAR_START)),
                  yield = 2 * abs(diff(yield)) / sqrt(12),
                  log_yield = 2 * abs(diff(log_yield)) / sqrt(12),
                  price = 2 * abs(diff(price)) / sqrt(12),
                  log_price = 2 * abs(diff(log_price)) / sqrt(12))

    prior_mean <-
        summarise(subset(bonddata, date == POST_WAR_START),
                  yield = mean(yield),
                  log_yield = mean(log_yield),
                  price = mean(price),
                  log_price = mean(log_price))

    list(data = prices,
         prior_sd = prior_sd,
         prior_mean = prior_mean)
}
