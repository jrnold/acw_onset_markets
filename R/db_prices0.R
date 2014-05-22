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
library("plyr")

BANKERS_FILE <- "submodules/civil_war_era/findata/bankers_magazine_govt_state_loans_yields_2.csv"
MERCHANTS_FILE <- "submodules/civil_war_era/findata/merchants_magazine_us_paper_yields_2.csv"
GREENBACKS_FILE <- "submodules/civil_war_era_findata/data/greenbacks.csv"

.DEPENDENCIES <- c(BANKERS_FILE,
                   MERCHANTS_FILE,
                   GREENBACKS_FILE)

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
      "US_ten_forty" = "Union",
      "greenbacks" = "Union")

bankers <- function() {
    bankers <- read.csv(
    bankers <-
        subset(bankers_magazine_govt_state_loans_yields_2"]](),
               ! is.na(price_gold_dirty))
    bankers$src <- "Bankers'"
    bankers$series <- as.character(bankers$series)
    bankers
}

merchants <- function() {
    merchants <-
        subset(FINDATA[["merchants_magazine_us_paper_yields_2"]](),
               ! series %in% c("five_twenty_reg",
                               "sixes_1881_reg")
               & ! is.na(price_gold_dirty))
    merchants$src <- "Merchants'"
    merchants$series <- as.character(merchants$series)
    merchants[["series"]] <-
        revalue(merchants[["series"]],
                 c("fives_1874"="US_5pct_1874",
                   "five_twenty_coup"="US_five_twenty",
                   "oneyr_new"="US_oneyr_new",
                   "oneyr_old"="US_oneyr_old",
                   "seven_thirties"="US_seven_thirty",
                   "sixes_1881_coup"="US_6pct_1881",
                   "ten_forty"="US_ten_forty"))
    merchants
}

greenbacks <- function() {
  vars <- c(paste0("price_gold_", c("clean", "dirty")),
            paste0("price_paper_", c("clean", "dirty")),
            "yield", "src", "date", "series")
  mutate(subset(FINDATA[["greenbacks"]](), ! is.na(low)),
         price_gold_clean = exp(0.5 * (log(high) + log(low))),
         price_gold_dirty = price_gold_clean,
         price_paper_clean = 100,
         price_paper_dirty = price_paper_clean,
         yield = -log(price_gold_clean / 100), # Calculated assuming 1 year redemption
         duration = -log(price_gold_clean / 100) / 0.05, # Unlike bonds, bonds ! = duration
         series = "greenbacks",
         src = "Mitchell")[ , vars]
}

main <- function() {
  ret <- rbind.fill(bankers(), merchants(), greenbacks())
  ret$series <- factor(ret$series)
  ret$group <- BOND_GROUPS[as.character(ret$series)]
  RDATA[["prices"]] <- ret
}
