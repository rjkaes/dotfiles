#!/usr/bin/env bash
set -euo pipefail
input=$(cat)

# Subagent calls have agent_id set — silent pass.
if [[ "$(jq -r '.agent_id // empty' <<<"$input")" != "" ]]; then
  exit 0
fi

# Per-session state, reset by inject-delegate-directive.sh on each prompt
# and by any dispatch: how many deliverable writes the main agent has made,
# and whether it has already been advised.
session_id=$(jq -r '.session_id // "nosession"' <<<"$input")
state_dir="${TMPDIR:-/tmp}/claude-delegate"
count_file="$state_dir/$session_id.count"
notified_file="$state_dir/$session_id.notified"

tool_name=$(jq -r '.tool_name // empty' <<<"$input")

# Dispatching is the desired behavior — clear the slate.
if [[ "$tool_name" == "Agent" ]]; then
  rm -f "$count_file" "$notified_file"
  exit 0
fi

# Manual escape hatch — silent pass.
if [[ -n "${ALLOW_DIRECT_EDIT:-}" ]]; then
  exit 0
fi

# Orchestration artifacts (ledgers, plans, memory) are the orchestrator's own
# work — silent pass, not counted.
file_path=$(jq -r '.tool_input.file_path // .tool_input.notebook_path // .tool_input.path // empty' <<<"$input")
case "$file_path" in
  */tmp/* | */.claude/plans/* | */.claude/projects/*/memory/*) exit 0 ;;
esac

# Bash is a deliverable write only when it edits a file in place or redirects
# into a file with an extension, outside tmp/. Anything else exits here, fast:
# this hook runs on every Bash call.
# ponytail: text heuristic. Misses extensionless targets and writes done by
# scripts or other tools; counts a `>` inside a heredoc body or quoted string
# when the word after it ends in .ext. Upgrade path: parse the command.
if [[ "$tool_name" == "Bash" ]]; then
  command=$(jq -r '.tool_input.command // empty' <<<"$input")
  inplace_re='(^|[^[:alnum:]_-])(sed|perl|ruby)[[:space:]]+(-[^[:space:]]*[[:space:]]+)*(-[pnlawEsrz]*i[^[:space:]]*|--in-place[^[:space:]]*)'
  # Redirect or tee target. `=>` and `->` are not redirects; `2>&1` has no
  # target token because & ends it.
  target_re='(^|[^=-])>>?[[:space:]]*[^[:space:];|&<>)]+|(^|[[:space:];|&(])tee([[:space:]]+-a)?[[:space:]]+[^[:space:];|&<>)]+'
  ext_re='\.[A-Za-z0-9]+$'
  deliverable_write=
  if [[ "$command" =~ $inplace_re && "$command" != *tmp/* ]]; then
    deliverable_write=1
  else
    while IFS= read -r match; do
      target=${match##*[[:space:]>]}
      target=${target//[\'\"]/}
      if [[ "$target" =~ $ext_re && "$target" != tmp/* && "$target" != */tmp/* ]]; then
        deliverable_write=1
        break
      fi
    done < <(grep -oE "$target_re" <<<"$command" || true)
  fi
  if [[ -z "$deliverable_write" ]]; then
    exit 0
  fi
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

oversize=
if [[ "$replace_all" == "true" ]] || (( nlines > max_lines || nchars > max_chars )); then
  oversize=1
fi

mkdir -p "$state_dir"
count=0
if [[ -f "$count_file" ]]; then
  count=$(<"$count_file")
fi
count=$((count + 1))
echo "$count" >"$count_file"

# Advise once per prompt-or-dispatch window, at the second deliverable write
# or the first oversize one. Model and routing rules live in the
# session-start directive; repeating them here only piled up copies in history.
if [[ -f "$notified_file" ]] || { (( count < 2 )) && [[ -z "$oversize" ]]; }; then
  exit 0
fi

if [[ "$replace_all" == "true" ]]; then
  reason="replace_all sweep"
elif [[ -n "$oversize" ]]; then
  reason="${nlines}-line / ${nchars}-char edit"
else
  reason="2nd deliverable edit"
fi

touch "$notified_file"

jq -n \
  --arg reason "$reason" \
  '{
    hookSpecificOutput: {
      hookEventName: "PreToolUse",
      additionalContext: ("Delegate: " + $reason + " since the last prompt or dispatch. Hand the rest of this change to a subagent per the CLAUDE.md routing, listing the files touched so far, or SendMessage the agent that produced it.")
    }
  }'

exit 0
