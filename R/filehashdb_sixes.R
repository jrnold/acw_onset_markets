library("plyr")

.DEPENDENCIES <- sapply(c("merchants_magazine_us_paper_yields.csv",
                          "bankers_magazine_govt_state_loans_yields.csv"),
                        get_findata_path)

main <- function() {
  bankers_bond_yields <- FINDATA[["bankers_magazine_govt_state_loans_yields"]]()
  merchants_bond_yields <- FINDATA[["merchants_magazine_us_paper_yields"]]()
  ret <- subset(rbind(subset(merchants_bond_yields,
                             bond == "us_sixes_18810701"
                             & series == "sixes_1881_coup"),
                      subset(bankers_bond_yields,
                             bond %in% c("us_sixes_18680701", "us_sixes_18810701"))),
                ! is.na(price_paper_clean))

  ret <-
    ddply(ret, "date",
          summarise,
          n = length(date),
          price_paper_clean = mean(price_paper_clean, na.rm = TRUE),
          price_paper_dirty = mean(price_paper_dirty, na.rm = TRUE),
          price_gold_clean = mean(price_gold_clean, na.rm = TRUE),
          price_gold_dirty = mean(price_gold_dirty, na.rm = TRUE),
          yield = mean(yield, na.rm = TRUE),
          duration = mean(duration, na.rm = TRUE),
          maturity = mean(maturity, na.rm = TRUE),
          current_yield = mean(current_yield, na.rm = TRUE),
          accrued = mean(accrued, na.rm = TRUE))
  ret$is_1868 <- ret$date < as.Date("1861-9-1")

  RDATA[[commandArgs(TRUE)[1]]] <- ret
}
