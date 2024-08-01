precision mediump float;

varying vec3 vPosition;
uniform mat4 uModel;
uniform mat4 uView;
varying vec3 vNormal;

uniform vec3 uLightPos;
uniform vec3 uDiffColor;

void main() {
    vec4 vPosWorldHom = uModel * vec4(vPosition, 1.0);
    vec3 vPosWorldCart = vec3(vPosWorldHom / vPosWorldHom.w);
    vec3 lightDir = normalize(uLightPos - vPosWorldCart);
    float diffuse = max(dot(lightDir, normalize(vec3(uModel * vec4(vNormal, 0.0)))), 0.0);
    gl_FragColor = vec4(diffuse * uDiffColor, 1.0);
}
