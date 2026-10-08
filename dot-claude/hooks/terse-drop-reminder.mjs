#!/usr/bin/env node
// Truncate the terse plugin's rules/REMINDER.md to zero bytes.
//
// Why: terse's UserPromptSubmit hook (`inject-rules.js UserPromptSubmit
// rules/REMINDER.md`) injects the file as additionalContext on every user
// prompt, about 577 chars per turn. inject-rules.js exits silently when the
// trimmed file is empty, so an empty REMINDER.md removes the injection.
//
// Trade-off: the terse README says the reminder counters style drift after 20
// to 30 turns. Without it, long sessions may drift. The Output Style stays in
// the system prompt, and the SubagentStart RULES.md injection is untouched.
//
// Rejected alternatives:
//   - A config or env knob: inject-rules.js reads none. The only inputs are
//     argv and CLAUDE_PLUGIN_ROOT.
//   - Disabling the plugin: drops the Output Style with it.
//   - Editing the file once by hand: plugin update installs a fresh version
//     dir with the original REMINDER.md. Hence re-applying on SessionStart.
//
// Takes effect at once: inject-rules.js reads the file on each prompt, so
// every prompt after this hook runs gets nothing.
import { readdirSync, statSync, truncateSync } from "node:fs";
import { join, resolve } from "node:path";
import { homedir } from "node:os";

// Honors CLAUDE_CONFIG_DIR, matching the context-mode hooks.
function cfgDir() {
  const e = process.env.CLAUDE_CONFIG_DIR;
  if (e && e.trim() !== "") {
    return e.startsWith("~") ? resolve(homedir(), e.replace(/^~[/\\]?/, "")) : resolve(e);
  }
  return resolve(homedir(), ".claude");
}

const cacheDir = join(cfgDir(), "plugins", "cache", "terse", "terse");
try {
  for (const version of readdirSync(cacheDir)) {
    const reminder = join(cacheDir, version, "rules", "REMINDER.md");
    try {
      if (statSync(reminder).size > 0) truncateSync(reminder, 0);
    } catch { /* no such version dir or file */ }
  }
} catch { /* terse not installed */ }

// Silent by design: SessionStart stdout is injected into the session context.
