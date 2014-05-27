#'
#' Estimates of the riskfree interest rates from the Macualay (1938) interest rates.
#' 
library("dplyr")
library("reshape2")
library("zoo")
library("lubridate")

.DEPENDENCIES <- PROJ$dbpath("macaulay")

main <- function() {
    macaulay <- PROJ$db[["macaulay"]]
    railroads <-
        merge(data.frame(date = seq(as.Date("1857-2-15"), as.Date("1879-1-15"), by = 1)),
              (filter(macaulay, variable == "railroad_bond_yields")
               %>% mutate(railroad = rate, date = date + 14L)
               %>% select(-rate, -variable)),
              all.x = TRUE)
    railroads$railroads_smooth <- as.numeric(tsSmooth(StructTS(railroads$railroad, "level")))
    municipal <-
        merge(data.frame(date = seq(as.Date("1857-2-15"), as.Date("1879-1-15"), by = 1)),
              (filter(macaulay, variable == "municipal_bond_yields")
               %>% mutate(municipal = rate, date = date + months(1) + 14L)
               %>% select(-rate, -variable)),
              all.x = TRUE)
    municipal$municipal_smooth <- as.numeric(tsSmooth(StructTS(municipal$municipal, "level")))
    mutate(merge(railroads, municipal),
           riskfree = 0.5 * railroads_smooth + 0.5 * municipal_smooth)
}
