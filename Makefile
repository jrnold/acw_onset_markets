FILEHASH_SRC = $(wildcard R/filehashdb_*.R)
FILEHASH_OBJ = $(FILEHASH_SRC:R/filehashdb_%.R=filehashdb/%)
R_SRC = $(wildcard R/*.R)

TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

all: $(robjects)
	@echo $(robjects)

touchdb:
	for i in filehashdb/*; do \
	touch $${i}; done 

depends: rdepends.inc

### Data
rdepends.inc:
	bin/make_R_dependencies $@

# Only use lower-case names for files
filehashdb/%: R/db_%.R
	runR $<

-include rdepends.inc

.PHONY: all

