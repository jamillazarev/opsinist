#!/usr/bin/env python3
"""Is the project's guard installed, current, and actually wired to fire?

    guard-status.py [project-root]

**Measured on a live project, 2026-09-16**: the guard was there — `_ops/scripts/`, 128 KB, version
0.2.18 — and `.git/hooks/` held nothing but git's own samples. Nine tasks in two incompatible
shapes, two accepted with no review evidence, two claiming commits that are not in the history:
every gate the methodology describes was prose in that repository, because the one thing that
turns those gates into refusals had never been run. **A guard that is copied is not a guard that
is wired**, and nothing said so — the file's presence reads as protection.

What it reports, each with what to do about it:
  - the guard file: present, and whether it is a copy of this skill's `templates/company-preflight.sh`
  - its version against the skill's, since a stale guard does not complain; it does less
  - the doors beside it (`transition.py`, `new-id.py`), which §1 refuses a wired project without
  - **the hook**: `pre-commit` in the repository's real hooks directory — the one
    `git rev-parse --git-path hooks` names, so `core.hooksPath` and worktrees are seen, not assumed
  - whether that hook is the guard's own (it carries the guard's sentinel line) or someone else's

Exit 0 when the guard is wired and current; 1 when anything above is missing, so a health sweep
can read the code and a person can read the lines. It writes nothing, anywhere.
"""
import os, re, subprocess, sys

SENTINEL = "# managed by opsinist company-preflight"
STAMP = re.compile(r"^#\s*guard-version:\s*([0-9][0-9.]*)", re.M)
DOORS = ("transition.py", "new-id.py")


def git(root, *args):
    r = subprocess.run(["git", "-C", root] + list(args), capture_output=True, text=True)
    return r.stdout.strip() if r.returncode == 0 else None


def skill_version():
    """The version this skill ships, from the guard template's own stamp."""
    here = os.path.dirname(os.path.abspath(__file__))
    path = os.path.join(here, "..", "templates", "company-preflight.sh")
    try:
        m = STAMP.search(open(path, encoding="utf-8", errors="replace").read())
    except OSError:
        return None
    return m.group(1) if m else None


def find_guard(root):
    """The guard by its stamp, not by its name — a project may keep the template's filename."""
    for rel in ("_ops/scripts/preflight.sh", "scripts/preflight.sh",
                "_ops/scripts/company-preflight.sh", "_ops/preflight.sh"):
        p = os.path.join(root, rel)
        if os.path.isfile(p):
            m = STAMP.search(open(p, encoding="utf-8", errors="replace").read())
            if m:
                return rel, m.group(1)
    return None, None


def main(argv):
    root = os.path.abspath(argv[0] if argv else ".")
    lines, ok = [], True
    if git(root, "rev-parse", "--git-dir") is None:
        print("not a git repository: %s — the guard is a pre-commit hook, so there is nothing to wire" % root)
        return 1

    rel, version = find_guard(root)
    if rel is None:
        lines.append("✗ no guard in this project — copy it: "
                     "`cp <skill>/templates/company-preflight.sh _ops/scripts/preflight.sh`")
        ok = False
    else:
        mine = skill_version()
        if mine and version != mine:
            lines.append("! the guard is version %s and this skill ships %s — re-copy it; "
                         "a stale guard does not complain, it does less" % (version, mine))
            ok = False
        else:
            lines.append("✓ the guard is here (%s, version %s)" % (rel, version))
        missing = [d for d in DOORS if not os.path.isfile(os.path.join(root, os.path.dirname(rel), d))]
        if missing:
            lines.append("✗ the doors are not beside it: %s — §1 refuses every commit in a wired "
                         "project whose doors are absent" % ", ".join(missing))
            ok = False

    hooks = git(root, "rev-parse", "--git-path", "hooks")
    hooks = hooks if hooks and os.path.isabs(hooks) else os.path.join(root, hooks or ".git/hooks")
    hook = os.path.join(hooks, "pre-commit")
    if not os.path.isfile(hook):
        lines.append("✗ **nothing is wired**: no `pre-commit` in %s — every gate this methodology "
                     "describes is prose until it is. Fix: `bash %s --install`"
                     % (os.path.relpath(hooks, root), rel or "_ops/scripts/preflight.sh"))
        ok = False
    else:
        body = open(hook, encoding="utf-8", errors="replace").read()
        if SENTINEL in body:
            lines.append("✓ the hook is wired, and it is the guard's own (%s)" % os.path.relpath(hook, root))
        else:
            lines.append("! `pre-commit` exists and is not this guard's — read it before touching it, "
                         "then chain or replace: `bash %s --install`" % (rel or "_ops/scripts/preflight.sh"))
            ok = False
        if not os.access(hook, os.X_OK):
            lines.append("✗ the hook is not executable, so git skips it silently: `chmod +x %s`"
                         % os.path.relpath(hook, root))
            ok = False

    print("guard status — %s" % root)
    for l in lines:
        print("  " + l)
    print("  %s" % ("every gate can fire" if ok else
                    "until the lines above are answered, the gates are descriptions, not refusals"))
    return 0 if ok else 1


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
