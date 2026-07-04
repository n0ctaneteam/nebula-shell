"""
UI module for Nebula Shell.

Provides widget classes for building desktop shell interfaces.
All widgets display information but never fetch it.
Data fetching belongs inside services.
"""

from nebula_shell.ui.widget import Widget
from nebula_shell.ui.container import Container
from nebula_shell.ui.box import Box, Orientation, Alignment
from nebula_shell.ui.label import Label
from nebula_shell.ui.button import Button
from nebula_shell.ui.overlay import Overlay, OverlayAlignment
from nebula_shell.ui.stack import Stack
from nebula_shell.ui.grid import Grid
from nebula_shell.ui.separator import Separator
from nebula_shell.ui.spacer import Spacer
from nebula_shell.ui.icon import Icon
from nebula_shell.ui.image import Image
from nebula_shell.ui.entry import Entry
from nebula_shell.ui.window import Window, Anchor, Layer, KeyboardMode, Monitor
from nebula_shell.ui.panel import Panel

__all__ = [
    "Widget",
    "Container",
    "Box",
    "Orientation",
    "Alignment",
    "Label",
    "Button",
    "Overlay",
    "OverlayAlignment",
    "Stack",
    "Grid",
    "Separator",
    "Spacer",
    "Icon",
    "Image",
    "Entry",
    "Window",
    "Anchor",
    "Layer",
    "KeyboardMode",
    "Monitor",
    "Panel",
]
