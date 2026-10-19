---
title: Get a throwaway VM you're allowed to break
level: L2
distros:
  ubuntu:
    - "24.04"
requires:
  - snapd
risk: changes-system
last_tested: TODO-TEST
tags:
  - start-here
  - labs
  - multipass
  - vm
  - testing
---

<!-- TODO-TEST: before publishing, `grep -n TODO-TEST` this file and resolve every hit:
  1. Confirm --memory (vs older --mem) on the current multipass version
  2. Confirm snapshot/restore syntax, including whether restore prompts and --destructive skips the prompt
  3. Confirm which networking breaks keep `multipass shell` alive (fill the table from real tests)
  4. Paste REAL `multipass list` and `multipass info` output
  5. Confirm the GNOME Boxes install route on 24.04
  6. Set last_tested
-->

# Get a throwaway VM you're allowed to break

## TL;DR

```bash
sudo apt install multipass
multipass launch 24.04 --name sandbox --cpus 2 --memory 4G --disk 20G
multipass shell sandbox
```

You're now inside a disposable Ubuntu. Break anything you like.

## When you need this

- **Interns:** every checkpoint where a mentor "breaks something" happens here, never on your real machine.
- **Maintainers:** golden rule #1 says every command is run on 24.04 before it's published. This is where.
- **Anyone** who wants to try a command from the wiki before running it for real.

## Commands

> Tested on: **Ubuntu 24.04** host, 24.04 guest TODO-TEST

### 1. Check your machine can run VMs

```bash
grep -c -E 'vmx|svm' /proc/cpuinfo
```

Any number above `0` is fine. `0` means virtualization is off in your BIOS/UEFI. Turn on **Intel VT-x** or **AMD-V** there, then reboot.

### 2. Install and launch

```bash
sudo snap install multipass
multipass launch 24.04 --name sandbox --cpus 2 --memory 4G --disk 20G   # TODO-TEST: --memory vs --mem
```

The first launch downloads the Ubuntu image, which takes a few minutes. Later launches are fast.

### 3. Work inside it

```bash
multipass shell sandbox      # opens a terminal inside; you're user "ubuntu" with sudo
exit                         # back to your real machine
```

Run a single command without opening a shell:

```bash
multipass exec sandbox -- ip a
```

### 4. Snapshot before you break anything

This is the habit that makes the VM worth having.

```bash
multipass stop sandbox
multipass snapshot sandbox --name clean
multipass start sandbox
```

After you've broken it:

> [!WARNING]
> Restoring **throws away everything** done in the VM since that snapshot.

```bash
multipass stop sandbox
multipass restore sandbox.clean     # TODO-TEST: does it prompt? --destructive skips the prompt
multipass start sandbox
```

### 5. Share the wiki with the VM (maintainers)

```bash
multipass mount ~/linux-ubuntu-wiki sandbox:/home/ubuntu/wiki
```

Edit pages on your real machine, and test the commands in the VM on the same files.

### 6. Throw it away

> [!WARNING]
> `--purge` deletes the VM and all its snapshots permanently.

```bash
multipass delete sandbox --purge
```

## What the output means

```
TODO-TEST: paste real `multipass list` output
Name          State       IPv4            Image
sandbox       Running     10.x.x.x        Ubuntu 24.04 LTS
```

- `State`: `Running`, `Stopped`, `Suspended`, or `Deleted` (deleted but not yet purged; `multipass recover sandbox` brings it back).
- `IPv4`: the VM's address on a private network between your machine and the VM. It's how `multipass shell` connects. Keep this in mind for the next section.

For CPU, RAM, disk, and snapshot details:

```bash
multipass info sandbox
```

## Breaking networking safely

[Networking checkpoints](../onboarding/intern-path.md#week-3--networking) break the network on purpose. The catch: **`multipass shell` itself reaches the VM over the network.** Break the wrong thing and you've locked yourself out.

| What you break | Safe in Multipass? | Why |
|----------------|--------------------|-----|
| DNS | ✅ Yes TODO-TEST | Your shell uses an IP, not a name |
| Default route | ✅ Yes TODO-TEST | Host and VM share a local subnet; no gateway needed |
| A port / firewall rule on another port | ✅ Yes | SSH (port 22) unaffected |
| Firewall blocking port 22 | ❌ No | That's the port your shell uses |
| Interface down / DHCP lease | ❌ No | The VM loses the address your shell connects to |

**Locked out anyway?** Restart the VM; a reboot usually undoes temporary changes like `ip route del` or `ip link set down`:

```bash
multipass restart sandbox
```

If the change was permanent (a config file), restore the snapshot from step 4.

For the ❌ rows, use a desktop VM. It has a screen and keyboard, so it works with the network gone.

## Desktop VM (for Obsidian, and for the ❌ rows)

Multipass VMs have **no desktop**, so you can't test Obsidian, GUI apps, or Wi-Fi settings in one.

```bash
sudo apt install -y gnome-boxes      # TODO-TEST: confirm apt vs flatpak route on 24.04
```

Download the **Ubuntu 24.04 Desktop** ISO from ubuntu.com, create a VM from it in Boxes, and **take a snapshot right after installation** (Boxes: VM → Properties → Snapshots).

## If it doesn't work

- **`launch failed: ... KVM ...`** → virtualization is off. See step 1.
- **Launch hangs or times out** → the image download is slow, or a VPN on your host is interfering. Retry with the VPN off.
- **`multipass shell` hangs after you broke networking** → you hit a ❌ row. `multipass restart sandbox`, or restore the snapshot.
- **Running inside a VM already** (e.g. a work laptop that's itself virtual) → needs nested virtualization, often unavailable. Use a physical machine.

## Go deeper (L2 / L3)

- **Several VMs at once** simulate a small network: `multipass launch 24.04 --name client` plus `--name server`, then practise SSH and `ufw` between them (week 4).
- **Cloud-init:** `multipass launch --cloud-init config.yaml` preinstalls packages and users, so every intern gets an identical lab in one command. Worth adding once labs are standardised.

## Related

- [Intern onboarding path](../onboarding/intern-path.md)
- [Networking concepts, no commands](../05-networking/networking-concepts.md)
- [Get this wiki onto your machine](get-this-wiki.md)
