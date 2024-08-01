main.js: main.ts vertex.glsl fragment.glsl
	node build.mjs

%.glsl: %.lgl
	gatorc $^ > $@
