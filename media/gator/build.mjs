import { build } from "esbuild";
import { polyfillNode } from "esbuild-plugin-polyfill-node";

await build({
	entryPoints: ["main.ts"],
	bundle: true,
	outfile: "main.js",
    minify: true,
	plugins: [
		polyfillNode({}),
	],
    loader: {".glsl": "text"},
});
