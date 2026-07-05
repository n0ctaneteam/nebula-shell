#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Nebula Shell Installer
###############################################################################

PREFIX="/usr"
BUILDDIR="builddir"

info()  { printf '\033[1;34m:: %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m:: %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m:: %s\033[0m\n' "$*"; }
err()   { printf '\033[1;31m:: %s\033[0m\n' "$*" >&2; exit 1; }

###############################################################################
# Root Check
###############################################################################

# if [[ $EUID -ne 0 ]]; then
#     info "Requesting administrator privileges..."
#     exec sudo --preserve-env=PATH bash "$0" "$@"
# fi

###############################################################################
# Dependency Check
###############################################################################

###############################################################################
# Dependencies
###############################################################################

info "Checking dependencies..."

deps=(
    meson
    ninja
    vala
    gcc
    git
    python
    gtk4
    gtk4-layer-shell
    libgee
    json-glib
    gobject-introspection
)

missing=()

for pkg in "${deps[@]}"; do
    pacman -Q "$pkg" >/dev/null 2>&1 || missing+=("$pkg")
done

if (( ${#missing[@]} )); then
    warn "Missing packages:"
    printf '  %s\n' "${missing[@]}"

    info "Installing missing dependencies..."
    if ! pacman -S --needed --noconfirm "${missing[@]}"; then
        err "Failed to install required dependencies."
    fi

    ok "Dependencies installed."
else
    ok "All dependencies are already installed."
fi

###############################################################################
# Configure
###############################################################################

info "Configuring project..."

if [[ -d "$BUILDDIR" ]]; then
    rm -rf "$BUILDDIR" 2>/dev/null || sudo rm -rf "$BUILDDIR"
fi

meson setup "$BUILDDIR" \
    --prefix="$PREFIX" \
    --buildtype=plain \
    -Dwerror=false

###############################################################################
# Build
###############################################################################

info "Building..."

ninja -C "$BUILDDIR"

ok "Build complete."

###############################################################################
# Patch GIR (workaround for g-ir-scanner parent detection bug)
###############################################################################

info "Patching GIR (adding GObject.Object parent to NebulaShell.Object)..."

./patch-gir.sh "$BUILDDIR/core/nebula-shell" "$BUILDDIR/core/nebula-shell"

ok "GIR patched."

###############################################################################
# Tests
###############################################################################

info "Running tests..."

if ! meson test -C "$BUILDDIR" --print-errorlogs; then
    warn "Some tests failed."
fi

###############################################################################
# Install binaries
###############################################################################

info "Installing framework..."

ninja -C "$BUILDDIR" install

###############################################################################
# Python bindings
###############################################################################

info "Installing Python bindings..."

SITE_PACKAGES=$(python3 -c 'import site; print(site.getsitepackages()[0])')

rm -rf bindings/nebula_shell/__pycache__ 2>/dev/null || true
find bindings/nebula_shell -name '__pycache__' -exec rm -rf {} + 2>/dev/null || true

mkdir -p "$SITE_PACKAGES"

cp -r bindings/nebula_shell "$SITE_PACKAGES/"

###############################################################################
# Config
###############################################################################

info "Installing configuration..."

mkdir -p /etc/nebula-shell

if [[ ! -f /etc/nebula-shell/shell.py ]]; then
    install -Dm644 data/shell.py \
        /etc/nebula-shell/shell.py
else
    warn "/etc/nebula-shell/shell.py already exists."
    warn "Keeping existing configuration."
fi

###############################################################################
# XDG Autostart
###############################################################################

info "Installing autostart entry..."

install -Dm644 \
    data/nebula-shell.desktop \
    /usr/share/xdg/autostart/nebula-shell.desktop

###############################################################################
# Finished
###############################################################################

ok ""
ok "Nebula Shell installed successfully."
ok ""
ok "Configuration : /etc/nebula-shell"
ok "Python module : ${SITE_PACKAGES}/nebula_shell"
ok "Prefix        : ${PREFIX}"
ok ""