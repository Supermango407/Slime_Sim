#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout (rgba8, binding = 0) uniform image2D InputImage;
layout (rgba8, binding = 1) uniform writeonly image2D OutputImage;

layout(std430, binding = 2) buffer PosBuffer {
    vec2 values[];
} agent_positions;

layout(std430, binding = 3) buffer DirBuffer {
    float values[];
} agent_directions;

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    vec4 color = imageLoad(InputImage, global_id.xy);
    color = vec4(0, 0, 0, 1); // Default to black
    for (int i = 0; i < agent_positions.values.length(); i++) {
        vec2 pos = agent_positions.values[i];
        if (distance(vec2(pos), vec2(global_id)) < 10) {
            color = vec4(1, 1, 1, 1);
            break;
        }
    }
    
    imageStore(OutputImage, global_id, color);
}