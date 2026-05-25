---
description: Consult Google Gemini Pro as a deep-dive engineering second opinion. Use when user asks for "deep review", "second opinion", "consult gemini", architecture critique, security audit, whole-codebase analysis, or tough debugging that benefits from Gemini's larger context window. Also triggered manually via /consult-gemini or /consult-gemini <question>.
allowed-tools: Task, Read, Grep, Glob, Bash(which gemini), Bash(gemini --version), Bash(gemini --help)
argument-hint: [question]
---

## When to use

Trigger phrases and patterns:

- "deep review", "deep dive", "second opinion", "challenge this"
- "consult gemini", "what does gemini think"
- Architecture critique, security audit, whole-codebase analysis
- Debugging a problem that benefits from Gemini's larger context window
- Manual invocation: `/consult-gemini` (prompts for scope) or `/consult-gemini <question>` (uses argument directly)

Gemini's known strengths vs Claude (per the Magpie benchmark — 15 Milvus PRs, 5 flagship models; see [Milvus blog](https://milvus.io/blog/ai-code-review-gets-better-when-models-debate-claude-vs-gemini-vs-codex-vs-qwen-vs-minimax.md)):

- **Concurrency races** — Gemini 1/2, Claude 0/2
- **API compatibility** — cross-version, cloud-storage, deprecated SDKs (Gemini 1/2, Claude 0/2)
- **Permission / authorization gaps** — Gemini catches missing access checks Claude misses
- **Structural & engineering-standards critique** — Gemini opens with strong design opinions; useful for forcing re-checks
- **Multi-turn iterative debate** — Gemini's single-pass score is the weakest of the five, but it improves noticeably in adversarial back-and-forth

The Claude+Gemini pair already covers ~91% of a 5-model debate ceiling (10/15 vs 11/15). Frame the consultation as Gemini *challenging* Claude's conclusions, not just reviewing the code fresh.

## When NOT to use

- Small, targeted questions Claude can answer alone without loading many files.
- Tasks that require iterative editing; route those to `feature-engineer` or `refactor-engineer` instead.
- Any question where the answer does not require broad context or a second opinion.
- **Deep logic bugs** — Claude outperforms Gemini alone in this category; don't burn the call to confirm what Claude already nailed.
- **Data-structure lifecycle / ownership bugs** — Claude 3/4, Gemini 1/4 in benchmark; not Gemini's strength.
- **Math-heavy verification** — both models get overconfident with arithmetic; use a deterministic checker.

## Workflow

This skill owns: scope clarification, prompt assembly, file validation, Task dispatch, and output presentation. The `gemini-consultant` subagent owns: Bash execution, exit-code handling, timeouts, and verbatim relay. File contents never enter this skill's context — only paths are passed to the subagent, which lists them in the prompt for Gemini to read via its `read_file` tool.

1. **Clarify scope.** User's invocation argument: `$ARGUMENTS`. If non-empty, treat it as the question and proceed directly to step 3. If empty, confirm the question and the set of files, paths, or topics to include — ask one focused clarifying question if the request is ambiguous.

2. **Build the prompt.** Use the templates below. Name the role, the deliverable shape, and any constraints relevant to the user's goal. List context files as explicit paths — no glob expansion. Confirm each listed file exists (`ls <paths>`) before dispatching; surface any missing paths to the user and stop.

3. **Dispatch `gemini-consultant`.** Use `Task` with `subagent_type: "gemini-consultant"`, passing the assembled prompt with file paths listed inside the prompt string. Tell the subagent to `cd` to the project root before running `ask-gemini` so that relative paths in the prompt resolve correctly. The subagent runs `ask-gemini "<question>"` as a **single-line Bash command** — no multiline strings, no heredoc (fish shell does not handle them reliably). Gemini reads files via its own `read_file` tool — list paths in the prompt, do not `cat` them. If `Task` cannot resolve `gemini-consultant`, verify `~/.claude/agents/gemini-consultant.md` exists. For a follow-up consultation on the same context, tell the subagent to use `--resume latest` rather than starting a fresh session.

4. **Integrate findings.** Based on Gemini's output, propose concrete next actions scaled to severity and volume: blocking/critical issues — **explicitly suggest creating a new sub-task for each issue found**; single architectural blocker — offer a design decision or ADR; list of medium/minor fixes — offer to implement directly or batch into a PR. Do not relay findings without a proposed action.

## Prompt templates

All templates assume Claude has already produced an analysis or implementation. Gemini's job is to **challenge** it, not duplicate it. Three hard rules apply to every template (these come from the debate rules that lifted detection from 53% to 80% in the Magpie benchmark):

1. **Evidence rule** — every finding must cite `file:line` (or a verbatim snippet). Claims without a code reference are rejected.
2. **No verdict-first reasoning** — lead with evidence, conclude with verdict. Gemini's known failure mode is opening with a strong verdict and backfilling; this rule blocks it.
3. **No empty agreement** — if Gemini agrees with Claude on a point, it must explain *why* (which evidence supports it), not just "agreed" or "good point".

Select the template that matches the user's goal:

- Correctness, design, edge cases, broken behavior → **Adversarial code review**
- Service boundaries, coupling, scalability, system-level design → **Architecture challenge**
- Auth, injection, data exposure, compliance, supply chain → **Security audit**
- Specific bug, unexpected behavior, failing test, root-cause hunt → **Debugging consult**
- Hard problem needing multi-round back-and-forth → **Iterative debate** (use `--resume latest`)

