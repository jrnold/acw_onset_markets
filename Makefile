R = Rscript

FILEHASH_SRC = $(wildcard R/filehashdb_*.R)
FILEHASH_OBJ = $(FILEHASH_SRC:R/filehashdb_%.R=filehashdb/%)

all: R/DEPENDENCIES $(FILEHASH_OBJ)

filehashdb/%: R/filehashdb_%.R
	$(R) -e 'source("$<");main()' $(notdir $(basename $<))

R/DEPENDENCIES: bin/R_dependencies.R $(wildcard R/*.R)
	$(R) $< R > $@

-include R/DEPENDENCIES
