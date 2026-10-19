---
title: "Week 3 lab: mentor answer key"
level: L2
type: lab
distros:
  ubuntu: ["24.04"]
requires: [multipass]
risk: read-only
last_tested: TODO-TEST   # set after every fault below was broken and fixed on a real VM
tags: [labs, onboarding, networking, mentors]
---

# Week 3 lab: mentor answer key

> [!CAUTION]
> **Interns: stop here.** This page has the answers. Reading it ruins your exercise.

The intern always gets the same brief: *"`sudo apt update` fails. Find out why and fix it."* The fault behind it is one of these five. Every symptom, command, and fix below is **TODO-TEST** until you've run it on a real VM.

## The five faults at a glance

| # | Fault | Runbook step | Ping by IP | Names resolve | Web works |
|---|-------|--------------|------------|---------------|-----------|
| 1 | Dead DNS server (netplan) | 4 – DNS | ✅ | ❌ | ❌ |
| 2 | Poisoned `/etc/hosts` | 4 – DNS | ✅ | ⚠️ wrong IP for apt mirrors only | ⚠️ everything except apt |
| 3 | `systemd-resolved` disabled | 4 – DNS | ✅ | ❌ | ❌ |
| 4 | No default route | 3/5 – gateway/route | ❌ (outside the subnet) | ✅ | ❌ |
| 5 | Firewall blocks outbound 80/443 | 6 – port | ✅ | ✅ | ❌ |

Three of the five are DNS on purpose. DNS is the most common real-world cause, and the three look alike from the outside while having completely different causes. Telling them apart is the skill.

## Fault by fault

### 1. Dead DNS server

- **What was done:** `/etc/netplan/99-lab-week3.yaml` ignores DHCP's DNS and sets `192.0.2.53`, a documentation address that never answers.
- **Good diagnosis path:** `ip a` (has IP) → `ip r` (has default route) → `ping -c3 1.1.1.1` works → `ping example.com` fails → `resolvectl status` shows `192.0.2.53` as the link's DNS server → "where does that come from?" → `ls /etc/netplan/`.
- **Fix:** delete the file, then `sudo netplan apply`.
- **Listen for:** do they distinguish "network is down" from "names don't resolve" *before* touching anything? Do they ask where a DNS setting comes from, rather than just overriding it?
- **Workaround to reject:** writing `nameserver 1.1.1.1` into `/etc/resolv.conf`. The check script fails it.

### 2. Poisoned `/etc/hosts`

- **What was done:** lines added to `/etc/hosts` mapping apt's mirror hosts to `203.0.113.80`, which doesn't answer.
- **Good diagnosis path:** general connectivity is fine → `curl -I https://ubuntu.com` works → `apt update` shows the mirror hostname failing → `getent hosts archive.ubuntu.com` returns `203.0.113.80` → `resolvectl query archive.ubuntu.com` returns a *different*, real address → "something before DNS answers first" → `/etc/hosts`.
- **Fix:** delete those lines. Takes effect immediately.
- **Listen for:** this is the hardest one. The key insight is that `getent` and `resolvectl` disagree. An intern who only uses `ping` and `dig` may never find it, because `dig` bypasses `/etc/hosts` [Likely]. Hint if stuck for 30+ min: *"compare what different tools say the address is."*

### 3. `systemd-resolved` disabled

- **What was done:** `systemctl disable --now systemd-resolved`.
- **Good diagnosis path:** ping by IP works, names fail → `cat /etc/resolv.conf` shows `nameserver 127.0.0.53` → "is anything listening there?" → `systemctl status systemd-resolved` shows inactive (dead) and disabled.
- **Fix:** `sudo systemctl enable --now systemd-resolved`.
- **Listen for:** a link back to week 2 (services). Do they use `enable --now`, not just `start`? `start` passes the check today but breaks again after a reboot. Ask them to reboot and run the check again.

### 4. No default route

- **What was done:** `/etc/netplan/99-lab-week3.yaml` sets `dhcp4-overrides: use-routes: false`, so DHCP's default route is ignored.
- **Good diagnosis path:** `ip a` (has IP) → `ip r` shows only the local subnet, **no `default via` line** → `ping` the gateway (works, same subnet) → `ping 1.1.1.1` fails with `Network is unreachable` → "why no default route?" → netplan.
- **Fix:** delete the file, then `sudo netplan apply`.
- **Listen for:** the error wording matters. `Network is unreachable` (no route) is different from a timeout (the route exists but something's blocking). Names still resolve, because the DNS server is on the local subnet. Did they notice that, and does it confuse them?
- **Workaround to reject:** `sudo ip route add default via …` works until the next reboot. Ask them to reboot and run the check again.

### 5. Firewall blocks outbound web

- **What was done:** `ufw` denies outgoing TCP 80 and 443, and allows SSH in.
- **Good diagnosis path:** IP, route, ping, and DNS all fine → `curl -v http://archive.ubuntu.com` hangs at "Trying …" → "packets aren't getting out on this port" → `sudo ufw status verbose` shows the `DENY OUT` rules.
- **Fix:** `sudo ufw status numbered`, then `sudo ufw delete <n>` for both rules (re-check the numbers after the first delete, because they shift).
- **Listen for:** "the network works, but this port doesn't" is the step-6 lesson. Did they look at the firewall *because the evidence pointed there*, or by guessing?
- **Workaround to reject:** `sudo ufw disable`. It passes the check, but in a real environment it removes protection. Discuss it; don't fail them for it.

## Grading

Pass the checkpoint if the intern can:

1. Name the failed runbook step **and the evidence** that proved it
2. Explain the root cause, not only the fix
3. Make the fix survive a reboot (check script passes after `multipass restart week3`)

The time taken doesn't matter. Guessing your way to a fix doesn't pass; give them another fault.

## Related

- [Lab README](README.md)
- [The "internet doesn't work" runbook](../../05-networking/internet-doesnt-work-runbook.md)
