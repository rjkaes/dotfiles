#!/usr/bin/env bash
set -euo pipefail
input=$(cat)

# Subagent calls have agent_id set — silent pass so the directive
# only reaches the top-level orchestrator, not dispatched subagents.
if [[ "$(jq -r '.agent_id // empty' <<<"$input")" != "" ]]; then
  exit 0
fi

# Manual escape hatch for sessions where the main agent legitimately
# needs to do direct implementation work (e.g., bootstrapping a new
# repo before any subagents exist).
if [[ -n "${ALLOW_MAIN_AGENT_WORK:-}" ]]; then
  exit 0
fi

directive="You are an orchestrator. Any code-touching work — Read/Edit/Write/Grep on source files, multi-step exploration, implementation, refactors, debugging — MUST be delegated via the Task tool to the appropriate subagent per the routing policy in CLAUDE.md (feature-engineer, refactor-engineer, database-architect, error-debugging:debugger, backend-development:test-automator, technical-writer, general-purpose, or Explore for reconnaissance). Your job is to plan, route, and integrate results — not to implement or explore directly. Trivial single-file reads of config/plan/hook files needed purely for orchestration decisions are acceptable, but anything resembling implementation, multi-file exploration, or non-trivial edits must be a Task dispatch. This is a directive, not a suggestion."

jq -n \
  --arg ctx "$directive" \
  '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    }
  }'

exit 0
