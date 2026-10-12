# CLAUDE.md

Guidance for Claude Code sessions working in this repo.

## `mlj convert`

`scripts/commands/convert.sh` regenerates `docs/notes/*.html` from every
notebook in `notes/`, and deletes any HTML file in `docs/notes/` that has no
matching `.ipynb` of the same name, treating it as a stale leftover.

`docs/notes/optimizer-playground.html` and `docs/notes/relu-boundary-lab.html`
are exceptions: they're hand-authored interactive pages (not generated from a
notebook) linked from the "Interactive" section of `docs/notes.html`. They have
no corresponding `.ipynb` and never will — **do not let `mlj convert` delete
them**. `convert.sh` skips names listed in `KEEP_HTML`; add any new
hand-authored page there. If you run `mlj convert`, check `git status`
afterward and restore these files if they were removed, rather than
committing the deletion.
