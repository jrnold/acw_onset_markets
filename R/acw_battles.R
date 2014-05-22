#' Pre-process dataset of American Civil War Battles
acw_battles <- function(project) {
    outcome_factor_3 <- function(x) {
        ordered(x, c("Confederate", "Inconclusive", "Union"))
    }
    outcome_factor_2 <- function(x) {
        ordered(x, c("Confederate", "Union"))
    }

    mutate(read.csv(file.path(project$datadir(), "acw_battles", "data", "battles.csv")),
           start_date = as.Date(start_date),
           end_date = as.Date(end_date),
           mid_date = as.Date(mid_date),
           start_date_1 = as.Date(start_date_1),
           end_date_1 = as.Date(end_date_1),
           start_date_2 = as.Date(start_date_2),
           end_date_2 = as.Date(end_date_2),
           significance = ordered(significance, c("D", "C", "B", "A")),
           surrender = ordered(surrender, c("Confederate complete", "Confederate partial", "None", "Union partial", "Union complete")),
           outcome_cwsac1 = outcome_factor_3(outcome_cwsac1),
           outcome_cwsac2 = outcome_factor_3(outcome_cwsac2),
           outcome_fox = outcome_factor_3(outcome_fox),
           outcome_dbp = outcome_factor_3(outcome_dbp),
           outcome_bod = outcome_factor_2(outcome_bod),
           outcome_liv = outcome_factor_3(outcome_liv),
           outcome_cdb90 = outcome_factor_2(outcome_cdb90),
           outcome = outcome_factor_3(outcome))
}
