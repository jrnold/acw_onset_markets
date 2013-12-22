#!/usr/bin/env Rscript
DIR <- commandArgs(TRUE)[1]

for (file in dir(DIR, pattern="\\.R$", full.names=TRUE)) {
    e <- new.env()
    sys.source(file, env=e)
    for (depends in e$.DEPENDENCIES) {
        cat(sprintf("%s: %s\n", file, depends))
    }
}
