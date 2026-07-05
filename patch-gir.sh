#!/bin/sh
# Workaround: g-ir-scanner fails to detect GObject.Object as the parent of
# NebulaShell.Object even though the C struct has GObject parent_instance.
# This script patches the installed GIR and regenerates the typelib.
set -e

GIR_DIR="${1:-/usr/share/gir-1.0}"
TYPELIB_DIR="${2:-/usr/lib/girepository-1.0}"

GIR_FILE="$GIR_DIR/NebulaShell-1.0.gir"
TYPELIB_FILE="$TYPELIB_DIR/NebulaShell-1.0.typelib"

if [ ! -f "$GIR_FILE" ]; then
    echo "Error: $GIR_FILE not found" >&2
    exit 1
fi

# Check if parent is already set
if grep -q 'class name="Object" parent=' "$GIR_FILE"; then
    echo "GIR already has parent attribute, skipping patch."
else
    echo "Patching GIR to add parent=\"GObject.Object\"..."
    perl -0i -pe 's/<class name="Object"\n           c:symbol-prefix/<class name="Object"\n           parent="GObject.Object"\n           c:symbol-prefix/' "$GIR_FILE"
    echo "GIR patched."
fi

# Regenerate typelib from patched GIR
if command -v g-ir-compiler >/dev/null 2>&1; then
    echo "Regenerating typelib..."
    g-ir-compiler "$GIR_FILE" -o "$TYPELIB_FILE"
    echo "Typelib regenerated."
else
    echo "Warning: g-ir-compiler not found, typelib not regenerated." >&2
fi

echo "Done."
