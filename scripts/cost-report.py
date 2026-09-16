#!/usr/bin/env python3
"""What the work cost, rolled up from the run records — per task, per release, per model.

    cost-report.py [--root .] [--write] [--by task|release|model|month] [--since YYYY-MM-DD]

**Reads, never writes anything but its own page.** The run record is the measurement
(`templates/RUN-template.md` gives the four token numbers their own cells); this rolls them up and
puts the result in `_ops/COST.md` with `--write`. Nothing here is a second ledger: delete the page
and it regenerates identically from the same records.

**Four numbers, never one total** (`cost.md`). `input` · `output` · `cache_read` · `cache_write`
are kept apart because cache reads are the overwhelming majority on any project with a stable
prefix, and are far cheaper — a single total hides the one lever that moves the bill.

**`unknown` is a value and is reported as one.** Where a runtime reported nothing, the record says
`unknown` rather than guessing, and this page says how many runs it could not count — a rollup that
silently drops them reads as a cheap project. **And money is not invented**: third-party spend is
summed where the records state an amount and currency, and the token columns stay tokens. On a
subscription the harness's own usage view is the bill and this is attribution; on an API key it is
the other way round (`cost.md` → *Two bills*).

**Why this exists** (measured 2026-09-16, a live project of nine tasks and fifteen commits): **no
run records at all**, so the questions *what did this task cost* and *what has this release cost so
far* had no answer anywhere — and neither did *what did we spend on work that produced nothing*,
which is the slice worth having.
"""
import argparse, os, re, sys
from datetime import date

TOKENS = ("input", "output", "cache_read", "cache_write")


def cell(text, name):
    """A value from a `| **Name** | value |` row, or a `**Name**: value` line — the record is a
    table in the template and prose in the wild, and both are read rather than one refused."""
    m = re.search(r"^\|\s*[*`_]*%s[*`_]*\s*\|\s*(.+?)\s*\|" % re.escape(name), text,
                  re.I | re.M)
    if not m:
        m = re.search(r"^(?![ ]{4}|\t)[^\n]*?[*`_]*%s[*`_]*\s*:\s*([^·|\n]+)" % re.escape(name),
                      text, re.I | re.M)
    if not m:
        return ""
    v = m.group(1).strip().strip("*`_").strip()
    return "" if "{{" in v else v


def token_row(text):
    """The four numbers, wherever the record puts them: the template's own four-column row, or
    `input: 1200` lines. Returns a dict of int-or-None — **None is `unknown`, not zero**, and the
    difference is the whole honesty of the page."""
    got = {k: None for k in TOKENS}
    head = re.search(r"^\|\s*`?input`?\s*\|\s*`?output`?\s*\|\s*`?cache_read`?\s*\|"
                     r"\s*`?cache_write`?\s*\|\s*$", text, re.I | re.M)
    if head:
        rest = text[head.end():].lstrip("\n").split("\n")
        for line in rest[1:3] if rest and set(rest[0]) <= set("|-: ") else rest[:2]:
            cells = [c.strip().strip("`") for c in line.strip().strip("|").split("|")]
            if len(cells) >= 4 and any(c for c in cells[:4]):
                for k, c in zip(TOKENS, cells[:4]):
                    n = re.sub(r"[ ,_']", "", c)
                    got[k] = int(n) if n.isdigit() else None
                return got
    for k in TOKENS:
        v = re.sub(r"[ ,_']", "", cell(text, k))
        got[k] = int(v) if v.isdigit() else None
    return got


def spend(text):
    """Third-party money, where the record states it: (amount, currency) pairs summed per currency.
    A quantity without an amount is counted as a run with unpriced spend, and said so — *"140 image
    generations"* is a number someone can price later; silence is not."""
    out, unpriced = {}, 0
    for m in re.finditer(r"([0-9]+(?:\.[0-9]+)?)\s*(USD|EUR|GBP|RUB|\$|€|£|₽)|"
                         r"(USD|EUR|GBP|RUB|\$|€|£|₽)\s*([0-9]+(?:\.[0-9]+)?)",
                         cell(text, "Third-party spend") or "", re.I):
        amt = m.group(1) or m.group(4)
        cur = (m.group(2) or m.group(3) or "").upper().replace("$", "USD").replace("€", "EUR") \
                                                      .replace("£", "GBP").replace("₽", "RUB")
        out[cur] = out.get(cur, 0.0) + float(amt)
    raw = cell(text, "Third-party spend")
    if raw and not out and raw.lower() not in ("none", "—", "-", "n/a"):
        unpriced = 1
    return out, unpriced


def read_runs(root, since=""):
    d = os.path.join(root, "_ops", "runs")
    runs = []
    for name in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if not (name.endswith(".md") and name.startswith("R-")):
            continue
        text = open(os.path.join(d, name), encoding="utf-8", errors="replace").read()
        ran = cell(text, "Ran")
        day = (re.search(r"\d{4}-\d{2}-\d{2}", ran) or re.search(r"\d{4}-\d{2}-\d{2}", text))
        day = day.group(0) if day else ""
        if since and day and day < since:
            continue
        task = cell(text, "Task")
        tid = re.search(r"[A-Z]{1,2}-[0-9A-Z]{6}", task or "")
        money, unpriced = spend(text)
        runs.append({"file": name, "task": tid.group(0) if tid else "",
                     "model": cell(text, "Model that answered") or cell(text, "Model requested")
                              or "unknown",
                     "outcome": (cell(text, "Outcome") or "unknown").split()[0].lower(),
                     "attempt": cell(text, "Attempt").split(" ")[0] or "",
                     "day": day, "tokens": token_row(text), "money": money, "unpriced": unpriced})
    return runs


