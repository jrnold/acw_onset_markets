#' # Create Macros for Use in LaTeX

#' # Header
args <- commandArgs(TRUE)
fileout <- args[1]

dateFormat <- function(x) format(x, "%B %d, %Y")
intFormat <- function(x) formatC(x, big.mark=",", format="f", digits=0)
floatFormat <- function(x, digits = 2) {
  formatC(x, big.mark=",", format="fg", digits = digits)
}
# Assumes x is a share
percent <- function(x, digits = 0) {
  paste0(round(100 * x, digits = digits), "\\%")
}

MACROS <- list()
add_macro <- function(name, value) {
    MACROS[[name]] <<- value
}

###############

#' # Macro definitions
battles1 <- RDATA[["battles1"]]

#' Number of CWSAC battles between Union and Confederate forces
add_macro("AcwBattleNum",
          intFormat(nrow(battles1)))
#' Number of significant battles
add_macro("AcwBattleNumSigA",
          intFormat(nrow(subset(battles1, significance == "A"))))

#' Percent of sig = A battles
battles_sig_a <- subset(battles1, significance == "A")
add_macro("AcwBattlePctSigA", intFormat(sum(battles1$significance == "A") / nrow(battles1)))


#' Military significant battles
local({
  outcomes <- subset(RDATA[["battles1"]],
                     significance == "A")$outcome

  #' Number of battles ending in each outcome
  add_macro("AcwBattleSigAOutcomeC", intFormat(sum(outcomes == "Confederate")))
  add_macro("AcwBattleSigAOutcomeU", intFormat(sum(outcomes == "Union")))
  add_macro("AcwBattleSigAOutcomeI", intFormat(sum(outcomes == "Inconclusive")))

  #' Percent of battles ending in each outcome
  add_macro("AcwBattleSigAOutcomeCPct",
            sprintf("%s\\%%",
                    floatFormat(100 * sum(outcomes == "Confederate") / length(outcomes), 1)))
  add_macro("AcwBattleSigAOutcomeIPct",
            sprintf("%s\\%%",
                    floatFormat(100 * sum(outcomes == "Inconclusive")/ length(outcomes), 1)))
  add_macro("AcwBattleSigAOutcomeUPct",
            sprintf("%s\\%%", floatFormat(100 * sum(outcomes == "Union")/ length(outcomes), 1)))

})

#' Outcomes for ALL battles
local({
  outcomes <- RDATA[["battles1"]]$outcome

  #' Number of battles ending in each outcome
  add_macro("AcwBattleOutcomeC", intFormat(sum(outcomes == "Confederate")))
  add_macro("AcwBattleOutcomeU", intFormat(sum(outcomes == "Union")))
  add_macro("AcwBattleOutcomeI", intFormat(sum(outcomes == "Inconclusive")))

  #' Percent of battles ending in each outcome
  add_macro("AcwBattleOutcomeCPct",
            sprintf("%s\\%%",
                    floatFormat(100 * sum(outcomes == "Confederate") / length(outcomes), 1)))
  add_macro("AcwBattleOutcomeIPct",
            sprintf("%s\\%%",
                    floatFormat(100 * sum(outcomes == "Inconclusive")/ length(outcomes), 1)))
  add_macro("AcwBattleOutcomeUPct",
            sprintf("%s\\%%", floatFormat(100 * sum(outcomes == "Union")/ length(outcomes), 1)))

})


#' ## Prices
#'
#' Start and end dates and number of observations
local({
  SIXES_START_DATE <- as.Date("1861-4-6")
  SIXES_END_DATE <- as.Date("1865-4-12")
  sixes <- merge(data.frame(date = seq(SIXES_START_DATE, SIXES_END_DATE, 1)),
                 subset(RDATA[["sixes"]], between(date, SIXES_START_DATE, SIXES_END_DATE)),
                 all.x = TRUE)
  ndays <- nrow(sixes)
  nonmiss <- sum(!is.na(sixes$clean_price))
  dailyfreq <- diff(subset(sixes, !is.na(clean_price))$date)

  add_macro("AcwSixesStart", dateFormat(SIXES_START_DATE))
  add_macro("AcwSixesEnd", dateFormat(SIXES_END_DATE))
  add_macro("AcwSixesNobs", intFormat(nonmiss))
  add_macro("AcwSixesDays", intFormat(ndays))
  add_macro("AcwSixesPctMissing",
            sprintf("%s\\%%", intFormat(round(100 * (1 - nonmiss / ndays)))))
  #' Min and max days between non-missing observations
  add_macro("AcwSixesDayDiffMin", min(dailyfreq))
  add_macro("AcwSixesDayDiffMax", max(dailyfreq))
})


#' # Print Macro
macrostring <- mapply(function(name, value) {
    sprintf("\\newcommand{\\%s}{%s}", name, value)
}, names(MACROS), MACROS)

cat(str_c(macrostring, collapse="\n"), file=fileout)
