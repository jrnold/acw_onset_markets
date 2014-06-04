#' Estimating Probability of start of civil war
#'
#' For all government and state bonds estimates the probability of the initiation of the civil war in the period 1858-1861 using a crude estimate.
#' For state bonds, only southern and border state bonds are used because they were much more sensitive to the start of the war.
#' 
#' Let $p$ be the probability of war, $y_t$ is the yield at time $t$, then the yield at a given time is
#' $$
#' y_t = p y_w + (1 - p) y_p
#' $$
#' which can be rewritten to solve for $p$,
#' $$
#' p = \frac{y_t - y_p}{y_w - y_p}
#' $$
#' This is intuitive, but I have not worked out the precise justification of this approximation.
#' 
library("dplyr")
library("jsonlite")

BOND_METADATA_FILE <- "./submodules/civil_war_era_findata/data/bond_metadata.json"
BANKERS_FILE <- "./submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv"
MODEL_FILE <- "stan/prwar.stan"
    
.DEPENDENCIES <-
    c(MODEL_FILE, BOND_METADATA_FILE, BANKERS_FILE)

PEACE <- as.Date(c("1855-08-24", "1857-10-16"))
WAR <- as.Date(c("1861-04-15", "1861-05-18"))
RANGE <- as.Date(c("1858-1-1", "1861-4-10"))

#' Only use the U.S. Government, confederate and border states.
BONDSERIES <- c("georgia_6pct" = "georgia_6pct_1872",
                "kentucky_6pct" = "kentucky_6pct_1871",
                "louisiana_6pct" = "louisiana_6pct_1881",
                "missouri_6pct" = "missouri_6pct_1872",
                "north_carolina_6pct" = "north_carolina_1873",
                "tennessee_6pct" = "tennessee_6pct_1889",
                "US_6pct_1868" = "us_6pct_1868_jul",
                "US_5pct_1874" = "us_5pct_1874",
                "virginia_6pct" = "virginia_6pct_1888"
                )

get_bond_yields <- function() {
    (mutate(read.csv(BANKERS_FILE),
            date = as.Date(date))
     %>% filter(bond %in% unname(BONDSERIES))
     %>% mutate(series = factor(series),
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
        (group_by(bond_yields, series)
         %>% filter(date >= PEACE[1] & date <= PEACE[2])
         %>% summarise(yield_peace = mean(ytm),
                       yield_peace_sd = sd(ytm),
                       price_peace = mean(price),
                       price_peace_sd = sd(price))
         )
    
    war_yields <-
        (group_by(bond_yields, series)
         %>% filter(date >= WAR[1] & date <= WAR[2])
         %>% summarise(yield_war = mean(ytm),
                       yield_war_sd = sd(ytm),
                       price_war = mean(price),
                       price_war_sd = sd(price))
         )
    
    wp_yields <- merge(war_yields, peace_yields, all=TRUE)
    wp_yields[wp_yields$series == "US_5pct_1874", c("yield_peace", "yield_peace_sd")] <-
        wp_yields[wp_yields$series == "US_6pct_1868", c("yield_peace", "yield_peace_sd")]
    wp_yields
}


get_data <- function() {
    #' Keep only dates in the relevant range
    metadata <- get_bond_metadata()
    bond_data <-
        filter(get_bond_yields(),
               date >= RANGE[1] & date <= RANGE[2])
    yields <- get_war_peace_yields()
    .data <- (merge(bond_data, yields)
              %>% mutate(prwar = pmax(0, (ytm - yield_peace) / (yield_war - yield_peace)))
              )
    .data[["cashflows"]] <- lapply(as.character(.data$bond), function(i) metadata[[i]][["cashflows"]])
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
    (mutate(.data,
            prwar2 = (ytm - yield_peace) / (1 - price_war / 100),
            prwar3 = (ytm - yield_peace) / (1 - pv_yield_war / 100))
     %>% select(-wgt))
}

main <- get_data
