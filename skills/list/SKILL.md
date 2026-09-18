---
name: list
description: Show everything currently pinned in this project via context-anchor. Use when the user asks what's pinned, or runs /context-anchor:list.
---

Steps:

1. Read `${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/context-anchor/anchors.jsonl` if it exists.
2. List each pinned entry as a bullet, most recent first, with its
   `pinned_at` timestamp.
3. If the file does not exist or is empty, say nothing is pinned yet — do
   not treat that as an error.
