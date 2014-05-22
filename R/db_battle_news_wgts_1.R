library("dplyr")

WAR_NEWS_FILE <- "data/news/data/major_battle_news.csv"

.DEPENDENCIES <- WAR_NEWS_FILE
    
main <- function() {
    do.call(rbind,
            mutate(read.csv(WAR_NEWS_FILE),
                   start_date = as.Date(start_date),
                   end_date = as.Date(end_date))
            %.% group_by(battle)
            %.% do(function(.data) {
                mutate(data.frame(battle = .data$battle,
                                  date = seq(.data$start_date, .data$end_date, 1)),
                       wgt = 1 / length(date))
            }))
}
