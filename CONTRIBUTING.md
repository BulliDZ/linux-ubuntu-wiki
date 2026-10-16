# Contributing (maintainers only)

This wiki is read-only for the team. Only maintainers write pages. These rules keep
pages consistent, correct, and safe to copy-paste from.

## Golden rules

1. **Test before you publish.** Every command in a page must have been run on a real
   Ubuntu 24.04 machine (or VM). Record the date in the page's `last_tested`
   frontmatter. A wrong command in a wiki is worse than no wiki.
2. **Target 24.04.** Only mention 22.04 where it genuinely differs and someone still
   runs it. Delete those notes once the team is fully on 24.04.
3. **Relative links only.** `../05-networking/ports.md`, never a full `https://github.com/...`
   URL. Absolute links break in Obsidian and break again if the repo ever moves.
4. **No `[[wikilinks]]`.** The vault is configured for standard Markdown links so GitHub
   renders them. Obsidian inserts them for you with this config.
5. **Callouts: only the five GitHub supports** — `> [!NOTE]`, `> [!TIP]`,
   `> [!IMPORTANT]`, `> [!WARNING]`, `> [!CAUTION]`. Others render as plain quotes on GitHub.
6. **No secrets, ever.** No real internal IPs, hostnames, usernames, or tokens. Use
   placeholders: `<LAB_SUBNET>`, `user@host`, `192.0.2.0/24` (TEST-NET), `example.com`.
   Git history is permanent — a deleted secret is still in history.
7. **Shared pages contain only GitHub-renderable Markdown.** No Dataview queries,
   Obsidian Charts blocks, `.canvas` files, or raw `.excalidraw.md` drawings in shared
   pages. Diagrams go in `_assets/` as exported SVG/PNG and are linked with a standard
   image link: `![Layered runbook](../_assets/runbook.svg)`. This is also what makes
   pages exportable with pandoc — see
   [export to docx/pdf](_maintainers/export-to-docx-pdf.md).

## Page template

Copy `_templates/page-template.md`. Keep the fixed section order so readers at every
level know where to look:

1. **TL;DR** — the one command an L1 reader needs. Nothing else.
2. **When you need this**
3. **Commands** — each block tagged with the version(s) it was tested on. Version
   differences go in a `> [!NOTE]` callout, not scattered inline.
4. **What the output means** — annotated real output. For non-specialists this is the
   most valuable section; don't skip it.
5. **If it doesn't work** — common failures and fixes.
6. **Go deeper (L2 / L3)** — advanced material, so beginners can stop before it.
7. **Related** — link at least one other page so nothing is orphaned in the graph.

## Page types

Every page declares a `type` in its frontmatter. There are exactly four. Pick the
first one that fits, top to bottom:

| `type` | Use it when the page… | Template | Example |
|--------|------------------------|----------|---------|
| `how-to` | …helps the reader do one task (**default**) | `page-template.md` | `00-start-here/get-this-wiki.md` |
| `concept` | …explains ideas, with **zero** commands | `concept-template.md` | `05-networking/concepts-no-commands.md` |
| `lab` | …is a hands-on exercise in a throwaway VM | `lab-template.md` | `labs/week3-network/README.md` |
| `path` | …walks the reader through other pages in order | none (free-form) | `onboarding/intern-path.md` |

Don't invent a fifth type. If a page fits none of these, split it until each part does.

**Not pages, no `type` needed:** the top-level `README.md`, `CONTRIBUTING.md`,
`ROADMAP-*.md`, `*.LOCAL.md`, and anything in `_templates/`, `_assets/`, `_personal/`.
Future CI skips these by path.

### `how-to` pages

Use the 7-section order above.

### `concept` pages

A page that explains ideas and contains **zero runnable commands** uses
`_templates/concept-template.md`. Its section order:

1. **TL;DR** — the one idea to remember, ideally with a diagram
2. **When you need this**
3. **The concepts** — one `###` per concept, plain language, one consistent analogy
4. **Check yourself** — 3–5 questions, answers in a collapsed `<details>` block
5. **Related** — must link the command page(s) where the concepts get used

Rules, so this doesn't become a loophole:

- Frontmatter must have `type: concept` and `risk: read-only`.
- **One command block disqualifies it.** If you need to show a command, it's a normal page.
- `last_tested` records the date a **second person reviewed the facts**, since there's nothing to run.
- Every concept page needs at least one command page linking back to it.

