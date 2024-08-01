precision mediump float;

varying vec3 vPosition;
uniform mat4 uModel;
uniform mat4 uView;
varying vec3 vNormal;

uniform vec3 uLightPos;
uniform vec3 uDiffColor;

void main() {
    // Get the direction from the fragment position to the light.
    vec3 lightDir = normalize(uLightPos - vPosition);

    // Compute the dot product between the surface normal and light direction.
    float lambertian = max(dot(lightDir, vNormal), 0.0);

    // Produce a color with a 100% alpha channel.
    gl_FragColor = vec4(lambertian * uDiffColor, 1.0);
}
