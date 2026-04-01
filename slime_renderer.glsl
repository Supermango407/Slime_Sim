#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout (rgba32f, binding = 0) uniform readonly image2D InputImage;
layout (rgba32f, binding = 1) uniform writeonly image2D OutputImage;

uniform float subtract_rate = 0.125;

// layout(std430, binding = 2) buffer PosBuffer {
//     vec2 values[];
// } agent_positions;

// layout(std430, binding = 3) buffer DirBuffer {
//     vec2 values[];
// } agent_directions;

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    vec4 color = vec4(0, 0, 0, 1.0);

    // Average the color with its neighbors to create a blur effect
    for (int i=-1; i < 2; i++) {
        for (int j=-1; j < 2; j++) {
            color.rgb += (imageLoad(InputImage, global_id.xy+ivec2(i, j)).rgb)/9.0;
        }
    }

    // subtract a small amount from the color to create a fading effect
    float fade = subtract_rate;
    color.rgb = vec3(max(0, color.r-fade), max(0, color.g-fade), max(0, color.b-fade));

    imageStore(OutputImage, global_id, color);
}