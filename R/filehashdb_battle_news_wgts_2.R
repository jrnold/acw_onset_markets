#' Weights for news from battles; all news days.
#'
#' Returns
#' -----------
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
library("plyr")
library("sp")

.DEPENDENCIES <-
    c(DATAFILE("news/data/battle_news.csv"),
      file.path(DATA_DIR, "acw_battles", "data", "battles.csv"))

GEO_NEW_YORK <- c(long=75, lat=43)

battles <- function() {
    battles <- ACW_BATTLES()[ , c("battle", "start_date", "end_date", "theater", "lat", "long")]
    battles$dist_ny <- spDistsN1(as.matrix(battles[ , c("long", "lat")]), GEO_NEW_YORK, longlat = TRUE)
    battles
}

main <- function() {
    lagp <- 0.5
    
    battle_news <-
        mutate(WAR_NEWS[["battle_news"]]()[ , c("battle", "pubdate", "startPage")],
               wgt = 1 / startPage)
    
    battle_news <-
        ddply(ddply(battle_news, c("battle", "pubdate"),
                    summarise, wgt = sum(wgt)),
              c("battle"),
              function(x) {
                  x1 <- data.frame(date = x$pubdate,
                                   wgt = x$wgt / sum(x$wgt))
                  x2 <- rename(mutate(x1, date = date - 1L),
                               c("wgt" = "lagwgt"))
                  mutate(merge(x1, x2, all = TRUE),
                         wgt = fill_na(wgt),
                         lagwgt = fill_na(lagwgt),
                         wgt2 = (1 - lagp) * wgt + lagp * lagwgt,
                         lag_start = as.integer(date - start_date),
                         lag_end = as.integer(date - end_date))
              })

    RDATA[["battle_news_wgts_2"]] <- battle_news
}
