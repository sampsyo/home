precision mediump float;

varying vec3 vPosition;
uniform mat4 uModel;
uniform mat4 uView;
varying vec3 vNormal;

uniform vec3 uLightPos;
uniform vec3 uDiffColor;

void main() {
    // Get the world-space direction from the fragment position to the light.
    vec4 posWorldHom = uModel * vec4(vPosition, 1.0);
    vec3 posWorldCart = vec3(posWorldHom / posWorldHom.w);
    vec3 lightDir = normalize(uLightPos - posWorldCart);

    // Compute the dot product between the surface normal and light direction.
    vec3 normWorld = normalize(vec3(uModel * vec4(vNormal, 0.0)));
    float lambertian = max(dot(lightDir, normWorld), 0.0);

    // Produce a color with a 100% alpha channel.
    gl_FragColor = vec4(lambertian * uDiffColor, 1.0);
}
