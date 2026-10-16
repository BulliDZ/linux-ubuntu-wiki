---
title: Intern onboarding path
level: L1
type: path
distros:
  ubuntu: ["24.04"]
requires: []
risk: read-only
last_tested: 2026-10-15
tags: [onboarding]
---

# Intern onboarding path

Follow this in order. Don't browse randomly yet — that comes later. Each week ends
with a **checkpoint** you complete and show a mentor. The goal is that after ~2–3
weeks you can handle your own machine without asking someone to sit with you.

> [!TIP]
> Do everything in a throwaway VM first (see [practice safely](#practice-safely)), not on a
> machine you can't afford to break. Breaking things on purpose is how you learn.

---

## Week 1 — Survive

**Read:**
- [Get a throwaway VM](practice-vm.md) — set this up first
- [Get this wiki](get-this-wiki.md)
- [Which Ubuntu am I on + how this works](../00-start-here/which-os-and-how-this-works.md)
- [Terminal survival](../00-start-here/terminal-survival.md)
- [Getting help](../00-start-here/getting-help.md)
- [sudo](../00-start-here/sudo.md)
- [Updating the system](../01-packages-and-software/updating-the-system.md)

**Checkpoint:**
- [ ] State your exact Ubuntu version and explain the difference between an LTS and an interim release
- [ ] Update the whole system cleanly
- [ ] Find a specific file somewhere under your home folder from the terminal
- [ ] Explain, in your own words, what the last `sudo` command you ran actually did

## Week 2 — Own your machine

**Read:**
- [Permission denied](../04-files-dirs-users/permission-denied.md)
- [Files & folders basics](../04-files-dirs-users/files-and-folders-basics.md)
- [What's using my CPU/RAM](../03-monitoring-and-hardware/whats-using-my-cpu-ram.md)
- [systemctl basics](../02-services-and-system/systemctl-basics.md)
- [When a service fails](../02-services-and-system/when-a-service-fails.md)

**Checkpoint:**
- [ ] Fix a "Permission denied" the mentor planted, and explain why it happened
- [ ] Find and kill a runaway process
- [ ] A mentor stops/breaks a service — find which one and why, using `journalctl`
- [ ] Explain one service from the "don't stop these" table and what breaks if you kill it

## Week 3 — Networking

**Read:**
- [Networking concepts (no commands)](concepts-no-commands.md)
- [What's my IP / am I connected](../05-networking/whats-my-ip-am-i-connected.md)
- [Connections and ports](../05-networking/connections-and-ports.md)
- [The "internet doesn't work" runbook](../05-networking/internet-doesnt-work-runbook.md)

**Checkpoint:**
- [ ] Draw your machine → router → internet and label IP, gateway, DNS
- [ ] Complete the [week 3 lab](labs/week3-network/README.md): a script breaks your VM's
      network in one of five ways — diagnose it by walking the runbook out loud, step by
      step, fix it, and get a `PASS` from the check script
- [ ] Show what's listening on your machine and explain two of the entries

## Week 4 — Remote & safe

**Read:**
- [SSH basics](../06-ssh-remote/ssh-basics.md)
- [SSH keys & config](../06-ssh-remote/ssh-keys-and-config.md)
- [Firewall (ufw)](../05-networking/firewall-ufw.md)
- The **L2 (Go deeper)** sections of the pages you've already read

**Checkpoint:**
- [ ] Set up key-based SSH to a lab VM (no password auth)
- [ ] Open exactly one port with `ufw` and confirm it: `ss` on one side, `nc` on the other
- [ ] Explain why you'd never expose SSH with password login to the internet

---

## Practice safely

Never run destructive commands on a machine you need. Use a disposable VM:

- **Multipass** (Ubuntu-native, fastest): `multipass launch 24.04 --name sandbox`
  then `multipass shell sandbox`. Blew it up? `multipass delete sandbox --purge` and relaunch.
- Or any VM in VirtualBox/GNOME Boxes with a snapshot you revert to.

Full setup, snapshots, and which network breaks are safe: **[Get a throwaway VM](practice-vm.md)**.

---

## When you're done

You've "completed onboarding" when you can do every checkpoint without help. After
that, the wiki is a reference — come back to specific pages as you hit real problems.

Cybersec interns: there's a separate Kali/OSINT track. You start it only after Week 4
and only inside the lab network.
