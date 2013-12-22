#' sixes_meas_err
#' =================
#'
#' Measurement error for 6's.
library("plyr")

main <- function() {
  foo <- FINDATA[["bankers_magazine_govt_bonds_quotes_in_text"]]()
  greenbacks_fill <- FINDATA[["greenbacks_fill"]]()
  descriptions <- c("US 6 per cent 1881", "US 6 per cent 1868 (coupon)",
                    "US 6 per cent 1868", "US 6 per cent 1867",
                    "US 6 per cent 1861 coupon", "US 6 per cent 1861 reg")
  foo <- subset(foo, description %in% descriptions & (high_price - low_price) > 0)
  foo$date <- as.Date(foo$date)
  foo <- merge(foo, greenbacks_fill, by="date", all.x = TRUE)
  
  foo <- mutate(foo,
                low_price_gold = low_price * (low / 100),
                high_price_gold = high_price * (high / 100),
                log_range = log(high_price_gold) - log(low_price_gold),
                log_var = (1/12) * (log_range^2))

  RDATA[[commandArgs(TRUE)[1]]] <-
      list(data = foo, log_mean = mean(log(foo$log_var)),
           log_sd = sd(log(foo$log_var)))
  
}

