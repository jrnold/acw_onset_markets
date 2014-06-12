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

.DEPENDENCIES <- c(PROJ$dbpath("prices0"))

END_DATE <- as.Date("1861-5-18")
START_DATE <- as.Date("1855-3-23")

standata <- function() {
    prices <-
        mutate(filter(PROJ$db[["prices0"]],
                      date <= END_DATE,
                      date >= START_DATE,
                      src == "Bankers",
                      ! grepl("California", series)))
    
    times <-
        mutate(data.frame(date = sort(unique(prices$date))),
               time = seq_along(date))
    
    series <- (group_by(prices, series)
               %>% dplyr::summarise(group = group[1])
               %>% arrange(group, series)
               %>% mutate(seriesn = seq_along(group)))
    
    prices <- merge(prices, times)
    prices <- merge(prices, series)
    
    # Variables
    y <- prices0$ytm * 100
    y_t <- as.integer(prices0$time)
    y_j <- as.integer(prices0$series)
    
    nfactors <- 4
    loadings <- matrix(NA_real_, nrow = nrow(series), ncol = nfactors)
    rownames(loadings) <- series$series
    colnames(loadings) <- c("all", "Union", "North", "South")
    for (j in as.character(filter(series, group == "Border")$series)) {
        loadings[j, "Union"] <- 0
    }
    for (j in as.character(filter(series, group == "North")$series)) {
        loadings[j, c("South", "Union")] <- 0
    }
    for (j in as.character(filter(series, group == "South")$series)) {
        loadings[j, c("North", "Union")] <- 0
    }
    for (j in as.character(filter(series, group == "Union")$series)) {
        loadings[j, c("North", "South")] <- 0
    }
    loadings["U.S. 6s, 1868", c("all", "Union")] <- 1
    loadings[c("Ohio 6s, 1886", "Ohio 6s, 1875"),  "North"] <- 1
    loadings["Virginia 6s",  "South"] <- 1
    flattened_loadings <- flatten_constraints(loadings)
    
    loading_data_n <- flattened_loadings$const_n
    loading_data_val <- flattened_loadings$const_val
    loading_data_i <- flattened_loadings$const_i[ , 1]
    loading_data_j <- flattened_loadings$const_i[ , 2]
    loading_param_n <- flattened_loadings$var_n
    loading_param_i <- flattened_loadings$var_i[ , 1]
    loading_param_j <- flattened_loadings$var_i[ , 2]
}

main <- function() {
    NULL
    
    
}
