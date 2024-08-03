SHADERS := vertex.glsl diffuse.glsl diffuse-bug.glsl diffuse-correct.glsl \
		   diffuse-naive.glsl in.glsl diffuse-alltrans.glsl
TS := render.ts lglexample.ts

.PHONY: all
all: main.js demo.js

%.js: %.ts $(TS) $(SHADERS)
	./node_modules/.bin/esbuild $< --bundle --outfile=$@ --minify \
			--loader:.glsl=text

%.glsl: %.lgl
	gatorc $^ > $@
