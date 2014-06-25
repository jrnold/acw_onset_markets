library("rstan")
library("reshape2")
library("dplyr")

#' Summarize output from db_spreads
DEPENDENCIES <- c(PROJ$dbpath("spreads1"))

main <- function() {
    spreads2 <- PROJ$db[["spreads2"]]
    .summary <- summary(spreads2$samples)

    tau_local <-
        (melt(extract(spreads2$samples, "tau_local")[[1]],
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
    tau_local <- merge(tau_local, spreads2$times)
    
    theta <-
        (melt(extract(spreads2$samples, "theta")[[1]],
              varnames =
              c("iterations", "time", "dimension"))
         %>% arrange(dimension, iterations, time)
         %>% group_by(dimension, iterations)
         %>% dplyr::mutate(value_diff = value - lag(value))
         %>% group_by(time, dimension)
         %>% dplyr::summarise(value_mean = mean(value),
                              value_sd = sd(value),
                              value_median = median(value),
                              value_p025 = quantile(value, 0.025),
                              value_p25 = quantile(value, 0.25),
                              value_p75 = quantile(value, 0.75),
                              value_p975 = quantile(value, 0.975),
                              diff_mean = mean(value_diff, na.rm = TRUE),
                              diff_sd = sd(value_diff, na.rm = TRUE),
                              diff_median = median(value_diff, na.rm = TRUE),
                              diff_p025 = quantile(value_diff, 0.025, na.rm=TRUE),
                              diff_p25 = quantile(value_diff, 0.25, na.rm = TRUE),
                              diff_p75 = quantile(value_diff, 0.75, na.rm = TRUE),
                              diff_p975 = quantile(value_diff, 0.975, na.rm = TRUE))
         %>% merge(spreads2$times)
         )

    diff_summary <- function(x, start_date, end_date) {
        (melt(extract(x$samples, "theta")[[1]],
              varnames =
              c("iterations", "time", "dimension"))
         %>% merge(x$times)
         %>% filter(date %in% c(start_date, end_date))
         %>% arrange(iterations, dimension, date)
         %>% group_by(iterations, dimension)
         %>% mutate(valdiff = value - lag(value))
         %>% filter(! is.na(valdiff))
         %>% group_by(dimension, date)
         %>% dplyr::summarise(probpos = mean(valdiff > 0),
                              mean = mean(valdiff),
                              sd = sd(valdiff),
                              median = median(valdiff),
                              p025 = quantile(valdiff, 0.025),
                              p25 = quantile(valdiff, 0.25),
                              p75 = quantile(valdiff, 0.75),
                              p975 = quantile(value, 0.975))
         )
    }

    list(summary = .summary
         , theta = theta
         , tau_local = tau_local
<<<<<<< HEAD
         , theta_diff_186001_186011 = diff_summary(as.Date("1859-12-30"),
               as.Date("1860-11-02"))
         , theta_diff_elec = diff_summary(as.Date("1860-11-02"),
               as.Date("1860-11-23"))
         , theta_diff_postelec = diff_summary(as.Date("1861-04-13"),
               as.Date("1860-11-23"))
         , theta_diff_1860_1857 = diff_summary(as.Date("1857-07-03"),
               as.Date("1859-12-30"))
=======
         , theta_diff_18550713_18601102 = diff_summary(spreads2, as.Date("1855-07-13"), as.Date("1860-11-02"))
               
         , theta_diff_elec = diff_summary(spreads2, as.Date("1860-11-02"), as.Date("1860-12-07"))
         , theta_diff_sumter = diff_summary(spreads2, as.Date("1860-04-13"), as.Date("1860-04-20"))
>>>>>>> 8c96875c3c5d3173a9a7cdec1a901fdd878ce3fe
         )
         
}
