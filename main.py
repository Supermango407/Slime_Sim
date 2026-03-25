from typing import Union
import pygame
from pygame import Vector2
import screeninfo
from PIL import Image
import random
import os

from spmg import Gameobject, Renderer, Canvas_Renderer, ShaderVariable, ShaderVarTypes


class SlimeRenderer():
    def __init__(self,
    agent_positions:list[tuple[float, float]]=None,
    agent_directions:list[float]=None,
    window_size:tuple[int, int]=None,
    ):
        self.window_size = window_size
        self.slime_renderer = Canvas_Renderer(
            shader_paths=["slime_renderer.glsl"],
            anchor=Vector2(0.5, 0.5),
            relative_position=Vector2(0.5, 0.5),
            group_sizes=[(16, 16)],
            size=Vector2(self.window_size[0], self.window_size[1]),
            default_color=(0, 0, 0, 255),
            shader_vars=[[
                ShaderVariable(
                    name="agent_positions",
                    data_type=ShaderVarTypes.VEC2,
                    array_size=(len(agent_positions)),
                    array_buffer=2,
                    value=agent_positions,
                ),
                ShaderVariable(
                    name="agent_directions",
                    data_type=ShaderVarTypes.VEC2,
                    array_size=(len(agent_directions)),
                    array_buffer=3,
                    value=agent_directions,
                )
            ]]
        )

        self.agent_image = Image.new("RGBA", (len(agent_positions), 1), (0, 0, 0, 255))
        self.set_agent_image()
        
        self.agent_renderer = Renderer(
            shader_paths=["agent_renderer.glsl"],
            default_image=self.agent_image,
            group_sizes=(1, 1),
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
            start_buffer=4
        )

    
    def update(self):
        # self.set_agent_image()
        self.slime_renderer.run_shader()
        self.agent_renderer.run_shader()

    def set_agent_image(self):
        """set the positions and directions of the agents in `agent_image`."""
        velocities = self.slime_renderer.get_shader_variable("agent_directions")
        for i, coords in enumerate(self.slime_renderer.get_shader_variable("agent_positions")):
            x, y = float(coords[0]), float(coords[1])
            x_vel, y_vel = float(velocities[i][0]), float(velocities[i][1])
            print(f"Agent {i}: Position=({int(256 * x / self.window_size[0])}, {int(256 * y / self.window_size[1])}), Velocity=({int(128 * (x_vel+1))}, {int(128 * (y_vel+1))})")
            self.agent_image.putpixel((i, 0), (
                int(256 * x / self.window_size[0]),
                int(256 * y / self.window_size[1]),
                int(128 * (x_vel+1)),
                int(128 * (y_vel+1))))

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
    window_size = (1056, 544)
    window = pygame.display.set_mode(window_size)
    clock = pygame.time.Clock()
    Gameobject.static_start(window)

    seed = 0
    rng = random.Random(seed)

    agent_positions: list[tuple[float, float]] = []
    agent_directions:float = []
    for i in range(10):
        agent_positions.append(Vector2(rng.randint(0, window_size[0]), rng.randint(0, window_size[1])))
        agent_directions.append((rng.randint(-1, 2), rng.randint(-1, 2)))

    renderer = SlimeRenderer(
        agent_positions=agent_positions,
        agent_directions=agent_directions,
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
