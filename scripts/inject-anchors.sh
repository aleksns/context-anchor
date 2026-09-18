#!/usr/bin/env bash
# SessionStart hook (matcher: "compact"): re-inject pinned anchors right
# after a compaction, since Claude Code has no built-in mechanism to carry
# them across the summarization boundary on its own.
#
# The hook output contract for context-injection is under-documented for
# this event (PreToolUse's `additionalContext` is confirmed; SessionStart's
# is not consistently documented). We emit the same message under every
# field a hook might plausibly read (`systemMessage`, top-level
# `additionalContext`, and nested under `hookSpecificOutput`) so this keeps
# working once/if the ambiguity is resolved upstream, rather than silently
# depending on an unverified field name.
set -euo pipefail

ANCHORS_FILE="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/context-anchor/anchors.jsonl"

if [ ! -s "$ANCHORS_FILE" ]; then
  exit 0
fi

python3 - "$ANCHORS_FILE" <<'PY'
import json
import sys

path = sys.argv[1]
lines = []
with open(path) as f:
    for raw in f:
        raw = raw.strip()
        if not raw:
            continue
        try:
            entry = json.loads(raw)
        except json.JSONDecodeError:
            continue
        text = entry.get("text")
        if text:
            lines.append(f"- {text}")

if not lines:
    sys.exit(0)

message = (
    "Context was just compacted. These facts/constraints were pinned "
    "earlier in this session and must not be lost or contradicted:\n"
    + "\n".join(lines)
)

print(json.dumps({
    "systemMessage": message,
    "additionalContext": message,
    "hookSpecificOutput": {"additionalContext": message},
}))
PY
