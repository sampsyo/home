.PHONY: setup site

site: index.md media/main.css
	jekyll build

setup:
	npm install
	./node_modules/bower/bin/bower install

media/main.css: bower_components/bootstrap/less/*.less
	./node_modules/less/bin/lessc $(LESSARGS) \
		bower_components/bootstrap/less/bootstrap.less $@
