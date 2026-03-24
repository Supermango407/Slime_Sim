import sys
import os

external_module_dir = os.path.abspath('../SPMG/')
if external_module_dir not in sys.path:
    sys.path.append(external_module_dir)

import spmg_pygame.gameobject as gameobject
from spmg_pygame.gameobject import Gameobject
from spmg_pygame.renderer import Canvas_Renderer, ShaderVariable, ShaderVarTypes
from spmg_renderer.renderer import Renderer
