#' Greenback Prices
#'
library("dplyr")

GREENBACKS_FILE <- "submodules/civil_war_era_findata/data/greenbacks.csv"

.DEPENDENCIES <- c(GREENBACKS_FILE)

main <- function() {
    mutate(read.csv(GREENBACKS_FILE, stringsAsFactors = FALSE),
           date = as.Date(date),
           log_mean = 0.5 * (log(high) + log(low)),
           log_var = (log(high) - log(low))^2 / 12)
}
