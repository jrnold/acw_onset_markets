export PATH := .:./bin:$(PATH)

RSCRIPT = Rscript

FILEHASHDB_DIR = filehashdb

ANALYSIS_DIR = doc/analysis
analysis_src = $(wildcard $(ANALYSIS_DIR)/*.Rmd)
analysis_html = $(analysis_src:%.Rmd=%.html)

TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

-include filehashdb.inc

all: db analysis

db: $(robjects)

analysis: $(analysis_html)

touchdb:
	for i in $(FILEHASHDB_DIR)/*; do \
	touch $${i}; done 

### Data
depends:
	bin/make_R_dependencies filehashdb.inc

# Only use lower-case names for files
filehashdb/%: R/db_%.R
	save_to_filehash $<  $(FILEHASHDB_DIR)

doc/analysis/%.html: doc/analysis/%.Rmd
	$(RSCRIPT) -e 'library(knitr);opts_knit$$set(upload.fun=image_uri);knit2html("$<",output="$@")'

.PHONY: all depends

.DEFAULT_GOAL := all
