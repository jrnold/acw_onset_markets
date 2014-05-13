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

R/%.q: R/%.R
	bin/R_dependencies.R $< > $@

.phony: all depends

-include $(R_DEPENDS)
