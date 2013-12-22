#!/usr/bin/env Rscript
file <- commandArgs(TRUE)[1]
e <- new.env()
sys.source(file, env=e)
for (depends in e$.DEPENDENCIES) {
    cat(sprintf("%s: %s\n", file, depends))
}
