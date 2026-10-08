#!/usr/bin/env node
// Make the ponytail plugin inject its short ruleset instead of SKILL.md.
//
// Why: ponytail-instructions.js getPonytailInstructions() injects the whole
// skills/ponytail/SKILL.md body (about 5.2k chars) at SessionStart and again
// at every SubagentStart. The same file holds getFallbackInstructions(mode),
// about 2.7k chars, maintained by the plugin author with the same rules.
// Saves about 2.5k chars per session and per subagent.
//
// Patch: in getPonytailInstructions, the SKILL.md read
//   filterSkillBodyForMode(fs.readFileSync(SKILL_PATH, 'utf8'), effectiveMode)
// becomes
//   getFallbackInstructions(effectiveMode).replace(/^[^\n]*\n\n/, '')
// The replace drops the fallback's own "PONYTAIL MODE ACTIVE" line, because the
// caller already prefixes one.
//
// Trade-off: the fallback drops the "lazy senior developer" persona lines, the
// intensity table and worked example, and the `Pattern:` output line. It is
// author-maintained, so a plugin update can change it without notice.
//
// Rejected alternatives:
//   - Disabling the plugin: loses the rules entirely.
//   - Editing SKILL.md: the /ponytail skill body must stay whole.
//   - Editing once by hand: a plugin update installs a fresh version dir with
//     the original file. Hence re-applying on SessionStart.
//
// Fail safe: if the anchor text is absent (already patched, or the plugin code
// changed), the file is left alone and the full text loads as before.
//
// Takes effect at the next hook run: the hook scripts are required fresh per
// session and per subagent. A session already started keeps its injected text.
import { readdirSync, readFileSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { homedir } from "node:os";

const ANCHOR = "filterSkillBodyForMode(fs.readFileSync(SKILL_PATH, 'utf8'), effectiveMode)";
const REPLACEMENT = "getFallbackInstructions(effectiveMode).replace(/^[^\\n]*\\n\\n/, '')";

// Honors CLAUDE_CONFIG_DIR, matching the context-mode hooks.
function cfgDir() {
  const e = process.env.CLAUDE_CONFIG_DIR;
  if (e && e.trim() !== "") {
    return e.startsWith("~") ? resolve(homedir(), e.replace(/^~[/\\]?/, "")) : resolve(e);
  }
  return resolve(homedir(), ".claude");
}

const cacheDir = join(cfgDir(), "plugins", "cache", "ponytail", "ponytail");
try {
  for (const version of readdirSync(cacheDir)) {
    const file = join(cacheDir, version, "hooks", "ponytail-instructions.js");
    try {
      const src = readFileSync(file, "utf8");
      // Replace only when the anchor occurs exactly once.
      if (src.split(ANCHOR).length === 2) {
        writeFileSync(file, src.replace(ANCHOR, () => REPLACEMENT));
      }
    } catch { /* no such version dir or file */ }
  }
} catch { /* ponytail not installed */ }

// Silent by design: SessionStart stdout is injected into the session context.
