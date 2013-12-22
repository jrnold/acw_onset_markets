source("conf.R")
fileargs <- commandArgs(TRUE)
fileout <- fileargs[1]

sixes <- subset(RDATA[["sixes"]],
                date >= as.Date("1861-1-1"))
gg <- (ggplot(sixes, aes(x = date, y = clean_price))
       + geom_point(size = 1)
       + theme_local()
       + scale_y_continuous("Price")
       + scale_x_date("")
       )
       
ggsave(gg, file = fileout, width = WIDTH, height = HEIGHT)
