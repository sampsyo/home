.PHONY: setup site deploy clean_site

BUILDARGS :=
site: index.md media/main.css
	jekyll build $(BUILDARGS)

setup:
	npm install
	./node_modules/bower/bin/bower install

media/main.css: _source/main.less bower_components/bootstrap/less/*.less
	./node_modules/less/bin/lessc $(LESSARGS) $< $@

clean:
	rm -rf _site

CSEHOST := bicycle.cs.washington.edu
deploy: BUILDARGS=--config _config.yml,_config_deploy.yml
deploy: clean site
	rsync -avz -e ssh --delete _site/ $(CSEHOST):public_html/newsite
