SRC = Financial_Markets_and_Onset_of_the_American_Civil_War.Rnw
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
	$(LATEXMK) -pdf -pdflatex="xelatex -interaction=nonstopmode" -use-make $<

clean:
	-rm -f $(obj) *.aux *.bbl *-blx.bib *.log *.out *.run.xml *.blg *.bcf *.fls *.fdb_latexmk 

clean-all: clean
	-rm -rf $(pdffile) $(texfile) cache/*

.PRECIOUS: %.tex
