---
name: verifying-work
description: Use before claiming an implementation, refactor, or fix is done, and when planning multi-step work where each step needs a check. Covers the baseline-first rule, what counts as a check that can fail, the per-step loop, end-of-task scope confirmation via git diff --stat, and how to report a gap honestly.
---

# Verifying work

A claim of "done" is worth exactly the command output behind it. This is how to produce that output.

## Baseline first

Run the existing build and tests before changing anything. Without a baseline you cannot tell your failure from one that was already there, so you will either chase someone else's bug or ship your own believing it was pre-existing. Find the commands in the Makefile, `package.json`, the project docs, or the CI config; ask rather than guess when they are not discoverable.

If the baseline is already red, say so before starting and get direction. Do not build on top of it and hope.

## A step is not done until its check has run

Plan work past roughly ten lines as numbered steps, each carrying the check that proves it:

> Step 2: add the `tenant_id` column and backfill it. Check: run the migration against a restored copy, confirm zero remaining nulls in `tenant_id`.

The check has to be capable of failing. "Confirm the code looks right" is not a check. After each step: build or typecheck, run the tests covering that step, and read `git diff` to confirm you changed only what the step named. Catching drift at step two is cheap. Catching it at step nine means unpicking everything built on it.

## At the end

1. Full test suite, not only the tests you were watching.
2. `git diff --stat` against the scope you predicted at the start. Every file traces to the request, or it does not belong in the diff.
3. Trace the primary path by hand, entry point to result, confirming data actually flows rather than that each unit passes in isolation.
4. Re-read the original request, not the plan you wrote from it. Plans drift from intent, and this is the step that catches it.
5. Sweep for leftovers: debug output, commented-out code, scaffolding TODOs you added, stray files in `tmp/`.

## Reporting honestly

State what ran and what it said. Name any check that did not run and why, because an unmentioned gap reads as a check that passed. Show a failure rather than describing it. Verification reported plainly is worth more than a confident summary, and a "done" that turns out to be untested spends the trust that makes the next one believable.
