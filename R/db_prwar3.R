#' Factor model of the probability of war
library("dplyr")
library("rstan")

MODEL_FILE <- PROJ$path("stan/prwar2.stan")
.DEPENDENCIES <- c(PROJ$path("R/db_prwar2.R"),
                   MODEL_FILE)

prwar3 <- source_env(PROJ$path("R/db_prwar2.R"))

ITER <- 2^11
WARMUP <- 2^10
SAMPLES <- 2^9
THIN <- 2
CHAINS <- 1
SEED <- 294845

get_data <- prwar3$get_data
standata <- prwar3$standata

main <- function() {
    .data <- get_data()
    .standata <- standata(.data)
    mod <- stan_model(MODEL_FILE)
    ret <- sampling(mod,
                    data = .standata,
                    iter = ITER, warmup = WARMUP, thin = THIN,
                    chains = CHAINS, seed = SEED)
    list(samples = ret,
         times = .data$times,
         series = .data$SERIES)

}
