varying vec3 lightdir;           //切线空间灯光向量;
varying vec3 eyedir;             //切线空间眼点向量;
varying vec4 ambient, diffuse, specular;
attribute vec3 tangent;          //顶点切线;
uniform float time;                       //时间更新;
uniform vec3  lightPos;         //灯光的位置;
void main()
{
    vec3 vVertex = vec3(gl_ModelViewMatrix * gl_Vertex);
    vec3 L = normalize(lightPos - vVertex);            //定点到光源向量;
    vec3 E = normalize(-vVertex);                      //定点到眼点向量;
    vec3 N = normalize(gl_NormalMatrix * gl_Normal);
    vec3 H = normalize(L + E);
    //获取漫反射， 镜面反射量;
    ambient = vec4(1.0,1.0,1.0,1.0);
    diffuse = vec4(1.0,1.0,1.0,1.0);
    specular = vec4(1.0,1.0,1.0,1.0);
    float _diffuse = max(dot(L, N), 0.0);
    
    if(_diffuse > 0.0){
        diffuse = diffuse * _diffuse;
        float _specular = max(dot(H,N),0.0);
        specular = specular * pow(_specular , 64.0);
    }
    //计算切线空间量;
    vec3 T = normalize(vec3(gl_NormalMatrix * tangent));
    vec3 B = normalize(cross(N,T));
    
    lightdir.x = dot(L,T);
    lightdir.y = dot(L,B);
    lightdir.z = dot(L,N);
    lightdir = normalize(lightdir);
    
    eyedir.x = dot(E,T);
    eyedir.y = dot(E,B);
    eyedir.z = dot(E,N);
    lightdir = normalize(eyedir);
    
    gl_TexCoord[0] = gl_MultiTexCoord0;
    
    //根据时间获取法线纹理位置;
    gl_TexCoord[1].x = gl_TexCoord[0].x + time * 0.05;
    gl_TexCoord[1].y = gl_TexCoord[0].y + time * 0.05;
    
    gl_Position  = ftransform();
}
