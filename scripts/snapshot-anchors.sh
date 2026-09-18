#!/usr/bin/env bash
# PreCompact hook: guarantee pinned anchors are flushed to disk before the
# transcript gets summarized away, and log the compaction event for
# observability. Anchors themselves are written by the `pin` skill, not here
# — this just makes sure that write already landed and leaves a trail.
set -euo pipefail

ANCHORS_DIR="${CLAUDE_PROJECT_DIR:-$PWD}/.claude/context-anchor"
ANCHORS_FILE="$ANCHORS_DIR/anchors.jsonl"
LOG_FILE="$ANCHORS_DIR/compactions.log"

mkdir -p "$ANCHORS_DIR"
touch "$ANCHORS_FILE"
sync "$ANCHORS_FILE" 2>/dev/null || true

INPUT="$(cat || true)"
TRIGGER="$(printf '%s' "$INPUT" | python3 -c 'import json,sys
try:
    d = json.load(sys.stdin)
    print(d.get("trigger", "unknown"))
except Exception:
    print("unknown")' 2>/dev/null || echo "unknown")"

COUNT="$(wc -l < "$ANCHORS_FILE" | tr -d ' ')"
printf '%s compaction trigger=%s anchors=%s\n' "$(date -u +%FT%TZ)" "$TRIGGER" "$COUNT" >> "$LOG_FILE"

exit 0
