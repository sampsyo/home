SHADERS := vertex.glsl diffuse.glsl diffuse-bug.glsl diffuse-correct.glsl \
		   diffuse-naive.glsl in.glsl diffuse-alltrans.glsl
TS := main.ts lglexample.ts

main.js: $(TS) $(SHADERS)
	node build.mjs

%.glsl: %.lgl
	gatorc $^ > $@
