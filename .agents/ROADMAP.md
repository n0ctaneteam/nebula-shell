# Nebula Shell — AUR Packaging Roadmap

Version: 1.0.0

This roadmap covers packaging Nebula Shell for AUR, renaming the config file,
adding a welcome config, and setting up autostart.

---

## Phase 1: Rename config.py → shell.py

**Status:** `[x] Done`

Rename the configuration file from `config.py` to `shell.py` across the entire
codebase. Hard rename — no backwards compatibility fallback.

### Files to modify

| File | Changes |
|------|---------|
| `core/nebula-shell/config_manager.vala` | 3 path strings + docstring |
| `core/nebula-shell/cli_run.vala` | 4 path strings + docstrings |
| `core/nebula-shell/cli_dev.vala` | 4 path strings + docstrings |
| `core/nebula-shell/cli_doctor.vala` | 4 path strings |
| `core/nebula-shell/cli_init.vala` | file creation path + docstring |
| `core/nebula-shell/cli_format.vala` | candidate filename in list |
| `core/nebula-shell/config_reload.vala` | docstring example |
| `core/nebula-shell/hot_reload.vala` | docstring example |
| `docs/GETTING_STARTED.md` | example code |

### Search paths after rename

1. `~/.config/nebula-shell/shell.py`
2. `$XDG_CONFIG_HOME/nebula-shell/shell.py`
3. `/etc/nebula-shell/shell.py`

### Acceptance criteria

- [x] All `config.py` references replaced with `shell.py`
- [x] No regressions in existing functionality
- [x] Build passes with zero Vala warnings
- [x] All 11 tests pass

---

## Phase 2: Welcome Popup shell.py

**Status:** `[x] Done`

Create a default configuration file that gets installed at
`/etc/nebula-shell/shell.py`. This serves as the system-wide default and
a showcase of available widgets.

### Requirements

- Demonstrates core widgets: Label, Button, Box, Stack, Grid, Overlay
- Shows Separator and Spacer usage
- Includes basic CSS styling (dark theme, rounded corners, shadows)
- Shows reactive property binding example
- Shows animation example (fade-in)
- Provides helpful comments explaining each section
- Acts as a working first-run experience

### File location

`/etc/nebula-shell/shell.py` (installed by PKGBUILD)

### Acceptance criteria

- [x] Welcome config is syntactically valid Python
- [x] Imports work with the `nebula_shell` package
- [x] Showcases at least 6 different widget types
- [x] Includes inline CSS styling
- [x] Has clear comments explaining the structure

---

## Phase 3: XDG Autostart

**Status:** `[x] Done`

Create an XDG autostart `.desktop` file so Nebula Shell starts automatically
on Wayland login sessions.

### Desktop file

```
~/.config/autostart/nebula-shell.desktop
```

### Contents

```ini
[Desktop Entry]
Type=Application
Name=Nebula Shell
Comment=Desktop shell framework for Wayland
Exec=/usr/bin/nebula-shell run
Icon=nebula-shell
Terminal=false
Categories=System;
OnlyShowIn=Hyprland;sway;river;wlroots;
ConditionEnvironment=WAYLAND_DISPLAY
X-GNOME-Autostart-enabled=true
```

### File location in source tree

`data/nebula-shell.desktop`

### Meson install

```meson
install_data(
  'data/nebula-shell.desktop',
  install_dir: get_option('datadir') / 'xdg' / 'autostart',
)
```

### Acceptance criteria

- [x] Desktop file is valid XDG autostart format
- [x] Only starts under Wayland compositors
- [x] Only shows under supported compositors (Hyprland, sway, river, wlroots)
- [x] Installed to correct XDG autostart directory

---

## Phase 4: PKGBUILD for AUR

**Status:** `[x] Done`

Create a git-based PKGBUILD for Arch User Repository.

### Package metadata

```
pkgname=nebula-shell
pkgver=1.0.0
pkgrel=1
pkgdesc="Fast, lightweight desktop widgets and shell framework for Wayland"
arch=('x86_64' 'aarch64')
url="https://github.com/n0ctaneteam/nebula-shell"
license=('Apache-2.0')
```

### Dependencies

**makedepends:**
- meson
- ninja
- vala
- gcc
- gtk4
- gtk4-layer-shell
- libgee
- json-glib
- python
- gobject-introspection

**depends:**
- gtk4
- gtk4-layer-shell
- libgee
- json-glib
- python
- gobject-introspection

**optdepends:**
- python: for running Python shell configurations

### Build functions

- `pkgver()`: derives version from git tags
- `build()`: meson setup + ninja
- `check()`: meson test
- `package()`: ninja install + Python bindings install + config dir + default shell.py + .desktop file

### post_install

1. Create `/etc/nebula-shell/` if not exists
2. Install default `shell.py` if not already present
3. Install XDG autostart `.desktop` to `~/.config/autostart/`

### pre_install / post_remove

1. Remove old config files (migration from `config.py` if present)

### File location

`PKGBUILD` (root of repo)

### Acceptance criteria

- [x] PKGBUILD builds successfully with `makepkg -si`
- [x] All dependencies are correctly specified
- [x] Binary installed to `/usr/bin/nebula-shell`
- [x] Library installed to `/usr/lib/`
- [x] GIR/typelib installed to proper GI directories
- [x] Python bindings installed to `/usr/lib/python3.x/site-packages/nebula_shell/`
- [x] Default shell.py installed to `/etc/nebula-shell/shell.py`
- [x] Autostart .desktop installed
- [x] All 11 tests pass during build

---

## Phase 5: Build → QA → Optimize → Notify

**Status:** `[x] Done`

After each phase, run the full pipeline:

1. **Build**: Clean rebuild (`rm -rf builddir && meson setup builddir && ninja -C builddir`)
2. **QA**: Deploy qa-tester sub-agent to verify correctness
3. **Optimize**: Deploy optimizer sub-agent with embedded quick QA
4. **Notify**: `notify-send -t 3000 -a "opencode" -i system-run "Completed: <phase>"`
5. **Repeat**: Move to next phase

### Pipeline per phase

```
build
  ↓
qa-tester (sub-agent)
  ↓
optimizer (sub-agent, includes quick QA)
  ↓
notify-send "Completed: <phase name>"
  ↓
next phase
```

---

## Summary

| Phase | Description | Status |
|-------|-------------|--------|
| 1 | Rename config.py → shell.py | `[x]` |
| 2 | Welcome popup shell.py | `[x]` |
| 3 | XDG autostart .desktop | `[x]` |
| 4 | PKGBUILD for AUR | `[x]` |
| 5 | Build → QA → Optimize → Notify loop | `[x]` |

---

## Notes

- Config file is now `shell.py` (hard rename, no fallback)
- Autostart uses XDG .desktop file (not shell RC file modification)
- PKGBUILD is git-based (pulls from GitHub tags)
- All phases follow: build → qa → optimize → notify → next
