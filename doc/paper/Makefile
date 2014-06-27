SRC = Bonds_and_Battles.Rnw
BIBFILE = $(HOME)/Dropbox/jabref.bib

RSCRIPT = Rscript
JABREF = jabref
BIBTEX = biber
LATEX = xelatex
LATEXMK = latexmk

LATEX_OPTS = -interaction=nonstopmode -synctex=1  -file-line-error

texfile = $(SRC:%.Rnw=%.tex)
pdffile = $(texfile:%.tex=%.pdf)
auxfile = $(texfile:%.tex=%.bcf)
obj = $(pdffile)

all: $(obj)

$(texfile): $(SRC)
	$(RSCRIPT) -e 'library(knitr);knit("$<",output="$@")'

$(pdffile): $(texfile)
	$(LATEXMK) -pdf -pdflatex="xelatex -interactive=nonstopmode" -use-make $<

# $(pdffile): $(texfile)
# 	$(LATEX) $(LATEX_OPTS) $<
# 	$(BIBTEX) $(auxfile)
# 	$(LATEX) $(LATEX_OPTS) $<
# 	$(LATEX) $(LATEX_OPTS) $<

clean:
	-rm -f $(obj) *.aux *.bbl *-blx.bib *.log *.out *.run.xml *.blg *.bcf *.fls *.fdb_latexmk 

clean-all: clean
	-rm -rf $(pdffile) $(texfile) cache/*

.PRECIOUS: %.tex
