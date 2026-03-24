#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout (rgba8, binding = 4) uniform readonly image2D InputImage;
layout (rgba8, binding = 5) uniform writeonly image2D OutputImage;

layout (rgba8, binding = 6) uniform image2D PositionImage;

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    vec4 color = imageLoad(InputImage, global_id.xy);
    
    // Store the agent's position in the PositionImage
    ivec2 size = imageSize(PositionImage);
    imageStore(PositionImage, ivec2(int(color.x * size.x), int(color.y * size.y)), vec4(1, 0, 0, 1));

    imageStore(OutputImage, global_id, color);
}