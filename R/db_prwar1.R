library("rstan")
library("jsonlite")
library("dplyr")
library("reshape2")

BOND_METADATA_FILE <- "./submodules/civil_war_era_findata/data/bond_metadata.json"
BANKERS_FILE <- "./submodules/civil_war_era_findata/data/bankers_magazine_govt_state_loans_yields.csv"
MODEL_FILE <- "stan/prwar.stan"
    
.DEPENDENCIES <-
    c(MODEL_FILE, BOND_METADATA_FILE, BANKERS_FILE)

#' MCMC parameters
ITER <- 2^9
WARMUP <- 2^8
SAMPLES <- 2^8
THIN <- 1
SEED <- 254460
CHAINS <- 1

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

bondpresval <- function(r, x, m, p = 1) {
    n <- length(x)
    pv <- numeric(n)
    for (i in 1:n) {
        if (i == 1) {
            mlag <- p * 0 + (1 - p) * m[i]
        } else {
            mlag <- p * m[i - 1] + (1 - p) * m[i]
        }
        pv[i] <- sum(x[i:n] * exp(- r * (m[i:n] - mlag)))
    }
    pv
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
                       yield_peace_sd = sd(ytm))
         )
    
    war_yields <-
        (group_by(bond_yields, series)
         %>% filter(date >= WAR[1] & date <= WAR[2])
         %>% summarise(yield_war = mean(ytm),
                       yield_war_sd = sd(ytm))
         )
    
    wp_yields <- merge(war_yields, peace_yields, all=TRUE)
    wp_yields[wp_yields$series == "US_5pct_1874", c("yield_peace", "yield_peace_sd")] <-
        wp_yields[wp_yields$series == "US_6pct_1868", c("yield_peace", "yield_peace_sd")]
    wp_yields
}


get_data <- function() {
    #' Keep only dates in the relevant range
    bond_data <-
        (filter(get_bond_yields(),
                date >= RANGE[1] & date <= RANGE[2])
         %>% mutate(bond = as.factor(bond),
                    series = as.factor(series))
         %>% select(date, series, bond, price)
         %>% mutate(asset_num = as.integer(series))
         )
    datelist <-
        mutate(data.frame(date = sort(unique(bond_data$date))),
               time = seq_along(date),
               tdiff = c(7, as.integer(diff(time))))
    bond_data <- merge(bond_data, datelist[ , c("date", "time")])
    bond_metadata <- get_bond_metadata()

    yields <- get_war_peace_yields()
    
    #' Get cashflows
    cashflows <-
        plyr::mdply(merge(filter(bond_data, bond %in% BONDSERIES),
                          yields),
                    function(bond, date, yield_war, ...) {
                        bond <- as.character(bond)
                        date2 <- date
                        cashflows <-
                            (filter(mutate(bond_metadata[[bond]][["cashflows"]],
                                           date = as.Date(date)),
                                    date > date2)
                             %>% mutate(maturity = as.integer(date - date2) / 365.25)
                             %>% select(maturity, amount)
                             %>% group_by(maturity)
                             %>% summarise(amount = sum(amount))
                             %>% mutate(i = seq_along(amount),
                                        lagmaturity = c(0, maturity[-length(maturity)]),
                                        warpv1 = bondpresval(yield_war, amount, maturity, p = 1),
                                        warpv2 = bondpresval(yield_war, amount, maturity, p = 0),
                                        warpv3 = bondpresval(yield_war, amount, maturity, p = 0.5))
                             )
                    })

    
    numpayments <-
        (group_by(cashflows, time, series)
         %>% summarise(n = max(i)))
    amounts <- acast(cashflows, time + series ~ i, value.var = "amount",
                     fill = 0)
    maturities <- acast(cashflows, time + series ~ i, value.var = "maturity",
                        fill = 1000)
    maturities_lag <- acast(cashflows, time + series ~ i, value.var = "lagmaturity",
                            fill = 1000)
    maturities_mid <- 0.5 * (maturities + maturities_lag)
    warpv <- acast(cashflows, time + series ~ i, value.var = "warpv1",
                fill = 0)
    list(prices = bond_data,
         dates = datelist,
         cashflows = cashflows,
         numpayments = numpayments,
         amounts = amounts,
         maturities = maturities,
         maturities_lag = maturities_lag,
         maturities_mid = maturities_mid,
         warpv = warpv,
         yields = yields)
}

get_standata <- function() {
    .data <- get_data()
    list(nobs = nrow(.data$prices),
         n_times = max(.data$prices$time),
         time = .data$prices$time,
         tdiff = .data$dates$tdiff,
         n_series = length(unique(.data$prices$series)),
         series = as.integer(.data$prices$series),
         logprice = log(.data$prices$price),
         n_payments_max = ncol(.data$amounts),
         n_payments = .data$numpayments$n,
         payment = .data$amounts,
         maturity = .data$maturities,
         maturity_lag = .data$maturities_lag,
         yield_war = .data$yields$yield_war,
         yield_peace = .data$yields$yield_peace,
         warpv = .data$warpv,
         # initial state
         logbeta_init_mean = log(0.005),
         logbeta_init_sd = 10)
}

main <- function() {
    standata <- get_standata()
    m <- stan_model(MODEL_FILE)
    sampling(m, data = standata,
             chains = CHAINS, iter = ITER, seed = SEED,
             warmup = WARMUP, thin = THIN)
}
