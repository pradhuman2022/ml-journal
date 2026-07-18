# CLAUDE.md

Guidance for Claude Code sessions working in this repo.

## `mlj convert`

`scripts/commands/convert.sh` regenerates `docs/notes/*.html` from every
notebook in `notes/`, and deletes any HTML file in `docs/notes/` that has no
matching `.ipynb` of the same name, treating it as a stale leftover.

`docs/notes/optimizer-playground.html` is an exception: it's a hand-authored
interactive Plotly/math.js page (not generated from a notebook) linked from
the "Interactive" section of `docs/notes.html`. It has no corresponding
`notes/optimizer-playground.ipynb` and never will — **do not let `mlj convert`
delete it**. If you run `mlj convert`, check `git status` afterward and
restore this file if it was removed, rather than committing the deletion.
