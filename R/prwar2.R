n#' 
library("rstan")
library("jsonlite")
library("dplyr")
library("reshape2")

PRWAR1_FILE <- PROJ$path("R/db_prwar1.R")
    
.DEPENDENCIES <-
    c(BOND_METADATA_FILE, BANKERS_FILE, PRWAR1_FILE)

db_prwar1 <- source_env(PRWAR1_FILE)

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

pv_with_pr_war <- function(rate, yield_peace, yield_war, amount, maturity) {
    lag_maturity <- c(0, maturity[1:(length(maturity) - 1)])
    discounts <- exp(- yield_peace * maturity)
    pr_peace <- pexp(rate, lower.tail = FALSE)
    pr_war_lb <- pexp(rate, lag_maturity)
    pr_war_ub <- pexp(rate, maturity)
    pr_war <- pr_war_ub - pr_war_lb
    pv <- discount * (pr_war * bondpresval(yield_war, amount, maturity, p = 0)
                      + pr_peace * amount)
    sum(pv)
}

find_pr_war <- function(price, yield_peace, yield_war, amount, maturity, interval = c(0, 1000), ...) {
    .f <- function(rate) {
        (price - pv_with_pr_war(rate, yield_peace, yield_war, amount, maturity))^2
     }
    ret <- pv_with_pr_war(find_pr_war, interval = interval, ...)
    ret$par
}



get_data <- function() {
    yields <- db_prwar1$get_war_peace_yields()
    bond_data <- db_prwar1$get_data()
    
    cashflows <-
        plyr::mdply(merge(filter(bond_data, bond %in% BONDSERIES),
                          yields),
                    function(bond, date, price, yield_peace, yield_war, ...) {
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
                                        warpv1 = bondpresval(yield_war, amount, maturity, p = 1),
                                        warpv2 = bondpresval(yield_war, amount, maturity, p = 0),
                                        warpv3 = bondpresval(yield_war, amount, maturity, p = 0.5))
                             )
                        
                    })
    
}

main <- function() NULL
