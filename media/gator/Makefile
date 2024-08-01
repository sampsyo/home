SHADERS := vertex.glsl diffuse.glsl diffuse-bug.glsl
TS := main.ts lglexample.ts

main.js: $(TS) $(SHADERS)
	node build.mjs

%.glsl: %.lgl
	gatorc $^ > $@
