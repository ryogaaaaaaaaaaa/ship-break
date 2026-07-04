#!/usr/bin/env sh
set -eu

PROJECT_ROOT="$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)"
WEB_DIR="$PROJECT_ROOT/build/web"
PAGES_DIR="$PROJECT_ROOT/build/pages"

"$PROJECT_ROOT/tools/export_web.sh"
mkdir -p "$PAGES_DIR"

for name in index.html index.js index.wasm index.pck index.png index.icon.png index.apple-touch-icon.png index.audio.worklet.js index.audio.position.worklet.js .nojekyll; do
	if [ -f "$WEB_DIR/$name" ]; then
		cp "$WEB_DIR/$name" "$PAGES_DIR/$name"
	fi
done

echo "Pages package written to $PAGES_DIR"
