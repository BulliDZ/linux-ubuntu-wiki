---
title: "Week 3 lab: the internet doesn't work"
level: L1
type: lab
distros:
  ubuntu: ["24.04"]
requires: [multipass]
risk: changes-system
last_tested: TODO-TEST   # set after all 5 faults were broken and fixed on a real VM
tags: [labs, onboarding, networking]
---

# Week 3 lab: the internet doesn't work

A hands-on exercise for the [week 3 checkpoint](../../onboarding/intern-path.md#week-3--networking). A script breaks the network in a throwaway VM in one of five realistic ways. The intern finds which one using the [runbook](../../05-networking/internet-doesnt-work-runbook.md) and fixes it. A second script confirms the fix.

| File | Who uses it | What it does |
|------|-------------|--------------|
| `week3-break.sh` | Intern (or mentor) | Applies **one random** network fault, then reboots the VM |
| `week3-check.sh` | Both | Says whether the network is healthy again |
| `MENTORS.md` | **Mentors only** | The five faults, how to diagnose each, what to listen for. Spoilers. |

---

## For interns

### What it's for

Reading about networking isn't the same as fixing it. In this lab something really is broken, and you don't know what. It's the same situation you'll be in when your own machine stops working, except here nothing is at stake. The goal isn't just a passing check: it's to be able to say **which of the six steps failed and how you proved it**.

### How to do it

> [!WARNING]
> Run this **only in a lab VM**, never on your own machine. The script refuses to run outside a VM, but don't rely on that.

1. Make a fresh VM (see [Get a throwaway VM](../../00-start-here/practice-vm.md)):

   ```bash
   multipass launch 24.04 --name week3
   ```

2. Break it. From your wiki folder:

   ```bash
   multipass exec week3 -- sudo bash < labs/week3-network/week3-break.sh
   ```

3. Wait ~30 seconds for the reboot, then go in:

   ```bash
   multipass shell week3
   ```

4. **Your task:** `sudo apt update` fails. Find out why and fix it. Work through the runbook **in order**, out loud or in writing. Note what each command told you.

5. When you think it's fixed, check (from your wiki folder):

   ```bash
   multipass exec week3 -- sudo bash < labs/week3-network/week3-check.sh
   ```

6. Once it says `PASS`, show your mentor: what was broken, how you found it, how you fixed it.

### Rules

- **Fix the cause, not the symptom.** The check script notices workarounds, like hard-coding a DNS server into `/etc/resolv.conf`.
- **Don't read `week3-break.sh`, `MENTORS.md`, or `/root/.lab-week3-answer`.** You have `sudo` in the VM, so nothing is truly hidden. Peeking only wastes your own practice.
- **Rebooting won't fix it.** The fault is persistent on purpose.
- **Stuck for 30+ minutes?** Ask your mentor for a hint about *which runbook step* to look at again. Don't ask for the answer.
- Want another round? `multipass delete week3 --purge` and start again. You'll likely get a different fault.

---

## For mentors

### What it's for

It replaces "mentor breaks something by hand," which differs every time and is hard to grade. Each run picks one of five faults that map onto the runbook's six steps, so every intern gets a comparable exercise. The check script makes "done" objective. What you assess is the **diagnosis path**, not just the outcome; `MENTORS.md` says what a good one sounds like.

### How to run it

- **Intern runs it themselves** (the default, shown above). The fault is random, and you look it up afterwards:

  ```bash
  multipass exec week3 -- sudo cat /root/.lab-week3-answer
  ```

- **You pick the fault**, e.g. to give a second intern a different one:

  ```bash
  multipass exec week3 -- sudo FAULT=4 bash < labs/week3-network/week3-break.sh
  ```

- **Grade** with every check visible:

  ```bash
  multipass exec week3 -- sudo DETAILS=1 bash < labs/week3-network/week3-check.sh
  ```

- **Reset** the VM without recreating it:

  ```bash
  multipass exec week3 -- sudo MODE=undo bash < labs/week3-network/week3-break.sh
  ```

### Before the first intern

> [!IMPORTANT]
> Every fault is untested (`TODO-TEST`). Run all five yourself with `FAULT=1` … `FAULT=5`: break, confirm `multipass shell` still works, diagnose with the runbook, fix, run the check. A lab that locks the intern out or can't be fixed teaches the wrong lesson.

## If it doesn't work

- **`this does not look like a VM`** → you're on a real machine. Good, the guard worked.
- **`this VM is already broken`** → fix the current fault first, or use `MODE=undo`.
- **`multipass shell` hangs after the break** → a fault cut off the shell connection. That's a bug in the lab, not the intern's fault. Tell the maintainer which fault it was (mentor: check the answer file via `multipass exec`, or recreate the VM).
- **Check fails, but everything seems to work** → run it with `DETAILS=1` to see which check fails, then report it if it's wrong.

## Related

- [Intern onboarding path](../../onboarding/intern-path.md)
- [The "internet doesn't work" runbook](../../05-networking/internet-doesnt-work-runbook.md)
- [Networking concepts, no commands](../../05-networking/networking-concepts.md)
- [Get a throwaway VM](../../00-start-here/practice-vm.md)
