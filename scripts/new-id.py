#!/usr/bin/env python3
"""Mint an entity id that is not already taken.

The corpus claims collisions are prevented "structurally, not statistically". That was
false as shipped: no generator existed, so agents invented ids themselves — and a language
model asked for a random string is not a random source. Two unrelated projects, run
independently, produced the same five ids in the same order. Six characters from a
32-symbol alphabet is ~10^9 possibilities; five simultaneous collisions is not chance, it
is the same model reaching for the same tokens given a similar prompt.

So the entropy has to come from somewhere that has any: the system's random source, plus a
scan of what is already used. That is what makes the claim true rather than aspirational.

Usage:
  python3 scripts/new-id.py            # one id, prefixed T-
  python3 scripts/new-id.py --prefix R # a role: R-XXXXXX
  python3 scripts/new-id.py -n 5       # five, all distinct and all unused
  python3 scripts/new-id.py --root .   # where to scan for ids in use
"""

import argparse
import re
import secrets
import sys
from pathlib import Path

# 32 symbols: ten digits plus every letter except I, L, O and U — the four that are
# misread as 1, 1, 0 and V when a human copies an id off a screen.
ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
LENGTH = 6
ID_RE = re.compile(rf"\b([A-Z]{{1,2}})-([{ALPHABET}]{{{LENGTH}}})\b")


def ids_in_use(root: Path) -> set[str]:
    """Every id already visible in the tree — in filenames and in file bodies."""
    used = set()
    for p in root.rglob("*"):
        if ".git" in p.parts or not p.is_file():
            continue
        used.update(m.group(0) for m in ID_RE.finditer(p.name))
        if p.suffix.lower() in {".md", ".json", ".yaml", ".yml", ".txt", ".csv"}:
            try:
                used.update(m.group(0) for m in ID_RE.finditer(p.read_text(
                    encoding="utf-8", errors="ignore")))
            except OSError:
                continue
    return used


def mint(prefix: str, used: set[str]) -> str:
    while True:
        candidate = prefix + "-" + "".join(secrets.choice(ALPHABET) for _ in range(LENGTH))
        if candidate not in used:
            return candidate


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--prefix", default="T", help="T task · R role · G group · P pipeline")
    ap.add_argument("-n", type=int, default=1, help="how many")
    ap.add_argument("--root", default=".", help="tree to scan for ids already in use")
    a = ap.parse_args()

    # One or two letters: `RQ-` (a request) and `TH-` (a thread) were both in the corpus while
    # the door accepted a single letter only, so neither could be minted here and neither was
    # visible to the collision scan below — which is the whole reason this script exists.
    # `isascii()` too: `str.isalpha()` is Unicode-aware, so `--prefix ЖД` minted
    # `ЖД-6ZW5EA` and §1d of the guard then refuses that the moment it becomes a
    # filename — this door would hand a project an id its own guard rejects.
    # Measured 2026-08-15 (pass nine).
    if not (1 <= len(a.prefix) <= 2) or not (a.prefix.isascii() and a.prefix.isalpha()):
        print("prefix is one or two letters", file=sys.stderr)
        return 2
    a.prefix = a.prefix.upper()

    used = ids_in_use(Path(a.root).resolve())
    minted: set[str] = set()
    for _ in range(a.n):
        new = mint(a.prefix.upper(), used | minted)
        minted.add(new)
        print(new)
    return 0


if __name__ == "__main__":
    sys.exit(main())
