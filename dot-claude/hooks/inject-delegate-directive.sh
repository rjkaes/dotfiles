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

directive="You are the orchestrator. Subagents explore and implement; you plan, dispatch, verify, and record.\n\nInline for you: commit messages, PR bodies, ledgers, plans, memory, handoff notes in tmp/, and the reads needed for a precise dispatch (user-named files, a plan, a subagent report, git diff). One known edit to a deliverable is fine.\n\nSubagents': deliverables (code, tests, config, docs) beyond one known edit, and open-ended discovery (where is X, what calls Y, why does Z fail). Explore locates; the debugger finds root causes. Fixes to a result go back to its agent via SendMessage.\n\nModel: sonnet by default. haiku only for mechanical execution of a fully-specified instruction (exact edit at an exact location, specified rename, run-and-report-exit-code). Recon, Explore, review, debugging, and anything ending in a summary are not haiku. opus needs an ESCALATION: line in the prompt (why sonnet is insufficient, or that a sonnet attempt failed), else denied. fable is hard-denied; orchestrate harder instead. Omitted model is denied, except mechanical-editor (pins haiku): send exact edits, fixups, and run-and-report there with no model.\n\nContract: feature-engineer, refactor-engineer, and database-architect prompts need a Validation: line (exact command + expected result) and a Non-goals: line, or the guard denies them. Run the Validation command before dispatch; it must fail. Already green means a stale task: stop and report. Skip that run when the step writes the test first. On return, run the project's test-receipt check for the tree if its CLAUDE.md names one, else re-run Validation. Then read the diff (large diffs go to spec-reviewer). The report is intent, not evidence.\n\nSize: one plan step per dispatch for implementing agents; the next step gets a fresh agent. SendMessage only fixes the step just returned. A handoff or plan saying to reuse agents across steps does not override this. Turns above 200k context were 49% of subagent cache reads.\n\nAgent routing: CLAUDE.md."

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
