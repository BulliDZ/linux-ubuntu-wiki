# Roadmap — Ubuntu Wiki

Status key: `[ ]` not started · `[d]` drafted, untested (has `TODO-TEST` markers) · `[~]` testing in progress · `[x]` done (tested + reviewed)

Target OS: **Ubuntu 24.04 LTS**. Note 22.04 differences only where verified.
Audience: 6 daily users, each admins their own machine. Success = fewer basic
questions, faster intern onboarding (2–3 weeks), less mentor babysitting.

> **WIP limit:** no more than **3 pages at `[d]`** at once. Test before drafting more.
> A page leaves `[d]` only when `grep -n TODO-TEST <page>` returns nothing.

---

## Phase 0 — Scaffold

- [x] Folder tree
- [x] README with track + level legend
- [x] CONTRIBUTING with page template rules
- [x] `_templates/page-template.md`
- [x] `_templates/concept-template.md` + concept-page rule in CONTRIBUTING
- [x] CONTRIBUTING rule 7 (GitHub-renderable only) + maintainer tooling section
- [x] `.gitignore` (Obsidian state, `_personal/`, Kali roadmap)
- [ ] `.gitignore`: add `.obsidian/community-plugins.json` and `.obsidian/plugins/`
- [x] `.gitattributes` (LF line endings)
- [x] Shared `.obsidian/` config (relative links, no wikilinks, templates folder)
- [ ] First commit + push to private GitHub repo ← **blocks testing of page 1**
- [ ] Add 6 readers with **Read** role
- [ ] Protect `main` (optional at this scale, but cheap)
- [ ] Test VM: `multipass launch 24.04 --name wiki-test` (+ a desktop VM for Obsidian checks)

## Phase 1 — L1 core (the pages interns hit in week 1)

Priority order = how early an intern trips over it. Write 1, 12, 14 first as
reference-quality examples of the template.

- [d] 1. `00-start-here/get-this-wiki.md` — clone, open in Obsidian, update, recover from failed pull
- [d] 1b. `00-start-here/obsidian-plugins.md` — core plugins, Dataview/Omnisearch, plugin security warning
- [d] 1c. `00-start-here/practice-vm.md` — multipass sandbox, snapshot/restore, safe vs unsafe network breaks, desktop VM; replaces "labs (to be written)" in intern-path
- [ ] 2. `00-start-here/which-os-and-how-this-works.md` — `os-release`, levels, how to read a page
- [ ] 3. `00-start-here/terminal-survival.md` — navigation, tab-complete, history, Ctrl+C, copy/paste
- [ ] 4. `00-start-here/getting-help.md` — `man`, `--help`, `tldr`
- [ ] 5. `00-start-here/sudo.md` — what it does, when to use it, when NOT to
- [ ] 6. `01-packages-and-software/updating-the-system.md` — apt update vs upgrade, reboot-required
- [ ] 7. `01-packages-and-software/installing-software.md` — apt vs snap vs flatpak vs `.deb`
- [ ] 8. `04-files-dirs-users/files-and-folders-basics.md` — copy/move/delete safely, archives
- [ ] 9. `04-files-dirs-users/finding-things.md` — `find`, `locate`, `grep` for the scared
- [ ] 10. `04-files-dirs-users/permission-denied.md` — read `ls -l`, fix the error
- [ ] 11. `03-monitoring-and-hardware/whats-using-my-cpu-ram.md` — `htop`, `free`, kill a frozen app
- [d] 12. `05-networking/concepts-no-commands.md` — concept page; diagrams in `_assets/network-home.svg`, `_assets/network-request-journey.svg`
- [ ] 13. `05-networking/whats-my-ip-am-i-connected.md` — `ip a`, `ip r`, local vs public IP
- [ ] 14. `05-networking/internet-doesnt-work-runbook.md` — **the layered flowchart** ⭐ highest value; reuse the journey diagram's 6 steps; write it *while* breaking a VM
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

- [ ] Confirm the real "services you must not stop" list per actual team machines
      (depends on who runs Docker / VPN / SSH server)
- [ ] Collect the 5–10 questions people actually keep asking → turn each into a page
- [ ] Decide if/when to enable branch protection and CI
- [ ] Diagrams: keep the white SVG backgrounds, or make them dark-mode aware?
- [ ] Who is the "second reviewer" for concept pages until there's a second maintainer?
