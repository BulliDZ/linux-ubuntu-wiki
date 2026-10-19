# Roadmap — Ubuntu Wiki

Status key: `[ ]` not started · `[d]` drafted, untested (has `TODO-TEST` markers) · `[~]` testing in progress · `[x]` done (tested + reviewed)

Target OS: **Ubuntu 24.04 LTS**. Note 22.04 differences only where verified.

> **Status (2026-10-19):** focus has moved to the Kali/OSINT track this week. Ubuntu pages
> are in maintainer review; Vova updates them as each review finishes. Nothing new is
> drafted here until the review pass and the snap clean-up below are done.
Audience: 6 daily users, each admins their own machine. Success = fewer basic
questions, faster intern onboarding (2–3 weeks), less mentor babysitting.

> **WIP limit:** no more than **3 pages at `[d]`** at once. Test before drafting more.
> A page leaves `[d]` only when `grep -n TODO-TEST <page>` returns nothing.
>
> **No snap.** Install instructions never use `snap`: it ships outdated, limited, or
> irrelevant builds. Use apt, the vendor's official `.deb`/apt repo, Flatpak, or AppImage,
> and say which and why. See "Snap clean-up" below.

---

## Phase 0 — Scaffold

- [x] Folder tree
- [x] README with track + level legend
- [x] CONTRIBUTING with page template rules
- [x] `_templates/page-template.md`
- [x] `_templates/concept-template.md` + concept-page rule in CONTRIBUTING
- [x] CONTRIBUTING rule 7 (GitHub-renderable only) + maintainer tooling section
- [x] `.gitignore` (Obsidian state, `_personal/`, Kali roadmap)
- [x] `.gitignore` rewritten as an allow-list (only `app.json`, `templates.json`, `core-plugins.json` tracked)
- [x] `.gitattributes` (LF line endings)
- [x] Shared `.obsidian/app.json` restored: Markdown links, relative paths, attachments into `_assets/`
- [x] First push (history cleaned: no `*.LOCAL.md`, no personal Obsidian state)
- [ ] Make the repo **private** — still public as of 2026-10-19
- [ ] Add 6 readers with **Read** role
- [ ] Protect `main` (optional at this scale, but cheap)
- [ ] Test VM — snap-free option to be decided (see Snap clean-up)
- [x] Fixed 27 broken links; `_maintainers/tools/check-links.py` + GitHub Action now check every push

## Phase 1 — L1 core (the pages interns hit in week 1)

Priority order = how early an intern trips over it. Write 1, 12, 14 first as
reference-quality examples of the template.

- [d] 1. `00-start-here/get-this-wiki.md` — clone, open in Obsidian, update, recover from failed pull
- [d] 1b. `00-start-here/obsidian-plugins.md` — core plugins, Dataview/Omnisearch, plugin security warning
- [d] 1c. `00-start-here/practice-vm.md` — ⚠ uses snap (Multipass); needs a snap-free rewrite. Multipass sandbox, snapshot/restore, safe vs unsafe network breaks, desktop VM; replaces "labs (to be written)" in intern-path
- [ ] 2. `00-start-here/which-os-and-how-this-works.md` — `os-release`, levels, how to read a page
- [ ] 3. `00-start-here/terminal-survival.md` — navigation, tab-complete, history, Ctrl+C, copy/paste
- [ ] 4. `00-start-here/getting-help.md` — `man`, `--help`, `tldr`
- [ ] 5. `00-start-here/sudo.md` — what it does, when to use it, when NOT to
- [ ] 6. `01-packages-and-software/updating-the-system.md` — apt update vs upgrade, reboot-required
- [ ] 7. `01-packages-and-software/installing-software.md` — apt vs vendor `.deb`/repo vs Flatpak vs AppImage; **why we don't use snap**, and how to remove snap-installed apps
- [ ] 8. `04-files-dirs-users/files-and-folders-basics.md` — copy/move/delete safely, archives
- [ ] 9. `04-files-dirs-users/finding-things.md` — `find`, `locate`, `grep` for the scared
- [ ] 10. `04-files-dirs-users/permission-denied.md` — read `ls -l`, fix the error
- [ ] 11. `03-monitoring-and-hardware/whats-using-my-cpu-ram.md` — `htop`, `free`, kill a frozen app
- [d] 12. `05-networking/networking-concepts.md` — concept page; diagrams in `_assets/network-home.svg`, `_assets/network-request-journey.svg`
- [ ] 13. `05-networking/whats-my-ip-am-i-connected.md` — `ip a`, `ip r`, local vs public IP
- [~] 14. `05-networking/internet-doesnt-work-runbook.md` — ⭐ highest value; drafted and revised by Vova; in review. Capture real output with the week 3 lab
- [ ] 15. `03-monitoring-and-hardware/disk-is-full.md` — `df`, `du`, `ncdu`
- [ ] 16. `appendix/glossary.md`

## Phase 2 — L2 depth (power user)

