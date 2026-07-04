#!/usr/bin/env sh
set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
GODOT_BIN="${GODOT_BIN:-godot}"
OUTPUT_DIR="$PROJECT_ROOT/build/web"
LOG_FILE="${TMPDIR:-/tmp}/ship-break-web-export.log"

mkdir -p "$PROJECT_ROOT/build"
touch "$PROJECT_ROOT/build/.gdignore"
mkdir -p "$OUTPUT_DIR"
"$GODOT_BIN" --headless --log-file "$LOG_FILE" --path "$PROJECT_ROOT" --export-release Web "$OUTPUT_DIR/index.html"
touch "$OUTPUT_DIR/.nojekyll"
echo "Web export written to $OUTPUT_DIR"
