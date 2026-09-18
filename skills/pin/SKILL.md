---
name: pin
description: Pin a fact, decision, or constraint from this conversation so it survives context compaction. Use when the user says "remember this", "pin this", "don't lose this", "anchor this", or explicitly runs /context-anchor:pin.
---

The user wants to pin something so it is not lost when this conversation's
context gets compacted later.

Argument: `$ARGUMENTS` — the text to pin. If it is empty, ask the user what
they want pinned before doing anything else.

Steps:

1. Resolve the anchors directory: `${CLAUDE_PROJECT_DIR:-$(pwd)}/.claude/context-anchor`. Create it if it does not exist.
2. Append exactly one line to `anchors.jsonl` in that directory: a JSON
   object `{"text": "<fact>", "pinned_at": "<current UTC timestamp, ISO 8601>"}`.
   Trim only wording (e.g. drop "please remember that") — do not paraphrase
   or shorten the meaning of the fact itself.
3. Confirm what was pinned in one short line, e.g. `Pinned: <text>`.

Do not explain how the plugin works unless asked — just pin and confirm.
