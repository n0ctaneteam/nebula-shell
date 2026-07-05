"""
GObject Introspection bindings for Nebula Shell.

This module provides access to the underlying GI-generated bindings.
The bindings are generated at build time by meson.

When running without the built library, this module provides
fallback stubs for testing and development.
"""

import sys
import os
from pathlib import Path


def _find_typelib_dir():
    """Find the directory containing NebulaShell typelib."""
    project_root = Path(__file__).parent.parent.parent.parent
    builddir = project_root / "builddir" / "core" / "nebula-shell"

    if builddir.exists():
        return str(builddir)

    return None


try:
    import gi

    typelib_dir = _find_typelib_dir()
    if typelib_dir:
        sys.path.insert(0, typelib_dir)
        os.environ["GI_TYPELIB_PATH"] = typelib_dir

    gi.require_version("Gtk", "4.0")
    gi.require_version("NebulaShell", "1.0")
    from gi.repository import Gtk, NebulaShell

    Application = NebulaShell.Application
    Window = NebulaShell.Window
    Panel = NebulaShell.Panel
    Widget = NebulaShell.Widget
    Container = NebulaShell.Container
    Box = NebulaShell.Box
    Label = NebulaShell.Label
    Button = NebulaShell.Button
    Overlay = NebulaShell.Overlay
    Stack = NebulaShell.Stack
    Grid = NebulaShell.Grid
    Separator = NebulaShell.Separator
    Spacer = NebulaShell.Spacer
    Entry = NebulaShell.Entry
    Icon = NebulaShell.Icon
    Image = NebulaShell.Image

    Service = NebulaShell.Service
    Animation = NebulaShell.Animation
    FadeAnimation = NebulaShell.FadeAnimation
    SlideAnimation = NebulaShell.SlideAnimation
    ScaleAnimation = NebulaShell.ScaleAnimation

    Config = NebulaShell.Config
    Plugin = NebulaShell.Plugin
    PluginInfo = NebulaShell.PluginInfo
    Logger = NebulaShell.Logger

    Anchor = NebulaShell.Anchor
    Layer = NebulaShell.Layer
    KeyboardMode = NebulaShell.KeyboardMode
    Orientation = NebulaShell.Orientation
    Alignment = NebulaShell.Alignment
    OverlayAlignment = NebulaShell.OverlayAlignment
    GridAlignment = NebulaShell.GridAlignment
    SlideDirection = NebulaShell.SlideDirection

except (ImportError, ValueError):
    class _Stub:
        """Stub class for when GI bindings are not available."""
        def __init__(self, *args, **kwargs):
            raise RuntimeError(
                "NebulaShell GI bindings not found. "
                "Build the project first: meson setup builddir && ninja -C builddir"
            )

    Application = _Stub
    Window = _Stub
    Panel = _Stub
    Widget = _Stub
    Container = _Stub
    Box = _Stub
    Label = _Stub
    Button = _Stub
    Overlay = _Stub
    Stack = _Stub
    Grid = _Stub
    Entry = _Stub
    Icon = _Stub
    Image = _Stub
    Separator = _Stub
    Spacer = _Stub

    Service = _Stub
    Animation = _Stub
    FadeAnimation = _Stub
    SlideAnimation = _Stub
    ScaleAnimation = _Stub

    Config = _Stub
    Plugin = _Stub
    PluginInfo = _Stub
    Logger = _Stub

    class Anchor:
        TOP = 1
        BOTTOM = 2
        LEFT = 4
        RIGHT = 8
        NONE = 0
        ALL = 15

    class Layer:
        BACKGROUND = 0
        BOTTOM = 1
        TOP = 2
        OVERLAY = 3

    class KeyboardMode:
        NONE = 0
        EXCLUSIVE = 1
        ON_DEMAND = 2

    class Orientation:
        HORIZONTAL = 0
        VERTICAL = 1

    class Alignment:
        START = 0
        CENTER = 1
        END = 2
        FILL = 3

    class OverlayAlignment:
        TOP_LEFT = 0
        TOP_CENTER = 1
        TOP_RIGHT = 2
        MIDDLE_LEFT = 3
        CENTER = 4
        MIDDLE_RIGHT = 5
        BOTTOM_LEFT = 6
        BOTTOM_CENTER = 7
        BOTTOM_RIGHT = 8

    class GridAlignment:
        START = 0
        CENTER = 1
        END = 2
        FILL = 3

    class SlideDirection:
        LEFT = 0
        RIGHT = 1
        UP = 2
        DOWN = 3
