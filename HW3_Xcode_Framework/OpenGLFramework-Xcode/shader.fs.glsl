#version 330

in vec4 vertexInView;
in vec3 vertex_color;
in vec2 texCoord;
in vec3 N;
in vec3 L;
in vec3 V;

out vec4 fragColor;

uniform int mode;
uniform mat4 um4p;
uniform mat4 um4v;
uniform mat4 um4m;
uniform float x_shift;
uniform float y_shift;
uniform float shininess;
uniform int cur_light_mode;

struct light_setting
{
    vec3 position;
    vec3 La;
    vec3 Ld;
    vec3 Ls;
    vec3 spotDirection;
    float spotExponent;
    float spotCutoff;
    float constantAttenuation;
    float linearAttenuation;
    float quadraticAttenuation;
};
uniform light_setting light;

struct PhongMaterial
{
    vec3 Ka;
    vec3 Kd;
    vec3 Ks;
};
uniform PhongMaterial material;

vec3 computeLight(vec3 N, vec3 L, vec3 V, int cur_light_mode) {
    vec3 N_n = normalize(N);
    vec3 L_n = normalize(L);
    vec3 V_n = normalize(V);
    vec3 H_n = normalize(L_n + V_n);
    
    vec3 Ambient = light.La * material.Ka;
    vec3 Diffuse = max(dot(N_n, L_n), 0) * light.Ld * material.Kd;
    vec3 Specular = pow(max(dot(N_n, H_n), 0), shininess) * light.Ls * material.Ks;
    
    if (cur_light_mode == 0) {
        return Ambient + Diffuse + Specular;
    }
    
    float d = length(L);
    float attenuation_factor = min(1.0 / (light.constantAttenuation + light.linearAttenuation * d + light.quadraticAttenuation * pow(d, 2)), 1.0);
    
    if (cur_light_mode == 1) {
        return Ambient + attenuation_factor * (Diffuse + Specular);
    }

    float dotVD = dot(normalize(vertexInView.xyz - light.position), normalize(light.spotDirection));    // ????
    float spotlight_effect = (dotVD > cos(light.spotCutoff * radians(1)))? pow(max(dotVD, 0), light.spotExponent): 0.0;
    
    if (cur_light_mode == 2) {
        return Ambient + attenuation_factor * spotlight_effect * (Diffuse + Specular);
    }
}

// [TODO] passing texture from main.cpp
// Hint: sampler2D
uniform sampler2D texture_info;

void main() {
    if (mode == 0) {
        fragColor = vec4(vertex_color, 1.0);
    }
    else {
        vec3 color = computeLight(N, L, V, cur_light_mode);
        fragColor = vec4(color, 1.0);
    }

	// [TODO] sampleing from texture
	// Hint: texture
    fragColor *= texture(texture_info, texCoord + vec2(x_shift, y_shift));
}
