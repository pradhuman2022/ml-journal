#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "$0")/../.." && pwd)"
NOTES_DIR="$REPO_ROOT/notes"
OUT_DIR="$REPO_ROOT/docs/notes"
NOTES_HTML="$REPO_ROOT/docs/notes.html"

mkdir -p "$OUT_DIR"

# Remove stale checkpoint HTMLs
find "$OUT_DIR" -name "*-checkpoint.html" -delete

# Remove HTMLs with no matching source notebook
for html in "$OUT_DIR"/*.html; do
  [[ -f "$html" ]] || continue
  name="$(basename "$html" .html)"
  if ! find "$NOTES_DIR" -name "${name}.ipynb" -not -path "*/.ipynb_checkpoints/*" | grep -q .; then
    echo "Removing stale: $html"
    rm "$html"
  fi
done

notebooks=$(find "$NOTES_DIR" -name "*.ipynb" -not -path "*/.ipynb_checkpoints/*" | sort)

if [[ -z "$notebooks" ]]; then
  echo "No notebooks found in $NOTES_DIR"
  exit 0
fi

# Convert each notebook and strip absolute paths from the HTML
echo "$notebooks" | while read -r nb; do
  echo "Converting: $nb"
  jupyter nbconvert --to html "$nb" --output-dir "$OUT_DIR"

  html_out="$OUT_DIR/$(basename "$nb" .ipynb).html"

  python3 - "$html_out" <<'PYEOF'
import re, sys

path = sys.argv[1]
with open(path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace absolute paths (quoted or HTML-entity-quoted) with just the filename
content = re.sub(r'(?:/[^\s\'"&#]+/)([\w.\-]+)', r'\1', content)

with open(path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"  Redacted paths in: {path}")
PYEOF
done

# Generate cards for notes.html
colors=(c1 c2 c3 c4 c5 c6)
cards=""
i=0

while IFS= read -r nb; do
  title=$(python3 -c "
import json
nb = json.load(open('$nb'.replace(\"'\", \"'\\\"'\\\"'\")))
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
