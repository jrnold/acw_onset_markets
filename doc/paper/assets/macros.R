#' # Create Macros for Use in LaTeX
#'

#' # Header
source("conf.R", chdir=TRUE)
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

#' # Results for model m_sixes_3a

local({

  mod <- RDATA[["m_sixes_3a"]]
  mod_summary <- RDATA[["m_sixes_3a_summary"]]

  gamma <- mod[["gamma"]]
  gamma_mean <- apply(gamma, 1, mean)
  add_macro("AcwGammaMeanC", floatFormat(gamma_mean[1], 3))
  add_macro("AcwGammaMeanCPct", percent(-1 * gamma_mean[1], 1))
  add_macro("AcwGammaMeanI", floatFormat(gamma_mean[2], 3))
  add_macro("AcwGammaMeanIPct", percent(gamma_mean[2], 1))
  add_macro("AcwGammaMeanU", floatFormat(gamma_mean[3], 3))
  add_macro("AcwGammaMeanUPct", percent(gamma_mean[3], 1))


  add_macro("AcwTauCltU", floatFormat(mod_summary[["tau_confed_lt_union"]], 2))
  add_macro("AcwGammaCltUAbs", floatFormat(mod_summary[["gamma_confed_lt_union_abs"]], 2))

  btlbeta <- function(x) {
    subset(RDATA[["m_sixes_3a_summary"]][["beta_summary"]], battle == x)$mean
  }
  
  add_macro("AcwBetaGettysburg", percent(btlbeta("PA002"), 1))
  add_macro("AcwBetaFtSumter", percent(btlbeta("SC001"), 1))
  
})



#' # Print Macro
macrostring <- mapply(function(name, value) {
    sprintf("\\newcommand{\\%s}{%s}", name, value)
}, names(MACROS), MACROS)

cat(str_c(macrostring, collapse="\n"), file=fileout)
