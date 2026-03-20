#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout (rgba8, binding = 0) uniform image2D InputImage;
layout (rgba8, binding = 1) uniform writeonly image2D OutputImage;

uniform float offset = 0.00390625; // 1/256

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    vec4 color = imageLoad(InputImage, global_id.xy);
    color = vec4(abs(mod(color.r+offset, 1.0)), abs(mod(color.g+offset, 1.0)), abs(mod(color.b+offset, 1.0)), color.a);
    
    imageStore(OutputImage, global_id, color);
}