LESSC := ./node_modules/less/bin/lessc
BOOTSTRAP := node_modules/bootstrap/package.json
KATEX := node_modules/katex/dist
CLEANCSS := ./node_modules/clean-css/bin/cleancss

# Build the site itself using Jekyll.
.PHONY: site
GENERATED := media/main.css media/katex media/highlightjs
site: index.md $(GENERATED)
	jekyll build

# Compile the CSS using LESS. This consists of our main LESS file, which
# includes the LESS for Bootstrap.
_source/main.css: _source/main.less $(BOOTSTRAP) $(LESSC)
	$(LESSC) $< $@

# Then minify it with clean-css.
media/main.css: _source/main.css $(CLEANCSS)
	$(CLEANCSS) --skip-rebase -o $@ $<


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
	--delete -e ssh
DEST := dh:domains/adriansampson.net/home
deploy: cleanbuild site
	rsync $(RSYNCARGS) _site/ $(DEST)


# Install dependencies.

# Dependencies from npm. TODO: This should be replaced with a package.json.
$(LESSC):
	npm install less
	@touch $@
$(CLEANCSS):
	npm install clean-css
	@touch $@
$(KATEX):
	npm install katex
	@touch $@
$(BOOTSTRAP):
	npm install bootstrap@3.3.7
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
media/highlightjs: _source/highlightjs/build
	mkdir -p $@
	cp $</highlight.pack.js $@/highlight.min.js
	cp $</../src/styles/github-gist.css $@

# A phony target for installing all the dependencies.
.PHONY: setup
setup: $(GENERATED)
