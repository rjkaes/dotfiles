#!/usr/bin/env bash
set -euo pipefail

# SubagentStart: every subagent gets the dispatched-worker rules. Not in
# CLAUDE.md, which also loads into the main session, where "you cannot
# reach the user" is false. Not AGENTS.md, which Claude Code skips when a
# CLAUDE.md exists and does not document at user level.
file="$HOME/.claude/subagent-instructions.md"

# Fail loudly: a silent exit would drop the rules from every subagent.
if [[ ! -r "$file" ]]; then
  echo "inject-subagent-instructions: cannot read $file" >&2
  exit 1
fi

jq -n --rawfile ctx "$file" \
  '{hookSpecificOutput: {hookEventName: "SubagentStart", additionalContext: $ctx}}'
