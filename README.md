# Linux Ubuntu Wiki

A practical reference for using Ubuntu day-to-day: package management, services,
monitoring, files/users, and networking. Written for a small team where everyone
administers their own machine.

**Target OS:** Ubuntu **24.04 LTS** (the standard for this team).
Where 22.04 LTS still differs in a way that bites, a page calls it out explicitly.
22.04 standard support ends April 2027 — plan to be off it before then.

> This is a reference wiki *and* an Obsidian vault. It renders fine on GitHub in
> the browser, and opens as a vault in Obsidian for offline reading and search.

---

## Start here

1. **[Get this wiki onto your machine](00-start-here/get-this-wiki.md)** — clone, open
   in Obsidian, keep it updated, and recover if `git pull` ever fails.
2. **[Useful Obsidian plugins](00-start-here/obsidian-plugins.md)** — what's built in, what's
   worth adding, and why community plugins need care.
3. **[Get a throwaway VM you're allowed to break](00-start-here/practice-vm.md)** — try any
   command here before running it on your real machine.
4. **[Which Ubuntu am I on + how this wiki works](00-start-here/which-os-and-how-this-works.md)**
5. New to the terminal? **[Terminal survival](00-start-here/terminal-survival.md)**

If you're a new intern, follow the **[onboarding path](onboarding/intern-path.md)**
in order instead of browsing randomly.

---

## How pages are labelled

Every page has a **level** so you know how deep it goes:

| Level | Who it's for | Example |
|-------|--------------|---------|
| **L1** | Everyday user — just make the machine work | "My disk is full, what do I delete?" |
| **L2** | Power user — comfortable in the terminal | writing a cron job, reading `ss` states |
| **L3** | Admin / network config — changes system behaviour | `netplan`, hardening `sshd` |

Every command block says which Ubuntu version it was tested on. Every page that
changes the system has a **risk** tag in its frontmatter (`read-only`,
`changes-system`, or `destructive`) and a warning callout on the dangerous bits.

Most pages are **how-to** pages: commands, what the output means, what to do when it
fails. A few are **concept** pages (`type: concept`): no commands, just the mental model
the how-to pages assume — e.g. [networking concepts](05-networking/networking-concepts.md).
Read those first when a section has one.

---

## Map

| # | Section | What's in it |
|---|---------|--------------|
| 00 | [Start here](00-start-here/) | Get the wiki, Obsidian, a practice VM, terminal basics, `sudo`, getting help |
| 01 | [Packages & software](01-packages-and-software/) | apt, snap, flatpak, `.deb`, updates |
| 02 | [Services & system](02-services-and-system/) | `systemctl`, **which services not to stop**, `journalctl` |
| 03 | [Monitoring & hardware](03-monitoring-and-hardware/) | CPU / RAM / GPU load, disk, device specs |
| 04 | [Files, dirs & users](04-files-dirs-users/) | find, create/move/delete safely, permissions, users |
| 05 | [Networking](05-networking/) | concepts, your IP, `nmcli`/`netplan`, DNS, the troubleshooting runbook |
| 06 | [SSH & remote](06-ssh-remote/) | connect, copy files, keys |
| — | [Onboarding](onboarding/) | The intern path: what to read, week by week, with checkpoints |
| — | [Labs](labs/) | Hands-on exercises that break a VM on purpose, e.g. [week 3 networking](labs/week3-network/README.md) |
| — | [Appendix](appendix/) | glossary, cheat sheets, legacy→modern command map |

Folders starting with `_` aren't reading material: `_assets/` (diagrams),
`_templates/` (page templates), `_maintainers/` (maintainer how-tos),
`_personal/` (your own notes, never synced).

---

## Rules for readers

- This repo is **read-only** for you. Pull to get updates; don't commit.
- Want to take your own notes? Put them in **`_personal/`** — it never syncs, so it
  can't conflict and can't be overwritten. Never edit a shared page to add a note.
- **Never run lab scripts (`labs/`) on your real machine** — only in a throwaway VM.
- Found a mistake or a gap? Tell a maintainer (see below). Don't fix it in place.

## Maintainers

Currently: **Vova**. Corrections and "please add a page on X" go to the maintainer.

## Conventions for maintainers

See **[CONTRIBUTING.md](CONTRIBUTING.md)** before writing or editing a page.
