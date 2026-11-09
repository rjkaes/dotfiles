---
description: Run /gemini-review-pr, /code-review low and /ponytail:ponytail-review on one PR, then report one verified list
argument-hint: <pr-number>
---

Review PR #$ARGUMENTS in the current repo with three reviewers, then merge their findings.
The report lists every finding at every severity. The user picks what gets fixed.

## 1. Check out the PR

`/code-review` and `/ponytail:ponytail-review` read the working tree, so it must match the PR.

- If `$ARGUMENTS` is empty or not a number, ask for the PR number once and stop.
- Compare `git rev-parse HEAD` with `gh pr view $ARGUMENTS --json headRefOid -q .headRefOid`.
- They differ: stop and ask before `gh pr checkout $ARGUMENTS`. It changes the working tree.

## 2. Run the three reviews in parallel sub-agents

Send three Agent calls in one message: `subagent_type: claude`, `model: sonnet`.
Each prompt names one skill for the sub-agent to invoke with the Skill tool:

- `gemini-review-pr` with args `$ARGUMENTS`.
  In its review prompt, replace "skip trivial style nits unless they signal a systemic pattern" with "report style nits as Low".
- `code-review` with args `low`. Scope: `git diff origin/<base>...HEAD` for PR #$ARGUMENTS.
- `ponytail:ponytail-review` with args `PR #$ARGUMENTS`.

Each prompt also says:

- Change no code. Post nothing to GitHub.
- No Agent tool: run the skill's review steps inline.
- Write findings with the Write tool to `tmp/triple-review-$ARGUMENTS-<skill>.json`, `<skill>` being the skill name without its plugin prefix. No ReportFindings.
- The file holds one JSON array, one object per finding, keys `file`, `line`, `severity`, `claim`, `fix`, `dropped`.
- `file` and `line` are null when the finding has no location. `severity` is the skill's own label.
- `dropped` is the reason the skill's own check dropped the finding, else null.
- Include every finding at every severity, nits and dropped ones included. No count or word cap applies.
- Run `jq empty <file>` and rewrite the file until it passes.
- Return only the JSON path, `jq length` of it, and any capture file path the skill writes.

Wait for all three completion notifications.
Report each reviewer's finding count as it lands. Do not predict pending results.

## 3. Verify and merge

- Read the three returned JSON files. One fails `jq empty`: SendMessage its sub-agent to rewrite it.
- Verify every object, `dropped` ones included.
- Open each cited `file:line` in the repo and mark it Confirmed, Refuted or Could not confirm.
- A null `file` or `line`: search the code for the claim and name where you looked.
- Merge findings across reviewers only when they share a root cause. Name every reviewer that raised it.
- Number findings once across all reviewers, so the user can say "fix 2 and 5".
- Before reporting, map every object to one numbered finding. Give per-reviewer counts from `jq length` and the merged total.

## 4. Report

Build the report from the verified JSON objects. List every finding. The 300-word findings cap does not apply.
Each finding gets one or two sentences and one fix.

1. Decisions that need the user.
2. Must fix: Confirmed bugs, security, data loss, breaks at the expected load.
3. Should fix: every other Confirmed problem, such as missing tests, real slowness, duplication, dead code, weak error handling.
4. Nice to have: Confirmed style nits, small speed-ups, shorter forms.
5. Refuted, each with the line that refutes it.
6. Could not confirm, each with where you looked.

A finding that fits two sections goes in the higher one.

Give the Gemini capture path. End with `Verdict: Ship.` or `Verdict: fix <n> first.`
Change no code.
