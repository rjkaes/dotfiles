#!/usr/bin/env node
// Hide chosen plugin skills from the model's skill listing.
//
// Why: each skill's name and description sit in the model's context every
// session. skillOverrides in settings.json cannot hide them; the docs say
// "Plugin skills are not affected by skillOverrides". The frontmatter key
// `disable-model-invocation: true` does hide a skill, so this hook inserts it.
//
// Effect: the skill leaves the model's listing and the model cannot call it
// through the Skill tool. The user can still run it as /name.
//
// Rule for adding an entry: hide only a skill that nothing else invokes through
// the Skill tool (another skill, agent, or command that says "use the X skill").
// Grep the plugin for the skill name first.
//
// Rejected alternatives:
//   - skillOverrides: ignored for plugin skills.
//   - Editing SKILL.md once by hand: a plugin update installs a fresh version
//     dir with the original file. Hence re-applying on SessionStart.
//
// Fail safe: a missing dir, a file without frontmatter, or an unreadable file
// is skipped. A file that already has the key (any value) is left alone.
//
// Takes effect at the next session start, when the skill listing is built.
import { readFileSync, readdirSync, writeFileSync } from "node:fs";
import { join, resolve } from "node:path";
import { homedir } from "node:os";

// Skill dirs relative to plugins/cache. A "*" segment matches any one dir
// (the version dir).
const SKILL_DIRS = [
  // Its body is already injected every session by the SessionStart hook, and
  // /ponytail mode switching runs in the UserPromptSubmit hook, not the skill.
  "ponytail/ponytail/*/skills/ponytail",
  // Overlap pairs: keep the copy other skills invoke, hide the duplicate.
  // superpowers:test-driven-development is a REQUIRED SUB-SKILL of
  // executing-plans. Breaks: mattpocock /implement says "Use /tdd".
  "claude-plugins-official/mattpocock-skills/*/skills/engineering/tdd",
  // using-superpowers, injected every session, routes bugs to
  // superpowers:systematic-debugging. /diagnosing-bugs stays user-invocable.
  "claude-plugins-official/mattpocock-skills/*/skills/engineering/diagnosing-bugs",
  // verifying-work encodes the done-check-must-fail rule and the local
  // agents name it. Breaks: executing-plans:219 and systematic-debugging:189
  // point here, so that Skill call fails; verifying-work is listed instead.
  "claude-plugins-official/superpowers/*/skills/verification-before-completion",
  // Its template praises ("### Strengths") and writes to /tmp; nothing
  // invokes it through the Skill tool. mattpocock code-review stays.
  "claude-plugins-official/superpowers/*/skills/requesting-code-review",
  // mattpocock writing-for-agents covers skills and CLAUDE.md edits.
  "claude-plugins-official/superpowers/*/skills/writing-skills",
];

const KEY = "disable-model-invocation: true";

// Honors CLAUDE_CONFIG_DIR, matching the context-mode hooks.
function cfgDir() {
  const e = process.env.CLAUDE_CONFIG_DIR;
  if (e && e.trim() !== "") {
    return e.startsWith("~") ? resolve(homedir(), e.replace(/^~[/\\]?/, "")) : resolve(e);
  }
  return resolve(homedir(), ".claude");
}

function expand(base, segments) {
  if (segments.length === 0) return [base];
  const [head, ...rest] = segments;
  if (head !== "*") return expand(join(base, head), rest);
  let names = [];
  try { names = readdirSync(base); } catch { /* missing dir */ }
  return names.flatMap((n) => expand(join(base, n), rest));
}

const cacheDir = join(cfgDir(), "plugins", "cache");
for (const rel of SKILL_DIRS) {
  for (const dir of expand(cacheDir, rel.split("/"))) {
    const file = join(dir, "SKILL.md");
    try {
      const src = readFileSync(file, "utf8");
      const m = src.match(/^---\r?\n([\s\S]*?)\r?\n---/);
      if (!m || /^disable-model-invocation:/m.test(m[1])) continue;
      const eol = src.includes("\r\n") ? "\r\n" : "\n";
      // Insert as the last frontmatter line, just before the closing fence.
      const end = m[0].length - 3;
      writeFileSync(file, src.slice(0, end) + KEY + eol + src.slice(end));
    } catch { /* no such skill dir or file */ }
  }
}

// Silent by design: SessionStart stdout is injected into the session context.
