#!/usr/bin/env python3
"""Check-date validator: a date, not a tick.

The freshness law says every recorded fact that can change carries when it was verified,
and past its recheck it is *unknown, not fine*. Nothing enforced that, so the catalogue
rows and source entries carry dates that nobody compares to today.

This is the release gate for that law. It finds check-dates, ages them, and reports.

Output: path:line: LEVEL: [RULE] message

  FRESH001  WARN  a check-date older than --warn days
  FRESH002  FAIL  a check-date older than --fail days
  FRESH003  WARN  a row caches a claim that ages, with no check-date and no deferral

Exit 1 on any FAIL. Run at release, and at audit.

Usage: python3 scripts/check-freshness.py [root] [--warn 60] [--fail 180] [--today YYYY-MM-DD]
"""

import argparse
import re
import sys
from datetime import date
from pathlib import Path

DATE_RE = re.compile(
    r"(?:checked|verified|re-verified|rechecked|last checked|as of)\s*:?\s*"
    r"(\d{4})-(\d{2})-(\d{2})",
    re.I,
)
BARE_DATE = re.compile(r"\b(\d{4})-(\d{2})-(\d{2})\b")
FENCE = re.compile(r"^\s*(```|~~~)")
TABLE_ROW = re.compile(r"^\s*\|.*\|\s*$")
# A claim that ages: a named licence, a version, money, a tier or a limit. The bare words
# "licence" and "pricing" are deliberately absent — "licence-first, verify per item" is a method
# and a "pricing layer" is a product category, and neither rots. Everything else in a
# catalogue row is durable judgement — "what this is for" does not rot the way a price does,
# and flagging it would make this checker noise, which is how a checker gets bypassed.
ROTS = re.compile(
    r"\b(MIT|Apache-2|AGPL|LGPL|GPL|BSD|MPL|CC0|CC-BY|dual-licen[cs]ed|source-available"
    r"|free tier|freemium|paid (?:plan|seats?|tier)|per seat|per month|/mo\b|\$\d|€\d"
    r"|v\d+\.\d+|\d+\s?(?:k|K|M)\s?(?:★|stars|rows|MAU|req|builds|minutes|seats)"
    r"|quota|rate limit|hard stop|auto-charge)\b", re.I)
# A row that says it checks at the point of use is not caching, so it has nothing to date.
# This is the behaviour the freshness law asks for, and saying it commits the row to it.
DEFERS = re.compile(r"verify per item|at decision time|at the moment of (?:use|decision)"
                    r"|fetch(?:ed)? (?:current|live|the)", re.I)
SEPARATOR = re.compile(r"^\s*\|[\s:|-]+\|\s*$")

findings = []


def add(level, rule, path, line, msg):
    findings.append((level, f"{path}:{line}: {level}: [{rule}] {msg}"))


def outside_fences(lines):
    inside = False
    for i, raw in enumerate(lines, 1):
        if FENCE.match(raw):
            inside = not inside
            continue
        if not inside:
            yield i, raw


def check(md, root, today, warn_days, fail_days):
    rel = md.relative_to(root)
    lines = md.read_text(encoding="utf-8").splitlines()

    # A "dated table" is one where at least one row carries a check-date. Inside such a table,
    # a row that makes an ageing claim and carries no date is a fact nobody has ever verified.
    table, dated_tables = [], []
    for lineno, raw in outside_fences(lines):
        if TABLE_ROW.match(raw) and not SEPARATOR.match(raw):
            table.append((lineno, raw))
        elif table:
            if any(DATE_RE.search(r) for _, r in table):
                dated_tables.append(table)
            table = []
    if table and any(DATE_RE.search(r) for _, r in table):
        dated_tables.append(table)

    seen_undated = set()
    for tbl in dated_tables:
        for lineno, raw in tbl[1:]:                      # skip the header row
            if DATE_RE.search(raw) or lineno in seen_undated:
                continue
            claim = ROTS.search(raw)
            if not claim or DEFERS.search(raw):
                continue
            seen_undated.add(lineno)
            label = raw.strip().strip("|").split("|")[0].strip()[:44]
            add("WARN", "FRESH003", rel, lineno,
                f"«{label}» claims «{claim.group(0)}» with no check-date")

    for lineno, raw in outside_fences(lines):
        for m in DATE_RE.finditer(raw):
            y, mo, d = (int(g) for g in m.groups())
            try:
                when = date(y, mo, d)
            except ValueError:
                add("FAIL", "FRESH002", rel, lineno, f"impossible date: {m.group(0)}")
                continue
            age = (today - when).days
            if age < 0:
                add("WARN", "FRESH001", rel, lineno,
                    f"check-date is in the future: {when.isoformat()}")
            elif age >= fail_days:
                add("FAIL", "FRESH002", rel, lineno,
                    f"checked {age} days ago ({when.isoformat()}) — unknown, not fine")
            elif age >= warn_days:
                add("WARN", "FRESH001", rel, lineno,
                    f"checked {age} days ago ({when.isoformat()}) — recheck before release")


def main():
    p = argparse.ArgumentParser()
    p.add_argument("root", nargs="?", default=".")
    p.add_argument("--warn", type=int, default=60)
    p.add_argument("--fail", type=int, default=180)
    p.add_argument("--today", default=None, help="YYYY-MM-DD, for testing")
    a = p.parse_args()

    root = Path(a.root).resolve()
    today = date.fromisoformat(a.today) if a.today else date.today()

    for md in sorted(root.rglob("*.md")):
        if ".git" in md.parts or md.name == "CHANGELOG.md":
            continue
        check(md, root, today, a.warn, a.fail)

    fails = [m for lvl, m in findings if lvl == "FAIL"]
    warns = [m for lvl, m in findings if lvl == "WARN"]
    for m in fails + warns:
        print(m)
    print(f"\n{len(fails)} FAIL, {len(warns)} WARN "
          f"(warn at {a.warn}d, fail at {a.fail}d, today {today.isoformat()})")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
