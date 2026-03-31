#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout (rgba32f, binding = 4) uniform readonly image2D InputImage;
layout (rgba32f, binding = 5) uniform writeonly image2D OutputImage;

layout (rgba32f, binding = 0) uniform image2D SlimeInputImage;

uniform float speed = 1.0;

ivec2 screen_space (vec2 pos, vec2 size) {
    return ivec2(int(pos.x * size.x), int(pos.y * size.y));
}

vec2 vector_from_dir(float dir, float magnitude) {
    dir *= 6.28318;
    return vec2(cos(dir), sin(dir)) * magnitude;
}

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
    vec2 size = imageSize(SlimeInputImage);
    vec2 vel = vector_from_dir(agent_coords.z, speed)/size;
    
    // rotate based on color of directions
    vec2 clockwise_vel = rotate(vel, 0.7853981625); // pi/4
    vec2 counterclockwise_vel = rotate(vel, -0.7853981625); // -pi/4
    
    vec4 front = imageLoad(SlimeInputImage, screen_space(agent_coords.xy + vel, size));
    vec4 clockwise = imageLoad(SlimeInputImage, screen_space(agent_coords.xy + clockwise_vel, size));
    vec4 counterclockwise = imageLoad(SlimeInputImage, screen_space(agent_coords.xy + counterclockwise_vel, size));

    if (clockwise.r > counterclockwise.r && clockwise.r > front.r) {
        // clockwise_vel is brightest dir
        vel = clockwise_vel;
    } else if (counterclockwise.r > clockwise.r && counterclockwise.r > front.r) {
        // counterclockwise_vel is brightest dir
        vel = counterclockwise_vel;
    } // else vel is brightest dir

    // Store the agent's position in the SlimeInputImage
    imageStore(SlimeInputImage, screen_space(agent_coords.xy, size), vec4(1, 1, 1, 1));

    agent_coords.xy += vel; // Move the agent according to its direction

    // bounce off the walls
    if (agent_coords.x < 0.0) {
        agent_coords.z = hash(agent_coords.xy).r/2 - 0.25; // face random direction from 0.25 to -0.25
        agent_coords.x = 0.0;
    } else if (agent_coords.x > 1.0) {
        agent_coords.z = hash(agent_coords.xy).r/2 + 0.25; // face random direction from 0.25 to 0.75
        agent_coords.x = 1.0;
    }
    if (agent_coords.y < 0.0) {
        agent_coords.z = hash(agent_coords.xy).r/2; // face random direction from 0 to 0.5
        agent_coords.y = 0.0;
    } else if (agent_coords.y > 1.0) {
        agent_coords.z = hash(agent_coords.xy).r/2 + 0.5; // face random direction from 0.5 to 1
        agent_coords.y = 1.0;
    }

    // save the agent's new cords
    imageStore(OutputImage, global_id, agent_coords);
}