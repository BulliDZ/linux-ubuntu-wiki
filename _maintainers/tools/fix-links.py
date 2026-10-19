#!/usr/bin/env python3
"""Rewrite broken relative links so they point to the right file again.

Run from the repo root:   python3 _maintainers/tools/fix-links.py [--dry-run]

Use it after renaming or moving a page, or if Obsidian rewrote links as bare
filenames. For each link whose target doesn't exist, it tries, in order:
  1. the link as a path from the repo root   (labs/x/README.md written from onboarding/)
  2. a file elsewhere in the repo with the same name, if exactly one exists
  3. the RENAMED map below                    (old filename -> new path)
Anything it can't place is left untouched and reported. Anchors (#...) are kept.
Afterwards, run check-links.py to confirm.
"""
import os
import re
import subprocess
import sys
import urllib.parse

DRY = "--dry-run" in sys.argv
SKIP_DIRS = ("_templates/", "_personal/")
# Old name -> current path. Add a line here whenever you rename a page.
RENAMED = {
    "concepts-no-commands.md": "05-networking/networking-concepts.md",
    "networking concepts.md": "05-networking/networking-concepts.md",
}
LINK_RE = re.compile(r"(!?\[[^\]]*\]\()([^)\s]+)(\))")
FENCE_RE = re.compile(r"^\s*(```|~~~)")

files = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True).stdout.split("\n")
files = [f for f in files if f]
by_name = {}
for f in files:
    by_name.setdefault(os.path.basename(f), []).append(f)


def fix_target(src, target):
    if re.match(r"^[a-z][a-z0-9+.-]*:", target) or target.startswith("#"):
        return None
    path, sep, anchor = target.partition("#")
    path = urllib.parse.unquote(path)
    here = os.path.dirname(src)
    if not path or os.path.exists(os.path.normpath(os.path.join(here, path))):
        return None
    candidate = None
    if os.path.exists(path):                                      # 1. repo-root path
        candidate = path
    elif len(by_name.get(os.path.basename(path), [])) == 1:       # 2. unique filename
        candidate = by_name[os.path.basename(path)][0]
    elif os.path.basename(path) in RENAMED:                       # 3. renamed page
        candidate = RENAMED[os.path.basename(path)]
    if candidate is None or not os.path.exists(candidate):
        return False
    new = os.path.relpath(candidate, here or ".").replace(os.sep, "/")
    new = urllib.parse.quote(new, safe="/._-")
    return new + (sep + anchor if sep else "")


changed, unresolved = 0, []
for f in files:
    if not f.endswith(".md") or f.startswith(SKIP_DIRS):
        continue
    lines = open(f, encoding="utf-8").read().split("\n")
    in_fence, dirty = False, False
    for i, line in enumerate(lines):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if in_fence:
            continue

        def repl(m):
            global changed
            res = fix_target(f, m.group(2))
            if res is False:
                unresolved.append(f"{f}:{i + 1}: {m.group(2)}")
                return m.group(0)
            if res is None:
                return m.group(0)
            print(f"{f}:{i + 1}: {m.group(2)}  ->  {res}")
            changed += 1
            return m.group(1) + res + m.group(3)

        new_line = LINK_RE.sub(repl, line)
        if new_line != line:
            lines[i], dirty = new_line, True
    if dirty and not DRY:
        open(f, "w", encoding="utf-8").write("\n".join(lines))

print(f"\n{changed} link(s) {'would be ' if DRY else ''}fixed")
if unresolved:
    print(f"{len(unresolved)} left as-is (target not found anywhere; planned pages are expected here):")
    for u in unresolved:
        print(f"  {u}")
