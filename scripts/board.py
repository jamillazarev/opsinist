#!/usr/bin/env python3
"""The board — every task, where it stands, who has it, which release it is for.

    board.py [--root .] [--write] [--check] [--by release|status|assignee]

**A view, never a second source of truth.** Every cell is read out of the task files at the moment
it runs; `--write` puts the result in `_ops/BOARD.md` and `--check` exits 1 when that file has
drifted from what the tasks now say, which is the only honest way to keep a generated page in a
repository. Nothing here is edited by hand, and nothing here is where a status lives.

**Why this exists** (measured on a live project, 2026-09-16): nine tasks, no board, and no way to
answer *what is in flight and who has it* without opening nine files — while two of them claimed
committed code that is in no commit and one was assigned to a role that exists in no file. A list
that is derived cannot drift; a list that is kept by hand had already drifted by the time anyone
asked.

**Status does not go in the filename.** It is the first thing everyone proposes — `TODO-`, `WIP-`,
`DONE-` — and it costs a rename on every move: the id is immutable precisely because links point at
the file, so a status in the name turns each transition into a broken-link event across every task,
run record and thread that cited it. The board is the answer to the same wish, and it is free.
"""
import argparse, os, re, subprocess, sys

STATE = ("Type", "Status", "Stage", "Assignee", "Parent", "Wave", "Release", "Milestone",
         "Blocked by")
CATEGORY = {   # the six categories, for ordering a board across pipelines that share none
    "backlog": 0, "ready": 1, "started": 2, "in progress": 2, "build": 2, "doing": 2,
    "review": 3, "in review": 3, "blocked": 4, "done": 5, "accept": 5, "accepted": 5,
    "shipped": 5, "archived": 6, "dropped": 6, "cancelled": 6, "canceled": 6,
}


