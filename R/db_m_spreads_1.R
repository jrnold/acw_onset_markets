#'
#' Price data
#'
library("dplyr")
library("rstan")

MODEL_FILE <- "stan/m1.stan"
    
.DEPENDENCIES <-
    c(MODEL_FILE,
      sapply(c("battle_news_wgts_2", "battles"), PROJ$dbpath),
      "R/db_m_spreads_0.R")

m_spreads_0 <- source_env("R/db_m_spreads_0.R")

START_DATE <- m_spreads_0$START_DATE
END_DATE <- m_spreads_0$END_DATE
EXCLUDED_BATTLES <- c("SC001", #  Fort Sumter
                      "AL006" # Fort Blakelya
                      )

#' MCMC parameters
ITER <- 2^11
WARMUP <- 2^10
SAMPLES <- 2^10
THIN <- 1
SEED <- 256323

get_battles <- function() {
    major_battle_news <- PROJ$db[["battle_news_wgts_2"]]
        
    #' Only use battles in the Major War News dataset
    #' Significanc A with news reported on them.
    battles <-
        filter(merge(major_battle_news,
                     (filter(PROJ$db[["battles"]],
                             significance == "A",
                             ! battle %in% EXCLUDED_BATTLES)
                      %>% select(battle, battle_name_short, outcome)),
                     by = "battle"),
               date >= START_DATE & date <= END_DATE)
    
    #' Since there are only two Inconclusive battles, recode their outcomes.
    #' Wilderness == "Union" victory. As per Bodart and my reading of newspapers
    battles[battles$battle == "VA046", "outcome"] <- "Union"
    #' Spotsylvania Court House: Much more inconclusive
    battles[battles$battle == "VA048", "outcome"] <- "Confederate"
    #' remove Inconclusive category.
    battles$outcome <- factor(battles$outcome, levels = c("Confederate", "Union"))
    battles$outcome_num <- as.integer(battles$outcome)

    #' Time
    battles$time <- as.integer(battles$date - START_DATE) + 1L

    #' Integer battles
    battles$battle <- factor(battles$battle)
    battles$battle_num <- as.integer(battles$battle)
    battles
}

standata <- function() {
    .data <- m_spreads_0$standata()
    .battles <- get_battles()
    .data[["n_battles"]] <- length(levels(.battles$battle))
    .data[["n_outcomes"]] <- 2
    .data[["n_lag_wgts"]] <- nrow(.battles)
    .data[["lag_wgts"]] <- .battles$wgt2
    .data[["lag_battle"]] <- .battles$battle_num
    .data[["lag_outcome"]] <- .battles$outcome_num
    .data[["lag_times"]] <- .battles$time
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
