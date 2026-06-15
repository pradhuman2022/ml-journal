#!/usr/bin/env bash
set -euo pipefail

KAGGLE_DIR="$HOME/.kaggle"
KAGGLE_JSON="$KAGGLE_DIR/kaggle.json"

echo "=== Kaggle environment setup ==="
echo ""

# Install kaggle package if missing
if ! command -v kaggle &>/dev/null; then
  echo "[1/3] Installing kaggle package..."
  pip install --quiet kaggle
  echo "      Done."
else
  echo "[1/3] kaggle package already installed ($(kaggle --version 2>&1))."
fi

# Write credentials
echo ""
echo "[2/3] Setting up API token."

if [[ -f "$KAGGLE_JSON" ]]; then
  read -r -p "      $KAGGLE_JSON already exists. Overwrite? [y/N] " confirm
  [[ "$(echo "$confirm" | tr '[:upper:]' '[:lower:]')" != "y" ]] && echo "      Skipped." && SKIP_CREDS=1
fi

if [[ "${SKIP_CREDS:-0}" != "1" ]]; then
  read -r -p "      Kaggle username: " KAGGLE_USER
  read -r -s -p "      Kaggle API key:  " KAGGLE_KEY
  echo ""

  mkdir -p "$KAGGLE_DIR"
  printf '{"username":"%s","key":"%s"}\n' "$KAGGLE_USER" "$KAGGLE_KEY" > "$KAGGLE_JSON"
  chmod 600 "$KAGGLE_JSON"
  echo "      Written: $KAGGLE_JSON (permissions: 600)"
fi

# Verify
echo ""
echo "[3/3] Verifying..."
kaggle_output=$(kaggle competitions list 2>&1)
if echo "$kaggle_output" | grep -qi "error\|401\|403\|forbidden\|unauthorized\|invalid"; then
  echo "      Error: $kaggle_output"
  echo ""
  echo "      Verification failed. Check your username and API key."
  echo "      You can regenerate your token at: https://www.kaggle.com/settings"
  exit 1
else
  echo "      Auth OK — Kaggle API is working."
fi

echo ""
echo "Setup complete. Try: kaggle competitions list"
