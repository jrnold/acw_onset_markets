R = Rscript
PLOT_SRC = $(wildcard plot-*.R)
PLOT_OUT = $(PLOT_SRC:%.R=%.pdf)
TAB_SRC = $(wildcard tab-*.R)
TAB_OUT = $(TAB_SRC:%.R=%.tex)

all: plots tables macros

plots: $(PLOT_OUT)

tables: $(TAB_OUT)

macros: macros.tex

plot-%.pdf: plot-%.R
	$(R) $< $@

tab-%.tex: tab-%.R
	$(R) $< $@

# All stuff depends on conf.R
$(TAB_OUT) $(PLOT_OUT) macros.tex: conf.R

macros.tex: macros.R
	$(R) $< $@

.PHONY: all plots macros