### `lab` pages

An exercise where something is broken **on purpose** in a throwaway VM. A lab lives in its
own folder under `labs/` and is built from `_templates/lab-template.md`:

```
labs/<weekN-topic>/
├── README.md          type: lab — for interns AND mentors
├── MENTORS.md         type: lab — answer key, starts with a CAUTION "interns stop here"
├── <topic>-break.sh   applies the fault(s); refuses to run outside a VM
└── <topic>-check.sh   pass/fail; exit 0 = solved
```

README section order:

1. **Intro** — one paragraph plus a table of the folder's files and who uses each
2. **For interns** — *What it's for*, *How to do it* (numbered), *Rules*
3. **For mentors** — *What it's for*, *How to run it*, *Before the first intern*
4. **If it doesn't work**
5. **Related** — must link the `how-to` page(s) the lab exercises

Rules:

- `risk: changes-system` on the README; `risk: read-only` on `MENTORS.md`.
- The break script **must** refuse to run on a non-VM (`systemd-detect-virt --quiet`).
- Faults must survive a reboot, or rebooting "fixes" them and teaches nothing.
- The check script must also catch workarounds, not just the symptom.
- `last_tested` = the date **every** fault was broken and fixed on a real VM.

### `path` pages

A reading order through other pages, with checkpoints. Free-form, but:

- Every link must point to a page that exists or is on the roadmap.
- `risk: read-only`; `last_tested` = the date someone last walked the path end to end.

## Frontmatter (required)

```yaml
---
title: Find what's listening on a port
level: L1                 # L1 | L2 | L3  (highest level the page reaches)
distros:
  ubuntu: ["24.04"]       # list every tested version; add "22.04" only if verified
requires: [iproute2]      # packages the commands need (apt names)
risk: read-only           # read-only | changes-system | destructive
type: how-to              # how-to | concept | lab | path  (see "Page types")
last_tested: 2026-10-15
tags: [networking, ports]
---
```

CI will reject a page missing `level`, `distros`, or `risk` once CI is enabled.
For now, treat these as mandatory by hand.

## Definition of done

- [ ] Follows the template section order
- [ ] Every command run on 24.04, `last_tested` set
- [ ] At least one annotated output example
- [ ] `risk` correct; every `changes-system`/`destructive` command has a `> [!WARNING]`
- [ ] Links to ≥1 related page
- [ ] No secrets, no absolute links, no non-standard callouts
- [ ] Only GitHub-renderable Markdown; diagrams are exported images in `_assets/`
- [ ] `grep -n TODO-TEST` on the page returns nothing

## Maintainer tooling

Community plugins run unsandboxed with your user's full access. Keep this list short.

| Tool | Use it for | Rule |
|------|------------|------|
| **Linter** (plugin) | Consistent formatting and frontmatter on save | Configure it to match this file; never let it reorder template sections |
| **Advanced Tables** (plugin) | Editing big tables (e.g. the services table) | No rule; harmless |
| **Excalidraw** (plugin) | Drawing networking diagrams | Keep sources in `_assets/src/`; **export SVG** to `_assets/` and link only the SVG |
| **Templates** (core plugin) | Inserting `_templates/page-template.md` | Use this, not Templater — the template has no dynamic fields, and Templater executes code |
| **pandoc** (CLI) | Exporting pages to `.docx` / `.pdf` | See [export to docx/pdf](_maintainers/export-to-docx-pdf.md) |

Do **not** commit `.obsidian/community-plugins.json` or `.obsidian/plugins/`.
Plugin choices are personal; committing them causes pull conflicts for every reader.

## What lives where

- `_templates/` — `page-template.md` (how-to), `concept-template.md`, `lab-template.md` (committed, shared).
- `labs/` — one folder per lab exercise (see `lab` pages above).
- `_assets/` — diagrams and screenshots as exported SVG/PNG. Drawing sources in `_assets/src/`.
- `_maintainers/` — maintainer-only how-tos (export, tooling). Committed; not part of the reader path.
- `_personal/` — gitignored. Reader scratch space. Nothing here is ever committed.
- `ROADMAP-ubuntu.md` — the backlog and checklist for this repo.
- `ROADMAP-kali.LOCAL.md` — **gitignored on purpose.** Working notes for the future
  Kali/OSINT repo. Never commit it; it moves to the private Kali repo later.
