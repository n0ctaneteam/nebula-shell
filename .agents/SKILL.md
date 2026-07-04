# Nebula Shell AI Skill

Version: 1.0.0

This document defines the engineering rules for Nebula Shell.

Every AI agent MUST read this document before generating code.

This document overrides assumptions made by language models.

If a generated implementation conflicts with this document, this document is always correct.

---

# Philosophy

Nebula Shell is a desktop shell framework.

It is NOT:

- another GTK wrapper
- another widget toolkit
- another desktop environment

NebulaShell provides abstractions for building desktop shell components.

GTK4 is an implementation detail.

The public API belongs to NebulaShell.

Never expose GTK types in public APIs unless there is no practical alternative.

---

# Project Priorities

Always optimize in this order.

1. Correctness

2. Stability

3. Performance

4. API consistency

5. Maintainability

6. Simplicity

7. Developer ergonomics

Never optimize for shorter code.

Never optimize for fewer lines.

Readable code is preferred.

---

# Architecture

NebulaShell is divided into layers.

Application

↓

Runtime

↓

Core Objects

↓

Reactive System

↓

Window System

↓

Services

↓

Widgets

↓

Python API

↓

Applications

Dependencies always flow downward.

Lower layers never depend on upper layers.

Widgets never depend on applications.

Services never depend on widgets.

Core never depends on services.

Never violate this rule.

---

# Public API

Everything intended for users belongs inside:

NebulaShell.*

Nothing outside the NebulaShell namespace is public.

Internal implementation details remain private.

Never expose internal helper classes.

---

# GTK

GTK is the renderer.

GTK is not the framework.

Do not leak GTK concepts into public APIs.

Bad:

Gtk.Window

Gtk.Box

Gtk.Label

Good:

NebulaShell.Window

NebulaShell.Panel

NebulaShell.Widget

NebulaShell.Container

Internally these may wrap GTK.

Users should rarely interact with GTK directly.

---

# Layer Shell

gtk4-layer-shell is internal.

Never expose gtk-layer-shell functions directly.

Provide NebulaShell abstractions instead.

Example:

Panel.anchor = TOP

instead of

gtk_layer_set_anchor(...)

---

# Wayland

NebulaShell is Wayland only.

Do not add X11 compatibility layers.

Do not write X11 workarounds.

Hyprland receives first-class support.

wlroots compositors should work without compositor-specific code whenever possible.

If compositor-specific behavior is required:

place it inside compositor adapters.

Never scatter compositor checks across the project.

---

# Object Ownership

Every object has exactly one owner.

Avoid shared mutable ownership.

Avoid global variables.

Prefer explicit ownership.

When ownership changes:

document it.

---

# Services

Services own state.

Examples:

BatteryService

AudioService

BluetoothService

MediaService

WorkspaceService

NotificationService

Widgets never own system state.

Widgets observe services.

---

# Widgets

Widgets display information.

Widgets do not fetch information.

Widgets should never:

poll

spawn processes

parse files

communicate with DBus

perform network requests

That belongs inside services.

---

# Polling

Polling is discouraged.

Preferred order:

signals

↓

file monitors

↓

DBus

↓

Wayland events

↓

timers

Timers are the last resort.

---

# Signals

Prefer signals over callbacks.

Prefer callbacks over polling.

Signals should describe events.

Examples:

battery_changed

volume_changed

workspace_changed

Never emit signals every frame.

---

# Properties

Properties represent state.

Signals represent changes.

Methods perform actions.

Never confuse these responsibilities.

---

# Threads

UI objects belong to the main thread.

Never mutate GTK objects from worker threads.

Background work belongs to worker threads.

Return results to the main loop.

---

# Async

Prefer async APIs.

Never block the UI thread.

Avoid synchronous IO.

---

# Errors

Recover when possible.

Crash only when continuing would corrupt state.

Use descriptive error messages.

Avoid silent failures.

---

# Logging

Logging is for developers.

Users should not see debug logs.

Provide log levels.

Trace

Debug

Info

Warning

Error

Fatal

---

# Performance

Every allocation matters.

Avoid:

temporary strings

temporary arrays

temporary objects

inside frequently executed code.

Cache when reasonable.

Do not cache prematurely.

---

# Memory

Prefer stack allocation when possible.

Avoid unnecessary heap allocations.

Avoid copies.

Reuse objects where practical.

---

# API Design

Every public API should answer:

Who owns it?

What does it do?

When is it valid?

Can it fail?

Thread safe?

Stable?

Every public API must have documentation.

---

# Naming

Classes

PascalCase

Methods

snake_case

Signals

snake_case

Properties

snake_case

Constants

UPPER_CASE

Private fields

_begin_with_underscore

---

# Files

One public class per file.

File name matches class name.

Window.vala

Panel.vala

Application.vala

Never place unrelated classes together.

---

# Composition

Prefer:

Panel

contains

Widgets

instead of

Panel

inherits

CustomPanel

Avoid inheritance trees.

Composition is preferred.

---

# Configuration

Configuration is Python.

Never invent a custom DSL.

Users write Python.

The framework executes Python.

---

# Python API

Python is first-class.

Never make Python feel like generated bindings.

The API should feel handwritten.

Simple.

Predictable.

Pythonic.

---

# Build System

Meson

Ninja

No CMake.

No Makefiles.

---

# Dependencies

Every dependency must justify its existence.

Ask:

Can GLib already do this?

Can GTK already do this?

Avoid unnecessary third-party libraries.

---

# Documentation

Every public class needs:

Purpose

Lifecycle

Properties

Signals

Methods

Examples

Notes

---

# Tests

Critical logic requires tests.

Widgets do not replace tests.

---

# Examples

Every feature should have an example.

If documentation exists without examples,

consider it incomplete.

---

# AI Behaviour

When implementing code:

Read architecture.

Read API.

Read style.

Read roadmap.

Then implement.

Never invent APIs.

Never rename existing APIs.

Never introduce breaking changes silently.

When unsure,

leave a TODO with explanation.

Do not guess.

---

# Pull Requests

Prefer many small pull requests.

Avoid huge rewrites.

Keep commits focused.

---

# Future

NebulaShell is expected to evolve.

The architecture should make adding:

new widgets

new services

new compositors

new bindings

possible without rewriting the core.

Always design for extension.

Never design for hacks.

---

# Final Rule

If there are two possible implementations,

choose the one that:

reduces long-term maintenance,

improves API consistency,

and keeps the architecture clean,

even if it requires slightly more work today.