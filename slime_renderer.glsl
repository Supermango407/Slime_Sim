#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout (rgba8, binding = 0) uniform readonly image2D InputImage;
layout (rgba8, binding = 1) uniform writeonly image2D OutputImage;

// layout(std430, binding = 2) buffer PosBuffer {
//     vec2 values[];
// } agent_positions;

// layout(std430, binding = 3) buffer DirBuffer {
//     vec2 values[];
// } agent_directions;

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    // Average the color with its neighbors to create a blur effect
    vec4 color = imageLoad(InputImage, global_id.xy);
    color.rgb += imageLoad(InputImage, global_id.xy+ivec2(1, 0)).rgb;
    color.rgb += imageLoad(InputImage, global_id.xy+ivec2(0, -1)).rgb;
    color.rgb += imageLoad(InputImage, global_id.xy+ivec2(0, 1)).rgb;
    color.rgb += imageLoad(InputImage, global_id.xy+ivec2(-1, 0)).rgb;
    color.rgb /= 5.0;

    // subtract a small amount from the color to create a fading effect
    color.rgb -= 0.0009765625; // 1/1024

    imageStore(OutputImage, global_id, color);
}