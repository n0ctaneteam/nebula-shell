#!/usr/bin/env bash
set -euo pipefail

# Nebula Shell — Local Install Script
# Builds and installs Nebula Shell to the system without AUR/makepkg.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="${SCRIPT_DIR}/builddir"
PREFIX="${PREFIX:-/usr/local}"
PYTHON_SITE="$(python3 -c 'import site; print(site.getsitepackages()[0])')"

info()  { printf '\033[1;34m:: %s\033[0m\n' "$*"; }
ok()    { printf '\033[1;32m:: %s\033[0m\n' "$*"; }
warn()  { printf '\033[1;33m:: %s\033[0m\n' "$*"; }
err()   { printf '\033[1;31m:: %s\033[0m\n' "$*" >&2; exit 1; }

# ---------------------------------------------------------------------------
# Parse arguments
# ---------------------------------------------------------------------------

ACTION="install"
SKIP_BUILD=false
SKIP_TESTS=false

for arg in "$@"; do
    case "$arg" in
        --build-only)   ACTION="build" ;;
        --prefix=*)     PREFIX="${arg#*=}" ;;
        --skip-tests)   SKIP_TESTS=true ;;
        --help|-h)
            echo "Usage: $0 [OPTIONS]"
            echo ""
            echo "Options:"
            echo "  --build-only      Build only, do not install"
            echo "  --prefix=PATH     Install prefix (default: /usr/local)"
            echo "  --skip-tests      Skip test suite"
            echo "  --help, -h        Show this help"
            exit 0
            ;;
        *) err "Unknown option: $arg" ;;
    esac
done

# ---------------------------------------------------------------------------
# Preflight checks
# ---------------------------------------------------------------------------

info "Nebula Shell — Local Install"
echo "  Prefix:   ${PREFIX}"
echo "  Python:   ${PYTHON_SITE}"
echo ""

for cmd in meson ninja valac python3; do
    command -v "$cmd" &>/dev/null || err "'$cmd' not found. Install build dependencies first."
done

# ---------------------------------------------------------------------------
# Build
# ---------------------------------------------------------------------------

info "Configuring..."
rm -rf "${BUILD_DIR}"
meson setup "${BUILD_DIR}" "${SCRIPT_DIR}" \
    --prefix="${PREFIX}" \
    --buildtype=plain \
    -Dwerror=false \
    2>&1 | tail -3

info "Building..."
ninja -C "${BUILD_DIR}" 2>&1 | grep -E '^\[|error|FAILED' | tail -5

ok "Build complete"

# ---------------------------------------------------------------------------
# Test
# ---------------------------------------------------------------------------

if [ "${SKIP_TESTS}" = false ]; then
    info "Running tests..."
    if meson test -C "${BUILD_DIR}" 2>&1 | grep -q 'Ok:.*11'; then
        ok "All 11 tests passed"
    else
        err "Some tests failed"
    fi
fi

if [ "${ACTION}" = "build" ]; then
    ok "Build-only mode. Skipping install."
    exit 0
fi

# ---------------------------------------------------------------------------
# Install
# ---------------------------------------------------------------------------

info "Installing to ${PREFIX}..."
sudo DESTDIR="" ninja -C "${BUILD_DIR}" install

# ---------------------------------------------------------------------------
# Python bindings
# ---------------------------------------------------------------------------

info "Installing Python bindings..."
sudo install -dm755 "${PYTHON_SITE}"
sudo cp -r "${SCRIPT_DIR}/bindings/nebula_shell" "${PYTHON_SITE}/"
ok "Python bindings installed to ${PYTHON_SITE}/nebula_shell"

# ---------------------------------------------------------------------------
# System config directory
# ---------------------------------------------------------------------------

info "Setting up /etc/nebula-shell/..."
sudo install -dm755 /etc/nebula-shell

if [ ! -f /etc/nebula-shell/shell.py ]; then
    sudo install -Dm644 "${SCRIPT_DIR}/data/shell.py" /etc/nebula-shell/shell.py
    ok "Default shell.py installed"
else
    warn "shell.py already exists, skipping (use --force to overwrite)"
fi

# ---------------------------------------------------------------------------
# XDG autostart (user-level)
# ---------------------------------------------------------------------------

AUTOSTART_DIR="${HOME}/.config/autostart"
info "Installing XDG autostart to ${AUTOSTART_DIR}..."
install -dm755 "${AUTOSTART_DIR}"
install -Dm644 "${SCRIPT_DIR}/data/nebula-shell.desktop" "${AUTOSTART_DIR}/nebula-shell.desktop"
ok "Autostart desktop file installed"

# ---------------------------------------------------------------------------
# Done
# ---------------------------------------------------------------------------

echo ""
ok "Installation complete!"
echo ""
echo "  To run:  nebula-shell run"
echo "  To dev:  nebula-shell dev"
echo "  Config:  /etc/nebula-shell/shell.py (system)"
echo "           ~/.config/nebula-shell/shell.py (user)"
echo ""
