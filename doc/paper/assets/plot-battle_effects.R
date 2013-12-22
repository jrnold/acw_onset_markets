source("conf.R")
fileargs <- commandArgs(TRUE)
fileout <- fileargs[1]

.data <- mutate(RDATA[["m_sixes_3a_summary"]][["beta_summary"]],
                short_battle_name =
                str_trim(gsub(" *Battle of *", " ", battle_name)))
.data$short_battle_name <- reorder(.data$short_battle_name, .data$mean)


gg <- (ggplot(.data)
       + geom_linerange(aes(x = short_battle_name,
                            ymin = p025, ymax = p975), colour="gray70")
       + geom_pointrange(aes(x = short_battle_name,
                             ymin = p25, ymax = p75, y = mean,
                             colour = outcome))
       + coord_flip()
       + scale_x_discrete("")
       + scale_y_continuous(expression(paste("p", bgroup("(", paste(beta[b], "|", y), ")"))))
       + theme_gray(base_size = 8))

ggsave(gg, file = fileout, width = WIDTH_FULL, height = HEIGHT_FULL)
