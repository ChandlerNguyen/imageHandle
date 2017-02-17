varying vec3 lightdir;
varying vec3 eyedir;
varying vec4 ambient, diffuse, specular;
uniform sampler2D baseTex;
uniform sampler2D normTex;
void main()
{
    vec3 L = normalize(lightdir);
    vec3 E = normalize(eyedir);
    vec4 _baseColor = texture2D(baseTex, gl_TexCoord[0].xy);
    vec3 _normColor = texture2D(normTex, gl_TexCoord[1].xy).xyz;
    
    _baseColor = texture2D(baseTex, gl_TexCoord[0].xy + _normColor * 0.35); //调制底面纹理波动;
    _normColor = texture2D(normTex, gl_TexCoord[1].xy + _normColor * 0.02).xyz;
    vec3 N = normalize(_normColor * 2.0 - vec3(1.0));     //将法线转到[-1,1]范围;
    float _diff = max(dot(L,N),0.0);
    float _spec = max(dot(E,N),0.0);
    if(_diff > 0.0)
    {
        _spec = pow(_spec, 64.0);
    }
    gl_FragColor = vec4(ambient.xyz * _baseColor.xyz + diffuse.xyz * _diff * _baseColor.xyz + specular * _spec, 1.0);
}
