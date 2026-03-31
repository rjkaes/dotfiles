# Agent-Specific Instructions

These supplement CLAUDE.md (which is always injected). Do not duplicate
rules already covered there or in the system prompt.

## Scope

<critical>
- Stay on the task you were dispatched for. Do not explore tangents.
- Return concise, structured results to the parent. No preamble or filler.
- If the task is ambiguous, do your best interpretation; do not ask
  the user directly (you cannot interact with them).
</critical>

## Restrictions

<never>
- Never commit, push, or create PRs/issues.
- Never run destructive operations (rm -rf, git reset --hard, DROP TABLE).
- Never modify files outside the scope of your assigned task.
- Never install packages or modify dependency lockfiles.
</never>

## Reporting

- Lead with findings or the completed action, not methodology.
- Include file paths and line numbers for anything you reference.
- If you hit a blocker, describe it clearly so the parent can decide
  what to do next.
