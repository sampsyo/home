BOWER := node_modules/bower/bin/bower
BOWER_ARGS := --config.interactive=false
LESSC := ./node_modules/less/bin/lessc
BOOTSTRAP := bower_components/bootstrap/bower.json
KATEX := bower_components/katex/dist
HIGHLIGHT_JS := bower_components/highlightjs/highlight.pack.min.js
SOURCE_SANS_PRO := bower_components/source-sans-pro
CLEANCSS := ./node_modules/clean-css/bin/cleancss

# Build the site itself using Jekyll.
.PHONY: site
GENERATED := media/main.css media/katex media/highlightjs \
	media/font/source-sans-pro
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
PRODUCTS := _site media/font media/highlightjs media/katex \
	media/main.css _source/main.css
clean:
	rm -rf $(PRODUCTS)
cleanall:
	rm -rf $(PRODUCTS) _source/highlightjs node_modules bower_components


# Deployment.

RSYNCARGS := --compress --recursive --checksum --itemize-changes \
	--delete -e ssh
DEST := dh:domains/adriansampson.net/home
deploy: clean site
	rsync $(RSYNCARGS) _site/ $(DEST)


# Install dependencies.

# Bootstrap.
$(BOOTSTRAP): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) bootstrap\#~3.2.0
	@touch $@

# KaTeX.
$(KATEX): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) katex\#~0.5.1
	@touch $@
media/katex: $(KATEX)
	cp -r $< $@

# Source Sans Pro.
$(SOURCE_SANS_PRO): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) \
		git://github.com/adobe-fonts/source-sans-pro.git\#release
	@touch $@
media/font/source-sans-pro: $(SOURCE_SANS_PRO)
	mkdir -p media/font
	cp -r $< $@

# Install Bower, LESS, and clean-css using Node.
$(BOWER):
	npm install bower
	@touch $@
$(LESSC):
	npm install less
	@touch $@
$(CLEANCSS):
	npm install clean-css
	@touch $@

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
