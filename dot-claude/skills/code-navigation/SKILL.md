---
name: code-navigation
description: Use before renaming, moving, deleting, or changing the signature or type of an existing symbol, and when mapping the blast radius of a change. Routes between the language server (LSP), ast-grep, and grep, and lists what each one cannot see. Read this instead of assuming grep found every caller.
---

# Code navigation

Grep finds text. A rename needs every *reference*, which is a different set: grep misses overload resolution, re-exports, and inherited members, while inventing false hits inside strings and comments. Route by what you are actually asking.

## Language server, for anything structural

Each operation needs `filePath`, `line` (1-based), and `character` (1-based).

| Operation | The question it answers |
|----|-----------------|
| `findReferences` | Who touches this symbol? Authoritative blast radius before a rename or delete. |
| `goToDefinition` | Am I editing the right symbol? Resolves overloads and re-exports. |
| `documentSymbol` | What lives in this file? Inventory before restructuring it. |
| `workspaceSymbol` | Where is this symbol, when you do not know its file? |
| `goToImplementation` | Every concrete implementation, before changing an interface or abstract member. |
| `incomingCalls` | Every caller, before moving or deleting a function. |
| `outgoingCalls` | What this function depends on, before extracting it. |
| `hover` | The resolved type, before checking downstream consumers of a type change. |

## What the language server cannot see

It resolves code, so it is blind to references that are not code at analysis time:

- String references: reflection by name, `getattr`, DI registration under a string key, dynamic import.
- Configuration: a class name in YAML or JSON, a route registered in config, a serialized type discriminator.
- Templates and views, where the framework binds by convention rather than by reference.
- Generated code, and code behind a build step the server did not run.
- Tests that assemble a name dynamically.

Grep for these separately. A rename that satisfied `findReferences` and still broke at runtime almost always broke one of the above.

## ast-grep, for multi-file structural transforms

When the change is structural *and* spans many sites, `ast-grep` both finds and rewrites, which the language server will not do. See the `bulk-refactoring` skill.

## Order of operations

Map before editing: `findReferences` for the code set, grep for the string and config set, then check the total against what the plan assumed. A change that turns out to touch 50 call sites across 20 files is a scope change worth reporting before you start, not after.
