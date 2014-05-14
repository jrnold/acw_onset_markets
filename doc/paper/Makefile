SRC = Bonds_and_Battles.Rnw
BIBFILE = $(HOME)/Dropbox/jabref.bib

RSCRIPT = Rscript
JABREF = jabref
BIBTEX = biber
LATEX = xelatex
LATEX_OPTS = -interaction=nonstopmode -synctex=1  -file-line-error

texfile = $(SRC:%.Rnw=%.tex)
pdffile = $(texfile:%.tex=%.pdf)
pdffile = $(texfile:%.tex=%.pdf)
obj = $(pdffile)

all: $(obj)

$(texfile): $(rnwfile)
	cd ../../; \
	$(RSCRIPT) -e 'library(knitr);knit($(abspath $<),output="$(abspath $@)")'

$(pdffile): $(SRC)
	$(LATEX) -job-name=$(objname) $(LATEX_OPTS) $<
	$(BIBTEX) $(auxfile)
	$(LATEX) -job-name=$(objname) $(LATEX_OPTS) $<
	$(LATEX) -job-name=$(objname) $(LATEX_OPTS) $<


.PHONY: assets
