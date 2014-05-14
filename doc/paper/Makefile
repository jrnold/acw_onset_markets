SRC = Pricing_the_Costly_Lottery.tex
BIBFILE = $(HOME)/Dropbox/jabref.bib

RSCRIPT = Rscript
JABREF = jabref
BIBTEX = biber
LATEX = xelatex
LATEX_OPTS = -interaction=nonstopmode -synctex=1  -file-line-error

texfile = $(SRC:%.Rnw=%.tex)
auxfile = $(texfile:%.tex=%.bcf)
pdffile = $(texfile:%.tex=%.pdf)

all: $(pdffile)

%.tex: %.Rnw
	$(RSCRIPT) -e 'library(knitr);knit("$<",output="$@")'

$(pdffile): $(texfile)
	$(LATEX) $(LATEX_OPTS) $<
	$(BIBTEX) $(auxfile)
	$(LATEX) $(LATEX_OPTS) $<
	$(LATEX) $(LATEX_OPTS) $<

clean:
	-rm $(obj) *.aux *.bbl *-blx.bib *.log *.out *.run.xml *.blg *.bcf

clean-all: clean
	-rm $(pdffile) $(texfile)

.PRECIOUS: %.tex
