unif_sd <- function(x) {
    sqrt((1 / 12) * diff(range(x))^2)
}

subset(ddply(subset(RDATA[["prices"]],  series %in% c("US_6pct_1881")),
             "date", summarise,
             yield_sd = unif_sd(yield),
             logyield_sd = unif_sd(log(yield)),
             price_gold_clean_sd = unif_sd(price_gold_clean),
             logprice_gold_clean_sd = unif_sd(log(price_gold_clean))),
       yield_sd > 0)