- [ ] `02-services-and-system/systemctl-basics.md` — status/start/stop/enable
- [ ] `02-services-and-system/services-you-must-not-stop.md` — ⭐ the safety table (service → what it does → safe to restart? → what breaks)
- [ ] `02-services-and-system/when-a-service-fails.md` — `journalctl -u`, reading unit failures
- [ ] `02-services-and-system/scheduled-jobs.md` — cron vs systemd timers
- [ ] `03-monitoring-and-hardware/gpu-load.md` — `nvidia-smi` / `intel_gpu_top` / `radeontop`
- [ ] `03-monitoring-and-hardware/device-specs.md` — `lscpu`, `lsblk`, `lsusb`, `inxi -Fxz`
- [ ] `04-files-dirs-users/permissions-chmod-chown.md` — numeric + symbolic, groups, umask
- [ ] `04-files-dirs-users/managing-users.md` — add/modify/delete users, the `sudo` group
- [ ] `05-networking/connections-and-ports.md` — `ss -tulpn`, `lsof -i`, reading states
- [ ] `05-networking/dns-on-ubuntu.md` — systemd-resolved, `resolvectl` (concepts page already links here)
- [ ] `06-ssh-remote/ssh-basics.md` — connect, host keys, `scp`/`rsync`
- [ ] `06-ssh-remote/ssh-keys-and-config.md` — keypairs, `~/.ssh/config`, agent
- [ ] `appendix/legacy-to-modern.md` — `ifconfig`→`ip`, `netstat`→`ss` map
- [ ] `appendix/cheat-sheet-L1.md` — one-page everyday commands

## Phase 3 — L3 (admin / network config)

- [ ] `05-networking/nmcli.md` — managing connections from CLI
- [ ] `05-networking/netplan.md` — static IP, config files (mostly servers)
- [ ] `05-networking/firewall-ufw.md` — ufw basics, Docker-bypasses-ufw gotcha
- [ ] `02-services-and-system/writing-a-unit-file.md`
- [ ] `04-files-dirs-users/acls-and-special-bits.md` — setfacl, SUID/SGID/sticky
- [ ] `06-ssh-remote/hardening-sshd.md` — no password auth, no root, fail2ban, socket activation note
- [ ] `appendix/distro-differences.md` — 22.04 vs 24.04 single source of truth

## Snap clean-up (blocks testing of the pages below)

- [ ] `00-start-here/get-this-wiki.md` — Obsidian via snap → official `.deb` or Flatpak (Flathub); decide one and say how it updates
- [ ] `00-start-here/practice-vm.md` — Multipass is snap-only on Linux → pick a snap-free VM tool (candidates: Incus from apt/Zabbly, libvirt + `virt-install` with cloud images, VirtualBox)
- [ ] `labs/week3-network/` README, MENTORS, `_templates/lab-template.md`, CONTRIBUTING lab section, `onboarding/intern-path.md` — all say `multipass exec/shell`; update once the VM tool is chosen
- [ ] CONTRIBUTING — add golden rule 8: no snap
- [ ] `README.md` map row 01 — drop "snap" from the Packages section description

## Review findings (2026-10-19)

- [x] Links: Obsidian had rewritten links as bare filenames (worked in Obsidian, 404 on GitHub). Fixed, and `app.json` restored so it doesn't recur
- [x] Concepts page renamed to `networking-concepts.md` (no space); its diagrams render again
- [x] `.gitattributes` added
- [ ] Turn on branch protection for `main` with the **Check links** status check required (Settings → Branches), so a broken link can't land on `main`

## Labs (`labs/`, hands-on checkpoint exercises)

- [d] `labs/week3-network/` — break/check scripts (5 random persistent faults) + README (interns & mentors) + MENTORS.md answer key; **test all 5 faults before the first intern**
- [ ] `labs/week2-services/` — same pattern: planted permission error, runaway process, broken service
- [ ] `labs/week4-ssh-ufw/` — two VMs, key-only SSH, one open port

## Maintainer pages (`_maintainers/`, not on the reader path)

- [d] `_maintainers/export-to-docx-pdf.md` — pandoc export; low priority, most unknowns

## Later / optional (not committed to)

- [ ] CI: markdownlint + link check + frontmatter validator incl. `type` and `TODO-TEST` grep (add at ~30 pages)
- [ ] Container smoke-test matrix (ubuntu:24.04)
- [ ] Staleness check on `last_tested` (Dataview query works as a stopgap)
- [ ] GitHub Pages / Quartz site for browser reading without Obsidian
- [ ] Full-wiki PDF/docx handout via pandoc

---

## Open questions to resolve as we go

- [ ] Which snap-free VM tool replaces Multipass for practice VMs and labs?
- [ ] Obsidian install: `.deb` (manual updates) or Flatpak (auto-updates, sandboxed)?

- [ ] Confirm the real "services you must not stop" list per actual team machines
      (depends on who runs Docker / VPN / SSH server)
- [ ] Collect the 5–10 questions people actually keep asking → turn each into a page
- [ ] Decide if/when to enable branch protection and CI
- [ ] Diagrams: keep the white SVG backgrounds, or make them dark-mode aware?
- [ ] Who is the "second reviewer" for concept pages until there's a second maintainer?
