number_repayments <- function(pv, r, P, n) {
    -log(1 - (pv * r) / P) / log(1 + r)
}

number_repayments(700, 0.06 / 2, 80 / 2) / 2
number_repayments(967, 0.06 / 2, 80 / 2) / 2
number_repayments(1500, 0.06 / 2, 100 / 2) / 2
number_repayments(1200, 0.06 / 2, 100 / 2) / 2

property_union <- 13395
property_confed <- 3467
property_us <- property_union + property_confed

p1 <- 0.75
payment1 <- property_union * p1 / 100
payment2 <- property_us * p1 / 100
debt1 <- 1000
debt2 <- 1500

number_repayments(debt1, 0.06, payment1)
number_repayments(debt2, 0.06, payment2)
number_repayments(debt2, 0.06, payment1)
