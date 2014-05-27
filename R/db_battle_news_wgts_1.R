library("dplyr")

WAR_NEWS_FILE <- "data/news/data/major_battle_news.csv"

.DEPENDENCIES <- WAR_NEWS_FILE
    
main <- function() {
  expand_dates <- function(x) {
    mutate(data.frame(battle = x$battle,
                      date = seq(x$start_date, x$end_date, by = 1)),
           wgt = 1 / length(date))
  }
  .data <- mutate(read.csv(WAR_NEWS_FILE),
                 start_date = as.Date(start_date),
                 end_date = as.Date(end_date))
  plyr::ddply(.data, "battle", expand_dates)   
}