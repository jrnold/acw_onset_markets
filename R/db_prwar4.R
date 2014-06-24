#' Factor model of the probability of war
library("dplyr")
library("rstan")

MODEL_FILE <- PROJ$path("stan/prwar3.stan")
.DEPENDENCIES <- c(PROJ$dbpath("prices0"),
                   PROJ$dbpath("prwar1"),
                   MODEL_FILE)

ITER <- 2^12
WARMUP <- 2^11
SAMPLES <- 2^9
THIN <- 2^2
CHAINS <- 1
SEED <- 122218

SERIES <- c("Georgia 6s", "Kentucky 6s", 
            "Louisiana 6s", "Tennessee 6s", "Virginia 6s")

get_data <- function() {
    within(list(), {
        yields <- filter(PROJ$db[["prwar1"]][["yields"]],
                         series %in% SERIES)
        nseries <- nrow(yields)
        rownames(yields) <- SERIES
        
        prices <-
            mutate(filter(PROJ$db[["prwar1"]][["prwar"]],
                          series %in% SERIES),
                   series = factor(as.character(series), levels = SERIES),
                   seriesn = as.integer(series))
        times <-
            mutate(data.frame(date = sort(unique(prices$date))),
                   time = seq_along(date))
        ntimes <- nrow(times)
        prices <- merge(prices, times)
    })
}

standata <- function(.data) {
    list(n = nrow(.data$times)
         , r = .data$nseries
         , y_nobs = nrow(.data$prices)
         , y = .data$prices$ytm
         , y_variable = .data$prices$seriesn
         , y_time = .data$prices$time
         , recovery = .data$prices$pv_yield_war / 100
         , riskfree = exp(.data$yields$logyield_peace)
         # logit scaled prob war (0.001, 0.02)
         , theta_init_loc = -5.4
         , theta_init_scale = 0.75
         )
    
}

#' Generate initial values (1 chain only)
staninit <- function(.standata, .data) {
    ret <- list()
    #' intitial values of theta from estimates in prwar1
    p <- pmax((group_by(.data$prices, time)
               %>% dplyr::summarise(prwar = mean(prwar2)))$prwar,
              0.001)
    ret$epsilon <- c(0, diff(log(p / (1 - p))))
    # ret$sigma <- rep(0.5 * sd(.standata$y), .standata$r)
    ret$sigma <- 0.5 * sd(.standata$y)
    ret$tau <- 1
    ret$tau_local <- rep(1, .standata$n - 1)
    ret$nu <- 3
    list(ret)
}

main <- function() {
    .data <- get_data()
    .standata <- standata(.data)
    .staninit <- staninit(.standata, .data)
    mod <- stan_model(MODEL_FILE)
    ret <- sampling(mod,
                    data = .standata, init = .staninit,
                    iter = ITER, warmup = WARMUP, thin = THIN,
                    chains = CHAINS, seed = SEED)
    list(samples = ret,
         times = .data$times,
         series = SERIES)

}
