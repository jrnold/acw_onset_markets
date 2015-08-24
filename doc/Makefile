R = Rscript
SRC = analysis.Rmd
OUTPUT = $(SRC:%.Rmd=%.html)

all: $(OUTPUT)

$(OUTPUT): $(SRC)
	$(R) -e 'library(knitr);knit("$<",output="$@")'

clean:
	-rm -rf $(OUTPUT) $(SRC:%.Rmd=%.RData) *_cache cache figures/* tex/* 

