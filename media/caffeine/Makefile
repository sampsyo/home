PLOTS := freqline tod where

# This is where I store my plain-text coffee log.
DATA_SOURCE := ~/Dropbox/Notes/coffeelog.txt

.PHONY: all
all: $(PLOTS:%=%.pdf)

coffees.json: tojson.py $(DATA_SOURCE)
	python3 $^ > $@

# Execute a Vega spec to produce an SVG image.
%.svg: %.vg.json coffees.json
	vg2svg $< > $@

# Render a PDF from an SVG, the obvious (and bad-looking) way.
# %.pdf: %.svg
# 	svg2pdf < $< > $@

# Render a PDF from an SVG using WebKit. This looks great!
# wkpdf: http://plessl.github.io/wkpdf/
# The --no-paginate option produces a PDF with exactly the right bounding box.
%.pdf: %.svg
	wkpdf --no-paginate --source $< --output $@
