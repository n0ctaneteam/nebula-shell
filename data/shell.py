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
    Overlay,
    OverlayAlignment,
    Stack,
    Icon,
    Image,
    Window,
    Panel,
    Orientation,
    Alignment,
    Anchor,
    Layer,
    KeyboardMode,
)
from nebula_shell.animation import FadeAnimation, SlideAnimation, ScaleAnimation
from nebula_shell.theme import Theme
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
# Theme
# ---------------------------------------------------------------------------

theme = "n0ctos"

# ---------------------------------------------------------------------------
# Load Styles
# ---------------------------------------------------------------------------

Theme.load_default()

if theme:
    try:
        theme_obj = Theme(theme)
        theme_obj.load()
        logger.info(f"Loaded theme: {theme}")
    except FileNotFoundError:
        logger.warning(f"Theme '{theme}' not found, using defaults")


# ===========================================================================
# PANEL — Top bar with system indicators
# ===========================================================================

def create_top_panel():
    """Create the top status bar panel using Box, Label, Button, Spacer, Icon."""
    panel = Box(Orientation.HORIZONTAL, name="top-panel")
    panel.spacing = 8

    # Left: workspace indicator
    ws_icon = Icon("view-workspaces-symbolic")
    ws_icon.pixel_size = 16
    ws_label = Label("1: web", name="workspace-label")
    ws_label.add_style_class("status-label")

    left = Box(Orientation.HORIZONTAL, name="panel-left")
    left.spacing = 6
    left.append(ws_icon)
    left.append(ws_label)

    # Center: clock
    clock = Label("00:00", name="clock")
    clock.add_style_class("status-label")

    # Right: system tray
    vol_icon = Icon("audio-volume-high-symbolic")
    vol_icon.pixel_size = 14
    vol_label = Label("75%", name="volume-label")
    vol_label.add_style_class("status-label")

    net_icon = Icon("network-wireless-connected-symbolic")
    net_icon.pixel_size = 14

    batt_icon = Icon("battery-full-symbolic")
    batt_icon.pixel_size = 14
    batt_label = Label("100%", name="battery-label")
    batt_label.add_style_class("status-label")

    quit_btn = Button("⏻", name="quit-btn")
    quit_btn.add_style_class("quit-btn")
    quit_btn.connect("clicked", lambda: app.quit())

    right = Box(Orientation.HORIZONTAL, name="panel-right")
    right.spacing = 10
    right.append(vol_icon)
    right.append(vol_label)
    right.append(Separator(orientation=Orientation.VERTICAL))
    right.append(net_icon)
    right.append(Separator(orientation=Orientation.VERTICAL))
    right.append(batt_icon)
    right.append(batt_label)
    right.append(Separator(orientation=Orientation.VERTICAL))
    right.append(quit_btn)

    panel.append(left)
    panel.append(Spacer())
    panel.append(clock)
    panel.append(Spacer())
    panel.append(right)

    return panel


# ===========================================================================
# WIDGET SHOWCASE — Demonstrates every widget type
# ===========================================================================

def create_widget_showcase():
    """Create a comprehensive widget showcase."""
    content = Box(Orientation.VERTICAL, name="showcase")
    content.spacing = 16

    # --- Header ---
    title = Label("Widget Showcase", name="showcase-title")
    subtitle = Label(
        "Every widget in Nebula Shell",
        name="showcase-subtitle",
    )
    header = Box(Orientation.VERTICAL, name="showcase-header")
    header.spacing = 4
    header.append(title)
    header.append(subtitle)
    content.append(header)

    content.append(Separator(orientation=Orientation.HORIZONTAL))

    # --- Grid: 2 rows x 3 cols of widget cards ---
    grid = Grid(name="widget-grid")
    grid.row_spacing = 12
    grid.column_spacing = 12
    grid.rows = 2
    grid.columns = 3

    # Card 1: Label showcase
    grid.attach(create_label_card(), 0, 0)
    # Card 2: Button showcase
    grid.attach(create_button_card(), 1, 0)
    # Card 3: Entry showcase
    grid.attach(create_entry_card(), 2, 0)
    # Card 4: Icon showcase
    grid.attach(create_icon_card(), 0, 1)
    # Card 5: Stack showcase
    grid.attach(create_stack_card(), 1, 1)
    # Card 6: Overlay showcase
    grid.attach(create_overlay_card(), 2, 1)

    content.append(grid)
    content.append(Separator(orientation=Orientation.HORIZONTAL))

    # --- Bottom bar with spacer demo ---
    bottom = Box(Orientation.HORIZONTAL, name="bottom-bar")
    bottom.spacing = 8

    resize_grip = Label("⠿", name="resize-grip")
    resize_grip.add_style_class("resize-grip")

    mode_label = Label("Normal Mode", name="mode-label")
    mode_label.add_style_class("mode-label")

    hint = Label("Alt+1–9 to switch workspaces", name="hint")
    hint.add_style_class("hint")

    bottom.append(resize_grip)
    bottom.append(Separator(orientation=Orientation.VERTICAL))
    bottom.append(mode_label)
    bottom.append(Spacer())
    bottom.append(hint)

    content.append(bottom)

    return content


