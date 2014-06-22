library("rstan")
library("reshape2")
library("dplyr")

#' Summarize output from db_spreads
.DEPENDENCIES <- c(PROJ$dbpath("prwar3"))

main <- function() {
    prwar2 <- PROJ$db[["prwar3"]]
    .summary <- summary(prwar2$samples)
    phi <- 
        (melt(extract(prwar2$samples, "phi")[[1]],
              varnames = c("iterations", "time"))
         %>% group_by(time)
         %>% dplyr::summarise(mean = mean(value),
                              sd = sd(value),
                              median = median(value),
                              p025 = quantile(value, 0.025),
                              p25 = quantile(value, 0.25),
                              p75 = quantile(value, 0.75),
                              p975 = quantile(value, 0.975))
         %>% merge(prwar2$times)
         )
    list(summary = .summary,
         phi = phi)
}
