library("rstan")
library("reshape2")
library("dplyr")

#' Summarize output from db_spreads
DEPENDENCIES <- c(PROJ$dbpath("spreads1"))

main <- function() {
    spreads1 <- PROJ$db[["spreads1"]]
    .summary <- summary(spreads1$samples)
    theta <-
        (melt(extract(spreads1$samples, "theta")[[1]],
              varnames =
              c("iterations", "time", "dimension"))
         %>% group_by(time, dimension)
         %>% dplyr::summarise(mean = mean(value),
                              sd = sd(value),
                              median = median(value),
                              p025 = quantile(value, 0.025),
                              p25 = quantile(value, 0.25),
                              p75 = quantile(value, 0.75),
                              p975 = quantile(value, 0.975))
         )
    theta <- merge(theta, spreads1$times)
    list(summary = .summary,
         theta = theta)
}
