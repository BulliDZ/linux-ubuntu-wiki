#!/usr/bin/env python3
"""Check every relative link in the wiki and enforce the link rules from CONTRIBUTING.

Run from the repo root:   python3 _maintainers/tools/check-links.py
Exit code: 0 = no errors (warnings allowed), 1 = errors found.

ERRORS (fail the check):
  - a relative link whose target doesn't exist, unless the target is a planned page
    listed in ROADMAP-ubuntu.md
  - a [[wikilink]] or ![[embed]] outside code
  - a file or folder name containing a space
WARNINGS (reported, don't fail):
  - a link to a planned page that hasn't been written yet

Links inside fenced code blocks and `inline code` are ignored, so examples in
CONTRIBUTING and the templates don't count. Files in _templates/ are skipped.
"""
import os
import re
import subprocess
import sys
import urllib.parse

ROOT = os.getcwd()
ROADMAP = "ROADMAP-ubuntu.md"
SKIP_DIRS = ("_templates/", "_personal/")

LINK_RE = re.compile(r"!?\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
WIKILINK_RE = re.compile(r"!?\[\[[^\]]+\]\]")
FENCE_RE = re.compile(r"^\s*(```|~~~)")
INLINE_CODE_RE = re.compile(r"`[^`]*`")


def tracked_files():
    out = subprocess.run(["git", "ls-files"], capture_output=True, text=True, check=True)
    return [f for f in out.stdout.splitlines() if f]


def strip_code(text):
    """Yield (line_number, line) with fenced blocks removed and inline code blanked."""
    in_fence = False
    for n, line in enumerate(text.splitlines(), 1):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            continue
        if not in_fence:
            yield n, INLINE_CODE_RE.sub("", line)


def planned_pages():
    """Paths mentioned in backticks in the roadmap, e.g. `05-networking/dns-on-ubuntu.md`."""
    if not os.path.exists(ROADMAP):
        return set()
    text = open(ROADMAP, encoding="utf-8").read()
    return {m for m in re.findall(r"`([\w./-]+\.md)`", text)}


def main():
    files = tracked_files()
    planned = planned_pages()
    errors, warnings = [], []

    for f in files:
        if " " in f:
            errors.append(f"{f}: file or folder name contains a space (use kebab-case)")

    for f in files:
        if not f.endswith(".md") or f.startswith(SKIP_DIRS):
            continue
        here = os.path.dirname(f)
        text = open(f, encoding="utf-8").read()
        for n, line in strip_code(text):
            for m in WIKILINK_RE.finditer(line):
                errors.append(f"{f}:{n}: wikilink {m.group(0)} (use a standard Markdown link)")
            for m in LINK_RE.finditer(line):
                target = m.group(1)
                if re.match(r"^[a-z][a-z0-9+.-]*:", target) or target.startswith("#"):
                    continue  # http:, mailto:, or same-page anchor
                path = urllib.parse.unquote(target.split("#", 1)[0])
                if not path:
                    continue
                resolved = os.path.normpath(os.path.join(here, path))
                if os.path.exists(resolved):
                    continue
                if resolved in planned:
                    warnings.append(f"{f}:{n}: {target} (planned, not written yet)")
                else:
                    errors.append(f"{f}:{n}: broken link {target} -> {resolved} does not exist")

    for w in warnings:
        print(f"WARN   {w}")
    for e in errors:
        print(f"ERROR  {e}")
    print(f"\n{len(errors)} error(s), {len(warnings)} warning(s)")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
