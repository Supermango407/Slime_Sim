#version 430

// Set local workgroup size. The total number of workgroups will be calculated
// from the image size and these values.
layout (local_size_x = 1, local_size_y = 1, local_size_z = 1) in;

layout (rgba32f, binding = 4) uniform readonly image2D InputImage;
layout (rgba32f, binding = 5) uniform writeonly image2D OutputImage;

layout (rgba32f, binding = 0) uniform image2D SlimeInputImage;

uniform float speed = 2.0;
uniform float turn_speed = 0.5;
uniform float strength = 1.0;

ivec2 screen_space (vec2 pos, vec2 screen_size) {
    return ivec2(int(pos.x * screen_size.x), int(pos.y * screen_size.y));
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

float get_strength(vec2 position, vec2 screen_size, vec4 color) {
    ivec2 point = screen_space(position.xy, screen_size);
    float value = 0.0;
    value += imageLoad(SlimeInputImage, point).r/5.0;
    value += imageLoad(SlimeInputImage, point+ivec2(0, 1)).r/5.0;
    value += imageLoad(SlimeInputImage, point+ivec2(0, -1)).r/5.0;
    value += imageLoad(SlimeInputImage, point+ivec2(1, 0)).r/5.0;
    value += imageLoad(SlimeInputImage, point+ivec2(-1, 0)).r/5.0;
    return value;
}

void main() {
    ivec2 global_id = ivec2(gl_GlobalInvocationID.xy);
    
    // the rg/xy values are the xy position of the agent,
    // and the ba/zw value is the direction
    vec4 agent_coords = imageLoad(InputImage, global_id.xy);
    vec2 screen_size = imageSize(SlimeInputImage);

    vec4 rng = hash(agent_coords.xy);
    float turn_random = pow(rng.r-0.5, 4)*2;
    float right = get_strength(agent_coords.xy+vector_from_dir(agent_coords.z+0.125, speed*2)/screen_size, screen_size, vec4(0, 1, 0, 1));
    float left = get_strength(agent_coords.xy+vector_from_dir(agent_coords.z-0.125, speed*2)/screen_size, screen_size, vec4(0, 0, 1, 1));
    // left -= pow(rng.r, 1);
    // right -= pow(rng.g, 1);

    float turn = max(min(right-left+turn_random, 1), -1)*turn_speed;
    // float turn = 0.0125;
    agent_coords.z += turn;
    vec2 vel = vector_from_dir(agent_coords.z, speed)/screen_size;
    
    // rotate based on color of directions
    // vec2 clockwise_vel = rotate(vel, 0.7853981625); // pi/4
    // vec2 counterclockwise_vel = rotate(vel, -0.7853981625); // -pi/4
    
    // vec4 front = imageLoad(SlimeInputImage, screen_space(agent_coords.xy + vel, size));
    // vec4 clockwise = imageLoad(SlimeInputImage, screen_space(agent_coords.xy + clockwise_vel, size));
    // vec4 counterclockwise = imageLoad(SlimeInputImage, screen_space(agent_coords.xy + counterclockwise_vel, size));

    // if (clockwise.r > counterclockwise.r && clockwise.r > front.r) {
    //     // clockwise_vel is brightest dir
    //     vel = clockwise_vel;
    // } else if (counterclockwise.r > clockwise.r && counterclockwise.r > front.r) {
    //     // counterclockwise_vel is brightest dir
    //     vel = counterclockwise_vel;
    // } // else vel is brightest dir

    // Store the agent's position in the SlimeInputImage
    ivec2 screen_pos = screen_space(agent_coords.xy, screen_size);
    float current_color = imageLoad(SlimeInputImage, screen_pos).r;
    float final_color = min(current_color+strength, 1);
    imageStore(SlimeInputImage, screen_pos, vec4(final_color, final_color, final_color, 1));

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