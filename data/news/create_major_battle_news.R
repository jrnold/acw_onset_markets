library("yaml")
library("plyr")

news <- ldply(yaml.load_file("sources/major_battle_news.yaml"),
              function(x) {
                  if (is.null(x$end_date)) x$end_date <- x$start_date
                  data.frame(x)
              })
names(news)[1] <- "battle"

news <- mutate(news,
               start_date = as.Date(start_date),
               end_date = as.Date(end_date))

write.csv(news, file="data/major_battle_news.csv", row.names=FALSE)