def field(text, *names):
    """A field in either dialect: `**Status**: x`, `- **Status:** x`, `status: x`. The second is
    what an agent writes when nothing hands it a template — measured on nine live tasks, six of
    them in that shape — and a board that reads only the first shows a project half empty."""
    for n in names:
        # **The field is rarely first on its line.** The template writes `**Type**: x · **Status**:
        # y`, so a pattern anchored at the line start read Type and reported Status empty — three
        # of nine tasks on the measured project came out blank that way, which is a board that
        # quietly says a project is not running. Anything may precede it; four spaces or a tab may
        # not, because markdown makes that an example (the same rule the door and the guard use).
        m = re.search(r"^(?![ ]{4}|\t)[^\n]*?[*`_]*%s[*`_]*[ \t]*:[ \t]*[*`_]*([^·|\n]+)"
                      % re.escape(n), text, re.I | re.M)
        if m:
            # a linked name is the same name: `[Web Engineer](../roles/web_engineer.md)`
            v = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", m.group(1)).strip().strip("*`_").strip()
            if v and "{{" not in v:
                return v
    return ""


def stages_of(root, type_name):
    """The ladder's stages, for ordering — the type's own file, else nothing."""
    for rel in ("_ops/process/types/%s.md" % type_name, "_ops/process/types/default.md"):
        p = os.path.join(root, rel)
        if not type_name or not os.path.isfile(p):
            continue
        text = open(p, encoding="utf-8", errors="replace").read().replace("→", "->")
        m = re.search(r"^\s*stages:\s*\[([^\]]+)\]", text, re.M)
        if m:
            return [x.strip().strip("'\"") for x in m.group(1).split(",") if x.strip()]
        m = re.search(r"^([\w-]+(?:\s*->\s*[\w-]+)+)\s*$", text, re.M)
        if m:
            return [x.strip() for x in m.group(1).split("->")]
    return []


def read_tasks(root):
    d = os.path.join(root, "_ops", "tasks")
    out = []
    for name in sorted(os.listdir(d)) if os.path.isdir(d) else []:
        if not name.endswith(".md"):
            continue
        text = open(os.path.join(d, name), encoding="utf-8", errors="replace").read()
        ident = (re.match(r"^([A-Z]{1,2}-[0-9A-Z]{6})", name) or [None, ""])[1] \
            if re.match(r"^([A-Z]{1,2}-[0-9A-Z]{6})", name) else ""
        head = re.search(r"^#\s+(.*)$", text, re.M)
        title = head.group(1).strip() if head else name[:-3]
        title = re.sub(r"^[A-Z]{1,2}-[0-9A-Z]{6}\s*[—:-]\s*", "", title).strip()
        t = {"id": ident or (head and title[:12]) or name[:-3], "file": name, "title": title}
        for f in STATE:
            t[f.lower().replace(" ", "_")] = field(text, f, f.replace(" ", "_"))
        t["status"] = t["status"] or t["stage"]
        # **A borrowed field is shown, and shown as borrowed.** Six of nine tasks on the measured
        # project wrote `Role:` where the template says `Assignee`; a board that reads only the
        # declared name shows those rows empty and reads as "nobody is working", while one that
        # reads both silently blesses the dialect §23 now refuses. So: read it, mark it `*`.
        t["borrowed"] = ""
        if not t["assignee"]:
            for alt in ("Role", "Owner", "Worker"):
                v = field(text, alt)
                if v and v.lower() not in ("unassigned", "none", "—", "-"):
                    t["assignee"], t["borrowed"] = v, alt
                    break
        for k in ("wave", "parent", "release", "milestone", "blocked_by"):
            if t[k].lower() in ("none", "—", "-", "n/a"):
                t[k] = ""
        # the last dated line of History — when this task last moved, whoever moved it
        hist = re.split(r"^##\s+History\s*$", text, flags=re.M | re.I)
        dates = re.findall(r"(\d{4}-\d{2}-\d{2})", hist[-1] if len(hist) > 1 else "")
        t["moved"] = max(dates) if dates else ""
        t["stages"] = stages_of(root, t["type"])
        out.append(t)
    return out


def rank(t):
    """Where a task sits, for ordering: its own ladder first, the six categories as the fallback
    that lets two pipelines sharing no stage name appear on one board."""
    s = (t.get("status") or "").lower()
    if t["stages"] and s in [x.lower() for x in t["stages"]]:
        return ([x.lower() for x in t["stages"]].index(s), 0)
    return (CATEGORY.get(s, 9), 1)


def link(t):
    return "[%s](tasks/%s)" % (t["id"], t["file"])


def table(rows):
    out = ["| Task | What | Type | Status | Who | Wave | Parent | Last moved |",
           "|---|---|---|---|---|---|---|---|"]
    for t in sorted(rows, key=lambda x: (rank(x), x["id"])):
        parent = t["parent"]
        pid = re.search(r"[A-Z]{1,2}-[0-9A-Z]{6}", parent or "")
        status = t["status"] or "—"
        if t["stages"] and status.lower() not in [x.lower() for x in t["stages"]]:
            status += " ⚠"                       # on no rung of this task's own ladder
        if t["blocked_by"] and t["blocked_by"].lower() not in ("none", "—", "-"):
            status += " · blocked"
        out.append("| %s | %s | %s | %s | %s | %s | %s | %s |" % (
            link(t), t["title"][:60], t["type"] or "—", status,
            (t["assignee"] + "\u2009*" if t["borrowed"] else t["assignee"]) or "—",
            t["wave"] or "—", pid.group(0) if pid else "—", t["moved"] or "—"))
    return out


def render(root, tasks, by="release"):
    head = subprocess.run(["git", "-C", root, "log", "-1", "--format=%h"],
                          capture_output=True, text=True).stdout.strip()
    lines = ["# Board — every task, where it stands", "",
             "**Generated by the skill's `scripts/board.py`%s. Do not edit.** Every cell is read "
             "from the task files; the task file is the truth and this page is a view of it. "
             "Regenerate after any move — `--check` says whether it has drifted."
             % (" from %s" % head if head else ""), ""]
    counts = {}
    for t in tasks:
        counts[t["status"] or "—"] = counts.get(t["status"] or "—", 0) + 1
    lines += ["**%d task%s**: %s" % (len(tasks), "" if len(tasks) == 1 else "s",
                                     " · ".join("%s %d" % (k, v) for k, v in
                                                sorted(counts.items(), key=lambda kv: -kv[1]))), ""]
    groups = {}
    for t in tasks:
        key = (t.get(by) or "").strip() if by != "status" else (t.get("status") or "")
        groups.setdefault(key or "no %s" % by, []).append(t)
    for key in sorted(groups, key=lambda k: (k.startswith("no "), k)):
        if len(groups) > 1:
            lines += ["## %s" % key, ""]
        lines += table(groups[key]) + [""]
    borrowed = [t for t in tasks if t.get("borrowed")]
    if borrowed:
        lines += ["> [!NOTE]",
                  "> **A `*` after a name means it was read from a field the template does not "
                  "declare** — %s. "
                  "The field is `**Assignee**`; the guard's §23 refuses a new task that uses "
                  "another, and these predate it." %
                  ", ".join("%s (`%s:`)" % (t["id"], t["borrowed"]) for t in borrowed[:8]), ""]
    odd = [t for t in tasks if t["stages"]
           and (t["status"] or "").lower() not in [x.lower() for x in t["stages"]]]
    if odd:
        lines += ["> [!WARNING]",
                  "> **⚠ marks a status on no rung of that task's own ladder** — %s. A status "
                  "nothing declared is a status no gate can hold." %
                  ", ".join("%s (`%s`)" % (t["id"], t["status"]) for t in odd[:8]), ""]
    return "\n".join(lines).rstrip() + "\n"


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--root", default=".")
    ap.add_argument("--write", action="store_true", help="write _ops/BOARD.md")
    ap.add_argument("--check", action="store_true",
                    help="exit 1 if _ops/BOARD.md differs from what the tasks now say")
    ap.add_argument("--by", default="release", choices=["release", "milestone", "status",
                                                        "assignee", "type"])
    a = ap.parse_args(argv)
    root = os.path.abspath(a.root)
    if not os.path.isdir(os.path.join(root, "_ops", "tasks")):
        print("no _ops/tasks/ under %s — this is not a project this skill operates" % root,
              file=sys.stderr)
        return 2
    text = render(root, read_tasks(root), a.by)
    path = os.path.join(root, "_ops", "BOARD.md")
    if a.check:
        have = open(path, encoding="utf-8", errors="replace").read() if os.path.isfile(path) else ""
        # the generated-from line moves with every commit; the board itself is what is compared
        strip = lambda s: re.sub(r" from [0-9a-f]{7,}\.", ".", s)
        if strip(have) == strip(text):
            print("_ops/BOARD.md is current")
            return 0
        print("_ops/BOARD.md is %s — rerun with --write"
              % ("absent" if not have else "behind what the tasks say"))
        return 1
    if a.write:
        open(path, "w", encoding="utf-8").write(text)
        print("wrote %s" % os.path.relpath(path, root))
        return 0
    sys.stdout.write(text)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
