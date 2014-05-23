library("Quandl")
library("jsonlite")

#' Download three series from Quandl from Macaulay (1938) "The Movement Of Interest Rates, Bond Yields, And Stock Prices In The United States Since 1856"
#' These are the standard short and long-run interest series for the Civil War Era,
#' e.g. see Homer and Sylla.

.data <- list()
#' 
#' [Railroad Bond Yields Index for US](http://www.quandl.com/FRED/M1319AUSM156NNBR")
.data[["railroad_bond_yields"]] <- Quandl("FRED/M1319AUSM156NNBR")

#' [Municipal Bond Yields for New England](http://www.quandl.com/FRED/Q13020USQ156NNBR)
.data[["municipal_bond_yields"]] <- Quandl("FRED/Q13020USQ156NNBR")

#' [Call money rates, mixed collateral ](http://www.quandl.com/FRED/M13001USM156NNBR)
#' 
.data[["call_money_mixed"]] <- Quandl("FRED/M13001USM156NNBR")

#' [U.S. Call money rates](http://www.quandl.com/FRED/M1301AUSM156NNBR)
.data[["call_money_rates"]] <- Quandl("FRED/M13001USM156NNBR")

cat(toJSON(.data), file="macaulay.json")
