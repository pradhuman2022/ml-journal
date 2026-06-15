#!/usr/bin/env bash
set -euo pipefail

usage() {
  echo "Usage: mlj new <title> [output-path]"
  echo "  title        Notebook title (quote if it contains spaces)"
  echo "  output-path  Optional .ipynb path (default: notes/<slug>.ipynb)"
  exit 1
}

[[ $# -lt 1 ]] && usage

TITLE="$1"
REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"

if [[ $# -ge 2 ]]; then
  OUT="$2"
else
  SLUG="$(echo "$TITLE" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|-$//g')"
  OUT="$REPO_ROOT/notes/${SLUG}.ipynb"
fi

[[ "$OUT" != *.ipynb ]] && OUT="${OUT}.ipynb"

mkdir -p "$(dirname "$OUT")"

cat > "$OUT" <<NOTEBOOK
{
 "cells": [
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "# ${TITLE}"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Imports"
   ]
  },
  {
   "cell_type": "code",
   "execution_count": null,
   "metadata": {},
   "outputs": [],
   "source": [
    "import numpy as np\n",
    "import pandas as pd\n",
    "import matplotlib.pyplot as plt"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Notes"
   ]
  },
  {
   "cell_type": "markdown",
   "metadata": {},
   "source": [
    "## Experiments"
   ]
  }
 ],
 "metadata": {
  "kernelspec": {
   "display_name": "Python 3",
   "language": "python",
   "name": "python3"
  },
  "language_info": {
   "name": "python",
   "version": "3.10.0"
  }
 },
 "nbformat": 4,
 "nbformat_minor": 5
}
NOTEBOOK

echo "Created: $OUT"
