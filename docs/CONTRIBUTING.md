# Contributing to Nebula Shell

Version: 0.1.0

Guidelines for contributing to the Nebula Shell project.

---

# Table of Contents

- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Code Style](#code-style)
- [Architecture Rules](#architecture-rules)
- [API Design](#api-design)
- [Documentation](#documentation)
- [Testing](#testing)
- [Pull Requests](#pull-requests)
- [Issue Reporting](#issue-reporting)

---

# Getting Started

1. Fork the repository
2. Clone your fork
3. Create a feature branch
4. Make your changes
5. Submit a pull request

---

# Development Setup

## Prerequisites

- Linux with Wayland compositor
- Vala compiler
- Meson + Ninja
- Python 3.10+
- GTK4 development files
- gtk4-layer-shell development files

## Building

```bash
git clone https://github.com/n0ctaneteam/nebula-shell.git
cd nebula-shell
meson setup builddir
ninja -C builddir
```

## Running Tests

```bash
ninja -C builddir test
```

---

# Code Style

## Vala

- One public class per file
- File name matches class name
- Use NebulaShell namespace
- Follow PascalCase for classes
- Follow snake_case for methods, properties, signals
- Follow UPPER_CASE for constants
- Prefix private fields with underscore

## Python

- Follow PEP 8
- Use type hints where appropriate
- Write docstrings for public functions

## Files

```
core/nebula-shell/
├── application.vala      # Application class
├── window.vala           # Window base class
├── widget.vala           # Widget base class
├── container.vala        # Container base class
├── label.vala            # Label widget
├── button.vala           # Button widget
└── ...
```

---

# Architecture Rules

## Layer Dependencies

Dependencies flow downward only:

```
Application
    ↓
Widgets
    ↓
Services
    ↓
Reactive System
    ↓
Core Runtime
    ↓
GTK4 + gtk4-layer-shell
    ↓
Wayland
```

**Never violate this rule.**

## GTK Exposure

GTK is private. Never expose GTK types in public APIs.

Bad:
```vala
public Gtk.Window get_window ();
```

Good:
```vala
public void show ();
public void hide ();
```

## Layer Shell

gtk4-layer-shell is private. Never expose its API.

Bad:
```vala
gtk_layer_set_anchor(...)
```

Good:
```vala
panel.anchor = Anchor.TOP;
```

## State Ownership

- Services own state
- Widgets observe services
- Widgets never own system state

## Polling

Polling is discouraged. Preferred order:

1. Signals
2. File monitors
3. DBus
4. Wayland events
5. Timers (last resort)

---

# API Design

## Public API Rules

1. Every public API must be documented
2. Every public API must have examples
3. Never invent new naming patterns
4. Prefer composition over inheritance
5. Properties describe state
6. Signals describe events
7. Methods perform actions

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Class | PascalCase | `BatteryService` |
| Method | snake_case | `get_volume()` |
| Property | snake_case | `is_connected` |
| Signal | snake_case | `volume_changed` |
| Constant | UPPER_CASE | `MAX_RETRIES` |
| Private | _underscore | `_internal_value` |

## Stability

- Public API: Stable
- Internal API: Unstable
- Private: May change at any time

Breaking changes require a major version bump.

---

# Documentation

## Required Documentation

Every public class needs:

1. **Purpose** — What it does
2. **Lifecycle** — How it's created and destroyed
3. **Properties** — All public properties
4. **Signals** — All public signals
5. **Methods** — All public methods
6. **Examples** — Working code examples
7. **Notes** — Important caveats

## Vala Documentation

Use Valadoc comments:

```vala
/**
 * Brief description.
 *
 * Longer description if needed.
 *
 * Example:
 *   var widget = new Widget ();
 *   widget.show ();
 */
public class Widget : GLib.Object {
```

## Python Documentation

Use docstrings:

```python
def get_volume():
    """Get the current audio volume.

    Returns:
        int: Volume level (0-100)
    """
    pass
```

---

# Testing

## Test Requirements

- Critical logic requires tests
- Widgets do not replace tests
- Every feature should be testable

## Running Tests

```bash
ninja -C builddir test
```

## Writing Tests

- Test one thing per test
- Use descriptive test names
- Clean up after tests
- Mock external dependencies

---

# Pull Requests

## Process

1. Create feature branch from main
2. Make focused changes
3. Write or update tests
4. Update documentation
5. Run linter and tests
6. Submit PR with clear description

## PR Guidelines

- One feature per PR
- Keep changes focused
- Write clear commit messages
- Include tests for new features
- Update API documentation if needed
- Follow existing code style

## Commit Messages

Use conventional commits:

```
feat: add battery service
fix: resolve memory leak in animation
docs: update API reference
test: add widget unit tests
refactor: simplify container logic
```

---

# Issue Reporting

## Bug Reports

Include:

- Steps to reproduce
- Expected behavior
- Actual behavior
- Environment details
- Logs if applicable

## Feature Requests

Include:

- Use case description
- Proposed API
- Examples
- Alternatives considered

---

# Code of Conduct

- Be respectful
- Focus on technical merit
- Welcome newcomers
- Provide constructive feedback

---

# Questions?

Open an issue or start a discussion on GitHub.