# ---------------------------------------------------------------------------
# Card: Labels
# ---------------------------------------------------------------------------

def create_label_card():
    """Demonstrate Label widget with various styles."""
    card = Box(Orientation.VERTICAL, name="label-card")
    card.add_style_class("widget-card")
    card.spacing = 8

    card_title = Label("Label")
    card_title.add_style_class("card-title")

    default = Label("Default label")
    default.add_style_class("card-body")

    bold = Label("Bold label")
    bold.add_style_class("card-body")
    bold.add_style_class("bold")

    small = Label("Small text, 11px")
    small.add_style_class("card-body")
    small.add_style_class("small")

    colored = Label("Colored text")
    colored.add_style_class("card-body")
    colored.add_style_class("accent")

    wrapped = Label(
        "This label wraps because it has a max width set via CSS",
        name="wrapped-label",
    )
    wrapped.add_style_class("card-body")
    wrapped.add_style_class("wrapped")

    card.append(card_title)
    card.append(default)
    card.append(bold)
    card.append(small)
    card.append(colored)
    card.append(wrapped)

    return card


# ---------------------------------------------------------------------------
# Card: Buttons
# ---------------------------------------------------------------------------

def create_button_card():
    """Demonstrate Button widget with variants."""
    card = Box(Orientation.VERTICAL, name="button-card")
    card.add_style_class("widget-card")
    card.spacing = 8

    card_title = Label("Button")
    card_title.add_style_class("card-title")

    default = Button("Default")
    default.add_style_class("btn")

    primary = Button("Primary")
    primary.add_style_class("btn")
    primary.add_style_class("btn-primary")
    primary.connect("clicked", lambda: logger.info("Primary clicked"))

    danger = Button("Danger")
    danger.add_style_class("btn")
    danger.add_style_class("btn-danger")
    danger.connect("clicked", lambda: logger.info("Danger clicked"))

    ghost = Button("Ghost")
    ghost.add_style_class("btn")
    ghost.add_style_class("btn-ghost")

    card.append(card_title)
    card.append(default)
    card.append(primary)
    card.append(danger)
    card.append(ghost)

    return card


# ---------------------------------------------------------------------------
# Card: Entry
# ---------------------------------------------------------------------------

def create_entry_card():
    """Demonstrate Entry widget."""
    card = Box(Orientation.VERTICAL, name="entry-card")
    card.add_style_class("widget-card")
    card.spacing = 8

    card_title = Label("Entry")
    card_title.add_style_class("card-title")

    search = Entry("", name="search-entry")
    search.placeholder = "Search..."

    cmd = Entry("", name="cmd-entry")
    cmd.placeholder = "Run command..."

    disabled = Entry("Read only", name="disabled-entry")
    disabled.add_style_class("disabled")

    card.append(card_title)
    card.append(search)
    card.append(cmd)
    card.append(disabled)

    return card


# ---------------------------------------------------------------------------
# Card: Icons
# ---------------------------------------------------------------------------

def create_icon_card():
    """Demonstrate Icon widget with different icon names."""
    card = Box(Orientation.VERTICAL, name="icon-card")
    card.add_style_class("widget-card")
    card.spacing = 8

    card_title = Label("Icon")
    card_title.add_style_class("card-title")

    icons = [
        ("folder-symbolic", "Folder"),
        ("document-symbolic", "Document"),
        ("emblem-favorite-symbolic", "Favorite"),
        ("weather-clear-symbolic", "Weather"),
        ("system-shutdown-symbolic", "Shutdown"),
    ]

    icon_row = Box(Orientation.HORIZONTAL, name="icon-row")
    icon_row.spacing = 12

    for icon_name, tooltip in icons:
        icon = Icon(icon_name)
        icon.pixel_size = 24
        icon.add_style_class("showcase-icon")
        icon_row.append(icon)

    card.append(card_title)
    card.append(icon_row)

    return card


# ---------------------------------------------------------------------------
# Card: Stack
# ---------------------------------------------------------------------------

