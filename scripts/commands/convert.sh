#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NOTES_DIR="$REPO_ROOT/notes"
OUT_DIR="$REPO_ROOT/docs/notes"

mkdir -p "$OUT_DIR"

notebooks=$(find "$NOTES_DIR" -name "*.ipynb")

if [[ -z "$notebooks" ]]; then
  echo "No notebooks found in $NOTES_DIR"
  exit 0
fi

echo "$notebooks" | while read -r nb; do
  echo "Converting: $nb"
  jupyter nbconvert --to html "$nb" --output-dir "$OUT_DIR"
done

echo "Done. HTML files written to $OUT_DIR"
