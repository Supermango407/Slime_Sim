#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout (rgba8, binding = 0) uniform readonly image2D InputImage;
layout (rgba8, binding = 1) uniform writeonly image2D OutputImage;

layout(std430, binding = 2) buffer PosBuffer {
    vec2 values[];
} agent_positions;

layout(std430, binding = 3) buffer DirBuffer {
    vec2 values[];
} agent_directions;

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    // Average the color with its neighbors to create a blur effect
    vec4 color = imageLoad(InputImage, global_id.xy);
    // color.rgb -= 0.01;
    // vec4 middle = imageLoad(InputImage, global_id.xy);
    // vec4 right = imageLoad(InputImage, global_id.xy+ivec2(10, 0));
    // vec4 left = imageLoad(InputImage, global_id.xy+ivec2(0, -1));
    // vec4 top = imageLoad(InputImage, global_id.xy+ivec2(0, 1));
    // vec4 bottom = imageLoad(InputImage, global_id.xy+ivec2(-1, 0));
    // if (right.r > 0.0) {
    //     color = vec4(1, 0, 1, 1);
    // }

    imageStore(OutputImage, global_id, color);
}