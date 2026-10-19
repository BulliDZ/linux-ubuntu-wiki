---
title: Useful Obsidian plugins for reading this wiki
level: L1
distros:
  ubuntu:
    - "24.04"
requires: []
risk: changes-system
last_tested: Oct 19
tags:
  - start-here
  - obsidian
---

# Useful Obsidian plugins for reading this wiki

## TL;DR

You don't need any community plugins. The built-in (core) ones already cover search, outline, and graph. Install community plugins only if you understand the warning below.

## When you need this

You've [opened the wiki in Obsidian](get-this-wiki.md) and want faster search, better navigation, or a way to filter pages by level or risk.

## Commands


There's nothing to run in a terminal. Everything is under **Settings** (gear icon, bottom left).

### Core plugins (built in, safe)

**Settings → Core plugins**. These ship with Obsidian and are maintained by its developers.

| Plugin | Why it helps here |
|--------|-------------------|
| **Search** | Full-text search across every page. `Ctrl+Shift+F` |
| **Quick switcher** | Jump to a page by name. `Ctrl+O` |
| **Outline** | Shows a page's headings in the sidebar. Lets you jump straight to *If it doesn't work*. |
| **Backlinks** | Shows which pages link *to* the one you're reading |
| **Graph view** | Map of how pages connect. Pretty, occasionally useful. |
| **Page preview** | Hover a link with `Ctrl` held to peek without leaving the page |
| **Command palette** | Every Obsidian action by name. `Ctrl+P` |
| **File recovery** | Snapshots of *your* `_personal/` notes in case you delete something |
| **Canvas** | A whiteboard for arranging notes and arrows. Use it in `_personal/` only; `.canvas` files don't render on GitHub. |

### Community plugins (optional, read the warning first)

> [!CAUTION]
> Community plugins are third-party code with **the same access as your user account**: every file in your home folder, your network, your SSH keys. Obsidian does not sandbox them. Install only plugins you need, from authors with a track record, and keep the list short.

To install: **Settings → Community plugins → Turn on community plugins → Browse**.

| Plugin | What it does                                                                                              | Who it's for |
| -------------- | --------------------------------------------------------------------------------------------------------- | ----------------------------------- |
| **Dataview** | Queries page frontmatter: "every L1 page", "every `destructive` page". Use it in `_personal/` notes only. | Anyone who wants a custom index |
| **Omnisearch** | Fuzzy, typo-tolerant keyword search that ranks results better than core Search. Not AI.                   | Readers who search a lot |
| **QuickAdd** | Hotkeys to capture quick notes into `_personal/`                                                          | Optional, personal note-taking only |

Plugins for *writing* pages (Linter, Advanced Tables, Excalidraw) aren't listed here because readers don't edit shared pages. Maintainers: see [CONTRIBUTING](CONTRIBUTING.md#maintainer-tooling).

> [!WARNING]
> **Don't use Obsidian Git** (or any auto-commit plugin) on this repo. It's built to commit and push on a timer. You have read-only access, so the best case is constant failed pushes and noise. The worst case is local commits that make your next `git pull` fail. Update with `git pull` in a terminal.

## What the output means

A Dataview query that lists every page with its level and risk. Put it in a note **inside `_personal/`**, never in a shared page:

````markdown
```dataview
TABLE level, risk, last_tested
FROM -"_personal" AND -"_templates"
WHERE level
SORT level ASC
```
````

Sample result:

- `level`, `risk`, `last_tested`: columns read straight from each page's frontmatter
- `WHERE level`: only pages that *have* a level, which skips README, roadmaps, etc.
- A page that's missing from the table is missing its frontmatter. Tell the maintainer.

## If it doesn't work

- **`git pull` blocked by `.obsidian/core-plugins.json` or `community-plugins.json`** → turning a plugin on or off changed a shared settings file → see [recovering from a failed pull](get-this-wiki.md#if-it-doesnt-work).
- **A Dataview block shows as plain code** → Dataview isn't installed or enabled. Also normal on GitHub, which never runs plugins.
- **Community plugins section is greyed out** → Restricted mode is on. That's the default and the safe state. Turn it off only if you've read the caution above.

## Go deeper (L2 / L3)

- **Why plugin choices cause pull conflicts:** the list of enabled plugins lives in `.obsidian/`. If that file is committed, every reader who toggles a plugin modifies a tracked file. Maintainer decision: commit only the core-plugin list and gitignore `community-plugins.json` and `plugins/`, so community plugins stay personal. TODO-TEST: confirm against the repo's `.gitignore`.
- **Checking a plugin before you trust it:** every community plugin links to its GitHub source. Look at the last commit date, open issues, and how many people use it. An abandoned plugin with broad file access is a liability.

## Related

- [Get this wiki onto your machine](get-this-wiki.md)
- [Which Ubuntu am I on + how this wiki works](which-os-and-how-this-works.md)
