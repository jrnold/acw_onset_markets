#' Estimating Probability of start of civil war
#'
#' For all government and state bonds estimates the probability of the initiation of the civil war in the period 1858-1861 using a crude estimate.
#' For state bonds, only southern and border state bonds are used because they were much more sensitive to the start of the war.
library("dplyr")
library("jsonlite")

BOND_METADATA_FILE <- PROJ$path("./submodules/civil_war_era_findata/data/bond_metadata.json")
BANKERS_FILE <- PROJ$path("./submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv")
PRICES0 <- PROJ$dbpath("prices0")

prices0 <- PROJ$db[["prices0"]]
    
.DEPENDENCIES <-
    c(BOND_METADATA_FILE, BANKERS_FILE)

PEACE <- as.Date(c("1855-07-01", "1857-9-1"))
WAR <- as.Date(c("1861-04-15", "1861-05-18"))
RANGE <- as.Date(c("1858-3-1", "1861-4-13"))

#' Only use the U.S. Government, confederate and border states.
BONDSERIES <- c("Georgia 6s" = "georgia_6pct_1872",
                "Kentucky 6s" = "kentucky_6pct_1871",
                "Louisiana 6s" = "louisiana_6pct_1881",
                "Missouri 6s" = "missouri_6pct_1872",
                "North Carolina 6s" = "north_carolina_1873",
                "Tennessee 6s" = "tennessee_6pct_1889",
                "U.S. 6s, 1868" = "us_6pct_1868_jul",
                "U.S. 5s, 1874" = "us_5pct_1874",
                "Virginia 6s" = "virginia_6pct_1888"
                )



get_bond_yields <- function() {
    (mutate(read.csv(BANKERS_FILE),
            date = as.Date(date))
     %>% filter(bond %in% unname(BONDSERIES))
     %>% mutate(series = unname(attr(prices0, "rename_bankers")[series]),
                bond = factor(bond))
     )
}

get_bond_metadata <- function() {
    fromJSON(BOND_METADATA_FILE)
}

pvbond <- function(rate, effectiveDate, cashflows) {
    sum((filter(cashflows,
                date > effectiveDate)
         %>% mutate(date = as.Date(date),
                    maturity = as.integer(date - effectiveDate) / 365.25,
                    dcf = amount * exp(-rate * maturity)))$dcf)
}

#' Calculate yields for War and Peace
#'
#' For 5's of 1874 use the peace yield for 6's of 1868
#' 
get_war_peace_yields <- function() {
    bond_yields <- get_bond_yields()

    peace_yields <-
        (filter(bond_yields,
                date >= PEACE[1] & date <= PEACE[2],
                series != "U.S. 5s, 1874")
         %>% group_by(series)
         %>% summarise(yield_peace = mean(ytm),
                       yield_peace_min = min(ytm),
                       yield_peace_sd = sd(ytm),
                       price_peace = mean(price),
                       price_peace_min = min(price),                       
                       price_peace_sd = sd(price),
                       logyield_peace = mean(log(ytm)),
                       logyield_peace_sd = sd(log(ytm)),
                       logprice_peace = mean(log(price)),
                       logprice_peace_sd = sd(log(price)))
         )
    peace_yields <-
        rbind(peace_yields,
              mutate(filter(peace_yields, series == "U.S. 6s, 1868"),
                     series = "U.S. 5s, 1874"))
    
    war_yields <-
        (group_by(bond_yields, series)
         %>% filter(date >= WAR[1] & date <= WAR[2])
         %>% summarise(yield_war = mean(ytm),
                       yield_war_min = min(ytm),
                       yield_war_sd = sd(ytm),
                       price_war = mean(price),
                       price_war_min = min(price),
                       price_war_sd = sd(price),
                       logyield_war = mean(log(ytm)),
                       logyield_war_sd = sd(log(ytm)),
                       logprice_war = mean(log(price)),
                       logprice_war_sd = sd(log(price)))
                       
         )
    alt_yields <- data.frame(
        series = 
        c("Georgia 6s",
          "Kentucky 6s",
          "Louisiana 6s",
          "Missouri 6s",
          "North Carolina 6s",
          "Tennessee 6s",
          "U.S. 6s, 1868",
          "U.S. 5s, 1874",
          "Virginia 6s"),
        yield_peace_2 =
        c(6, 6, 6, 6, 6, 6, 5, 5, 6) / 100
        )
    
    wp_yields <- merge(war_yields, peace_yields, all=TRUE)
    wp_yields <- merge(wp_yields, alt_yields)
    wp_yields
}

get_data <- function() {
    #' Keep only dates in the relevant range
    metadata <- get_bond_metadata()
    bond_data <-
        filter(get_bond_yields(),
               date >= RANGE[1] & date <= RANGE[2])
    yields <- get_war_peace_yields()
    .data <- merge(bond_data, yields)
    .data[["cashflows"]] <-
        lapply(as.character(.data$bond), function(i) metadata[[i]][["cashflows"]])
    .data[["pv_yield_peace"]] <-
        sapply(seq_len(nrow(.data)),
               function(i) {
                   pvbond(.data[["yield_peace"]][i],
                          .data[["date"]][i],
                          .data[["cashflows"]][i][[1]])
               })
    .data[["pv_yield_war"]] <-
        sapply(seq_len(nrow(.data)),
               function(i) {
                   pvbond(.data[["yield_war"]][i],
                          .data[["date"]][i],
                          .data[["cashflows"]][i][[1]])
               })
    .data[["pv_4pct"]] <-
        sapply(seq_len(nrow(.data)),
               function(i) {
                   pvbond(0.04,
                          .data[["date"]][i],
                          .data[["cashflows"]][i][[1]])
               })
    .data[["pv_5pct"]] <-
        sapply(seq_len(nrow(.data)),
               function(i) {
                   pvbond(0.05,
                          .data[["date"]][i],
                          .data[["cashflows"]][i][[1]])
               })
    .data[["pv_6pct"]] <-
        sapply(seq_len(nrow(.data)),
               function(i) {
                   pvbond(0.06,
                          .data[["date"]][i],
                          .data[["cashflows"]][i][[1]])
               })
    .data[["pv_7pct"]] <-
        sapply(seq_len(nrow(.data)),
               function(i) {
                   pvbond(0.07,
                          .data[["date"]][i],
                          .data[["cashflows"]][i][[1]])
               })
    .data[["cashflows"]] <- NULL
    ret <- (mutate(.data,
                   prwar1 = (ytm - yield_peace) / (1 - price_war / 100),
                   prwar2 = (ytm - yield_peace) / (1 - pv_yield_war / 100),
                   prwar3 = (ytm - yield_peace_min) / (1 - price_war / 100),
                   prwar4 = (ytm - yield_peace_min) / (1 - pv_yield_war / 100),
                   prwar5 = (ytm - yield_peace_2) / (1 - price_war / 100),
                   prwar6 = (ytm - yield_peace_2) / (1 - pv_yield_war / 100),
                   ## variation of proportional method proposed by Frey
                   prwar7 = (ytm - yield_peace) / (yield_war - yield_peace),
                   prwar8 = (ytm - yield_peace_2) / (yield_war - yield_peace_2),
                   prwar9 = (ytm - yield_peace_min) / (yield_war - yield_peace_min),                   
                  )
           %>% select(-wgt))
    list(prwar = ret,
         yields = yields,
         peace_dates = PEACE,
         war_dates = WAR)
}

main <- get_data
