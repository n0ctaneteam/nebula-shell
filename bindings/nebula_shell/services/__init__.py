"""
Services module for Nebula Shell.

Services provide system state through properties, signals, and methods.
Widgets observe services but never own system state themselves.
"""

from nebula_shell.services.service import Service
from nebula_shell.services.battery import BatteryService
from nebula_shell.services.audio import AudioService
from nebula_shell.services.bluetooth import BluetoothService
from nebula_shell.services.media import MediaService
from nebula_shell.services.workspace import WorkspaceService
from nebula_shell.services.network import NetworkService

__all__ = [
    "Service",
    "BatteryService",
    "AudioService",
    "BluetoothService",
    "MediaService",
    "WorkspaceService",
    "NetworkService",
]
