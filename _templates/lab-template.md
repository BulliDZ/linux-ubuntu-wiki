---
title: "Week <N> lab: <the symptom the intern is told about>"
level: L1
type: lab
distros:
  ubuntu: ["24.04"]
requires: [multipass]
risk: changes-system
last_tested: TODO-TEST   # date EVERY fault was broken and fixed on a real VM
tags: [labs, onboarding]
---

<!-- TODO-TEST: before publishing, `grep -n TODO-TEST` this file and resolve every hit:
  1. Create MENTORS.md (type: lab, risk: read-only) with the answer key
  2. Write <topic>-break.sh: refuses non-VMs, faults survive a reboot
  3. Write <topic>-check.sh: exit 0 = solved, catches workarounds
  4. Break and fix EVERY fault on a real VM; set last_tested
  Then delete this comment.
-->

# Week <N> lab: <symptom>

A hands-on exercise for the [week <N> checkpoint](intern-path.md#<anchor>). <One or two sentences: what gets broken and what the intern uses to find it.>

| File | Who uses it | What it does |
|------|-------------|--------------|
| `<topic>-break.sh` | Intern (or mentor) | <what it breaks> |
| `<topic>-check.sh` | Both | Says whether it's fixed |
| `MENTORS.md` | **Mentors only** | Answer key. Spoilers. |

---

## For interns

### What it's for

<Why doing this beats reading about it. What they should be able to explain at the end.>

### How to do it

> [!WARNING]
> Run this **only in a lab VM**, never on your own machine.

1. Make a fresh VM: `multipass launch 24.04 --name week<N>`
2. Break it:

   ```bash
   multipass exec week<N> -- sudo bash < labs/<folder>/<topic>-break.sh
   ```

3. Go in: `multipass shell week<N>`
4. **Your task:** <the one-line symptom>
5. Check:

   ```bash
   multipass exec week<N> -- sudo bash < labs/<folder>/<topic>-check.sh
   ```

6. Show your mentor what was broken, how you found it, and how you fixed it.

### Rules

- Fix the cause, not the symptom.
- Don't read the break script, `MENTORS.md`, or the answer file.
- Stuck for 30+ minutes? Ask for a hint, not the answer.

---

## For mentors

### What it's for

<What this replaces, and what you're assessing: the diagnosis path, not just the outcome.>

### How to run it

- **Pick a fault:** `... sudo FAULT=<n> bash < ...`
- **Grade:** `... sudo DETAILS=1 bash < <topic>-check.sh`
- **Reset:** `... sudo MODE=undo bash < <topic>-break.sh`

### Before the first intern

> [!IMPORTANT]
> Break and fix every fault yourself first.

## If it doesn't work

- **<symptom>** → <cause> → <fix>

## Related

- [<How-to page this lab exercises>](../../<section>/<page>.md)
- [Get a throwaway VM](practice-vm.md)
