#!/usr/bin/env bash
set -euo pipefail
input=$(cat)

# Subagent calls have agent_id set — silent pass.
if [[ "$(jq -r '.agent_id // empty' <<<"$input")" != "" ]]; then
  exit 0
fi

# Plans dir is authored by the main orchestrator — silent pass.
file_path=$(jq -r '.tool_input.file_path // .tool_input.path // empty' <<<"$input")
if [[ "$file_path" == /Users/rjk/.claude/plans/* ]]; then
  exit 0
fi

# Manual escape hatch — silent pass.
if [[ -n "${ALLOW_DIRECT_EDIT:-}" ]]; then
  exit 0
fi

# Measure the edit footprint across all supported tool shapes.
footprint=$(jq -r '
  [
    (.tool_input.new_string // empty),
    (.tool_input.old_string // empty),
    (.tool_input.content // empty),
    (.tool_input.new_source // empty),
    (.tool_input.edits // [] | map((.new_string // .content // "") + "\n" + (.old_string // "")) | join("\n"))
  ] | map(select(. != "")) | join("\n")
' <<<"$input")

max_lines=${MAX_DIRECT_LINES:-20}
max_chars=${MAX_DIRECT_CHARS:-1500}

if [[ -z "$footprint" ]]; then
  nlines=0
else
  nlines=$(awk 'END{print NR}' <<<"$footprint")
fi
nchars=${#footprint}
replace_all=$(jq -r '.tool_input.replace_all // false' <<<"$input")
tool=$(jq -r '.tool_name' <<<"$input")

# Trivial edit — silent pass.
if [[ "$replace_all" != "true" ]] && (( nlines <= max_lines && nchars <= max_chars )); then
  exit 0
fi

# Non-trivial: allow, but inject advisory for Claude to read next turn.
if [[ "$replace_all" == "true" ]]; then
  reason="a replace_all sweep"
else
  reason="${nlines} lines / ${nchars} chars (over ${max_lines}/${max_chars})"
fi

jq -n \
  --arg tool "$tool" \
  --arg reason "$reason" \
  '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: ("Advisory: this " + $tool + " call was " + $reason + ". For non-trivial implementation work, dispatch a subagent via Task to keep the orchestrator'\''s context lean. When you dispatch, set model: sonnet by default; drop to model: haiku only when the subagent has no decisions and no summarization to produce (purely mechanical execution). Never model: opus. Routing: see CLAUDE.md. This edit was allowed; consider delegating the next one.")
    }
  }'

exit 0
