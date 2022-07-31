KATEX_VERSION := 0.16.0

THEME_CSS := _source/tomorrow_night_bright.css _source/tomorrow_night_blue.css
GENERATED := media/katex $(THEME_CSS)

# Build the site itself using Jekyll.
.PHONY: site
site: index.md $(GENERATED)
	jekyll build


# Cleaning.

.PHONY: clean cleanall
PRODUCTS := _site media/highlightjs media/katex \
	media/main.css _source/main.css
clean:
	rm -rf $(PRODUCTS)
cleanall:
	rm -rf $(PRODUCTS) _source/highlightjs node_modules
cleanbuild:
	rm -rf _site


# Deployment.

RSYNCARGS := --compress --recursive --checksum --itemize-changes \
	--delete -e ssh --timeout=30
DEST := cslinux:/people/als485/home
deploy: cleanbuild site
	rsync $(RSYNCARGS) _site/ $(DEST)


# Install dependencies.

# Dependencies from npm. TODO: This should be replaced with a package.json.
_source/katex:
	mkdir -p _source
	curl -L https://github.com/KaTeX/KaTeX/releases/download/v$(KATEX_VERSION)/katex.tar.gz -o _source/katex.tar.gz
	cd _source ; tar xf katex.tar.gz

# Publish client-side assets.
media/katex: _source/katex
	cp -r $< $@

# Rouge/Pygments themes.
$(THEME_CSS): _source/%.css:
	curl -L -o $@ https://raw.githubusercontent.com/mozmorris/tomorrow-pygments/c6ca1a308e7e93cb18a54f93bf964f56e4d07acf/css/$*.css

# A phony target for installing all the dependencies.
.PHONY: setup
setup: $(GENERATED)
