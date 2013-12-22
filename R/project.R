suppressPackageStartupMessages({
    library("filehash")
    library("rstan")
})

ROOT_DIR <- "."
STAN_MODEL_DIR <- file.path(ROOT_DIR, "stan")
DATA_DIR <- file.path(ROOT_DIR, "data")
FILEHASH_DB <- file.path(ROOT_DIR, "filehashdb")
RDATA <- dbInit(FILEHASH_DB, "RDS")

filehashdb_key <- function(filename = commandArgs(FALSE)[1]) {
    gsub("filehashdb_", "", tools::file_path_sans_ext(basename(filename)))
}

CIVIL_WAR_FINDATA <- file.path(ROOT_DIR, "submodules/civil_war_era_findata")
get_findata_path <- function(key) file.path(CIVIL_WAR_FINDATA, "data", key)

DATAFILE <- function(path) {
  file.path(ROOT_DIR, "data", path)
}

STAN_MODELS <- function(key) {
  file.path(STAN_MODEL_DIR, sprintf("%s.stanx", key))
}

INIT_FILE <- function(key) {
  DATAFILE(sprintf("model_init/%s.rds", key))
}

GET_INIT <- function(key) {
  filename <- INIT_FILE(key)
  if (file.exists(filename)) {
    readRDS(filename)
  } else {
    NULL
  }
}

GEN_INIT <- function(key, n = 4, parameters = NULL, chain_id = NULL) {
  mod <- RDATA[[key]]
  params <- mcmcdb_parameters(mod)
  if (is.null(parameters)) parameters <- setdiff(names(params), "lp__")
  params <- params[parameters]
  samples <-
    mcmcdb_resample(mod, n = n, replace = FALSE, chain_id = chain_id,
                    flatten = FALSE, parameters = names(params))
  saveRDS(samples, file=INIT_FILE(key))
}

GEN_INIT_2 <- function(model, n = 4, chain_id = NULL, key = NULL) {
    n_kept <- model@sim$n_save - model@sim$warmup2
    iters <- sample.int(n_kept, n, replace=FALSE)
    pars <- grep("__$", model@model_pars, value=TRUE, invert=TRUE)
    samples <- llply(iters,
          function(i) {
              x <- llply(pars,
                         function(parname) {
                             x <- extract(model, parname)[[1]]
                             d <- dim(x)
                             ndim <- length(d)
                             dlist <- list(i)
                             if (ndim > 1) {
                                 for (j in 2:ndim) {
                                     dlist[[j]] <- seq_len(d[j])
                                 }
                             }
                             do.call(`[`, c(list(x), dlist))
                         })
              names(x) <- pars
              x
          })
    if (!is.null(key)) {
        saveRDS(samples, file=INIT_FILE(key))
    } 
}


FINDATA <- list()
FINDATA[["bond_metadata"]] <-
  function() {
    con <- file(get_findata_path("bond_metadata.json"), "r")
    bond_metadata <- fromJSON(con)
    close(con)
    bond_metadata
  }
FINDATA[["greenbacks"]] <-
    function() {
        mutate(read.csv(get_findata_path("greenbacks.csv")),
               date = as.Date(date))
    }
FINDATA[["greenbacks_fill"]] <-
    function() {
        mutate(read.csv(get_findata_path("greenbacks_fill.csv")),
               date = as.Date(date))
    }
FINDATA[["bankers_magazine_govt_state_loans_yields"]] <-
    function() {
        mutate(read.csv(get_findata_path("bankers_magazine_govt_state_loans_yields.csv")),
               date = as.Date(date))
    }
FINDATA[["bankers_magazine_govt_state_loans_yields_2"]] <-
    function() {
        mutate(read.csv(get_findata_path("bankers_magazine_govt_state_loans_yields_2.csv")),
               date = as.Date(date))
    }
FINDATA[["merchants_magazine_us_paper_yields"]] <-
    function() {
        mutate(read.csv(get_findata_path("merchants_magazine_us_paper_yields.csv")),
               date = as.Date(date))
    }
FINDATA[["merchants_magazine_us_paper_yields_2"]] <-
    function() {
        mutate(read.csv(get_findata_path("merchants_magazine_us_paper_yields_2.csv")),
               date = as.Date(date))
    }
FINDATA[["bankers_magazine_govt_bonds_quotes_in_text"]] <- 
    function() {
        mutate(read.csv(get_findata_path("bankers_magazine_govt_bonds_quotes_in_text.csv")),
               date = as.Date(date))
    }
FINDATA[["events_smith_smith"]] <- 
    function() {
        mutate(read.csv(get_findata_path("events_smith_smith.csv")),
               start_date = as.Date(start_date),
               end_date = as.Date(end_date))
    }
FINDATA[["auction_18610213"]] <-
    function() read.csv(get_findata_path("auction_18610213.csv"))
FINDATA[["auction_18610322"]] <-
    function() read.csv(get_findata_path("auction_18610322.csv"))
FINDATA[["auction_18610511"]] <-
    function() read.csv(get_findata_path("auction_18610511.csv"))
FINDATA[["dewey1918_expenditures_1862_1865"]] <-
    function() read.csv(get_findata_path("dewey1918_expenditures_1862_1865.csv"))
FINDATA[["dewey1918_deficit_1862_1865"]] <-
    function() read.csv(get_findata_path("dewey1918_deficit_1862_1865.csv"))


ACW_BATTLES <- function() {
    outcome_factor_3 <- function(x) {
        ordered(x, c("Confederate", "Inconclusive", "Union"))
    }
    outcome_factor_2 <- function(x) {
        ordered(x, c("Confederate", "Union"))
    }

    mutate(read.csv(file.path(DATA_DIR, "acw_battles", "data", "battles.csv")),
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

WAR_NEWS <- list()
WAR_NEWS[["battle_news"]] <- function() {
    mutate(read.csv(DATAFILE("news/data/battle_news.csv")),
           pubdate = as.Date(pubdate))
}
WAR_NEWS[["major_battle_news"]] <- function() {
     mutate(read.csv(DATAFILE("news/data/major_battle_news.csv")),
            start_date = as.Date(start_date),
            end_date = as.Date(end_date))
}
