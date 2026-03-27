#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

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

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    // the rg/xy values are the xy position of the agent,
    // and the ba/zw value is the direction
    vec4 agent_coords = imageLoad(InputImage, global_id.xy);
    vec4 random = hash(global_id+ivec2(1, 1));
    agent_coords.xy = random.rg; // move the agent in a random direction

    agent_coords.zw = rotate(agent_coords.zw, random.b*6.28318);

    // save the agent's new cords
    imageStore(OutputImage, global_id, agent_coords);
}