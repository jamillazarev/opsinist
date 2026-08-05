#!/usr/bin/env python3
"""The changelog skeleton — collation the author writes over, never the entry itself.

Collects everything since the last tag: subjects with dates, the tree's touched
directories, the trailers that say who produced what. The entry itself — leading with the
capability, naming the migration steps — is writing, and stays a person's (shipping.md).

  changelog.py [root]      markdown skeleton to stdout

Stdlib only. Exit 0; 2 when there is no git history to read.
"""

import subprocess
import sys
from collections import Counter
from pathlib import Path


def git(root, *args):
    r = subprocess.run(["git", "-C", str(root), *args], capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def main(argv):
    root = Path(argv[0]).resolve() if argv else Path.cwd()
    if git(root, "rev-parse", "HEAD") is None:
        print("✗ no git history here")
        return 2
    tag = git(root, "describe", "--tags", "--abbrev=0")
    rng = f"{tag}..HEAD" if tag else "HEAD"
    log = git(root, "log", rng, "--format=%as\x01%s\x01%(trailers:only,unfold)") or ""
    if not log:
        print(f"nothing since {tag or 'the beginning'} — the skeleton would be empty")
        return 0

    subjects, trailers = [], Counter()
    for entry in log.split("\n"):
        parts = entry.split("\x01")
        if len(parts) < 2 or not parts[1]:
            continue
        subjects.append((parts[0], parts[1]))
        if len(parts) > 2 and parts[2]:
            for t in parts[2].split("\n"):
                if ":" in t:
                    trailers[t.strip()] += 1

    touched = Counter()
    for f in (git(root, "diff", "--name-only", rng) or "").split("\n"):
        if f:
            touched[f.split("/")[0] if "/" in f else "(root)"] += 1

    since = f"since `{tag}`" if tag else "the whole history (no tag yet)"
    print(f"## {{version}} — {{the capability, in one line}}\n")
    print(f"*Skeleton: {len(subjects)} commit(s) {since}. Rewrite; do not ship this.*\n")
    print("**What changed, newest first:**\n")
    for date, subj in subjects:
        print(f"- {date} — {subj}")
    print("\n**Ground touched:** " + " · ".join(
        f"`{d}` ({n})" for d, n in touched.most_common(12)))
    if trailers:
        print("\n**Trailers seen:** " + " · ".join(
            f"{t} ×{n}" for t, n in trailers.most_common(8)))
    print("\n**Migration map — write it, the audit reads it (`upgrading.md`):**\n")
    print("- {{what an existing project must do, or 'nothing', per change}}")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
