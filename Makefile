.PHONY: setup site deploy clean_site

BUILDARGS :=
site: index.md media/main.css
	jekyll build $(BUILDARGS)

BOWER_STUFF := bower_components/bootstrap/bower.json
media/main.css: _source/main.less $(BOWER_STUFF)
	./node_modules/less/bin/lessc $(LESSARGS) $< $@

# Somewhat dumb way to invoke setup on first run (but not thereafter) or on
# manual invocation.
$(BOWER_STUFF):
	npm install
	./node_modules/bower/bin/bower install
setup: $(BOWER_STUFF)

clean:
	rm -rf _site

cleanall:
	rm -rf _site node_modules bower_components

CSEHOST := bicycle.cs.washington.edu
deploy: BUILDARGS=--config _config.yml,_config_deploy.yml
deploy: clean site
	rsync --compress --recursive --checksum --itemize-changes --delete -e ssh _site/ $(CSEHOST):public_html/home

cv.pdf:
	wkpdf --source file://$(shell pwd)/_site/cv/index.html --output cv.pdf --caching false --stylesheet-media print --margins 52 36 88 18 --paper letter
