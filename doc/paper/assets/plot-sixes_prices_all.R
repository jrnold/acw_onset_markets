source("conf.R")
fileargs <- commandArgs(TRUE)
fileout <- fileargs[1]


sixes <- subset(RDATA[["sixes"]])
WAR_START_DATE <- as.Date("1861-4-12")
WAR_END_DATE <- as.Date("1865-4-10")

wardata <- data.frame(ymin = min(sixes$clean_price),
                      ymax = 120,
                      xmin = WAR_START_DATE,
                      xmax = WAR_END_DATE)

gg <- (ggplot()
       + geom_rect(mapping =
                   aes(xmin = xmin, xmax = xmax,
                       ymin = ymin, ymax = ymax),
                   data = wardata, alpha = 0.3)
       + geom_point(data = sixes,
                    mapping = aes(x = date, y = clean_price),
                    size = 1)
       + scale_y_continuous("Price")
       + scale_x_date("")
       + theme_local())
       
ggsave(gg, file = fileout, width = WIDTH, height = HEIGHT)
