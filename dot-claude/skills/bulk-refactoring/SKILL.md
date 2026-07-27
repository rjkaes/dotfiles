---
name: bulk-refactoring
description: Use when a change spans more than three files, repeats the same textual edit many times, or is a sweeping structural change (renames, signature changes, import rewrites, API migrations) across a codebase. Covers choosing between ast-grep, ruby -pi -e, and a throwaway script, plus the dry-run and verify-then-delete workflow. Read this instead of hand-editing file after file.
---

# Bulk refactoring

Editing thirty files by hand burns context, invites transcription errors, and produces a diff nobody can review for consistency. Express the change once as a rule, run it, then verify the result.

## Pick the tool by what you are matching

**Structure: `ast-grep`.** Anything that is a code construct: renames, signature changes, call sites, argument reordering, wrapping an expression. It matches the syntax tree, so it will not corrupt a string literal or a comment that happens to contain the same text.

- Single pattern: `ast-grep run --pattern '<pattern>' --rewrite '<replacement>' -l <lang> <path>`
- Needs constraints (only inside a class, only when an argument has a given type, relational matching): write a temp YAML rule and run `ast-grep scan --rule tmp/rule.yml`.
- Metavariables: `$NAME` captures one node, `$$$ARGS` captures a variable-length list.
- Run the pattern *without* `--rewrite` first and read the match list. The full rule-authoring reference lives in the `ast-grep` plugin skill, which has to be enabled in `settings.json` to load.

**Text: `ruby -pi -e`.** Only when the target genuinely is not code: comment bodies, string content, config values, prose in docs. `ruby -pi -e 'gsub(/old/, "new")' <files>`. Anchor the regex tightly, because a loose pattern here is exactly how a rename lands in the middle of an unrelated string.

**Neither fits: a throwaway script.** `.csx` via `dotnet-script`, `.ts` via `npx tsx`, written to `tmp/`. Reach for this when the transform needs real logic: reading one file to decide an edit in another, parsing and re-emitting, conditional rewrites. Last resort, because a script is one more thing you now have to debug.

## Workflow

1. Write the rule or script to `tmp/`.
2. Dry-run it. `ast-grep` without `--rewrite`; a script with its write step stubbed. Read the match list before it can do damage.
3. Compare the match count against your prediction. A rule matching 200 sites where you expected 30 is a wrong rule, not a large refactor. Fix it before running.
4. Run it.
5. `git diff --stat`, and confirm the file count and shape match the prediction. Spot-read two or three diffs, including one you expect to be atypical.
6. Build or typecheck. On failure, revert to a clean tree (`git checkout -- .`), fix the rule, and re-run. Hand-patching the output leaves the rule and the tree disagreeing, so the next run undoes your fix.
7. Delete the rule or script from `tmp/`.

## Reporting

Report the file count and the build result. Do not paste the rule, the script, or rewritten file contents into the conversation: that context cost is the whole reason to use tooling here.
