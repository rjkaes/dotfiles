#!/usr/bin/env bash
set -euo pipefail
input=$(cat)

# Subagent calls have agent_id set — silent pass, no counter.
if [[ "$(jq -r '.agent_id // empty' <<<"$input")" != "" ]]; then
  exit 0
fi

# Manual escape hatch — silent pass, no counter.
if [[ -n "${ALLOW_HEAVY_READS:-}" ]]; then
  exit 0
fi

# Session state lives in a per-session directory under TMPDIR.
# We track a call counter and a "already notified" sentinel so the
# advisory fires exactly once per session regardless of which rule
# triggers it.
state_dir="${TMPDIR:-/tmp}/claude-explore-advisor"
mkdir -p "$state_dir"

session_id=$(jq -r '.session_id // "unknown"' <<<"$input")
count_file="${state_dir}/${session_id}.count"
notified_file="${state_dir}/${session_id}.notified"

# Increment the counter first so threshold checks are against the
# post-increment value (first call = 1, fifth call = 5).
count=1
if [[ -f "$count_file" ]]; then
  count=$(( $(cat "$count_file") + 1 ))
fi
printf '%d' "$count" >"$count_file"

# If we already fired the advisory this session, just pass silently.
if [[ -f "$notified_file" ]]; then
  exit 0
fi

tool=$(jq -r '.tool_name' <<<"$input")
threshold=${EXPLORE_ADVISE_AT:-5}
reason=""

# Rule 1: cumulative call count reached threshold.
if (( count >= threshold )); then
  reason="${count} tool calls so far"
fi

# Rule 2: Read with a large or absent limit.
# Check this only for the Read tool; trueline_read is handled by Rule 3.
if [[ "$tool" == "Read" ]]; then
  # jq returns "null" when the field is absent, a number when present.
  limit_raw=$(jq -r '.tool_input.limit // "null"' <<<"$input")
  if [[ "$limit_raw" == "null" ]]; then
    reason="a Read with no limit (default 2000)"
  elif (( limit_raw >= 500 )); then
    reason="a Read with limit=${limit_raw}"
  fi
fi

# Rule 3: trueline_read where any file_paths element lacks a :range suffix.
# A bare path (no colon) means the whole file is requested.
if [[ "$tool" == "mcp__plugin_trueline-mcp_mcp__trueline_read" ]]; then
  # Extract the first file_paths entry that has no ":" in it.
  offending=$(jq -r '
    (.tool_input.file_paths // [])[]
    | select(contains(":") | not)
  ' <<<"$input" | head -n1)
  if [[ -n "$offending" ]]; then
    reason="trueline_read of full file ${offending}"
  fi
fi

# Nothing triggered — pass silently.
if [[ -z "$reason" ]]; then
  exit 0
fi

# Mark notified before emitting so a concurrent invocation cannot
# race past the sentinel check above.
touch "$notified_file"

advisory="Advisory: heavy exploratory tool use detected (${reason}). For broad codebase exploration or open-ended research, dispatch the Explore subagent — it returns curated excerpts rather than dumping whole files into Opus's context. Use direct Read/Grep when you already know the target; switch to Explore for reconnaissance. Per CLAUDE.md: more than 3 exploratory queries warrants an Explore dispatch. (This advisory fires once per session.)"

jq -n \
  --arg ctx "$advisory" \
  '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: $ctx
    }
  }'

exit 0
