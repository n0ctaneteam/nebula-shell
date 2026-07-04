# Nebula Shell — Implementation Rules

Version: 1.0.0

This document defines HOW code should be written.

It complements:

- AGENTS.md
- SKILL.md
- API.md
- ARCHITECTURE.md

These rules exist to keep NebulaShell consistent over many years.

---

# Rule 1

Never implement code before checking whether a similar abstraction already exists.

Prefer extending existing abstractions.

Do not duplicate concepts.

---

# Rule 2

Every class must have exactly ONE responsibility.

If a class description contains "and", it probably needs to be split.

Good

BatteryService

Panel

Animation

Bad

PanelManagerAnimationController

---

# Rule 3

Every directory owns one domain.

Example

core/

Application lifecycle

services/

System state

ui/

Rendering

animation/

Animations

ipc/

IPC

plugin/

Plugin system

Never mix domains.

---

# Rule 4

Managers own objects.

Objects never own managers.

Correct

PluginManager

↓

Plugin

Wrong

Plugin

↓

PluginManager

---

# Rule 5

Services own data.

Widgets never own data.

Correct

BatteryService

↓

BatteryWidget

Wrong

BatteryWidget

↓

Read battery directly

---

# Rule 6

Widgets never execute shell commands.

Shell commands belong inside services.

---

# Rule 7

Widgets never poll.

Never.

Preferred order

Wayland events

↓

Signals

↓

DBus

↓

File monitor

↓

Timer

Timers are last resort.

---

# Rule 8

GTK is private.

Users should not know NebulaShell uses GTK.

Never expose Gtk.Window.

Never expose Gtk.Widget.

Never expose Gtk.Box.

Wrap everything.

---

# Rule 9

gtk4-layer-shell is private.

Never expose its API.

Public API should describe behavior.

Not implementation.

---

# Rule 10

Every new feature begins with

API.md

before implementation.

Documentation first.

Implementation second.

---

# Rule 11

Never invent new naming patterns.

Reuse existing ones.

Manager

Service

Widget

Window

Panel

Popup

Overlay

Registry

Factory

Provider

Keep vocabulary small.

---

# Rule 12

Everything should have one owner.

Avoid shared mutable ownership.

---

# Rule 13

Singletons are allowed ONLY for framework-wide systems.

Examples

ThemeManager

PluginManager

ConfigManager

ServiceRegistry

Logger

Never create singleton widgets.

---

# Rule 14

Constructors should be lightweight.

Heavy initialization belongs inside

initialize()

---

# Rule 15

Shutdown must mirror initialization.

Example

initialize()

↓

load config

↓

start services

↓

load plugins

↓

create windows

Shutdown

↓

destroy windows

↓

unload plugins

↓

stop services

↓

save config

Reverse order.

---

# Rule 16

Every manager implements the same lifecycle.

initialize()

shutdown()

reload()

This consistency is intentional.

---

# Rule 17

Every service exposes

Properties

Signals

Methods

No rendering.

---

# Rule 18

Every widget exposes

Properties

Signals

Child management

Widgets should never expose service internals.

---

# Rule 19

Never create utility classes for unrelated functions.

Instead

config/

animation/

ipc/

theme/

utils/

Each module owns its utilities.

---

# Rule 20

Never optimize blindly.

Measure first.

Optimize second.

---

# Rule 21

Avoid inheritance unless it represents a true "is-a" relationship.

Prefer composition.

---

# Rule 22

Public APIs should read naturally.

Good

panel.show()

panel.hide()

panel.toggle()

Bad

panel.perform_visibility_operation()

---

# Rule 23

Methods perform actions.

Properties describe state.

Signals describe events.

Never mix these responsibilities.

---

# Rule 24

No magic.

If behavior is surprising,

it is wrong.

---

# Rule 25

Every subsystem should be replaceable.

Animation engine

Theme engine

Plugin loader

IPC transport

Should all be swappable internally.

---

# Rule 26

Never expose implementation-specific enums.

Expose NebulaShell enums.

Translate internally.

---

# Rule 27

Every public object should answer:

Who owns me?

Who destroys me?

Can I be subclassed?

Thread safe?

Stable API?

---

# Rule 28

Examples are mandatory.

If a public API has no example,

it is incomplete.

---

# Rule 29

Performance matters.

Avoid

temporary allocations

deep inheritance

dynamic lookups

reflection

when unnecessary.

---

# Rule 30

Memory allocations should be intentional.

Never allocate every frame.

Reuse where practical.

---

# Rule 31

Background work belongs in worker threads.

UI work belongs in the main thread.

Never cross them.

---

# Rule 32

Do not expose private implementation details to Python.

Python API should remain small and stable.

---

# Rule 33

Every feature should be testable.

Avoid tightly coupled code.

---

# Rule 34

Large systems should be built from many small classes.

Avoid "God Objects."

---

# Rule 35

Configuration is declarative.

Framework logic belongs in NebulaShell.

Not user configs.

---

# Rule 36

Plugins should depend only on public APIs.

Never internal headers.

---

# Rule 37

Compositor-specific code belongs inside compositor adapters.

Never sprinkle compositor checks across the codebase.

---

# Rule 38

Every source file should be understandable in isolation.

Small files are preferred.

---

# Rule 39

Comments explain WHY.

Code explains WHAT.

Never duplicate code in comments.

---

# Rule 40

The framework should always favor long-term maintainability over short-term convenience.

A small inconvenience today is preferable to years of technical debt.