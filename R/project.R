suppressPackageStartupMessages({
    library("filehash")
    library("plyr")
    library("devtools")
})

Project <-
  setRefClass("Project", fields = list(rootdir = "character", db = "filehashRDS"),
              methods = list(
                  initialize = function(rootdir = ".") {
                      rootdir <<- rootdir
                      db <<- dbInit(file.path(rootdir, "filehashdb"), "RDS")
                  },
                  dbpath = function(key) {
                      file.path(db@dir, key)
                  },
                  path = function(...) file.path(rootdir, ...),
                  stan_model_dir = function() path("stan"),
                  data_dir = function() path("data"),
                  civil_war_findata = function() {
                      file.path(rootdir, "submodules/civil_war_era_findata")
                  },
                  getfindata_path = function(key) {
                      file.path(civil_war_findata(), "data", key)
                  },
                  datafile = function(...) {
                      file.path(rootdir, "data", ...)
                  },
                  init_file = function(key) {
                      datafile(sprintf("init/%s.rds", key))
                  },
                  read_init = function(key) {
                      filename <- init_file(key)
                      if (file.exists(filename)) {
                          readRDS(filename)
                      } else {
                          NULL
                      }
                  },
                  save_init = function(key, model, n = 4) {
                      samples <- generate_init(model, n)
                      saveRDS(samples, file=init_file(key))
                  }
                  )
              )

generate_init <- function(model, n = 4) {
    n_kept <- model@sim$n_save  - model@sim$warmup2
    iters <- sample.int(n_kept, n, replace = FALSE)
    pars <- grep("__$", model@model_pars, value=TRUE, invert=TRUE)
    samples <- plyr::llply(iters,
                           function(i) {
                               x <- plyr::llply(pars,
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
}

make_filehashdb_key <- function(filename = commandArgs(FALSE)[1]) {
    gsub("filehashdb_", "", tools::file_path_sans_ext(basename(filename)))
}

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

unif_var <- function(x) {
    (1 / 12) * diff(range(x))^2
}
