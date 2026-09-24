#!/usr/bin/env bash
#
# Assemble a LineageOS-recovery / TWRP-flashable installer zip from a built
# TWRP boot image.
#
# Usage:
#   tools/mkzip.sh <path-to-boot.img> [output.zip]
#
# The resulting zip contains the recovery-as-boot installer (see
# installer/META-INF/.../update-binary) which dd's boot.img to the active slot.
#
set -euo pipefail

REPO_DIR="$(cd "$(dirname "$0")/.." && pwd)"
INSTALLER_DIR="$REPO_DIR/installer"

BOOT_IMG="${1:-}"
if [ -z "$BOOT_IMG" ] || [ ! -f "$BOOT_IMG" ]; then
    echo "usage: $0 <path-to-boot.img> [output.zip]" >&2
    exit 1
fi

OUT_ZIP="${2:-$REPO_DIR/TWRP-mh2lm-$(date +%Y%m%d).zip}"

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

# Layout the zip contents.
cp -a "$INSTALLER_DIR/." "$STAGE/"
cp "$BOOT_IMG" "$STAGE/boot.img"
chmod 0755 "$STAGE/META-INF/com/google/android/update-binary"

# Build the zip (store the top level; keep update-binary permissions).
rm -f "$OUT_ZIP"
if command -v zip >/dev/null 2>&1; then
    ( cd "$STAGE" && zip -r -X "$OUT_ZIP" META-INF boot.img >/dev/null )
else
    # Fallback: build the zip with python, preserving the update-binary exec bit.
    ( cd "$STAGE" && python3 - "$OUT_ZIP" <<'PY'
import os, sys, zipfile, stat
out = sys.argv[1]
with zipfile.ZipFile(out, "w", zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk("."):
        for name in files:
            path = os.path.join(root, name)
            arc = os.path.relpath(path, ".")
            zi = zipfile.ZipInfo(arc)
            mode = os.stat(path).st_mode
            zi.external_attr = (mode & 0xFFFF) << 16
            zi.compress_type = zipfile.ZIP_DEFLATED
            with open(path, "rb") as f:
                z.writestr(zi, f.read())
PY
    )
fi

echo "Created: $OUT_ZIP"
