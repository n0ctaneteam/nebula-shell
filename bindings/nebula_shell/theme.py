"""
Theme module for Nebula Shell.

Provides CSS theme loading and application for GTK widgets.
Themes are stored as .css files in ~/.config/nebula-shell/themes/.
"""

import os
from pathlib import Path
from typing import Optional


class Theme:
    """Manages GTK CSS theme loading and application.

    Theme wraps Gtk.CssProvider to provide a Python-native API
    for applying CSS styles to Nebula Shell widgets.

    Attributes:
        name: The theme name (filename without .css extension).
        path: Absolute path to the CSS file.
    """

    _themes_dir: Path = Path.home() / ".config" / "nebula-shell" / "themes"
    _provider: Optional[object] = None
    _current_name: Optional[str] = None

    @classmethod
    def _ensure_provider(cls) -> object:
        """Ensure a Gtk.CssProvider exists."""
        if cls._provider is None:
            from gi.repository import Gtk
            cls._provider = Gtk.CssProvider()
        return cls._provider

    @classmethod
    def _apply_css(cls, css: str) -> None:
        """Apply CSS string to the display.

        Args:
            css: CSS content to apply.
        """
        from gi.repository import Gtk, Gdk

        provider = cls._ensure_provider()
        provider.load_from_string(css)
        Gtk.StyleContext.add_provider_for_display(
            Gdk.Display.get_default(),
            provider,
            Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION,
        )

    @classmethod
    def set_themes_dir(cls, path: str) -> None:
        """Set the themes directory.

        Args:
            path: Absolute path to the themes directory.
        """
        cls._themes_dir = Path(path)

    @classmethod
    def get_themes_dir(cls) -> Path:
        """Get the themes directory."""
        return cls._themes_dir

    @classmethod
    def list_themes(cls) -> list:
        """List all available theme names.

        Returns:
            List of theme names (without .css extension).
        """
        themes = []
        if cls._themes_dir.exists():
            for f in cls._themes_dir.iterdir():
                if f.suffix == ".css" and f.is_file():
                    themes.append(f.stem)
        return sorted(themes)

    @classmethod
    def current(cls) -> Optional[str]:
        """Get the name of the currently active theme."""
        return cls._current_name

    def __init__(self, name: str) -> None:
        """Create a Theme instance.

        Args:
            name: Theme name (filename without .css extension).

        Raises:
            FileNotFoundError: If the theme file does not exist.
        """
        self.name = name
        self.path = self._themes_dir / f"{name}.css"

        if not self.path.exists():
            raise FileNotFoundError(f"Theme '{name}' not found: {self.path}")

    def load(self) -> None:
        """Load and apply this theme to the display.

        Reads the CSS file and applies it via Gtk.CssProvider.
        """
        css = self.path.read_text()
        Theme._apply_css(css)
        Theme._current_name = self.name

    def reload(self) -> None:
        """Reload the CSS from disk and reapply."""
        self.load()

    @classmethod
    def load_default(cls) -> None:
        """Load the bundled default CSS (shell.css next to shell.py)."""
        import inspect
        caller_frame = inspect.stack()[1]
        caller_file = Path(caller_frame.filename)
        css_path = caller_file.parent / "shell.css"
        if css_path.exists():
            css = css_path.read_text()
            cls._apply_css(css)

    @staticmethod
    def load_css_string(css: str) -> None:
        """Apply a raw CSS string directly (without a file).

        Args:
            css: CSS content to apply.
        """
        Theme._apply_css(css)
