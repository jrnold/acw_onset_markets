export PATH := .:./bin:$(PATH)

RSCRIPT = Rscript

FILEHASHDB_DIR = filehashdb

ANALYSIS_DIR = doc/analysis
analysis_src = $(wildcard $(ANALYSIS_DIR)/*.Rmd)
analysis_html = $(analysis_src:%.Rmd=%.html)

TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

-include filehashdb.inc

all: $(robjects) $(analysis_html)
	@echo $(robjects)

db: $(robjects)

touchdb:
	for i in $(FILEHASHDB_DIR)/*; do \
	touch $${i}; done 

depends: filehashdb.inc

### Data
filehashdb.inc:
	bin/make_R_dependencies $@

# Only use lower-case names for files
filehashdb/%: R/db_%.R
	save_to_filehash $<  $(FILEHASHDB_DIR)

doc/analysis/%.html: doc/analysis/%.Rmd
	$(RSCRIPT) -e 'library(knitr);knit("$<",output="$@")'

.PHONY: all

.DEFAULT_GOAL := all
