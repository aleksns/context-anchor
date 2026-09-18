---
name: clear
description: Remove pinned context-anchor entries for this project. Use when the user asks to clear/forget/unpin anchors, or runs /context-anchor:clear.
---

Argument: `$ARGUMENTS` — optionally, which anchor to remove (by quoted text
or index from `/context-anchor:list`). If empty, ask whether to clear
everything or just show the list first; do not wipe everything on a bare
invocation without confirming.

Steps:

1. Anchors live at `${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/context-anchor/anchors.jsonl`.
2. If a specific anchor was identified, remove only that line and rewrite
   the file with the rest.
3. If clearing everything was confirmed, empty the file.
4. Confirm what was removed.
