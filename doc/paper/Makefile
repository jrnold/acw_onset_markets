SRC = Pricing_the_Costly_Lottery.tex
BIBFILE = $(HOME)/Dropbox/jabref.bib

RSCRIPT = Rscript
JABREF = jabref
BIBTEX = biber
LATEX = xelatex
LATEX_OPTS = -interaction=nonstopmode -synctex=1  -file-line-error

assetfiles = $(wildcard assets/tab-*.pdf)
assetfiles += $(wildcard assets/plot-*.pdf)
assetfiles += assets/macros.tex

version = $(shell cat version.txt | sed -e 's/\./_/g')

auxfile = $(SRC:%.tex=%.bcf)
pdffile = $(SRC:%.tex=%.pdf)
obj = $(pdffile:%.pdf=%_v_$(version).pdf)


all: $(obj)
	@echo $(version) $(objname)

version.tex: version.txt
	sed -e 's/\(.*\)/\\newcommand{\\version}{\1}/g' > $@  < $^

$(pdffile): $(SRC) assets $(assetfiles) version.tex
	$(LATEX) -job-name=$(objname) $(LATEX_OPTS) $<
	$(BIBTEX) $(auxfile)
	$(LATEX) -job-name=$(objname) $(LATEX_OPTS) $<
	$(LATEX) -job-name=$(objname) $(LATEX_OPTS) $<

$(obj): $(pdffile)
	cp $< $@

assets:
	make -C assets

clean: 
	-rm $(obj) *.aux *.bbl *-blx.bib *.log *.out *.run.xml *.blg *.bcf

.PHONY: assets
