KATEX := node_modules/katex/dist

# Build the site itself using Jekyll.
.PHONY: site
GENERATED := media/katex media/highlight.min.js
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
$(KATEX):
	npm install katex
	@touch $@

# Publish client-side assets.
media/katex: $(KATEX)
	cp -r $< $@

# Clone and build Highlight.js to get custom languages.
_source/highlightjs:
	git clone https://github.com/isagalaev/highlight.js.git $@
	cd $@ ; git checkout 8.8.0
_source/highlightjs/build: _source/highlightjs
	cd $< ; npm install
	cd $< ; node tools/build.js python c cpp bash typescript
media/highlight.min.js: _source/highlightjs/build
	cp $</highlight.pack.js $@

# A phony target for installing all the dependencies.
.PHONY: setup
setup: $(GENERATED)
