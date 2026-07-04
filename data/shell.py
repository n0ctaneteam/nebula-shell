"""
Nebula Shell — Default Configuration

Welcome to Nebula Shell! This is the default configuration file.
It showcases all available widgets and features.

Edit this file to customize your shell, or replace it entirely
with your own configuration.

Configuration is loaded from (in order):
  1. ~/.config/nebula-shell/shell.py
  2. /etc/nebula-shell/shell.py  (this file)

Documentation: https://github.com/n0ctaneteam/nebula-shell
"""

# ---------------------------------------------------------------------------
# Imports
# ---------------------------------------------------------------------------

import nebula_shell
from nebula_shell.ui import (
    Box,
    Label,
    Button,
    Spacer,
    Separator,
    Grid,
    Entry,
    Window,
    Orientation,
    Anchor,
    Layer,
    KeyboardMode,
)
from nebula_shell.animation import FadeAnimation
from nebula_shell.utils import Logger, LogLevel

# ---------------------------------------------------------------------------
# Application
# ---------------------------------------------------------------------------

app = nebula_shell.Application()

# ---------------------------------------------------------------------------
# Logger — set to DEBUG for development, INFO for daily use
# ---------------------------------------------------------------------------

logger = Logger.default()
logger.min_level = LogLevel.INFO
logger.info("Nebula Shell starting up...")

# ---------------------------------------------------------------------------
# Stylesheet
# ---------------------------------------------------------------------------

stylesheet = """
/* --- Global --- */
* {
    font-family: "Sans", "Segoe UI", "Noto Sans";
    font-size: 14px;
}

/* --- Top Panel --- */
#top-panel {
    background-color: rgba(15, 15, 20, 0.92);
    padding: 0 12px;
    min-height: 32px;
}

/* --- Clock Label --- */
#clock {
    color: #e0e0e0;
    font-weight: bold;
    font-size: 13px;
}

/* --- Status Labels --- */
.status-label {
    color: #b0b0b0;
    font-size: 13px;
}

.status-label.active {
    color: #a6e3a1;
}

/* --- Quit Button --- */
.quit-btn {
    background: transparent;
    color: #f38ba8;
    border: none;
    padding: 4px 10px;
    border-radius: 4px;
}

.quit-btn:hover {
    background-color: rgba(243, 139, 168, 0.15);
}

/* --- Welcome Card --- */
#welcome-card {
    background-color: rgba(30, 30, 40, 0.95);
    border-radius: 12px;
    padding: 24px;
    margin: 16px;
}

#welcome-title {
    color: #cdd6f4;
    font-size: 22px;
    font-weight: bold;
}

#welcome-subtitle {
    color: #a6adc8;
    font-size: 14px;
}

/* --- Info Card --- */
.info-card {
    background-color: rgba(30, 30, 40, 0.9);
    border-radius: 8px;
    padding: 16px;
    margin: 8px;
}

.info-card .card-title {
    color: #89b4fa;
    font-size: 16px;
    font-weight: bold;
    margin-bottom: 8px;
}

.info-card .card-body {
    color: #bac2de;
    font-size: 13px;
}

/* --- Action Button --- */
.action-btn {
    background-color: rgba(137, 180, 250, 0.15);
    color: #89b4fa;
    border: 1px solid rgba(137, 180, 250, 0.3);
    border-radius: 6px;
    padding: 8px 16px;
}

.action-btn:hover {
    background-color: rgba(137, 180, 250, 0.25);
}

/* --- Entry --- */
#search-entry {
    background-color: rgba(49, 50, 68, 0.8);
    color: #cdd6f4;
    border: 1px solid rgba(137, 180, 250, 0.2);
    border-radius: 6px;
    padding: 8px 12px;
    font-size: 14px;
}

/* --- Separator --- */
.separator {
    color: rgba(205, 214, 244, 0.1);
}

/* --- Feature Grid --- */
#feature-grid {
    margin: 8px;
}

.feature-item {
    background-color: rgba(49, 50, 68, 0.6);
    border-radius: 8px;
    padding: 12px;
    margin: 4px;
}

.feature-item .feature-title {
    color: #a6e3a1;
    font-size: 13px;
    font-weight: bold;
}

.feature-item .feature-desc {
    color: #a6adc8;
    font-size: 12px;
}
"""

# ---------------------------------------------------------------------------
# Welcome Panel (top bar)
# ---------------------------------------------------------------------------

