#' Battle News
#' ==========================
#'
library("plyr")

main <- function() {
    battles <- ACW_BATTLES()
    
    battle_news <-
        mutate(WAR_NEWS[["battle_news"]]()[ , c("battle", "pubdate", "startPage")],
               wgt = 1 / startPage)
    
    battle_news <-
        mutate(merge(battles[ , c('battle', 'start_date', 'end_date')],
                     ddply(rbind(battle_news, mutate(battle_news, pubdate = pubdate - 1)),
                           c("battle", "pubdate"),
                           summarise, wgt = sum(wgt) * 0.5)),
               lag = as.integer(pubdate - end_date))
    
    battle_news_lags <-
        ddply(battle_news, "battle",
              function(x) {
                  x <- subset(x, lag > 0)
                  wgt <- x$wgt / sum(x$wgt)
                  xmean <- sum(x$lag * wgt)
                  xvar <- sum(wgt * (x$lag - xmean)^2)
                  data.frame(mean = xmean, var = xvar)
              })
    
    battle_news_theater <-
        ddply(merge(battle_news_lags, battles[ , c("battle", "theater")]),
              "theater", summarise, lag_mean = mean(mean), lag_sd = sd(mean), var = mean(var))

    RDATA[[commandArgs(TRUE)[1]]] <- battle_news
}
