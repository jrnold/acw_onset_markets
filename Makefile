BIBFILE = $(HOME)/Dropbox/jabref.bib
R = Rscript
BIBTEX = biber
BIBEXT = .bcf
LATEX = xelatex
LATEX_OPTS = -interaction=nonstopmode -synctex=1  -file-line-error

FILEHASH_SRC = $(wildcard R/filehashdb_*.R)
FILEHASH_OBJ = $(FILEHASH_SRC:R/filehashdb_%.R=filehashdb/%)
R_SRC = $(wildcard R/*.R)
R_DEPENDS = $(R_SRC:.R=.q)

TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

all: $(FILEHASH_OBJ)

### Data
depends: $(R_DEPENDS)

filehashdb/%: R/filehashdb_%.R
	$(R) -e 'source("$<");main()' $(patsubst filehashdb_%,%,$(notdir $(basename $<)))

# R/%.q: R/%.R
# 	$(R) bin/R_dependencies.R $< > $@

### Paper
PAPER_DIR = doc/paper
PAPER_SRC = $(PAPER_DIR)/Pricing_the_Costly_Lottery.tex
PAPER_PDF1 = ${PAPER_SRC:.tex=.pdf}

PAPER_ASSETS = $(wildcard assets/tab-*.pdf)
PAPER_ASSETS += $(wildcard assets/plot-*.pdf)
PAPER_ASSETS += assets/macros.tex

PAPER_VERSION = $(shell cat doc/paper/version.txt | sed -e 's/\./_/g')
PAPER_PDF2 = ${PAPER_PDF1:.tex=.pdf}

$(PAPER_PDF1): $(PAPER_SRC)
	cd $(PAPER_DIR); \
	$(LATEX) $(LATEX_OPTS) $(notdir $<); \
	$(BIBTEX) $(subst .tex,.bcf,$(notdir $<)); \
	$(LATEX) $(LATEX_OPTS) $(notdir $<); \
	$(LATEX) $(LATEX_OPTS) $(notdir $<)

paper: $(PAPER_PDF1)

.PHONY: all plots macros

-include $(R_DEPENDS)