Combine templates when scope spans multiple concerns.

**Adversarial code review**
```
Role: Senior Staff Engineer acting as an adversarial reviewer.
Context: Claude has already reviewed/implemented this code. Your job is to challenge Claude's conclusions, not duplicate them. Assume Claude is competent on deep logic and data-structure lifecycle — focus your effort where Claude is statistically weakest:

  - Concurrency, data races, lock semantics, ordering assumptions
  - Cross-version / cloud-storage / deprecated-SDK API compatibility
  - Missing permission, authorization, or access checks
  - Structural / engineering-standards issues (coupling, layering, naming consistency)

Rules:
  1. Every finding must cite file:line (or a verbatim snippet). No claim without code reference.
  2. Lead with evidence, conclude with verdict. Do not assert "this is bad" before showing the trace.
  3. If you agree with Claude on a point, explain *why* — what evidence in the code supports it. Do not say "agreed" alone.

Deliverable: a markdown table with columns: File/Line | Severity (Blocking/Significant/Minor) | Issue | Evidence (code reference) | Suggested Fix.
Skip trivial style nits unless they indicate a systemic pattern.
```

**Architecture challenge**
```
Role: Senior Staff Engineer / Security Architect acting as an adversarial reviewer.
Context: Claude reviewed this architecture. Challenge Claude's structural conclusions. Lean into Gemini's strength: structural critique, engineering standards, service boundaries, missing failure modes.

Rules:
  1. Every concern must cite a specific file, interface, or contract.
  2. Lead with the observed coupling/risk, conclude with the structural verdict.
  3. Propose a concrete alternative for each concern — not "consider refactoring".

Deliverable: a markdown table with columns: Component | Risk | Evidence (code reference) | Concrete Alternative.
Exclude low-risk cosmetic concerns.
```

**Security audit**
```
Role: Senior Staff Engineer / Security Architect acting as an adversarial reviewer.
Context: Claude reviewed the security posture. Challenge Claude's conclusions. Bias toward Gemini's known strengths vs Claude:

  - Missing permission / authorization checks (Claude misses these)
  - API compatibility risks (deprecated auth flows, insecure defaults from older SDK versions)
  - Concurrency-related security issues (TOCTOU, races in auth/session code)

Rules:
  1. Every vulnerability must cite file:line and the specific call/sink/source.
  2. Lead with the attack path, conclude with severity.
  3. If Claude flagged something already, either confirm with new evidence or refute with a code reference.

Deliverable: a markdown table with columns: Severity (Critical/High/Medium/Low) | CVE Class | Affected Scope | Evidence (code reference) | Attack Path | Recommendation.
```

**Debugging consult**
```
Role: Senior Staff Engineer acting as an adversarial debugger.
Context: Claude has been investigating this bug. Challenge Claude's working hypotheses with alternatives — do not re-derive Claude's leading theory.

Symptoms / repro / Claude's current hypothesis: <fill in>

Rules:
  1. Every hypothesis must cite the file:line that supports it.
  2. Distinguish root cause from contributing factor explicitly per row.
  3. For each hypothesis, give a one-step diagnostic that would confirm or rule it out.
  4. Include at least one hypothesis that disagrees with Claude's leading theory, if any plausible one exists.

Deliverable: a markdown table with columns: Rank | Hypothesis | Type (Root Cause / Contributing) | Evidence | Diagnostic Step | Agrees-with-Claude (yes/no).
```

**Iterative debate** (use after a prior consult; subagent runs with `--resume latest`)
```
Role: Senior Staff Engineer continuing an adversarial debate.
Context: You previously reviewed this code. Claude has now responded to your findings — see Claude's rebuttal below. Update your position.

Claude's rebuttal:
<paste verbatim>

Rules:
  1. For each of your prior findings, state: HELD / WITHDRAWN / REVISED, with one sentence of code-cited reasoning.
  2. No empty agreement — withdrawing a finding requires citing the evidence that changed your mind.
  3. Surface any new findings Claude's rebuttal revealed.
  4. Keep debate chains to ≤3 rounds; Gemini grows inconsistent in later rounds (benchmark observation). Start a fresh session for new scope.

Deliverable: a markdown table with columns: Prior Finding | Status (Held/Withdrawn/Revised) | Code-Cited Reason | New Implication (if any).
```

## Claude's known blind spots — scan against these

When writing any of the templates above, explicitly ask Gemini whether the change introduces any of:

- **Concurrency races** (lock semantics, ordering, TOCTOU, missing synchronization)
- **API compatibility breaks** (cross-version SDK behavior, deprecated calls, cloud-storage semantics)
- **Missing permission / authorization checks** at function or route boundaries
- **Structural / layering violations** (cross-module coupling, naming inconsistency)

This bias is what makes the Claude+Gemini pair efficient: their misses barely overlap.

## Failure modes to counter in Gemini's output

- **"Comes in hot"** — opens with a strong verdict, then backfills justification. *Counter:* evidence-first rule above.
- **Stays at the surface** — doesn't trace call chains as far as Claude. *Counter:* name the specific blind-spot categories in the prompt; require file:line.
- **Drifts in later debate rounds** — keep `--resume latest` chains to ≤3 rounds.
- **Lower actionability score (peer-eval 7.2 vs Claude/Qwen 8.6)** — Gemini's fixes are often vaguer than its diagnoses. *Counter:* templates require a "Suggested Fix" / "Concrete Alternative" column, not free-text recommendations.

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
