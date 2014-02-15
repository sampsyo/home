.PHONY: setup site

site: index.md media/main.css
	jekyll build

setup:
	npm install
	./node_modules/bower/bin/bower install

media/main.css: _source/main.less bower_components/bootstrap/less/*.less
	./node_modules/less/bin/lessc $(LESSARGS) $< $@
