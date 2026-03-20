import pygame
from pygame import Vector2
import screeninfo
from PIL import Image
import os

from spmg import Gameobject, Canvas_Renderer, ShaderVariable, ShaderVarTypes


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

    renderer = Canvas_Renderer(
        ["shader_test.glsl"],
        anchor=Vector2(0.5, 0.5),
        relative_position=Vector2(0.5, 0.5),
        group_sizes=[(1, 1)],
        size=Vector2(512, 512)
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
