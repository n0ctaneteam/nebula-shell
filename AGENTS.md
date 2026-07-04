# AGENTS.md

> Primary AI entry point for the Nebula Shell repository.
>
> Every coding agent MUST read this file before making any changes.

---

# Project

Name: Nebula Shell

Repository:
https://github.com/n0ctaneteam/nebula-shell

Language Stack

- Core: Vala
- Toolkit: GTK4
- Layer Shell: gtk4-layer-shell
- User API: Python (via GObject Introspection)
- Build System: Meson + Ninja

License

Apache-2.0

---

# Project Vision

Nebula Shell is a fast, stable, hackable, configurable, performant and lightweight desktop widgets and shell framework for Wayland.

Nebula Shell is **NOT**:

- a desktop environment
- a window manager
- a GTK wrapper
- another Quickshell clone

Nebula Shell is a framework that allows developers to build desktop components such as:

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

using a modern reactive architecture.

GTK is considered an implementation detail and should not leak into the public API.

---

# Primary Design Goals

Priority order:

1. Performance
2. Stability
3. Clean API
4. Maintainability
5. Simplicity
6. Extensibility
7. Developer Experience

Never sacrifice performance for syntactic sugar.

---

# Supported Platforms

Official:

- Wayland

Primary compositor:

- Hyprland

Supported:

- wlroots compositors

Experimental support may be added later for other Wayland compositors.

X11 is NOT supported.

---

# Public Languages

Internal implementation:

- Vala

Public scripting API:

- Python

Bindings are generated through GObject Introspection.

Do not maintain handwritten Python bindings.

---

# Repository Structure

.agents/
    AI documentation

core/
    Framework runtime

bindings/
    Generated bindings

widgets/
    Official widgets

services/
    System services

examples/
    Example projects

docs/
    Human documentation

tools/
    Development tools

tests/
    Test suite

---

# AI Documentation

Every coding agent MUST read these documents before generating code.

Read order:

1. .agents/SKILL.md
2. .agents/ARCHITECTURE.md
3. .agents/API.md
4. .agents/STYLE.md
5. .agents/ROADMAP.md

If documentation conflicts:

SKILL.md wins.

---

# Architectural Principles

Never expose GTK directly.

Never expose gtk-layer-shell directly.

Every public API must belong to the NebulaShell namespace.

Widgets should not poll.

Services own state.

Widgets observe services.

Prefer signals over polling.

Prefer composition over inheritance.

Every public API should remain stable whenever possible.

---

# Performance Rules

Avoid unnecessary allocations.

Avoid polling loops.

Prefer event-driven architecture.

Never allocate every frame.

Avoid unnecessary redraws.

Lazy initialize expensive objects.

Do not perform blocking IO on the UI thread.

---

# AI Rules

When implementing features:

1.
Read the relevant specification.

2.
Follow STYLE.md.

3.
Follow API.md exactly.

4.
Never invent public APIs.

5.
If an API is missing:

Create a proposal instead of implementing it.

6.
Do not introduce breaking API changes without updating documentation.

---

# Development Order

Core runtime

↓

Reactive system

↓

Window system

↓

Services

↓

Python API

↓

CLI

↓

Official widgets

---

# Code Quality

Every public class must have:

- documentation
- examples
- comments where necessary

Every commit should improve readability.

Prefer explicit code over clever code.

---

# Long-Term Goal

Nebula Shell should become a professional-grade desktop shell framework with a clean architecture, predictable APIs and excellent AI-assisted development support.

Documentation is considered part of the source code.