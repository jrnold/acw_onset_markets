#'
#' Greenbacks model of battle effects
#'
library("dplyr")
library("rstan")

MODEL_FILE <- "stan/m2.stan"
    
.DEPENDENCIES <-
    c(MODEL_FILE,
      PROJ$dbpath("m_greenbacks_1"),
      PROJ$path("R/db_m_spreads_1.R"))

m_spreads_1 <- source_env("R/db_m_spreads_1.R")

START_DATE <- as.Date("1862-1-1")
END_DATE <- m_spreads_1$END_DATE

#' MCMC parameters
ITER <- 2^11
WARMUP <- 2^10
SAMPLES <- 2^10
THIN <- 1
SEED <- 535682

get_battles <- function() {
    battles <-
        mutate(filter(m_spreads_1$get_battles(),
                      date >= START_DATE
                      & date <= END_DATE),
               time = as.integer(date - START_DATE) + 1,
               battle = as.factor(battle),
               battle_num = as.integer(battle))
}

get_prices <- function() {
    mutate(filter(PROJ$db[["greenbacks_1"]],
                  ! is.na(high)
                  & date <= END_DATE),
           time = as.integer(date - START_DATE) + 1)
}

standata <- function() {
    battles <- get_battles()
    prices <- get_prices()
    .data <- list()
    .data[["y"]] <- prices$log_mean
    .data[["s2"]] <- prices$log_var
    .data[["nobs"]] <- nrow(prices)
    .data[["N"]] <- as.integer(END_DATE - START_DATE) + 1
    .data[["time"]] <- prices$time

    # priors
    .data[["theta0_loc"]] <- log(100)
    .data[["theta0_scale"]] <- 0.05
    
    .data[["n_battles"]] <- length(levels(battles$battle))
    .data[["n_outcomes"]] <- 2
    .data[["n_lag_wgts"]] <- nrow(battles)
    .data[["lag_wgts"]] <- battles$wgt2
    .data[["lag_battle"]] <- battles$battle_num
    .data[["lag_outcome"]] <- battles$outcome_num
    .data[["lag_times"]] <- battles$time
    .data
}

main <- function() {
    mod <- stan_model(MODEL_FILE)
    .standata <- standata()
    ret <- sampling(mod, data = .standata,
                    iter = ITER, warmup = WARMUP, thin = THIN,
                    chains = 1, seed = SEED)
    ret
}
