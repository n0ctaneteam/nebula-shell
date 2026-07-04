"""
Plugin module for Nebula Shell.

Plugins extend the framework through public APIs only.
Plugins cannot modify internal runtime state directly.
"""

from nebula_shell.plugin.plugin import Plugin, PluginInfo, PluginState

__all__ = [
    "Plugin",
    "PluginInfo",
    "PluginState",
]
