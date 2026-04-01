from typing import Union
import pygame
from pygame import Vector2
import screeninfo
import numpy
from PIL import Image
import random
import os

from spmg import Gameobject, Renderer, Canvas_Renderer, ShaderVariable, ShaderVarTypes


class SlimeRenderer():
    def __init__(self,
    window_size:tuple[int, int]=None,
    agent_scale=500, # the square root of the number of agents
    pixel_size:int = 1
    ):
        self.window_size = window_size
        self.slime_renderer = Canvas_Renderer(
            shader_paths=["slime_renderer.glsl", "clear.glsl"],
            anchor=Vector2(0.5, 0.5),
            relative_position=Vector2(0.5, 0.5),
            group_sizes=[(16, 16), (16, 16)],
            texture_size=(self.window_size[0]//pixel_size, self.window_size[1]//pixel_size),
            scaler=pixel_size,
            default_color=(0, 0, 0, 255),
            # shader_vars=[[
            #     ShaderVariable(
            #         name="agent_positions",
            #         data_type=ShaderVarTypes.VEC2,
            #         array_size=(len(agent_positions)),
            #         array_buffer=2,
            #         value=agent_positions,
            #     ),
            #     ShaderVariable(
            #         name="agent_directions",
            #         data_type=ShaderVarTypes.VEC2,
            #         array_size=(len(agent_directions)),
            #         array_buffer=3,
            #         value=agent_directions,
            #     )
            # ]]
        )

        # self.agent_image = Image.new("RGBA", (len(agent_positions), 1), (0, 0, 0, 255))
        # self.set_agent_image(positions=agent_positions, velocities=agent_directions)
        # agent_array = numpy.array(agent_coords, dtype=numpy.float32)

        self.agent_renderer = Renderer(
            shader_paths=["agent_renderer.glsl", "random_agents.glsl"],
            texture_size=(agent_scale, agent_scale),
            default_color=(0, 0, 1, 0),
            group_sizes=[(10, 10), (10, 10)],
            shader_vars=[[
                ShaderVariable(
                    name="SlimeInputImage",
                    data_type=ShaderVarTypes.IMAGE,
                    array_buffer=0,
                    value=Image.frombytes(
                        'RGBA',
                        self.slime_renderer.renderer.input_texture.size,
                        self.slime_renderer.renderer.input_texture.read()
                    ),
                )
            ]],
            start_buffer=4,
            texture_type=ShaderVarTypes.VEC4
        )
        self.agent_renderer.run_shader(1)
        # self.agent_renderer.run_shader()
        # pass
        # self.slime_renderer.run_shader(1)

    def update(self):
        # self.slime_renderer.run_shader(1)
        self.slime_renderer.run_shader()
        self.agent_renderer.run_shader()
        # self.slime_renderer.update_image()

    def set_agent_image(self, positions:list[tuple[float, float]], velocities:list[tuple[float, float]]):
        """set the positions and directions of the agents in `agent_image`."""
        for i, coords in enumerate(positions):
            x, y = float(coords[0]), float(coords[1])
            x_vel, y_vel = float(velocities[i][0]), float(velocities[i][1])
            # print(f"Agent {i}: Position=({x}, {y}), Velocity=({x_vel}, {y_vel})")
            self.agent_image.putpixel((i, 0), (
                int(x),
                int(y),
                int(x_vel),
                int(y_vel)
            ))

    def move_agents(self):
        """moves the agents according to their directions."""
        agent_positions = self.slime_renderer.get_shader_variable("agent_positions")
        agent_directions = self.slime_renderer.get_shader_variable("agent_directions")
        for i in range(len(agent_positions)):
            x, y = agent_positions[i]
            direction = agent_directions[i]
            x += 5 * pygame.math.Vector2(1, 0).rotate(direction).x
            y += 5 * pygame.math.Vector2(1, 0).rotate(direction).y
            x = max(0, min(self.window_size[0], x))
            y = max(0, min(self.window_size[1], y))
            agent_positions[i] = (x, y)
        
        self.slime_renderer.set_shader_variable("agent_positions", agent_positions)
        self.set_agent_image()


if __name__ == '__main__':
    # move window to second monitor if it exits
    if len(screeninfo.get_monitors()) == 2: # two monitors
        os.environ['SDL_VIDEO_WINDOW_POS'] = "%d,%d" % (1400,75)

    # initiate window
    pygame.init()
    pygame.display.set_caption("Slime Simulation")

    # Set global vars
    # window_size = (1024, 512)
    window_size = (512, 512)
    window = pygame.display.set_mode(window_size)
    clock = pygame.time.Clock()
    Gameobject.static_start(window)

    seed = 0
    rng = random.Random(seed)

    # agent_coords: list[tuple[float, float]] = []
    # for i in range(1000):
    #     velocity = Vector2(1, 0).rotate(rng.random()*360)
    #     agent_coords.append((
    #         rng.random(),
    #         rng.random(),
    #         velocity.x,
    #         velocity.y,
    #     ))

    renderer = SlimeRenderer(
        # agent_coords=agent_coords,
        window_size=window_size
    )

    # main loop
    running = True
    while running:
        window.fill((16, 16, 32))
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            Gameobject.static_event(event)
        
        renderer.update()
        Gameobject.static_update()
        pygame.display.update()
        clock.tick(30)

    pygame.quit()
