#' Weights for news from battles; all news days.
library("plyr")
library("sp")

battle_news_wgts_3 <- source_env("R/filehashdb_battle_news_wgts_2.R")

.DEPENDENCIES <- c("R/filehashdb_battle_news_wgts_2.R")

main <- function() {
    battles <- merge(RDATA[["battle_news_wgts_2"]],
                     battle_news_wgts_3$battles())
    battles$lag_start <- as.integer(battles$date - battles$start_date)
    battles$lag_end <- as.integer(battles$date - battles$end_date)

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
                         wgt2 = (1 - lagp) * wgt + lagp * lagwgt)
              })

    RDATA[["battle_news_wgts_2"]] <- battle_news
}
