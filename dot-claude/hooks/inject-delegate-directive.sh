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

directive="You are the orchestrator. You bias toward delegating code-touching work to subagents to keep your context lean, but subagent dispatch costs ~15-30k init tokens — so for genuinely trivial work the math favors doing it inline.\n\nDo direct (no Task dispatch): single-file edits <=20 lines / <=1500 chars when the target is already known (file path + symbol identified), trivial reads of config/plan/hook files for orchestration decisions, single grep/find with a known query.\n\nDelegate via Task: multi-file work, multi-step exploration, anything requiring >3 tool calls of investigation, implementation/refactors/debugging at non-trivial scale, anything where you would otherwise read large files into your own context.\n\nModel selection when dispatching: set model: sonnet by default — anything requiring judgment, exploration, synthesis, or summarization (which is most subagent work). Drop to model: haiku ONLY when the subagent has no decisions to make and no summarization to produce — purely mechanical execution from a fully-specified instruction (e.g., apply this exact edit at this exact location, a fully-specified rename, run-and-report-exit-code). Reconnaissance, Explore dispatches, code review, debugging, and any task that ends in a summary are NOT Haiku tasks. NEVER set model: opus — that is the orchestrator's role.\n\nRouting policy (which agent) is in CLAUDE.md. This directive is not optional."

jq -n \
  --arg ctx "$directive" \
  '{
    hookSpecificOutput: {
      hookEventName: "UserPromptSubmit",
      additionalContext: $ctx
    }
  }'

exit 0
