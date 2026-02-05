#!/usr/bin/env bash
# Package the readwise-reader Cowork plugin as a .zip for local upload.
#
# Usage: ./scripts/package_plugin.sh
# Output: readwise-reader.zip in the project root

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
PLUGIN_DIR="$PROJECT_ROOT/plugin/readwise-reader"
OUTPUT="$PROJECT_ROOT/readwise-reader.zip"

if [ ! -d "$PLUGIN_DIR/.claude-plugin" ]; then
    echo "Error: plugin directory not found at $PLUGIN_DIR" >&2
    exit 1
fi

rm -f "$OUTPUT"

cd "$PROJECT_ROOT/plugin"
zip -r "$OUTPUT" readwise-reader/ \
    -x "readwise-reader/.DS_Store" \
    -x "readwise-reader/**/.DS_Store"

echo "Packaged: $OUTPUT ($(du -h "$OUTPUT" | cut -f1))"
