# Build the site itself using Jekyll.
.PHONY: site
site: index.md media/main.css
	jekyll build

# Compile the CSS using LESS. This consists of our main LESS file, which
# includes the LESS for Bootstrap.
LESSC := ./node_modules/less/bin/lessc
BOOTSTRAP := bower_components/bootstrap/bower.json
media/main.css: _source/main.less $(BOOTSTRAP) $(LESSC)
	$(LESSC) $< $@

# Install Bootstrap using Bower.
BOWER := node_modules/bower/bin/bower
BOWER_ARGS := --config.interactive=false
$(BOOTSTRAP): $(BOWER)
	$(BOWER) install $(BOWER_ARGS) bootstrap\#~3.2.0
	@touch $@

# Install Bower and LESS using Node.
$(BOWER):
	npm install bower
	@touch $@
$(LESSC):
	npm install less
	@touch $@

# A phony target for installing all the dependencies.
.PHONY: setup
setup: $(BOOTSTRAP) $(LESSC)

# Cleaning.
.PHONY: clean cleanall
clean:
	rm -rf _site
cleanall:
	rm -rf _site node_modules bower_components

# Deployment.
RSYNCARGS := --compress --recursive --checksum --itemize-changes \
	--delete -e ssh
DEST := dh:domains/adriansampson.net/home
deploy: clean site
	rsync $(RSYNCARGS) _site/ $(DEST)