def release_of(root, task_id):
    d = os.path.join(root, "_ops", "tasks")
    for name in sorted(os.listdir(d)) if os.path.isdir(d) and task_id else []:
        if name.startswith(task_id) and name.endswith(".md"):
            text = open(os.path.join(d, name), encoding="utf-8", errors="replace").read()
            v = cell(text, "Release")
            return "" if v.lower() in ("none", "—", "-") else v
    return ""


def group_key(root, r, by, cache):
    if by == "task":
        return r["task"] or "no task — a quick job"
    if by == "model":
        return r["model"]
    if by == "month":
        return r["day"][:7] or "undated"
    key = r["task"] and cache.setdefault(r["task"], release_of(root, r["task"]))
    return key or "no release"


def num(n):
    return "unknown" if n is None else "{:,}".format(n).replace(",", " ")


def render(root, runs, by):
    groups, cache = {}, {}
    for r in runs:
        groups.setdefault(group_key(root, r, by, cache), []).append(r)
    lines = ["# Cost — what the work has spent", "",
             "**Generated by the skill's `scripts/cost-report.py --by %s`. Do not edit.** Every "
             "number is summed from `_ops/runs/`; the run record is the measurement and this page "
             "is a view of it. Four numbers, never one total — cache reads are most of the volume "
             "and a fraction of the price, so a single figure hides the only lever that moves the "
             "bill." % by, ""]
    if not runs:
        lines += ["**No run records.** Nothing has been measured, so nothing can be reported — "
                  "not *this project was free*. A dispatched run writes one "
                  "(`templates/RUN-template.md`); a job done by hand says so in the task's History.",
                  ""]
        return "\n".join(lines)
    lines += ["| %s | runs | input | output | cache read | cache write | not counted |" % by.title(),
              "|---|---|---|---|---|---|---|"]
    totals = {k: 0 for k in TOKENS}
    unknown_total, money_total, unpriced_total = 0, {}, 0
    for key in sorted(groups, key=lambda k: (k.startswith("no "), k)):
        rows = groups[key]
        sums = {k: 0 for k in TOKENS}
        unknown = 0
        for r in rows:
            if any(r["tokens"][k] is None for k in TOKENS):
                unknown += 1
            for k in TOKENS:
                sums[k] += r["tokens"][k] or 0
            for cur, amt in r["money"].items():
                money_total[cur] = money_total.get(cur, 0.0) + amt
            unpriced_total += r["unpriced"]
        for k in TOKENS:
            totals[k] += sums[k]
        unknown_total += unknown
        lines.append("| %s | %d | %s | %s | %s | %s | %s |" % (
            key, len(rows), num(sums["input"]), num(sums["output"]), num(sums["cache_read"]),
            num(sums["cache_write"]), ("%d run%s" % (unknown, "" if unknown == 1 else "s"))
            if unknown else "—"))
    lines.append("| **all** | **%d** | **%s** | **%s** | **%s** | **%s** | **%s** |" % (
        len(runs), num(totals["input"]), num(totals["output"]), num(totals["cache_read"]),
        num(totals["cache_write"]),
        ("%d" % unknown_total) if unknown_total else "—"))
    lines.append("")
    if unknown_total:
        lines += ["> [!WARNING]",
                  "> **%d of %d runs carry `unknown` in at least one of the four numbers** and are "
                  "summed as zero there. The totals above are a floor, not a measurement — where a "
                  "runtime reports nothing, the record says so rather than guessing, and a rollup "
                  "that hid that would read as a cheap project." % (unknown_total, len(runs)), ""]
    if money_total or unpriced_total:
        parts = ["%s %.2f" % (c, v) for c, v in sorted(money_total.items())]
        lines += ["**Third-party spend**: %s%s. Money spent inside a run on another key is in no "
                  "token count — a run that generated two hundred images describes its thinking in "
                  "the four numbers and misses the bill entirely." %
                  (" · ".join(parts) or "none priced",
                   " · **%d run%s state a quantity with no amount**, which someone can price later"
                   % (unpriced_total, "" if unpriced_total == 1 else "s") if unpriced_total else ""),
                  ""]
    waste = [r for r in runs if r["outcome"] in ("failed", "interrupted", "limit", "canceled",
                                                 "cancelled")]
    if waste:
        w = sum((r["tokens"][k] or 0) for r in waste for k in TOKENS)
        lines += ["**Spent on work that produced nothing**: %d run%s, %s tokens across the four "
                  "numbers — the slice the ledger exists for." %
                  (len(waste), "" if len(waste) == 1 else "s", num(w)), ""]
    retries = [r for r in runs if r["attempt"].isdigit() and int(r["attempt"]) > 1]
    if retries:
        lines += ["**Second and later attempts**: %d — the price of not getting it right the first "
                  "time, and three on one task is the escalation threshold (`escalating.md`)."
                  % len(retries), ""]
    lines += ["*A budget, where one is set, is stated as shares in `_ops/BUDGET.md`; this page is "
              "the ledger and exists whether or not a budget does.*", ""]
    return "\n".join(lines).rstrip() + "\n"


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--root", default=".")
    ap.add_argument("--write", action="store_true", help="write _ops/COST.md")
    ap.add_argument("--by", default="release", choices=["task", "release", "model", "month"])
    ap.add_argument("--since", default="", help="ignore runs dated before this day")
    a = ap.parse_args(argv)
    root = os.path.abspath(a.root)
    if not os.path.isdir(os.path.join(root, "_ops")):
        print("no _ops/ under %s — this is not a project this skill operates" % root,
              file=sys.stderr)
        return 2
    text = render(root, read_runs(root, a.since), a.by)
    if a.write:
        open(os.path.join(root, "_ops", "COST.md"), "w", encoding="utf-8").write(text)
        print("wrote _ops/COST.md")
        return 0
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
