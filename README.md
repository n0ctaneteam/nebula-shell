# Nebula Shell

**Version: 1.0.0** | **Status: Stable Release**

A fast, stable, hackable, configurable, performant and lightweight desktop widgets and shell framework for Wayland.

---

# What is Nebula Shell?

Nebula Shell is a modern desktop shell framework for building:

- Panels
- Bars
- Dashboards
- Notifications
- Launchers
- OSDs
- Popups
- Control Centers
- Lock Screens
- Desktop Widgets
- Overlays

using a reactive architecture with clean APIs.

---

# Key Features

- **Reactive Architecture** — State changes propagate automatically
- **Performance First** — Optimized for smooth rendering
- **Clean API** — Python is the user interface
- **Layer Shell** — Native Wayland integration
- **Theming** — GTK CSS-based styling
- **Plugin System** — Extend the framework

---

# Language Stack

| Component | Technology |
|-----------|------------|
| Core | Vala |
| Toolkit | GTK4 |
| Layer Shell | gtk4-layer-shell |
| Public API | Python |
| Build System | Meson + Ninja |

---

# Quick Start

## Installation

```bash
git clone https://github.com/n0ctaneteam/nebula-shell.git
cd nebula-shell
meson setup builddir
ninja -C builddir
ninja -C builddir install
```

## Your First Panel

Create `panel.py`:

```python
import nebula_shell
from nebula_shell.ui import Box, Label, Orientation

app = nebula_shell.Application()

panel = Box(Orientation.HORIZONTAL)
panel.spacing = 8
panel.append(Label("Hello, Nebula Shell!"))

app.run()
```

Run it:

```bash
nebula-shell panel.py
```

---

# Documentation

- [Getting Started](docs/GETTING_STARTED.md) — Setup and first steps
- [API Reference](docs/API_REFERENCE.md) — Complete API documentation
- [Examples](docs/EXAMPLES.md) — Code examples and explanations
- [Architecture](docs/ARCHITECTURE.md) — Framework architecture
- [Contributing](docs/CONTRIBUTING.md) — Contribution guidelines
- [Implementation Rules](docs/IMPLEMENTATION_RULES.md) — Code rules

---

# Project Structure

```
nebula-shell/
├── core/           # Framework runtime (Vala)
├── bindings/       # Python bindings
├── widgets/        # Official widgets
├── services/       # System services
├── examples/       # Example projects
├── docs/           # Documentation
├── tools/          # Development tools
├── tests/          # Test suite
└── .agents/        # AI documentation
```

---

# Platform Support

| Platform | Status |
|----------|--------|
| Wayland | Supported |
| Hyprland | Primary |
| wlroots | Supported |
| X11 | Not supported |

---

# Design Philosophy

1. **Performance** — Never sacrifice for syntactic sugar
2. **Stability** — Predictable behavior
3. **Clean API** — Simple and Pythonic
4. **Maintainability** — Long-term focus
5. **Simplicity** — Avoid unnecessary complexity

---

# What Nebula Shell Is NOT

- Not a desktop environment
- Not a window manager
- Not a GTK wrapper
- Not another Quickshell clone

---

# Release Status

**v1.0.0 — Stable Release**

- All modules compile independently
- All unit tests pass (11/11)
- No TODO markers in public APIs
- Zero GTK types leak into public APIs
- Public API frozen for v1.0.0

See [CHANGELOG.md](CHANGELOG.md) for release details.

See [RELEASE_CHECKLIST.md](RELEASE_CHECKLIST.md) for release verification.

---

# License

Apache-2.0

---

# Contributing

See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

---

# Community

- [GitHub Issues](https://github.com/n0ctaneteam/nebula-shell/issues)
- [Discussions](https://github.com/n0ctaneteam/nebula-shell/discussions)
