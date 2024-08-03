import { setup } from './render';

setup("diffuse", require("./diffuse.glsl"));
setup("diffuse-correct", require("./diffuse-correct.glsl"));
setup("diffuse-bug", require("./diffuse-bug.glsl"));
setup("diffuse-naive", require("./diffuse-naive.glsl"));
setup("diffuse-in", require("./in.glsl"));
setup("diffuse-alltrans", require("./diffuse-alltrans.glsl"));
