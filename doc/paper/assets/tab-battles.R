source("conf.R")
fileargs <- commandArgs(TRUE)
fileout <- fileargs[1]

battles <- mutate(subset(RDATA[["battles1"]], significance == "A",
                         c("battle_name", "start_date", "end_date", "outcome")),
                  battle_name = str_trim(gsub(" *Battle of *", " ", battle_name)),
                  start_date = format(start_date, "%Y-%m-%d"),
                  end_date = format(end_date, "%Y-%m-%d"))
                      
names(battles) <- c("", "Start", "End", "Outcome")

print(xtable(battles, digits = 3), file = fileout, floating = FALSE,
      include.rownames = FALSE)
      