def create_stack_card():
    """Demonstrate Stack widget — shows one child at a time."""
    card = Box(Orientation.VERTICAL, name="stack-card")
    card.add_style_class("widget-card")
    card.spacing = 8

    card_title = Label("Stack")
    card_title.add_style_class("card-title")

    stack = Stack(name="demo-stack")

    page1 = Box(Orientation.VERTICAL, name="stack-page-1")
    page1.spacing = 4
    p1_label = Label("Page 1: Notifications")
    p1_label.add_style_class("card-body")
    p1_sub = Label("3 unread messages")
    p1_sub.add_style_class("card-body")
    p1_sub.add_style_class("accent")
    page1.append(p1_label)
    page1.append(p1_sub)

    page2 = Box(Orientation.VERTICAL, name="stack-page-2")
    page2.spacing = 4
    p2_label = Label("Page 2: Calendar")
    p2_label.add_style_class("card-body")
    p2_date = Label("Sunday, July 5")
    p2_date.add_style_class("card-body")
    p2_date.add_style_class("accent")
    page2.append(p2_label)
    page2.append(p2_date)

    page3 = Box(Orientation.VERTICAL, name="stack-page-3")
    page3.spacing = 4
    p3_label = Label("Page 3: Media")
    p3_label.add_style_class("card-body")
    p3_track = Label("Now Playing: —")
    p3_track.add_style_class("card-body")
    p3_track.add_style_class("accent")
    page3.append(p3_label)
    page3.append(p3_track)

    stack.add_named("notifications", page1)
    stack.add_named("calendar", page2)
    stack.add_named("media", page3)
    stack.visible_child_name = "notifications"

    btn_row = Box(Orientation.HORIZONTAL, name="stack-nav")
    btn_row.spacing = 4

    prev_btn = Button("◀")
    prev_btn.add_style_class("btn")
    prev_btn.add_style_class("btn-sm")
    prev_btn.connect("clicked", lambda: navigate_stack(stack, -1))

    page_label = Label("1 / 3")
    page_label.add_style_class("card-body")
    page_label.name = "stack-page-label"

    next_btn = Button("▶")
    next_btn.add_style_class("btn")
    next_btn.add_style_class("btn-sm")
    next_btn.connect("clicked", lambda: navigate_stack(stack, 1))

    btn_row.append(prev_btn)
    btn_row.append(page_label)
    btn_row.append(next_btn)

    card.append(card_title)
    card.append(stack)
    card.append(btn_row)

    return card


_stack_pages = ["notifications", "calendar", "media"]


def navigate_stack(stack, direction):
    """Cycle through stack pages."""
    current = stack.visible_child_name
    idx = _stack_pages.index(current) if current in _stack_pages else 0
    idx = (idx + direction) % len(_stack_pages)
    stack.visible_child_name = _stack_pages[idx]


# ---------------------------------------------------------------------------
# Card: Overlay
# ---------------------------------------------------------------------------

def create_overlay_card():
    """Demonstrate Overlay widget — floating child on top of base."""
    card = Box(Orientation.VERTICAL, name="overlay-card")
    card.add_style_class("widget-card")
    card.spacing = 8

    card_title = Label("Overlay")
    card_title.add_style_class("card-title")

    overlay = Overlay(name="demo-overlay")
    overlay.default_alignment = OverlayAlignment.CENTER

    # Base layer
    base = Box(Orientation.VERTICAL, name="overlay-base")
    base.add_style_class("overlay-base")
    base.spacing = 4
    base_label = Label("Base Layer")
    base_label.add_style_class("card-body")
    base_sub = Label("Background content")
    base_sub.add_style_class("card-body")
    base_sub.add_style_class("dim")
    base.append(base_label)
    base.append(base_sub)

    # Floating badge
    badge = Label("3")
    badge.add_style_class("overlay-badge")

    overlay.append(base)
    overlay.set_child_alignment(badge, OverlayAlignment.TOP_RIGHT)

    card.append(card_title)
    card.append(overlay)

    return card


# ===========================================================================
# BOTTOM PANEL — Workspace bar
# ===========================================================================

def create_bottom_panel():
    """Create a bottom workspace indicator panel."""
    panel = Box(Orientation.HORIZONTAL, name="bottom-panel")
    panel.spacing = 6

    # Workspace indicators
    for i in range(1, 6):
        ws = Label(str(i), name=f"ws-{i}")
        ws.add_style_class("workspace")
        if i == 1:
            ws.add_style_class("active")
        panel.append(ws)

    panel.append(Spacer())

    # System info
    cpu_label = Label("CPU 12%", name="cpu-label")
    cpu_label.add_style_class("status-label")

    mem_label = Label("RAM 2.1G", name="mem-label")
    mem_label.add_style_class("status-label")

    panel.append(cpu_label)
    panel.append(Separator(orientation=Orientation.VERTICAL))
    panel.append(mem_label)

    return panel


# ===========================================================================
# MAIN WINDOW
# ===========================================================================

def create_window():
    """Create the main showcase window."""
    win = Window(name="showcase-window")
    win.title = "Nebula Shell"
    win.anchor = Anchor.TOP | Anchor.LEFT | Anchor.RIGHT
    win.layer = Layer.TOP
    win.keyboard_mode = KeyboardMode.EXCLUSIVE

    root = Box(Orientation.VERTICAL, name="root")
    root.spacing = 0

    root.append(create_top_panel())
    root.append(create_widget_showcase())
    root.append(create_bottom_panel())

    win.add(root)
    win.show()

    return win


# ===========================================================================
# ENTRY POINT
# ===========================================================================

window = create_window()

# Apply any CSS that was deferred (display wasn't ready during theme loading)
if hasattr(Theme, 'apply_pending_css'):
    Theme.apply_pending_css()

# ---------------------------------------------------------------------------
# Fade-in animation
# ---------------------------------------------------------------------------

fade_in = FadeAnimation(window, from_value=0.0, to_value=1.0)
fade_in.duration = 400
fade_in.start()

logger.info("Nebula Shell ready")

app.run()
