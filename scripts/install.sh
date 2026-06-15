#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
LINK="/usr/local/bin/mlj"

chmod +x "$SCRIPT_DIR/mlj"
chmod +x "$SCRIPT_DIR/commands/"*.sh

ln -sf "$SCRIPT_DIR/mlj" "$LINK"
echo "Installed: mlj -> $LINK"
echo ""
echo "Run 'mlj help' to get started."
