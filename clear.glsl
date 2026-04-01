#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 16, local_size_y = 16, local_size_z = 1) in;

layout (rgba32f, binding = 0) uniform readonly image2D InputImage;
layout (rgba32f, binding = 1) uniform writeonly image2D OutputImage;

// layout(std430, binding = 2) buffer PosBuffer {
//     vec2 values[];
// } agent_positions;

// layout(std430, binding = 3) buffer DirBuffer {
//     vec2 values[];
// } agent_directions;

vec4 hash(vec2 p) {
    vec4 p4 = fract(vec4(p.xyxy) * vec4(.1031, .1030, .0973, .1099));
    p4 += dot(p4, p4.wzxy + 33.33);
    return fract((p4.xxyz + p4.yzzw) * p4.zywx);
}

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    vec4 color = imageLoad(InputImage, global_id.xy);
    // color = vec4(hash(global_id.xy).rgb, 1); // Set the color to a random value based on the pixel's coordinates

    color.rgb = vec3(0, 0, 0); // Clear the image by setting all pixels to black

    imageStore(OutputImage, global_id, color);
}