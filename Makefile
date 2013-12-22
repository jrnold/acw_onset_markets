R = Rscript

FILEHASH_SRC = $(wildcard R/filehashdb_*.R)
FILEHASH_OBJ = $(FILEHASH_SRC:R/filehashdb_%.R=filehashdb/%)
R_SRC = $(wildcard R/*.R)
R_DEPENDS = $(R_SRC:.R=.q)

all: $(FILEHASH_OBJ)
	@echo $(R_DEPENDS)

depends: $(R_DEPENDS)

filehashdb/%: R/filehashdb_%.R
	$(R) -e 'source("$<");main()' $(patsubst filehashdb_%,%,$(notdir $(basename $<)))

R/%.q: R/%.R
	$(R) bin/R_dependencies.R $< > $@

-include $(R_DEPENDS)
