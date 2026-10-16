---
title: Get this wiki onto your machine
level: L2
distros:
  ubuntu: ["24.04"]
requires: [git]
risk: changes-system
last_tested: TODO-TEST   # set after running every command on a clean 24.04 VM
tags: [start-here, git, obsidian]
---

<!-- TODO-TEST: before publishing, `grep -n TODO-TEST` this file and resolve every hit:
  1. Replace <ORG>/<REPO> with the real repo path (4 places)
  2. Confirm the default branch is `main` (used in the reset --hard command)
  3. Confirm `sudo snap install obsidian --classic` works on 24.04
  4. Confirm the 22.04 `gh` note is still true, or delete it
  5. Paste REAL output from your VM into "What the output means"
  6. Set last_tested to the test date
-->

# Get this wiki onto your machine

## TL;DR

First time:

```bash
git clone git@github.com:BulliDZ/linux-ubuntu-wiki.git

```

Every time after that, to get the latest pages:

```bash
cd ~/linux-ubuntu-wiki && git pull
```

## When you need this

You've been added to the wiki repo and want to read it offline in Obsidian. You also want it to stay up to date without ever getting stuck on a broken `git pull`.

## Commands

> Tested on: **Ubuntu 24.04**

### 1. Install git

```bash
sudo apt update && sudo apt install -y git
git --version
```

### 2. Get access to the private repo

This repo is private, so GitHub needs to know who you are. Pick **one** option.

**Option A: SSH key (recommended)**

```bash
ssh-keygen -t ed25519 -C "you@example.com"   # press Enter to accept defaults; set a passphrase
cat ~/.ssh/id_ed25519.pub                     # copy this whole line
```

Paste the copied line into GitHub → **Settings → SSH and GPG keys → New SSH key**. Then check it worked:

```bash
ssh -T git@github.com
```

**Option B: GitHub CLI** (if you'd rather not deal with keys)

```bash
sudo apt install -y gh
gh auth login            # choose GitHub.com → SSH or HTTPS → log in via browser
```

> [!NOTE]
> On Ubuntu 22.04, `gh` from the default apt repositories is old. If `gh auth login` misbehaves, install it from GitHub's official apt repository instead.

### 3. Clone

```bash
git clone git@github.com:BulliDZ/linux-ubuntu-wiki.git
 ~/linux-ubuntu-wiki   # TODO-TEST: real repo path
```

### 4. Install Obsidian and open the vault

```bash
sudo snap install obsidian --classic
```

Open Obsidian → **Open folder as vault** → select `~/linux-ubuntu-wiki`.
When Obsidian asks, choose **Trust author and enable plugins**. The shared settings (relative links, templates folder) only take effect if you do.

### 5. Stay up to date

```bash
cd ~/linux-ubuntu-wiki && git pull
```

Do this whenever you sit down to read. It's safe as long as you follow the rules below.

> [!IMPORTANT]
> **Never edit shared pages.** Put your own notes in `_personal/`. Git never tracks that folder, so a pull can't conflict with it or overwrite it.

## What the output means

A normal update:

```
Updating 3f2a1c0..8b7d9e4
Fast-forward
 05-networking/internet-doesnt-work-runbook.md | 42 +++++++++++
 1 file changed, 42 insertions(+)
```

- `Fast-forward`: new pages arrived cleanly. This is what you want to see.
- `Already up to date.`: there was nothing new.

A pull that's blocked:

```
error: Your local changes to the following files would be overwritten by merge:
        .obsidian/app.json
Please commit your changes or stash them before you merge.
Aborting
```

- You (or Obsidian) changed a tracked file. Nothing was lost; git refused to proceed. See below.

## If it doesn't work

- **`Permission denied (publickey)`** → GitHub doesn't know your SSH key. Redo step 2, or check that `ssh -T git@github.com` greets you by name.
- **`Repository not found`** → you haven't been given access yet, or the URL has a typo. Ask the maintainer.
- **`Your local changes ... would be overwritten`** → you changed a shared file, often without meaning to (e.g. by changing an Obsidian setting). See what changed:

  ```bash
  git status
  ```

  Keep your changes aside and update anyway:

  ```bash
  git stash && git pull
  ```

  If you don't care about your local edits, reset to exactly what's on GitHub:

  > [!WARNING]
  > This **permanently discards** every change you made to tracked files. `_personal/` is untouched.

  ```bash
  git fetch origin && git reset --hard origin/main   # TODO-TEST: confirm branch name
  ```

- **`fatal: not a git repository`** → you're in the wrong folder. Run `cd ~/linux-ubuntu-wiki` first.

## Go deeper (L2 / L3)

- **Why Obsidian settings cause conflicts:** `.obsidian/` is partly shared (committed) and partly personal (gitignored, e.g. `workspace.json`). If you change a *shared* setting, you've modified a tracked file and your next pull blocks. Personal UI tweaks are fine. Settings like link format are not; ask the maintainer instead.
- **Prevent accidental commits:** you have read-only access, so `git push` will fail anyway. `git pull --ff-only` additionally refuses to create surprise merge commits:

  ```bash
  git config --global pull.ff only
  ```

- **Undo a stash later:** `git stash list` shows your stashes; `git stash pop` puts the latest one back.

## Related

- [Which Ubuntu am I on + how this wiki works](which-os-and-how-this-works.md)
- [SSH keys & config](../06-ssh-remote/ssh-keys-and-config.md)
