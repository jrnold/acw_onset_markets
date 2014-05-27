#'
#' Price data
#'
library("dplyr")
library("rstan")

MODEL_FILE <- "stan/m0.stan"
INIT_FILE <- "data/init/m_spreads_0.rds"

.DEPENDENCIES <-
    c(PROJ$dbpath(c("prices1", "riskfree")),
      MODEL_FILE, INIT_FILE)

#' First date definitely after Fort Sumter
START_DATE <- as.Date("1861-4-20")
#' First Date after Appomattox Courthouse
END_DATE <- as.Date("1865-4-12")

ITER <- 2^11
WARMUP <- 2^10
SAMPLES <- 2^10
THIN <- 1
SEED <- 803853

gen_prices <- function() {
    prices1 <- PROJ$db[["prices1"]]
    riskfree <- PROJ$db[["riskfree"]]
    
    filter(mutate(merge(prices1
                        %>% filter(series %in% c("US_5pct_1874",
                                                 "US_6pct_1868",
                                                 "US_6pct_1881")),
                        select(riskfree, date, municipal_smooth),
                        all.x = TRUE),
                  series = factor(series),
                  spread = ytm_mean * 100 - municipal_smooth),
           date >= START_DATE,
           date <= END_DATE)
}


standata <- function() {
    prices <- gen_prices()
    list(y = prices$spread,
         nobs = nrow(prices),
         N = as.integer(END_DATE - START_DATE + 1L),
         time = as.integer(prices$date - START_DATE) + 1L,
         r = length(levels(prices$series)),
         variable = as.integer(prices$series),
         theta0_loc = 3.5,
         theta0_scale = 1
         )
}

main <- function() {
    mod <- stan_model(MODEL_FILE)
    .standata <- standata()
    .init <- PROJ$read_init("m_spreads_0")
    ret <- sampling(mod, data = .standata, init = .init,
                    iter = ITER, warmup = WARMUP, thin = THIN,
                    chains = 1, seed = 803833)
    ret
}
