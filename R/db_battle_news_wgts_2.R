#' ---
#' dependencies:
#'  - "data/news/data/battle_news.csv"
#'  - "data/acw_battles/data/battles.csv"
#' ---
#' 
#' Weights for news from battles; all news days.
#'
#' # Returns
#'
#' ``data.frame``
#'
#' - ``battle``
#' - ``date``
#' - ``wgt``
#' - ``lagwgt``
#' - ``wgt2``:  A smoothed weight. ``0.5 * lagwgt + 0.5 * wgt``. Some articles report things that happened the
#'   day before that the market responded to; other articles report things that were known after the market closed.
#'   The weights are arbitrary. A better model would estimate them.
library("dplyr")
library("sp")

BATTLE_NEWS <- PROJ$path("data/news/data/battle_news.csv")
BATTLES <- PROJ$path("data/acw_battles/data/battles.csv")

.DEPENDENCIES <- c(BATTLE_NEWS, BATTLES)
LAGP <- 0.5

create_battles <- function() {
      mutate(read.csv(BATTLES)[ , c("battle", "start_date", "end_date", "theater", 
                                      "lat", "long")],
             start_date = as.Date(start_date),
             end_date = as.Date(end_date))
}

create_battle_news <- function() {
  battles <- create_battles()
  
  .data <-
    merge(mutate(read.csv(BATTLE_NEWS)[ , c("battle", "pubdate", "startPage")],
                 date = as.Date(pubdate),
                 wgt = 1 / startPage),
          battles, all.x = TRUE)

  .data2 <- (group_by(.data, battle, date)
   %>% summarise(wgt = sum(wgt))
   %>% group_by(battle)
   %>% mutate(wgt = 1 / sum(wgt))
   %>% select(battle, date, wgt)
  )
  
  .lagdata2 <- 
    (mutate(.data2, 
            date = date - 1L,
            lagwgt = wgt)
     %>% select(battle, date, lagwgt))
  
  .data3 <- 
    mutate(merge(.data2, .lagdata2,
                 by = c("battle", "date"),
                 all = TRUE),
           wgt = fill_na(wgt),
           lagwgt = fill_na(lagwgt),
           wgt2 = (1 - LAGP) * wgt + LAGP * lagwgt)
  .data3
}

main <- function() {
    create_battle_news()
}
