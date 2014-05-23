library("stringr")
library("yaml")

comment_regex <- "^(#\\S*)( +)?(.*)"
start_end <- "^(-{3}|\\.{3}) *$"
lines <- readLines("db_battle_news_wgts_2.R")
comment_lines <- na.omit(str_match(lines, comment_regex))[ , 4]
i <- which(str_detect(comment_lines, start_end))
metadata <- yaml.load(str_c(comment_lines[(i[1] + 1):(i[2] - 1)],
                            collapse = "\n"))




