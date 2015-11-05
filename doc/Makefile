R = Rscript
LATEXMK = latexmk

SRC = analysis.Rmd
OUTPUT = $(SRC:%.Rmd=%.html)

PAPER_SRC = Financial_Markets_and_Onset_of_the_American_Civil_War.Rnw
PAPER_TEX = $(PAPER_SRC:%.Rnw=%.tex)
PAPER_OUT = $(PAPER_SRC:%.Rnw=%.pdf)

all: $(OUTPUT) $(PAPER_OUT)

$(OUTPUT): $(SRC)
	$(R) -e 'library(knitr);knit("$<",output="$@")'

$(PAPER_TEX): $(PAPER_SRC) $(OUTPUT)
	$(R) -e 'library(knitr);knit("$<",output="$@")'

$(PAPER_OUT): $(PAPER_TEX) 
	$(LATEXMK) -pdf -pdflatex='xelatex -interaction=nonstopmode -file-line-error -synctex=1 -shell-escape %O %S' $(PAPER_TEX)

.PRECIOUS: $(PAPER_TEX)

clean:
	-rm -rf $(OUTPUT) $(SRC:%.Rmd=%.RData) *_cache cache figures/* tex/* $(PAPER_SRC) $(PAPER_TEX)

