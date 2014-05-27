#' Dataset that combines all available prices of state and U.S. government bonds
#' and greenbacks from Merchants' Magazine, Bankers' Magazine, and Mitchell (1908).
#'
#' The yields, clean prices, and durations are calculated for each bond.
#' For the greenbacks, the yields are calculated assuming 1 year redemption,
#' and the duration is the time to redemption assuming a 5% interest rate.
#' 
#' Returns
#' ----------------
#'
#' ``data.frame`` with prices and yields for bonds and greenbacks.
library("dplyr")
# library("plyr")

MERCHANTS_FILE <- "submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv"
BANKERS_FILE <- "submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv"

.DEPENDENCIES <- c(BANKERS_FILE,
                   MERCHANTS_FILE)

BOND_GROUPS <-
    c("california_7pct_1870" = "North",
      "california_7pct_1877" = "North",
      "georgia_6pct" = "South",
      "indiana_5pct" = "North",
      "indiana_6pct" = "North",
      "kentucky_6pct" = "Border",
      "louisiana_6pct" = "South",
      "missouri_6pct" = "Border",
      "north_carolina_6pct" = "South",
      "ohio_6pct_1874" = "North",
      "ohio_6pct_1886" = "North",
      "pennsylvania_6pct" = "North",
      "tennessee_6pct" = "South",
      "US_5pct_1874" = "Union",
      "US_6pct_1868" = "Union",
      "US_6pct_1881" = "Union",
      "virginia_6pct" = "South",
      "US_five_twenty" = "Union",
      "US_oneyr_new" = "Union",
      "US_oneyr_old" = "Union",
      "US_seven_thirty" = "Union",
      "US_ten_forty" = "Union")

get_bankers <- function() {
  (read.csv(BANKERS_FILE, stringsAsFactors = FALSE) 
   %>% mutate(src = "Bankers"))   
}

get_merchants <- function() {
    merchants <- 
      (mutate(read.csv(MERCHANTS_FILE, stringsAsFactors = FALSE), 
             src = "Merchants")
       %>% filter(! registered)
       %>% select(- registered)
      )
    merchants[["series"]] <-
        plyr::revalue(merchants[["series"]],
                 c("fives_1874"="US_5pct_1874",
                   "five_twenty_coup"="US_five_twenty",
                   "oneyr_new"="US_oneyr_new",
                   "oneyr_old"="US_oneyr_old",
                   "seven_thirties"="US_seven_thirty",
                   "sixes_1881_coup"="US_6pct_1881",
                   "ten_forty"="US_ten_forty"))
    merchants
}

main <- function() {
    ret <- rbind.fill(get_bankers(), get_merchants())
    ret$date <- as.Date(ret$date)
    ret$series <- factor(ret$series)
    ret$group <- BOND_GROUPS[as.character(ret$series)]
    ret
}
