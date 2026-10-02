#!/usr/bin/env bash
set -euo pipefail
input=$(cat)

# Subagent calls have agent_id set — silent pass so the directive
# only reaches the top-level orchestrator, not dispatched subagents.
if [[ "$(jq -r '.agent_id // empty' <<<"$input")" != "" ]]; then
  exit 0
fi

# New prompt starts a fresh delegation window: clear the multi-edit counter
# that enforce-subagent.sh advises from.
if [[ "${1:-}" != "session" ]]; then
  session_id=$(jq -r '.session_id // "nosession"' <<<"$input")
  rm -f "${TMPDIR:-/tmp}/claude-delegate/$session_id".count "${TMPDIR:-/tmp}/claude-delegate/$session_id".notified
fi

# Manual escape hatch for sessions where the main agent legitimately
# needs to do direct implementation work (e.g., bootstrapping a new
# repo before any subagents exist).
if [[ -n "${ALLOW_MAIN_AGENT_WORK:-}" ]]; then
  exit 0
fi

directive="You are the orchestrator. Subagents explore and implement; you plan, dispatch, verify, and record.\n\nYours, inline: commit messages, PR bodies, ledgers, plans, memory, handoff notes in tmp/, and the reads you need to write a precise dispatch: files named by the user, a plan, a subagent report, or git diff. A single known edit to a deliverable is fine inline.\n\nSubagents': deliverables (code, tests, config, docs) beyond one known edit, and open-ended discovery (where is X, what calls Y, why does Z fail): Explore to locate, the debugger for root causes. A result that needs fixes goes back to its agent via SendMessage, not inline edits.\n\nModel selection when dispatching: set model: sonnet by default — anything requiring judgment, exploration, synthesis, or summarization (which is most subagent work). Drop to model: haiku ONLY when the subagent has no decisions to make and no summarization to produce — purely mechanical execution from a fully-specified instruction (e.g., apply this exact edit at this exact location, a fully-specified rename, run-and-report-exit-code). Reconnaissance, Explore dispatches, code review, debugging, and any task that ends in a summary are NOT Haiku tasks. model: opus is permitted only with an ESCALATION: justification line in the dispatch prompt explaining why sonnet is insufficient (or that a sonnet attempt already failed); dispatches without it are denied. model: fable is never allowed for subagents (hard-denied by hook) — fable-grade problems get orchestrated harder, not re-dispatched. Omitted model is denied by the guard hook.\n\nDispatch contract: feature-engineer, refactor-engineer, and database-architect prompts need a Validation: line (exact command + expected result) and a Non-goals: line, or the guard denies them. Run the Validation command before dispatch: it must fail; already green means the task is stale, so stop and report. When the subagent returns, re-run it yourself and read the diff (hand large diffs to spec-reviewer); the report is intent, not evidence.\n\nRouting policy (which agent) is in CLAUDE.md. This directive is not optional."

# Full text once per context window (SessionStart fires on startup, clear,
# and compact); every prompt gets only a one-line reminder. Per-prompt copies
# of the full text accumulated in history, ~1.9k chars per turn.
if [[ "${1:-}" == "session" ]]; then
  event=SessionStart
else
  event=UserPromptSubmit
  directive="Orchestrator: deliverables and discovery go to subagents; orchestration artifacts are yours."
fi

# The literal \n separators keep the source on one line; expand them, or the
# model receives backslash-n between paragraphs.
directive=$(printf '%b' "$directive")

jq -n \
  --arg ctx "$directive" \
  --arg event "$event" \
  '{
    hookSpecificOutput: {
      hookEventName: $event,
      additionalContext: $ctx
    }
  }'

exit 0