def create_top_panel():
    """Create the top status bar panel."""
    panel = Box(Orientation.HORIZONTAL, name="top-panel")
    panel.spacing = 8

    # App name
    app_label = Label("Nebula Shell", name="app-name")
    app_label.add_style_class("status-label")
    app_label.add_style_class("active")

    # Clock
    clock = Label("00:00", name="clock")
    clock.add_style_class("status-label")

    # Quit button
    quit_btn = Button("Quit", name="quit-btn")
    quit_btn.add_style_class("quit-btn")
    quit_btn.connect("clicked", lambda: app.quit())

    panel.append(app_label)
    panel.append(Spacer())
    panel.append(clock)
    panel.append(Spacer())
    panel.append(quit_btn)

    return panel


# ---------------------------------------------------------------------------
# Welcome Content (center card)
# ---------------------------------------------------------------------------

def create_welcome_content():
    """Create the welcome card content."""
    content = Box(Orientation.VERTICAL, name="welcome-content")
    content.spacing = 16

    # --- Title ---
    title = Label("Welcome to Nebula Shell", name="welcome-title")
    subtitle = Label(
        "A fast, lightweight desktop shell framework for Wayland",
        name="welcome-subtitle",
    )

    header = Box(Orientation.VERTICAL, name="welcome-header")
    header.spacing = 4
    header.append(title)
    header.append(subtitle)

    # --- Search Entry ---
    search = Entry("", name="search-entry")
    search.placeholder = "Type a command..."

    # --- Feature Grid ---
    features = Grid(name="feature-grid")
    features.row_spacing = 8
    features.column_spacing = 8
    features.rows = 2
    features.columns = 3

    feature_items = [
        ("Reactive", "Property bindings\nand signals"),
        ("Widgets", "Label, Button, Box,\nGrid, Stack, Overlay"),
        ("Animation", "Fade, Slide, Scale\ntransitions"),
        ("Services", "Battery, Audio,\nNetwork, Workspace"),
        ("Theming", "CSS styling with\nlive reload"),
        ("Plugins", "Load custom modules\nat runtime"),
    ]

    for i, (title_text, desc_text) in enumerate(feature_items):
        row = i // 3
        col = i % 3

        card = Box(Orientation.VERTICAL, name=f"feature-{i}")
        card.add_style_class("info-card")
        card.spacing = 4

        card_title = Label(title_text)
        card_title.add_style_class("feature-title")

        card_desc = Label(desc_text)
        card_desc.add_style_class("feature-desc")

        card.append(card_title)
        card.append(card_desc)

        features.attach(card, col, row)

    # --- Action Buttons ---
    actions = Box(Orientation.HORIZONTAL, name="actions")
    actions.spacing = 8

    docs_btn = Button("Documentation", name="docs-btn")
    docs_btn.add_style_class("action-btn")
    docs_btn.connect("clicked", lambda: logger.info("Opening docs..."))

    config_btn = Button("Edit Config", name="config-btn")
    config_btn.add_style_class("action-btn")
    config_btn.connect("clicked", lambda: logger.info("Opening config..."))

    quit_btn = Button("Quit", name="welcome-quit")
    quit_btn.add_style_class("action-btn")
    quit_btn.connect("clicked", lambda: app.quit())

    actions.append(docs_btn)
    actions.append(config_btn)
    actions.append(Spacer())
    actions.append(quit_btn)

    # --- Footer ---
    footer = Label(
        "Edit ~/.config/nebula-shell/shell.py to customize",
        name="footer",
    )
    footer.add_style_class("status-label")

    # Assemble
    content.append(header)
    content.append(Separator(Orientation.HORIZONTAL))
    content.append(search)
    content.append(features)
    content.append(Separator(Orientation.HORIZONTAL))
    content.append(actions)
    content.append(footer)

    return content


# ---------------------------------------------------------------------------
# Main Window
# ---------------------------------------------------------------------------

def create_window():
    """Create the main welcome window."""
    win = Window(name="welcome-window")
    win.title = "Nebula Shell"
    win.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
    win.layer = Layer.TOP
    win.keyboard_mode = KeyboardMode.EXCLUSIVE

    # Root container
    root = Box(Orientation.VERTICAL, name="root")
    root.spacing = 0

    root.append(create_top_panel())
    root.append(create_welcome_content())

    win.add(root)
    win.show()

    return win


# ---------------------------------------------------------------------------
# Entry Point
# ---------------------------------------------------------------------------

window = create_window()

# ---------------------------------------------------------------------------
# Fade-in animation on the welcome card
# ---------------------------------------------------------------------------

fade_in = FadeAnimation(window, from_value=0.0, to_value=1.0)
fade_in.duration = 400
fade_in.start()

logger.info("Nebula Shell ready")

app.run()
