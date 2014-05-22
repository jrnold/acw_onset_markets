library("plyr")

main <- function() {
    news <- 
        ddply(WAR_NEWS[["major_battle_news"]](),
              "battle",
              function(.data) {
                  mutate(data.frame(date = seq(.data$start_date,
                                    .data$end_date, 1)),
                         wgt = 1 / length(date))
              })
    RDATA[[commandArgs(TRUE)[1]]] <- news
}
