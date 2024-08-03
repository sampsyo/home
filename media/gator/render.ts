import * as lgl from './lglexample';
import { mat4, vec3 } from 'gl-matrix';

export function setup(canvasId: string, fragShader: string) {
  let element = document.getElementById(canvasId);
  if (!element) {
    return;
  }
  let gl = lgl.setup(element, render);

  // Compile our shaders.
  let program = lgl.compileProgram(gl,
    require('./vertex.glsl'),
    fragShader,
  );

  // Uniform and attribute locations.
  let loc_uProjection = lgl.uniformLoc(gl, program, 'uProjection');
  let loc_uView = lgl.uniformLoc(gl, program, 'uView');
  let loc_uModel = lgl.uniformLoc(gl, program, 'uModel');
  let loc_aPosition = lgl.attribLoc(gl, program, 'aPosition');
  let loc_aNormal = lgl.attribLoc(gl, program, 'aNormal');
  let loc_uLightPos = lgl.uniformLoc(gl, program, 'uLightPos');
  let loc_uDiffColor = lgl.uniformLoc(gl, program, 'uDiffColor');

  let mesh = lgl.getBunny(gl);

  // Initialize the model position.
  let modelInit = mat4.create();
  mat4.translate(modelInit, modelInit, vec3.fromValues(0.0, -5.0, 0.0));
  let model = mat4.create();

  // Position the light source for the lighting effect.
  let light = vec3.fromValues(20., 0., 20.);
  let diffColor = vec3.fromValues(0.32, 0.63, 0.07);

  function render(view: mat4, projection: mat4) {
    // Time-varying model rotation.
    mat4.rotateY(model, modelInit, Date.now() * 0.0005);

    // Use our shader pair.
    gl.useProgram(program);

    // Set the shader "uniform" parameters.
    gl.uniformMatrix4fv(loc_uProjection, false, projection);
    gl.uniformMatrix4fv(loc_uView, false, view);
    gl.uniformMatrix4fv(loc_uModel, false, model);
    gl.uniform3fv(loc_uLightPos, light);
    gl.uniform3fv(loc_uDiffColor, diffColor);

    // Set the attribute arrays.
    lgl.bind_attrib_buffer(gl, loc_aNormal, mesh.normals, 3);
    lgl.bind_attrib_buffer(gl, loc_aPosition, mesh.positions, 3);

    gl.disable(gl.CULL_FACE);

    // Draw the object.
    lgl.drawMesh(gl, mesh);
  }
}
