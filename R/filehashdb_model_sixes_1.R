#' Model sixes 1
#' 
#' Returns
#' ----------
#' 
#' ``list`` with elements
#'
#' - ``time``
#' - ``sfit``
#' - ``summary``
source("R/constants.R")
sixes_0 <- source_env("R/filehashdb_model_sixes_0.R")

.DEPENDENCIES <-
    c(STAN_MODEL("model1"),
      "R/filehashdb_sixes_0.R",
      "R/constanst.R")

START_DATE <- sixes_0$START_DATE
END_DATE <- sixes_0$END_DATE

standata <- function() {
    sixes <- sixes_0$gen_sixes()
    sixes_meas_err <- RDATA[["sixes_meas_err"]]

    X <- data.frame(date = seq(START_DATE, END_DATE, 1))
    X$quote_1881 <- as.integer(X$date == SIXES_1881_START)
    X <- as.matrix(X[ , setdiff(names(X), "date"), drop=FALSE])

    within(list(), {
        N <- nrow(sixes)
        y <- sixes$y
        missing <- sixes$missing
        
        m0 <- y[1]
        C0 <- 0.05^2
        
        xi_loc <- sixes_meas_err$log_mean
        xi_scale <- sixes_meas_err$log_sd * 1.5
        
        X <- X
        X_cols <- ncol(X)
        
        alpha_loc <- 0
        alpha_scale <- diff(range(sixes$y[!sixes$missing]))
        phi_mean <- array(0, 1)
        phi_sd <- array(0.025 * 3, 1)
    })
}

main <- function() {
    RDATA[["model_sixes_1"]] <-
        run_stan(STAN_MODEL("model1"),
                 iter = 2^11,
                 chains = 1, #length(init),
                 thin = 1,
                 data = standata(),
                 control = list(),
                 seed = RANDOM[1])
}
