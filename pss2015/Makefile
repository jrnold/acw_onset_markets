include plotly.inc

export plotly_username
export plotly_api_key

RSCRIPT = Rscript

all: index.html

%.html: %.Rhtml
	$(RSCRIPT) -e 'knitr::knit("$^",output="$@")'
