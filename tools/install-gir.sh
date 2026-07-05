#!/usr/bin/env bash
set -euo pipefail

# Nebula Shell install helper
# Called by meson during `ninja install`
# Args: <gir_file> <datadir> <libdir>
# Env: DESTDIR, PREFIX

GIR_FILE="$1"
DATADIR="${2:-share}"
LIBDIR="${3:-lib}"
DESTDIR="${DESTDIR:-}"

GIR_DIR="${DESTDIR}/usr/${DATADIR}/gir-1.0"
TYPELIB_DIR="${DESTDIR}/usr/${LIBDIR}/girepository-1.0"

mkdir -p "$GIR_DIR"
mkdir -p "$TYPELIB_DIR"

cp "$GIR_FILE" "$GIR_DIR/NebulaShell-1.0.gir"

perl -0777 -i -pe 's/(<class name="Object"\s+)c:symbol-prefix/$1parent="GObject.Object"\nc:symbol-prefix/' \
    "$GIR_DIR/NebulaShell-1.0.gir"

g-ir-compiler "$GIR_DIR/NebulaShell-1.0.gir" -o "$TYPELIB_DIR/NebulaShell-1.0.typelib"
