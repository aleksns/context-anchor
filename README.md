# context-anchor

A Claude Code plugin that pins facts, decisions, and constraints so they
survive context compaction in long sessions.

## The problem

Claude Code summarizes the transcript ("compaction") when a session runs
long, to stay within the context window. That's necessary, but it means a
constraint stated early in a session ("don't touch the auth module", "the
deadline is Friday", "we decided X, not Y") can get smoothed over or dropped
by the summary — and there's no built-in mechanism to carry it forward
verbatim.

context-anchor gives you an explicit way to pin something so it survives
that boundary intact, instead of hoping the summarizer keeps it.

## Installation

```bash
claude --plugin-dir /path/to/context-anchor
```

There's no marketplace listing yet — for now this is installed by pointing
Claude Code at a local checkout of this repo:

```bash
git clone https://github.com/<your-username>/context-anchor.git
claude --plugin-dir ./context-anchor
```

## Usage

```
/context-anchor:pin "don't touch the auth module, it's mid-refactor"
/context-anchor:list
/context-anchor:clear
```

Pin anything worth protecting from a future compaction. It'll come back as
a reminder the moment the session resumes after one.

## How it works

- **`/context-anchor:pin <text>`** — appends `<text>` verbatim, with a
  timestamp, to `.claude/context-anchor/anchors.jsonl` in the current
  project.
- **`PreCompact` hook** — fires right before Claude Code compacts the
  transcript. Flushes the anchors file to disk and logs the compaction
  event (trigger, anchor count) to `.claude/context-anchor/compactions.log`.
- **`SessionStart` hook (matcher: `compact`)** — fires when the session
  resumes right after a compaction. Reads the pinned anchors and re-injects
  them as a reminder, so the constraint is back in view on the very next
  turn instead of relying on the summary to have kept it.
- **`/context-anchor:list`** / **`/context-anchor:clear`** — inspect or
  remove pinned anchors for the current project.

Anchors are scoped to the project directory (`CLAUDE_PROJECT_DIR`), not to
a single session — v1 assumes one active session per project at a time.

## Known uncertainty

Claude Code's hook documentation is inconsistent about which JSON field a
`SessionStart` hook can use to inject text back into the conversation
(`additionalContext` is confirmed for `PreToolUse`; it's undocumented
whether `SessionStart` honors the same field, `systemMessage`, or both).
`inject-anchors.sh` emits the same message under `systemMessage`,
top-level `additionalContext`, and `hookSpecificOutput.additionalContext`
simultaneously, so it keeps working regardless of which one Claude Code
actually reads.

This has been tested by feeding each hook script the JSON it would receive
on stdin and checking the output is well-formed — it has **not** yet been
verified against a real compaction in a live session. That's the next
thing to confirm before calling this solid; see Status below.

## Local development

```bash
claude --plugin-dir /path/to/context-anchor
```

Hook changes require restarting the session (`/reload-plugins` does not
reload hooks). Skill/command changes pick up with `/reload-plugins`.

## Status

v1: manual pinning only, unit-tested at the script level, not yet confirmed
against a real `/compact` in a live session. No automatic "this seems
important" detection — that's a fuzzier problem and deliberately out of
scope for now.

## License

MIT
