#!/usr/bin/env python3
"""Regenerate the map's `touched by:` blocks from the tasks' own declarations.

`mapping.md` promises the node answers back who is on it; this is the executor of that
promise (PATTERNS §5/§6: one side stored — the task's Touches — the other generated).
Idempotent: only text between the markers moves, and a run with nothing changed writes
nothing. Two live tasks on one node is stated in the block itself — a finding at
decomposition, not a surprise at review.

Usage: python3 scripts/map-blocks.py [repo-root]   (default: .)
"""
import re
import sys
from pathlib import Path

ROOT = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()
MAP = (ROOT / "_ops" / "MAP.md") if (ROOT / "_ops").is_dir() else (ROOT / "docs" / "MAP.md")
LIVE = {"started", "review", "in review", "doing"}   # categories that mean "on it now"


def tasks():
    tdir = (ROOT / "_ops" / "tasks") if (ROOT / "_ops" / "tasks").is_dir() else (ROOT / "tasks")
    for f in sorted(tdir.glob("*.md")) if tdir.is_dir() else []:
        text = f.read_text(encoding="utf-8", errors="replace")
        m = re.search(r"^\*{0,2}Touches\*{0,2}\s*:\s*(.+)$", text, re.M | re.I)
        if not m:
            continue
        nodes = [n.strip() for n in re.split(r"[,·]", m.group(1)) if n.strip()]
        s = re.search(r"^\*{0,2}Status\*{0,2}\s*:\s*([^·\n]+)", text, re.M | re.I)
        status = (s.group(1).strip() if s else "?").lower()
        tid = f.stem.split("-")[0] + "-" + f.stem.split("-")[1] if "-" in f.stem else f.stem
        yield tid, status, nodes


def block_for(node, rows):
    lines = [f"<!-- touched-by:{node} -->"]
    live = [t for t, s in rows if s in LIVE]
    for t, s in rows:
        lines.append(f"- {t} ({s})")
    if len(live) > 1:
        lines.append(f"- **finding: {' and '.join(live)} are both live on this node** — "
                     "settle it at decomposition (related · blocked_by), not at review")
    lines.append(f"<!-- /touched-by:{node} -->")
    return "\n".join(lines)


def main():
    if not MAP.is_file():
        print(f"no {MAP.relative_to(ROOT)} — nothing to regenerate")
        return 0
    per = {}
    for tid, status, nodes in tasks():
        for n in nodes:
            per.setdefault(n.lower(), []).append((tid, status))
    text = MAP.read_text(encoding="utf-8")
    changed = False
    for node, rows in sorted(per.items()):
        new = block_for(node, rows)
        pat = re.compile(rf"<!-- touched-by:{re.escape(node)} -->.*?<!-- /touched-by:{re.escape(node)} -->", re.S)
        if pat.search(text):
            if pat.search(text).group(0) != new:
                text = pat.sub(lambda _: new, text, count=1)
                changed = True
        else:
            text = text.rstrip() + "\n\n" + new + "\n"
            changed = True
    if changed:
        MAP.write_text(text, encoding="utf-8")
    print(("updated " if changed else "unchanged ") + str(MAP.relative_to(ROOT)) +
          f" — {len(per)} node(s)")
    return 0


if __name__ == "__main__":
    sys.exit(main())
