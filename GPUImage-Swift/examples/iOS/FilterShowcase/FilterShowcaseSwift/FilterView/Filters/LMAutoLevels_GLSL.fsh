precision highp float;

varying vec2 textureCoordinate;

uniform sampler2D inputImageTexture;

void main(){
    vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
    textureColor.r = 0.5;
    textureColor.g = 0.8;
    gl_FragColor = vec4(pow(textureColor.rgb, vec3(gamma)), textureColor.w);
}
