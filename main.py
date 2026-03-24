from typing import Union
import pygame
from pygame import Vector2
import screeninfo
from PIL import Image
import random
import os

from spmg import Gameobject, Canvas_Renderer, ShaderVariable, ShaderVarTypes


class SlimeRenderer(Canvas_Renderer):
    def __init__(self,
    agent_positions:list[tuple[float, float]]=None,
    agent_directions:list[float]=None,
    ):
        super().__init__(
            shader_paths=["draw_slime.glsl"],
            anchor=Vector2(0.5, 0.5),
            relative_position=Vector2(0.5, 0.5),
            group_sizes=[(1, 1)],
            size=Vector2(512, 512),
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
                    data_type=ShaderVarTypes.FLOAT,
                    array_size=(len(agent_directions)),
                    array_buffer=3,
                    value=agent_directions,
                )
            ]]
        )
    
    def update(self):
        self.move_agents()
        self.run_shader()
        super().update()

    def move_agents(self):
        """moves the agents according to their directions."""
        agent_positions = self.get_shader_variable("agent_positions")
        agent_directions = self.get_shader_variable("agent_directions")
        for i in range(len(agent_positions)):
            x, y = agent_positions[i]
            direction = agent_directions[i]
            x += 5 * pygame.math.Vector2(1, 0).rotate(direction).x
            y += 5 * pygame.math.Vector2(1, 0).rotate(direction).y
            x = max(0, min(1056, x))
            y = max(0, min(544, y))
            agent_positions[i] = (x, y)
        
        self.set_shader_variable("agent_positions", agent_positions)


if __name__ == '__main__':
    # move window to second monitor if it exits
    if len(screeninfo.get_monitors()) == 2: # two monitors
        os.environ['SDL_VIDEO_WINDOW_POS'] = "%d,%d" % (1400,75)

    # initiate window
    pygame.init()
    pygame.display.set_caption("Slime Simulation")

    # Set global vars
    # window = pygame.display.set_mode((576, 576))
    window = pygame.display.set_mode((1056, 544))
    clock = pygame.time.Clock()
    Gameobject.static_start(window)

    seed = 0
    rng = random.Random(seed)

    agent_positions: list[tuple[float, float]] = []
    agent_directions:float = []
    for i in range(10):
        agent_positions.append((rng.randint(0, 1056), rng.randint(0, 544)))
        agent_directions.append(rng.uniform(0, 360))

    renderer = SlimeRenderer(
        agent_positions=agent_positions,
        agent_directions=agent_directions
    )

    # main loop
    running = True
    while running:
        window.fill((16, 16, 32))
        for event in pygame.event.get():
            if event.type == pygame.QUIT:
                running = False
            Gameobject.static_event(event)
        
        Gameobject.static_update()
        pygame.display.update()
        clock.tick(30)

    pygame.quit()
