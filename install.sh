#!/usr/bin/env bash
set -euo pipefail

###############################################################################
# Nebula Shell Installer
#
# Usage:
#   ./install.sh           # Build + install
#   ./install.sh --dev     # Build only (no install, for development)
#   ./install.sh --clean   # Clean build artifacts
###############################################################################

PREFIX="/usr"
BUILDDIR="/tmp/nebula-build"
MODE="install"

info()  { printf '\033[1;34m:: %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m:: %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m:: %s\033[0m\n' "$*"; }
err()   { printf '\033[1;31m:: %s\033[0m\n' "$*" >&2; exit 1; }

###############################################################################
# Parse arguments
###############################################################################

for arg in "$@"; do
    case "$arg" in
        --dev)    MODE="dev" ;;
        --clean)  MODE="clean" ;;
        --help|-h)
            echo "Usage: $0 [--dev|--clean]"
            echo "  (default) Build and install to $PREFIX"
            echo "  --dev      Build only (no system install)"
            echo "  --clean    Remove build artifacts"
            exit 0
            ;;
        *) err "Unknown argument: $arg" ;;
    esac
done

###############################################################################
# Clean mode
###############################################################################

if [[ "$MODE" == "clean" ]]; then
    info "Cleaning build artifacts..."
    rm -rf "$BUILDDIR"
    ok "Done."
    exit 0
fi

###############################################################################
# Dependency check
###############################################################################

info "Checking dependencies..."

deps=(
    meson
    ninja
    vala
    gcc
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
# Configure (as current user)
###############################################################################

info "Configuring project..."

# Clean previous build to avoid stale/root-owned artifacts
if [[ -d "$BUILDDIR" ]]; then
    rm -rf "$BUILDDIR"
fi

meson setup "$BUILDDIR" \
    --prefix="$PREFIX" \
    --buildtype=plain \
    -Dwerror=false

###############################################################################
# Build (as current user — never root)
###############################################################################

info "Building..."

ninja -C "$BUILDDIR"

ok "Build complete."

###############################################################################
# Tests
###############################################################################

info "Running tests..."

if ! meson test -C "$BUILDDIR" --print-errorlogs; then
    warn "Some tests failed."
fi

###############################################################################
# Install (skip in dev mode)
###############################################################################

if [[ "$MODE" == "dev" ]]; then
    ok ""
    ok "Build complete (dev mode)."
    ok ""
    ok "Binary: $BUILDDIR/core/nebula-shell/nebula-shell"
    ok "Run with: GI_TYPELIB_PATH=$BUILDDIR/core/nebula-shell PYTHONPATH=/home/n0ctanedev/Projects/nebula-shell/ LD_PRELOAD=/usr/lib/libgtk4-layer-shell.so $BUILDDIR/core/nebula-shell/nebula-shell run"
    ok ""
    exit 0
fi

###############################################################################
# Install binaries (needs root for /usr)
###############################################################################

info "Installing framework..."

if [[ $EUID -ne 0 ]]; then
    sudo ninja -C "$BUILDDIR" install
else
    ninja -C "$BUILDDIR" install
fi

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
    install -Dm644 data/shell.py /etc/nebula-shell/shell.py
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
ok "Run with: nebula-shell run"
ok ""
