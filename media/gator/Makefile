SHADERS := vertex.glsl diffuse.glsl diffuse-bug.glsl diffuse-correct.glsl \
		   diffuse-naive.glsl in.glsl diffuse-alltrans.glsl
TS := main.ts lglexample.ts

main.js: $(TS) $(SHADERS)
	./node_modules/.bin/esbuild main.ts --bundle --outfile=main.js \
		--minify --loader:.glsl=text

%.glsl: %.lgl
	gatorc $^ > $@
