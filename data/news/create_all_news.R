library(stringr)
library(plyr)

process_file <- function(filename) {
  battle <- str_sub(basename(filename), 1, 5)
  .data <- read.csv(filename)
  .data[["battle"]] <- battle
  if (! "Title" %in% names(.data)) print(filename)
  .data
}

data <- mutate(ldply(dir("sources", pattern = "\\.csv$", full.names=TRUE),
                     process_file),
               FindACopy = NULL,
               DocumentURL = gsub("\\?.*$", "", DocumentURL),
               entryDate = as.Date(str_trim(as.character(entryDate)), "%b %d, %Y"),
               pubdate = as.Date(str_trim(as.character(pubdate)), "%b %d, %Y"))

idcols <- c("battle", "pubdate", "DocumentURL")
data <- data[ , c(c(idcols, setdiff(names(data), idcols)))]

write.csv(data, file = "data/battle_news.csv",
          na = "", row.names = FALSE)

