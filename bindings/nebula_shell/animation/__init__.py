"""
Animation module for Nebula Shell.

Provides declarative animation abstractions for animating
widget properties over time.
"""

from nebula_shell.animation.animation import Animation
from nebula_shell.animation.fade import FadeAnimation
from nebula_shell.animation.slide import SlideAnimation, SlideDirection
from nebula_shell.animation.scale import ScaleAnimation

__all__ = [
    "Animation",
    "FadeAnimation",
    "SlideAnimation",
    "SlideDirection",
    "ScaleAnimation",
]
