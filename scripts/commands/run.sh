#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
START_PATH="${1:-$REPO_ROOT/notes}"

if [[ -f "$START_PATH" ]]; then
  echo "Opening notebook: $START_PATH"
  jupyter notebook "$START_PATH"
else
  echo "Starting Jupyter in: $START_PATH"
  jupyter notebook --notebook-dir="$START_PATH"
fi
