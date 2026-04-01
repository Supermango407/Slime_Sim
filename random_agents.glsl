#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 10, local_size_y = 10, local_size_z = 1) in;

layout (rgba32f, binding = 4) uniform readonly image2D InputImage;
layout (rgba32f, binding = 5) uniform writeonly image2D OutputImage;

vec4 hash(vec2 p) {
    vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

vec2 rotate(vec2 v, float angle) {
    float cos_a = cos(angle);
    float sin_a = sin(angle);
    return vec2(v.x * cos_a - v.y * sin_a, v.x * sin_a + v.y * cos_a);
}

vec3 circle_coords(float radius, vec2 center, vec3 rng) {
    float theta = rng.r*6.28318;
    float r = radius * sqrt(rng.g);
    vec2 point = vec2(center.r+r * cos(theta), center.g+r * sin(theta));
    float a = 0.5+theta/6.28318;
    
    return vec3(point.xy, a);
}

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    // the rg/xy values are the xy position of the agent,
    // and the b/z value is the direction
    vec4 agent_coords = imageLoad(InputImage, global_id.xy);
    vec4 random = hash(global_id+ivec2(1, 1));
    agent_coords.xyz = circle_coords(0.35, vec2(0.5, 0.5), random.rgb); // move the agent to a random place
    // agent_coords.xyz = random.rgb; // move the agent to a random place
    // agent_coords.z = random.b; // point in a random direction

    // save the agent's new cords
    imageStore(OutputImage, global_id, agent_coords);
}