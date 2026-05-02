---
description: Consult Google Gemini Pro as a deep-dive engineering second opinion. Use when user asks for "deep review", "second opinion", "ask gemini", "consult gemini", architecture critique, security audit, whole-codebase analysis, or tough debugging that benefits from Gemini's larger context window. Also triggered manually via /consult-gemini.
allowed-tools: Task, Read, Grep, Glob, Bash(which gemini), Bash(gemini --version), Bash(gemini --help)
---

## When to use

Trigger phrases and patterns:

- "deep review", "deep dive", "second opinion"
- "ask gemini", "consult gemini", "what does gemini think"
- Architecture critique, security audit, whole-codebase analysis
- Debugging a problem that benefits from Gemini's larger context window
- Manual invocation: `/consult-gemini`

## When NOT to use

- Small, targeted questions Claude can answer alone without loading many files.
- Tasks that require iterative editing; route those to `feature-engineer` or `refactor-engineer` instead.
- Any question where the answer does not require broad context or a second opinion.

## Workflow

This skill owns: scope clarification, prompt assembly, file validation, Task dispatch, and output presentation. The `gemini-consultant` subagent owns: Bash execution, exit-code handling, timeouts, and verbatim relay. File contents never enter this skill's context — only paths are passed to the subagent, which lists them in the prompt for Gemini to read via its `read_file` tool.
1. **Preflight.** Run `which gemini`. If the binary is missing, surface install instructions (`npm i -g @google/gemini-cli` or equivalent) and stop.

2. **Clarify scope.** Confirm the question and the set of files, paths, or topics to include. If the user's request is ambiguous, ask one focused clarifying question before proceeding.

3. **Build the prompt.** Use the templates below. Name the role, the deliverable shape, and any constraints relevant to the user's goal. List context files as explicit paths — no glob expansion. Confirm each listed file exists (`ls <paths>`) before dispatching; surface any missing paths to the user and stop.

4. **Dispatch `gemini-consultant`.** Use `Task` with `subagent_type: "gemini-consultant"`, passing the assembled prompt with file paths listed inside the prompt string. The subagent runs `gemini -p "<question>"` (no `-s`; sandbox is unnecessary for read-only review and strict profiles restrict reads outside the working directory). Gemini reads files via its own `read_file` tool — list paths in the prompt, do not `cat` them. If `Task` cannot resolve `gemini-consultant`, verify `~/.claude/agents/gemini-consultant.md` exists. For a follow-up consultation on the same context, tell the subagent to use `--resume latest` rather than starting a fresh session.

5. **Receive and surface output.** Present a 3-6 bullet synthesis covering the highest-severity findings; if more than 10 findings, group by severity and lead with the top 3 blocking/critical items. Show the raw Gemini output inline only when short (under ~80 lines), otherwise offer to show specific sections. If the agent's provenance footer reports a non-zero exit, timeout, or error, surface the full agent output verbatim and ask the user how to proceed — do not retry.

6. **Integrate findings.** Based on Gemini's output, propose concrete next actions scaled to severity and volume: blocking/critical issues — propose a task or plan to address each; single architectural blocker — offer a design decision or ADR; list of medium/minor fixes — offer to implement directly or batch into a PR. Do not relay findings without a proposed action.

## Prompt templates

Select the template that matches the user's goal:

- Correctness, design, edge cases, broken behavior → **Deep code review**
- Service boundaries, coupling, scalability, system-level design → **Architecture critique**
- Auth, injection, data exposure, compliance, supply chain → **Security audit**
- Specific bug, unexpected behavior, failing test, root-cause hunt → **Debugging consult**

Combine templates when the scope spans multiple concerns (e.g. security audit + architecture critique for a new service).
**Deep code review**
```
[Task tier: deep-analysis — broad context, long reasoning chains, thorough multi-file review]
Review the provided code for correctness, design, maintainability, and edge cases.
Scope: flag blocking issues and significant design problems; skip trivial style nitpicks unless they indicate a systemic pattern.
Deliverable: numbered list of findings, each with file/line, severity (blocking/significant/minor), explanation, and suggested fix.
Do not summarize what the code does — focus on problems and improvements.
```

**Architecture critique**
```
[Task tier: deep-analysis — broad context, long reasoning chains, thorough multi-file review]
Identify structural weaknesses, coupling, scalability concerns, and missing failure modes. Exclude low-risk cosmetic concerns.
Deliverable: prioritized list of concerns with rationale and concrete alternatives.
```

**Security audit**
```
[Task tier: deep-analysis — broad context, long reasoning chains, thorough multi-file review]
Check for injection risks, auth gaps, insecure defaults, data exposure, supply-chain issues, and compliance/policy risks (e.g. PII handling, audit trails).
Deliverable: findings ranked by severity (critical / high / medium / low), each with CVE class if applicable, affected scope, and a fix recommendation.
```

**Debugging consult**
```
[Task tier: focused-analysis — bounded scope, targeted reasoning, single root-cause hunt]
Given the symptoms, stack traces, and relevant code, identify the most likely root causes. Distinguish between root causes and symptoms.
Deliverable: ranked hypotheses, each with supporting evidence from the provided code, a diagnostic step to confirm or rule it out, and whether it is a root cause or a contributing factor.
```

## Dispatch example

```
Task(
  subagent_type="gemini-consultant",
  description="Gemini debugging consult: auth session expiry bug",
  prompt="You are a senior engineer helping debug a hard problem.
Given the symptoms, stack traces, and relevant code, identify the most likely root causes. Distinguish between root causes and symptoms.
Deliverable: ranked hypotheses, each with supporting evidence from the provided code, a diagnostic step to confirm or rule it out, and whether it is a root cause or a contributing factor.

Symptoms: users randomly logged out after ~10 min despite a 24h session TTL. No errors in logs. Affects ~5% of users, primarily on mobile.

Files to review — Gemini will read these directly:
  src/auth/session.ts
  src/auth/middleware.ts
  tests/auth/session.test.ts"
)
```
