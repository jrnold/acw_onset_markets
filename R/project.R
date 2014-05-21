suppressPackageStartupMessages({
    library("filehash")
    library("plyr")
    library("devtools")
})

Project <-
  setRefClass("Project", fields = list(rootdir = "character"),
              methods = list(
              initialize = function(rootdir = ".") {
                rootdir <<- rootdir
              },
              stan_model_dir = function() {
                file.path(rootdir, "stan")
              })
              )

STAN_MODEL_DIR <- file.path(ROOT_DIR, "stan")
DATA_DIR <- file.path(ROOT_DIR, "data")
FILEHASH_DB <- file.path(ROOT_DIR, "filehashdb")
RDATA <- dbInit(FILEHASH_DB, "RDS")

filehashdb_path <- function(key) {
    file.path(FILEHASH_DB, key)
}

filehashdb_key <- function(filename = commandArgs(FALSE)[1]) {
    gsub("filehashdb_", "", tools::file_path_sans_ext(basename(filename)))
}

CIVIL_WAR_FINDATA <- file.path(ROOT_DIR, "submodules/civil_war_era_findata")
get_findata_path <- function(key) file.path(CIVIL_WAR_FINDATA, "data", key)

DATAFILE <- function(path) {
  file.path(ROOT_DIR, "data", path)
}

STAN_MODEL <- function(key) {
  file.path(STAN_MODEL_DIR, sprintf("%s.stan", key))
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


FINDATA <- within(list(), {
    bond_metadata <-
        function() {
            con <- file(get_findata_path("bond_metadata.json"), "r")
            bond_metadata <- fromJSON(con)
            close(con)
            bond_metadata
        }
    greenbacks <-
        function() {
            mutate(read.csv(get_findata_path("greenbacks.csv")),
                   date = as.Date(date))
        }
    greenbacks_fill <-
        function() {
            mutate(read.csv(get_findata_path("greenbacks_fill.csv")),
                   date = as.Date(date))
        }
    bankers_magazine_govt_state_loans <-
        function() {
            mutate(read.csv(get_findata_path("bankers_magazine_govt_state_loans.csv")),
                   date = as.Date(date))
        }
    bankers_magazine_govt_state_loans_yields <-
        function() {
            mutate(read.csv(get_findata_path("bankers_magazine_govt_state_loans_yields.csv")),
                   date = as.Date(date))
        }
    bankers_magazine_govt_state_loans_yields_2 <-
        function() {
            mutate(read.csv(get_findata_path("bankers_magazine_govt_state_loans_yields_2.csv")),
                   date = as.Date(date))
        }
    merchants_magazine_us_paper <-
        function() {
            mutate(read.csv(get_findata_path("merchants_magazine_us_paper.csv")),
                   date = as.Date(date))
        }
    merchants_magazine_us_paper_yields <-
        function() {
            mutate(read.csv(get_findata_path("merchants_magazine_us_paper_yields.csv")),
                   date = as.Date(date))
        }
    merchants_magazine_us_paper_yields_2 <-
        function() {
            mutate(read.csv(get_findata_path("merchants_magazine_us_paper_yields_2.csv")),
                   date = as.Date(date))
        }
    bankers_magazine_govt_bonds_quotes_in_text <- 
        function() {
            mutate(read.csv(get_findata_path("bankers_magazine_govt_bonds_quotes_in_text.csv")),
                   date = as.Date(date))
        }
    events_smith_smith <- 
        function() {
            mutate(read.csv(get_findata_path("events_smith_smith.csv")),
                   start_date = as.Date(start_date),
                   end_date = as.Date(end_date))
        }
    auction_18610213 <-
        function() read.csv(get_findata_path("auction_18610213.csv"))
    auction_18610322 <-
        function() read.csv(get_findata_path("auction_18610322.csv"))
    auction_18610511 <-
        function() read.csv(get_findata_path("auction_18610511.csv"))
    dewey1918_expenditures_1862_1865 <-
        function() read.csv(get_findata_path("dewey1918_expenditures_1862_1865.csv"))
    dewey1918_deficit_1862_1865 <-
        function() read.csv(get_findata_path("dewey1918_deficit_1862_1865.csv"))
})
                  
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
                  
                  

WAR_NEWS <- within(list(), {
    battle_news <- function() {
        mutate(read.csv(DATAFILE("news/data/battle_news.csv")),
               pubdate = as.Date(pubdate))
    }
    major_battle_news <- function() {
        mutate(read.csv(DATAFILE("news/data/major_battle_news.csv")),
               start_date = as.Date(start_date),
               end_date = as.Date(end_date))
    }
})

# Generated from random.org
RANDOM <-
    c(171232, 682784, 338850, 972279, 466199, 615165, 251671, 472549, 
      382866, 360606, 565704, 359736, 728668, 3494, 152416, 86284, 
      99250, 175844, 376047, 803853, 49440, 110698, 974699, 149111, 
      610677, 984849, 377821, 725568, 826107, 818054, 637696, 496283, 
      654926, 228523, 554869, 909460, 216596, 632569, 297362, 148618, 
      856393, 474905, 122219, 237773, 290663, 88516, 94585, 825080, 
      219261, 457069, 724089, 773091, 695544, 311121, 96542, 169690, 
      957675, 513582, 806737, 45522, 788881, 441525, 748263, 256323, 
      758178, 408589, 614201, 831229, 341090, 757732, 247350, 443040, 
      653490, 583285, 630805, 574087, 730085, 895743, 809472, 114400, 
      254460, 949796, 368255, 512097, 178890, 441026, 540647, 843075, 
      932254, 294845, 433803, 323333, 564263, 44421, 20577, 220209, 
      535682, 238598, 226390, 686098)

## run_stan <- function(file, ...) {
##     model <- stan_model(file)
##     timing <- system.time(ret <- sampling(model, ...))
##     ret_summary <- summary(ret)
##     list(sfit = ret,
##          summary = ret_summary,
##          timing = timing)
## }


source_env <- function(file, chdir = FALSE,
                       keep.source = getOption("keep.source.pkgs"), ...) {
    e <- new.env(...)
    sys.source(file, envir = e, chdir = chdir, keep.source = keep.source)
    e
}

source_list <- function(file, ...) {
    as.list(source_env(file, ...))
}

fill_na <- function(x, fill=0) {
    x[is.na(x)] <- fill
    x
}
