#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NOTES_DIR="$REPO_ROOT/notes"
OUT_DIR="$REPO_ROOT/docs/notes"
NOTES_HTML="$REPO_ROOT/docs/notes.html"

mkdir -p "$OUT_DIR"

notebooks=$(find "$NOTES_DIR" -name "*.ipynb" | sort)

if [[ -z "$notebooks" ]]; then
  echo "No notebooks found in $NOTES_DIR"
  exit 0
fi

# Convert each notebook to HTML
echo "$notebooks" | while read -r nb; do
  echo "Converting: $nb"
  jupyter nbconvert --to html "$nb" --output-dir "$OUT_DIR"
done

# Generate cards for notes.html
colors=(c1 c2 c3 c4 c5 c6)
cards=""
i=0

while IFS= read -r nb; do
  # Extract title from first markdown cell
  title=$(python3 -c "
import json, sys
nb = json.load(open('$nb'))
for cell in nb['cells']:
    if cell['cell_type'] == 'markdown':
        src = ''.join(cell['source'])
        line = src.strip().splitlines()[0]
        print(line.lstrip('# ').strip())
        break
" 2>/dev/null || basename "$nb" .ipynb)

  html_file="$(basename "$nb" .ipynb).html"
  color="${colors[$((i % 6))]}"

  cards="${cards}    <a class=\"card ${color}\" href=\"notes/${html_file}\">
      <div class=\"tag\">Notebook</div>
      <h3>${title}</h3>
      <div class=\"status\">Open →</div>
    </a>
"
  i=$((i + 1))
done <<< "$notebooks"

# Inject cards between sentinels in notes.html
python3 - <<PYEOF
import re

with open('$NOTES_HTML', 'r') as f:
    content = f.read()

new_block = '''<!-- NOTEBOOKS-START -->
${cards}<!-- NOTEBOOKS-END -->'''

content = re.sub(
    r'<!-- NOTEBOOKS-START -->.*?<!-- NOTEBOOKS-END -->',
    new_block,
    content,
    flags=re.DOTALL
)

with open('$NOTES_HTML', 'w') as f:
    f.write(content)

print('Updated: $NOTES_HTML')
PYEOF

echo "Done."
