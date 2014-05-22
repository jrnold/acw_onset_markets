FILEHASH_SRC = $(wildcard R/filehashdb_*.R)
FILEHASH_OBJ = $(FILEHASH_SRC:R/filehashdb_%.R=filehashdb/%)
R_SRC = $(wildcard R/*.R)
R_DEPENDS = $(R_SRC:.R=.q)

TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

all: paper

### Data
depends: $(R_DEPENDS)

# Only use lower-case names for files
filehashdb/%: R/db_%.R
	$(R) -e 'source("$<");main()' $(patsubst db_%,%,$(notdir $(basename $<)))

R/%.q: R/%.R
	bin/R_dependencies.R $< > $@

.phony: all depends

-include $(R_DEPENDS)
