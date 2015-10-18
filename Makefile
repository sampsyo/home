BOWER := node_modules/bower/bin/bower
BOWER_ARGS := --config.interactive=false
LESSC := ./node_modules/less/bin/lessc
BOOTSTRAP := bower_components/bootstrap/bower.json
KATEX := bower_components/katex/dist
HIGHLIGHT_JS := bower_components/highlightjs/highlight.pack.min.js
SOURCE_SANS_PRO := bower_components/source-sans-pro
SOURCE_CODE_PRO := bower_components/source-code-pro
CLEANCSS := ./node_modules/clean-css/bin/cleancss

# Build the site itself using Jekyll.
.PHONY: site
GENERATED := media/main.css media/katex media/highlightjs \
	media/font/source-sans-pro media/font/merriweather \
	media/font/source-code-pro
site: index.md $(GENERATED)
	jekyll build

# Compile the CSS using LESS. This consists of our main LESS file, which
# includes the LESS for Bootstrap.
_source/main.css: _source/main.less $(BOOTSTRAP) $(LESSC) _source/fonts.less
	$(LESSC) $< $@

# Then minify it with clean-css.
media/main.css: _source/main.css $(CLEANCSS)
	$(CLEANCSS) --skip-rebase -o $@ $<


# Cleaning.

.PHONY: clean cleanall
PRODUCTS := _site media/font media/highlightjs media/katex media/main.css
clean:
	rm -rf $(PRODUCTS)
cleanall:
	rm -rf $(PRODUCTS) node_modules bower_components


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

# Highlight.js.
$(HIGHLIGHT_JS): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) highlightjs\#~8.8.0
	@touch $@
media/highlightjs: $(HIGHLIGHT_JS)
	mkdir -p $@
	cp $(HIGHLIGHT_JS) $@/highlight.min.js
	cp bower_components/highlightjs/styles/github-gist.css $@

# Source Sans Pro.
$(SOURCE_SANS_PRO): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) \
		git://github.com/adobe-fonts/source-sans-pro.git\#release
	@touch $@
media/font/source-sans-pro: $(SOURCE_SANS_PRO)
	mkdir -p media/font
	cp -r $< $@

# Merriweather.
# TODO Replace with Source Serif Pro when it has italics.
TYPOPRO := bower_components/typopro-web
$(TYPOPRO): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) typopro
	@touch $@
media/font/merriweather: $(TYPOPRO)
	mkdir -p media/font
	cp -r $(TYPOPRO)/web/TypoPRO-Merriweather $@

# Source Code Pro.
$(SOURCE_CODE_PRO): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) \
		git://github.com/adobe-fonts/source-code-pro.git\#release
	@touch $@
media/font/source-code-pro: $(SOURCE_CODE_PRO)
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

# A phony target for installing all the dependencies.
.PHONY: setup
setup: $(GENERATED)
