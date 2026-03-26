#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout (rgba32f, binding = 4) uniform readonly image2D InputImage;
layout (rgba32f, binding = 5) uniform writeonly image2D OutputImage;

layout (rgba8, binding = 0) uniform image2D SlimeInputImage;

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    // the rg/xy values are the xy position of the agent,
    // and the ba/zw value is the direction
    vec4 agent_coords = imageLoad(InputImage, global_id.xy);
    
    // Store the agent's position in the SlimeInputImage
    vec2 size = imageSize(SlimeInputImage);
    imageStore(SlimeInputImage, ivec2(int(agent_coords.x * size.x), int(agent_coords.y * size.y)), vec4(1, 1, 1, 1));

    agent_coords.xy += 1/(size) * (agent_coords.zw-0.5); // Move the agent according to its direction

    // save the agent's new cords
    imageStore(OutputImage, global_id, agent_coords);
}