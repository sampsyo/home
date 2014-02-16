.PHONY: all
all: stackandcluster.pdf

# Execute a Vega spec to produce an SVG image.
%.svg: %.vg.json
	vg2svg $< > $@

# Render a PDF from an SVG, the obvious (and bad-looking) way.
# %.pdf: %.svg
# 	svg2pdf < $< > $@

# Render a PDF from an SVG using WebKit. This looks great!
# wkpdf: http://plessl.github.io/wkpdf/
# The --no-paginate option produces a PDF with exactly the right bounding box.
%.pdf: %.svg
	wkpdf --no-paginate --source $< --output $@
