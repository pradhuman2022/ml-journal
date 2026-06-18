#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
DATA_DIR="$REPO_ROOT/notes/data"

usage() {
  echo "Usage: mlj data <dataset-or-competition>"
  echo ""
  echo "  Downloads a Kaggle dataset or competition data into notes/data/"
  echo ""
  echo "Examples:"
  echo "  mlj data mirichoi0218/insurance"
  echo "  mlj data house-prices-advanced-regression-techniques"
  exit 1
}

[[ $# -lt 1 ]] && usage

INPUT="$1"
mkdir -p "$DATA_DIR"

if [[ "$INPUT" == *"/"* ]]; then
  echo "Downloading dataset: $INPUT"
  kaggle datasets download -d "$INPUT" --path "$DATA_DIR" --unzip
else
  echo "Downloading competition data: $INPUT"
  kaggle competitions download -c "$INPUT" --path "$DATA_DIR"
  unzip -o "$DATA_DIR/${INPUT}.zip" -d "$DATA_DIR" && rm -f "$DATA_DIR/${INPUT}.zip"
fi

echo "Done. Files saved to: $DATA_DIR"
