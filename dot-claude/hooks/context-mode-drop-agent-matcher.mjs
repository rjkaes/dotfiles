#!/usr/bin/env node
// Remove context-mode's PreToolUse "Agent" matcher from the plugin's hooks.json.
//
// Why: routing.mjs (`if (canonical === "Agent")`) returns action:"modify" and
// appends its <context_window_protection> block to every outgoing subagent
// prompt. Under `permissions.defaultMode: "auto"`, Claude Code's permission
// classifier reads that third-party block inside a spawn prompt as injected
// instructions and vetoes the dispatch itself — intermittently, mid-workflow
// (upstream mksglu/context-mode#967, #946, #911).
//
// Rejected alternatives:
//   - Allow-listing "Agent" in permissions.allow: does not work. The auto-mode
//     classifier sits above the permission-rule layer, so no allow rule exempts
//     it (confirmed in #946).
//   - An upstream opt-out: #832 asked for an env var and was closed; there is
//     no config toggle, so the matcher has to be deleted.
//   - Editing hooks.json by hand: plugin auto-update copies a fresh, unpatched
//     hooks.json into the new version dir. Hence re-applying on SessionStart.
//
// Scope of the loss: only subagent prompt injection. The plugin's SessionStart
// block and its other eight PreToolUse matchers (Bash, Read, Grep, WebFetch,
// mcp__*) still fire, so main-session routing to ctx_* is unchanged. Tool-
// restricted subagents (gemini-consultant, technical-writer, spec-reviewer)
// could never act on the injected block anyway — no ctx_* in their allowlist.
//
// Takes effect from the next session: Claude Code reads plugin hooks.json at
// startup, so the strip lands before the following session, not the current one.
import { existsSync, readFileSync, writeFileSync, readdirSync, statSync, realpathSync } from "node:fs";
import { join, resolve } from "node:path";
import { homedir } from "node:os";

// Honors CLAUDE_CONFIG_DIR at runtime, matching context-mode-cache-heal.mjs.
function cfgDir() {
  const e = process.env.CLAUDE_CONFIG_DIR;
  if (e && e.trim() !== "") {
    return e.startsWith("~") ? resolve(homedir(), e.replace(/^~[/\\]?/, "")) : resolve(e);
  }
  return resolve(homedir(), ".claude");
}

// Both the recorded installPath and every version dir under the plugin cache:
// auto-update stages a new version dir, and older dirs are symlinks to the
// live one, so realpath-dedupe covers all of them with one write.
function pluginRoots(cfg) {
  const roots = new Set();

  const installedPlugins = join(cfg, "plugins", "installed_plugins.json");
  if (existsSync(installedPlugins)) {
    try {
      const parsed = JSON.parse(readFileSync(installedPlugins, "utf-8"));
      for (const [key, entries] of Object.entries(parsed.plugins || {})) {
        if (!key.toLowerCase().includes("context-mode")) continue;
        for (const entry of entries || []) if (entry?.installPath) roots.add(entry.installPath);
      }
    } catch { /* malformed manifest — fall through to the cache scan */ }
  }

  const cacheDir = join(cfg, "plugins", "cache", "context-mode", "context-mode");
  if (existsSync(cacheDir)) {
    try {
      for (const dir of readdirSync(cacheDir)) {
        const candidate = join(cacheDir, dir);
        try { if (statSync(candidate).isDirectory()) roots.add(candidate); } catch { /* dangling link */ }
      }
    } catch { /* unreadable cache dir */ }
  }

  const resolved = new Set();
  for (const root of roots) {
    try { resolved.add(realpathSync(root)); } catch { /* gone */ }
  }
  return resolved;
}

// Token-level so a future combined matcher ("Bash|Agent") keeps its other
// tools instead of the whole entry disappearing. "Task" is the pre-2.0 name.
function withoutAgent(matcher) {
  const tokens = String(matcher ?? "").split("|");
  const kept = tokens.filter((token) => {
    const name = token.trim();
    return name !== "Agent" && name !== "Task";
  });
  return kept.length === tokens.length ? null : kept.join("|");
}

for (const root of pluginRoots(cfgDir())) {
  const hooksPath = join(root, "hooks", "hooks.json");
  if (!existsSync(hooksPath)) continue;
  try {
    const parsed = JSON.parse(readFileSync(hooksPath, "utf-8"));
    const preToolUse = parsed?.hooks?.PreToolUse;
    if (!Array.isArray(preToolUse)) continue;

    let changed = false;
    const kept = [];
    for (const entry of preToolUse) {
      const rewritten = withoutAgent(entry?.matcher);
      if (rewritten === null) { kept.push(entry); continue; }
      changed = true;
      if (rewritten !== "") kept.push({ ...entry, matcher: rewritten });
    }
    if (!changed) continue;

    parsed.hooks.PreToolUse = kept;
    writeFileSync(hooksPath, JSON.stringify(parsed, null, 2) + "\n", "utf-8");
  } catch { /* best effort — never block the session */ }
}

// Silent by design: SessionStart stdout is injected into the session context.
