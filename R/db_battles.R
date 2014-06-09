#' # Battle Data
#'
#' Dataset of battles
library("dplyr")
library("sp")

BATTLES_FILE <- PROJ$path("data/acw_battles/data/battles.csv")

.DEPENDENCIES <- c(BATTLES_FILE)

GEO_NY <- c(long = 75, lat = 43)

create_battles <- function() {
  battles <- read.csv(BATTLES_FILE)
  battles[["dist_ny"]] <-
    spDistsN1(as.matrix(battles[ , c("long", "lat")]), GEO_NY, longlat = TRUE)
  for (i in c(paste0("start_date", c("", "_1", "_2")),
              paste0("end_date", c("", "_1", "_2")))) {
    battles[[i]] <- as.Date(battles[[i]])
  }
  battles
}

main <- function() {
  create_battles()
}

