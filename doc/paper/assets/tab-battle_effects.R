source("conf.R")
library("xtable")
fileargs <- commandArgs(TRUE)
fileout <- fileargs[1]

mod <- RDATA[["m_sixes_3a"]]

.data <- mutate(RDATA[["m_sixes_3a_summary"]][["beta_summary"]],
                short_battle_name =
                str_trim(gsub(" *Battle of *", " ", battle_name)))
.data <- arrange(.data, -mean)

.data <- .data[ , c("short_battle_name", "mean", "sd",
                    "p025", "p25", "median", "p75", "p975")]
names(.data) <- c("", "Mean", "Std. Dev", "2.5%", "25%",
                  "50%", "75%", "97.5%")

print(xtable(.data, digits = 3), file = fileout, floating = FALSE,
      include.rownames = FALSE)
      
