.PHONY: setup

setup:
	npm install
	./node_modules/bower/bin/bower install

bootstrap.css: bower_components/bootstrap/less/*.less
	./node_modules/less/bin/lessc $(LESSARGS) \
		bower_components/bootstrap/less/bootstrap.less $@
