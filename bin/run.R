#!/usr/bin/env Rscript
file <- commandArgs(TRUE)[1]
envir <- suppressPackageStartupMessages(source_env(file))
key <- basename(tools::file_path_sans_ext(file))
RDATA[[key]] <- eval(envir$main())
