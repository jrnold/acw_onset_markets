R = Rscript

FILEHASH_SRC = $(wildcard R/filehashdb_*.R)
FILEHASH_OBJ = $(FILEHASH_SRC:R/filehashdb_%.R=filehashdb/%)
R_SRC = $(wildcard R/*.R)
R_DEPENDS = $(R_SRC:.R=.q)

TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

all: $(FILEHASH_OBJ)
	@echo $(R_DEPENDS)

### data 
depends: $(R_DEPENDS)

filehashdb/%: R/filehashdb_%.R
	$(R) -e 'source("$<");main()' $(patsubst filehashdb_%,%,$(notdir $(basename $<)))

R/%.q: R/%.R
	$(R) bin/R_dependencies.R $< > $@


### Plots
PLOT_SRC = $(wildcard plot-*.R)
PLOT_OUT = $(PLOT_SRC:%.R=%.pdf)

plots: $(PLOT_OUT)

tables: $(TAB_OUT)

macros: macros.tex

figures/%.pdf: plot/%.R
	$(R) $< $@

tex/%.tex: tex/%.R
	$(R) $< $@


.PHONY: all plots macros

-include $(R_DEPENDS)
