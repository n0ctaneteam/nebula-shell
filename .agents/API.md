# Nebula Shell Public API Specification

Version: 1.0.0

Status: Stable

This document defines the public API of Nebula Shell.

Only APIs documented here are considered public.

Everything else is internal.

---

# Design Goals

The API must be:

- Stable
- Predictable
- Minimal
- Pythonic
- Reactive
- Easy to extend

The public API must never expose GTK implementation details.

GTK is an implementation detail.

---

# Root Namespace

Python

```python
import nebula_shell
```

Everything begins from this namespace.

---

# Package Layout

nebula_shell

├── app

├── ui

├── services

├── animation

├── config

├── ipc

├── plugin

├── utils

└── version

Every module has one responsibility.

---

# Application

Purpose

Owns the application lifecycle.

Responsibilities

Initialize runtime

Initialize GTK

Load configuration

Load plugins

Start event loop

Shutdown cleanly

Public API

```python
app = nebula_shell.Application()

app.run()
```

Properties

config

runtime

plugin_manager

Methods

run()

quit()

reload()

Signals

started

stopping

reloaded

---

# Window

Base window object.

Every visible object inherits from Window.

Window is abstract.

Concrete windows:

Panel

Popup

Overlay

Methods

show()

hide()

toggle()

close()

destroy()

Properties

visible

width

height

monitor

anchor

layer

exclusive

keyboard_mode

---

# Panel

Represents a desktop panel.

Panel inherits Window.

Example

```python
panel = Panel()

panel.show()
```

Responsibilities

Reserve screen space.

Anchor to screen edge.

Contain widgets.

---

# Popup

Temporary floating window.

Examples

Launcher

Calendar

Power menu

Network menu

Methods

open()

close()

toggle()

Signals

opened

closed

---

# Overlay

Floating window that does not reserve space.

Used for

Notifications

OSD

HUD

Lock screen

---

# Widget

Base class of all widgets.

Widgets never fetch data.

Widgets display data.

Methods

show()

hide()

destroy()

Properties

visible

parent

style_classes

tooltip

Widgets may contain children.

---

# Container

A widget capable of containing child widgets.

Examples

Box

Grid

Stack

Flow

Methods

append()

prepend()

remove()

clear()

children()

---

# Services

Services provide system state.

Examples

Battery

Audio

Bluetooth

Media

Workspace

Notification

Network

Services are singleton objects.

Widgets subscribe to services.

Never poll from widgets.

---

# Service API

Example

```python
battery = BatteryService.default()

battery.percentage

battery.charging
```

Signals

changed

Properties

read-only whenever possible.

---

# Binding

Represents reactive data binding.

Purpose

Automatically synchronize state.

Example

```python
label.bind(
    battery.percentage,
    lambda p: f"{p}%"
)
```

Binding owns subscriptions.

Widgets do not manage signal lifetimes manually.

---

# Animation

Animation is declarative.

Example

```python
Animation.fade(widget)
```

Future animations

fade

slide

scale

rotate

blur

shake

bounce

Animation engine details remain private.

---

# Theme

GTK CSS is the official theme language.

Public API

Theme.load()

Theme.reload()

Theme.current()

---

# Config

Configuration is written in Python.

Example

```python
from nebula_shell import *

app = Application()

panel = Panel()

panel.show()

app.run()
```

No custom DSL.

No YAML.

No JSON.

---

# Plugin

Plugins extend NebulaShell.

Plugin API is versioned.

Plugins cannot modify internal runtime state directly.

Lifecycle

load

enable

disable

unload

---

# IPC

NebulaShell provides IPC.

Transport is internal.

Public API

```python
IPC.send()

IPC.listen()
```

Underlying transport may change.

Applications should never depend on implementation.

---

# Logger

Levels

Trace

Debug

Info

Warning

Error

Fatal

Public API

```python
Logger.info("Hello")
```

---

# Runtime

Internal object.

Not part of stable public API.

Applications should not access Runtime directly.

---

# GTK Exposure Policy

GTK types must never appear in public APIs unless absolutely required.

If a GTK object must be returned,

wrap it inside a NebulaShell abstraction.

---

# Versioning

Semantic Versioning.

MAJOR

Breaking API.

MINOR

New features.

PATCH

Bug fixes.

---

# Stability

Public API

Stable

Internal API

Unstable

Private classes

May change at any time.

---

# Future Modules

The following modules are planned.

notifications

hyprland

wallpaper

launcher

dashboard

clipboard

media

power

workspace

bluetooth

audio

network

battery

storage

weather

These modules should be implemented without breaking the existing API.

---

# Rule

Every new public class added to NebulaShell must first be documented here before implementation begins.

Documentation defines the API.

Code implements it.

Never do the reverse.