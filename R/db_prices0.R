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

MERCHANTS_FILE <- PROJ$path("submodules/civil_war_era_findata/data/merchants_magazine_us_paper_yields_2.csv")
BANKERS_FILE <- PROJ$path("submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields_2.csv")

.DEPENDENCIES <- c(BANKERS_FILE,
                   MERCHANTS_FILE)

RENAME_BANKERS <-
    c("California 7 per cents, 1870" = "California 7s, 1870",
      "California 7 per cents, 1877" = "California 7s, 1877",
      "Georgia 6 per cents" = "Georgia 6s",
      "Indiana 5 per cents" = "Indiana 5s",
      "Indiana 6 per cents" = "Indiana 6s",
      "Kentucky 6 per cents" = "Kentucky 6s",
      "Louisiana 6 per cents" = "Louisiana 6s",
      "Missouri 6 per cents" = "Missouri 6s",
      "North Carolina 6 per cents" = "North Carolina 6s",
      "Ohio 6 per cents, 1875" = "Ohio 6s, 1875",
      "Ohio 6 per cents, 1886" = "Ohio 6s, 1886",
      "Pennsylvania 5 per cents" = "Pennsylvania 5s",
      "Tennessee 6 per cents" = "Tennessee 6s",
      "U.S. 5 per cents, 1874" = "U.S. 5s, 1874",
      "U.S. 6 per cents, 1867-8" = "U.S. 6s, 1868",
      "U.S. 6 per cents, 1881" = "U.S. 6s, 1881",
      "Virginia 6 per cents" = "Virginia 6s"
      )

RENAME_MERCHANTS <-
    c("10-40's" = "U.S. 10-40s",
      "1 year certificate, New" = "U.S. 1-year, 1862",
      "1 year certificate, Old" = "U.S. 1-year, 1863",
      "5-20's, Coup." = "U.S. 5-20s",
      "6's, 1881 Coup." = "U.S. 6s, 1881",
      "7 3-10, 3 years" = "U.S. 7-30s")

BOND_GROUPS <-
    c("California 7's 1870" = "North",
      "California 7's 1877" = "North",
      "Georgia 6's" = "South",
      "Indiana 5's" = "North",
      "Indiana 6's" = "North",
      "Kentucky 6's" = "Border",
      "Louisiana 6's" = "South",
      "Missouri 6's" = "Border",
      "North Carolina 6's" = "South",
      "Ohio 6's, 1875" = "North",
      "Ohio 6's, 1886" = "North",
      "Pennsylvania 5's" = "North",
      "Tennessee 6's" = "South",
      "US 5's, 1874" = "Union",
      "US 6's, 1868" = "Union",
      "US 6's, 1881" = "Union",
      "Virginia 6's" = "South",
      "US 5-20's" = "Union",
      "US 1-year (old)" = "Union",
      "US 1-year (new)" = "Union",
      "US 7-30's" = "Union",
      "US 10-40's" = "Union")

get_bankers <- function() {
  ret <- (read.csv(BANKERS_FILE, stringsAsFactors = FALSE) 
          %>% mutate(src = "Bankers"))
  ret[["series"]] <-
      plyr::revalue(ret[["series"]], RENAME_BANKERS)
  ret
}

get_merchants <- function() {
    merchants <- 
      (mutate(read.csv(MERCHANTS_FILE, stringsAsFactors = FALSE), 
             src = "Merchants")
       %>% filter(series %in% names(RENAME_MERCHANTS))
       %>% select(- registered)
      )
    merchants[["series"]] <-
        plyr::revalue(merchants[["series"]], RENAME_MERCHANTS)
    merchants
}

main <- function() {
    ret <- rbind.fill(get_bankers(), get_merchants())
    ret$date <- as.Date(ret$date)
    ret$series <- factor(ret$series)
    ret$group <- BOND_GROUPS[as.character(ret$series)]
    attr(ret, "rename_merchants") <- RENAME_MERCHANTS
    attr(ret, "rename_bankers") <- RENAME_BANKERS
    ret
}
