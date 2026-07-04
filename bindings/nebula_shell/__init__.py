"""
Nebula Shell Python API.

A Pythonic wrapper for the Nebula Shell desktop shell framework.
Provides abstractions for building desktop shell components
such as panels, bars, dashboards, and notifications.

Example:
    import nebula_shell

    app = nebula_shell.Application()
    panel = nebula_shell.ui.Box()
    label = nebula_shell.ui.Label("Hello, World!")
    panel.append(label)
    app.run()
"""

from nebula_shell.version import __version__, __major__, __minor__, __patch__
from nebula_shell.app import Application
from nebula_shell.config.config import Config
from nebula_shell.ipc.ipc import Ipc
from nebula_shell.plugin.plugin import Plugin, PluginInfo, PluginState
from nebula_shell.utils.logger import Logger, LogLevel
from nebula_shell.animation.animation import Animation
from nebula_shell.animation.fade import FadeAnimation
from nebula_shell.animation.slide import SlideAnimation
from nebula_shell.animation.scale import ScaleAnimation

__all__ = [
    "__version__",
    "__major__",
    "__minor__",
    "__patch__",
    "Application",
    "Config",
    "Ipc",
    "Plugin",
    "PluginInfo",
    "PluginState",
    "Logger",
    "LogLevel",
    "Animation",
    "FadeAnimation",
    "SlideAnimation",
    "ScaleAnimation",
]

__version__ = __version__
