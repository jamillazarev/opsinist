#!/usr/bin/env python3
"""Write a task file from the template, so its shape is not a thing anyone has to remember.

    new-task.py --title "the thing" --type feature [--assignee web-engineer] [--root .]
                [--parent T-XXXXXX] [--wave 1] [--blocked-by T-XXXXXX] [--status ready]

**Measured on a live project, 2026-09-16**: nine tasks in two incompatible shapes — three from the
template, six invented (`# T-…: title` instead of the em dash, fields as a bullet list, `Role:`
where the template says `Assignee`, an extra `Owner:`, one file carrying two logs). The writer of
those six explained it exactly right: *there was no template on disk it was obliged to open, and
nothing refused the shape it wrote.* This is the first half of the repair — a door that writes the
file, so the shape comes for free — and the guard's §23, which refuses a new task that departs from
it, is the second. A rule needs both: something that makes the right thing easy, and something that
makes the wrong thing fail.

**Where the shape comes from**, in this order: the project's own `_ops/templates/TASK.md` when it
has one — that is how a project translates the headings into the language it works in, and the
guard reads the same file — otherwise the skill's `templates/TASK-template.md`, read live.

The id is minted, never invented (`new-id.py`'s alphabet and its scan of what is already used).
Placeholders it is not given stay as `{{…}}`: a hole the writer must fill is honest, and the guard
refuses the ones that matter empty.
"""
import argparse, os, re, subprocess, sys, unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
ALPHABET = "0123456789ABCDEFGHJKMNPQRSTVWXYZ"
FIELD = re.compile(r"^\*\*(Type|Status|Assignee|Parent|Wave|Blocked by)\*\*", re.I)


def template(root):
    """(text, where it came from) — the project's own first, the skill's otherwise."""
    own = os.path.join(root, "_ops/templates/TASK.md")
    if os.path.isfile(own):
        return open(own, encoding="utf-8").read(), "_ops/templates/TASK.md"
    src = os.path.join(HERE, "..", "templates", "TASK-template.md")
    return open(src, encoding="utf-8").read(), "the skill's templates/TASK-template.md"


def mint(root, prefix="T"):
    """An id no file or line in this tree already carries — new-id.py's own rule, its own way."""
    used = set()
    r = subprocess.run(["git", "-C", root, "grep", "-hoE", r"[A-Z]{1,2}-[%s]{6}" % ALPHABET],
                       capture_output=True, text=True, errors="replace")
    used.update(r.stdout.split())
    for d, _, files in os.walk(os.path.join(root, "_ops")):
        for f in files:
            used.update(re.findall(r"[A-Z]{1,2}-[%s]{6}" % ALPHABET, f))
    import secrets
    for _ in range(10000):
        cand = "%s-%s" % (prefix, "".join(secrets.choice(ALPHABET) for _ in range(6)))
        if cand not in used:
            return cand
    raise SystemExit("could not mint an unused id in 10000 tries — say so rather than reusing one")


CYR = dict(zip("абвгдеёжзийклмнопрстуфхцчшщъыьэюя",
                ["a", "b", "v", "g", "d", "e", "e", "zh", "z", "i", "y", "k", "l", "m", "n", "o",
                 "p", "r", "s", "t", "u", "f", "h", "c", "ch", "sh", "sch", "", "y", "", "e", "yu", "ya"]))


def slug(title):
    """The title's own words, transliterated — **the filename is ASCII even when the project is
    not**: the guard refuses a non-ASCII path under `_ops/` (git prints those as octal escapes and
    the two operating systems normalise them differently), while the text inside stays as written.
    Stripping to ASCII instead of transliterating would call every Russian task `task`."""
    text = unicodedata.normalize("NFC", title).lower()
    text = "".join(CYR.get(c, c) for c in text)
    text = "".join(c if (c.isascii() and (c.isalnum() or c in " -_")) else " " for c in text)
    return "-".join(text.split()[:6]) or "task"


def fill(text, values):
    """Replace the template's placeholders with what was given; leave the rest as holes.
    **A placeholder spans lines** — the template wraps at a hundred columns, so `**Status**: {{…}}`
    runs across two — and a line-by-line replacement quietly filled none of those."""
    for name, val in values.items():
        if val is None or name.startswith("__"):
            continue
        text = re.sub(r"(\*\*%s\*\*:\s*)\{\{.*?\}\}" % re.escape(name), lambda m: m.group(1) + val,
                      text, count=1, flags=re.I | re.S)
    if values.get("__title__"):
        text = re.sub(r"^#\s*\{\{.*?\}\}\s*—\s*\{\{.*?\}\}",
                      "# %s — %s" % (values["__id__"], values["__title__"]), text, count=1,
                      flags=re.M | re.S)
    return text


def main(argv):
    ap = argparse.ArgumentParser(description=__doc__.split("\n")[0])
    ap.add_argument("--title", required=True)
    ap.add_argument("--type", required=True, help="the project's own type — `_ops/process/types/`")
    ap.add_argument("--root", default=".")
    ap.add_argument("--assignee", default=None)
    ap.add_argument("--status", default=None, help="default: the first stage of the ladder, or `backlog`")
    ap.add_argument("--parent", default=None)
    ap.add_argument("--wave", default=None)
    ap.add_argument("--blocked-by", dest="blocked", default=None)
    ap.add_argument("--print-path", action="store_true", help="print only the path it wrote")
    a = ap.parse_args(argv)

    root = os.path.abspath(a.root)
    tasks = os.path.join(root, "_ops", "tasks")
    if not os.path.isdir(tasks):
        print("no _ops/tasks/ under %s — this is not a project this skill operates" % root, file=sys.stderr)
        return 2
    text, whence = template(root)
    ident = mint(root)
    values = {"__id__": ident, "__title__": a.title, "Type": a.type,
              "Status": a.status or first_stage(root, a.type) or "backlog",
              "Assignee": a.assignee, "Parent": a.parent, "Wave": a.wave, "Blocked by": a.blocked}
    body = fill(text, values)
    path = os.path.join(tasks, "%s-%s.md" % (ident, slug(a.title)))
    if os.path.exists(path):
        print("refusing to overwrite %s" % path, file=sys.stderr)
        return 1
    open(path, "w", encoding="utf-8").write(body)
    rel = os.path.relpath(path, root)
    if a.print_path:
        print(rel)
        return 0
    holes = len(re.findall(r"\{\{", body))
    print("wrote %s — from %s" % (rel, whence))
    print("  %d hole%s left to fill; the guard's §23 refuses this file while the fields and the "
          "sections it needs are missing or still in braces." % (holes, "" if holes == 1 else "s"))
    return 0


def first_stage(root, type_name):
    """The ladder's first stage, where the type or a pipeline names one — else nothing."""
    for rel in ("_ops/process/types/%s.md" % type_name, "_ops/process/types/default.md"):
        p = os.path.join(root, rel)
        if not os.path.isfile(p):
            continue
        text = open(p, encoding="utf-8", errors="replace").read()
        m = re.search(r"^\s*stages:\s*\[([^\]]+)\]", text, re.M)
        if m:
            return m.group(1).split(",")[0].strip().strip("'\"")
        m = re.search(r"^\s*-\s*([a-z][a-z -]*?)\s*(?:→|->)\s*", text, re.M)
        if m:
            return m.group(1).strip()
    return None


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
