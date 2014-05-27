#'
#' Load Macaualy (1938) interest rate data.
#' 
library("jsonlite")
library("dplyr")

MACAULAY_FILE <- "data/quandl/macaulay.json"
.DEPENDENCIES <- MACAULAY_FILE

main <- function() {
    interest_rates <-
        (mutate(plyr::ldply(fromJSON(MACAULAY_FILE)),
                date = as.Date(Date),
                rate = Value,
                variable = .id)
         %>% select(-.id, -Value, -Date))
}

