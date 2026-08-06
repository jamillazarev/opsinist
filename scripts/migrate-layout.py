#!/usr/bin/env python3
"""Move a pre-0.2.0 flat project into the `_ops/` layout — as history, not as loss.

    python3 scripts/migrate-layout.py <project-root> [--dry-run]

Every move is a `git mv`, so blame and history survive the migration; untracked
machinery (`.index/`, the checkout holder) is moved plainly. The script refuses a
dirty tree — a migration mixed into unrelated work is a diff nobody can review —
and it only ever moves what it recognises: the machinery's own files and
directories. A `docs/` entry it does not know is *left where it is* and named in
the output, because the directory may be the craft's, not the machinery's.

Idempotent: a second run finds nothing to do and says so. A destination that
already exists is a CONFLICT line and a nonzero exit, never a silent overwrite.
"""
import subprocess
import sys
from pathlib import Path

# Entity directories the machinery owns at a flat root. `scripts/` is absent on
# purpose: at a project root it is usually the craft's own; only the one file we
# ship there (the preflight) is claimed, below.
ENTITY_DIRS = [
    "tasks", "specs", "roles", "teams", "panels", "pipelines", "requests",
    "releases", "milestones", "automations", "resources", "skills",
    "runbooks", "research", "audience", "design-system", "brand", "process",
]

# docs/ members the machinery owns. Anything else under docs/ stays put.
DOCS_FILES = [
    "COMPANY.md", "ABOUT.md", "DECISIONS.md", "LATER.md", "BACKLOG.md",
    "MAP.md", "ARCHITECTURE.md", "BUDGET.md", "ECONOMICS.md", "TOOLING.md",
    "TEAM.md", "FIELD-NOTES.md", "DEBTS.md", "RUNS.md", "ROADMAP.md",
]

RENAMES = {"COMPANY.md": "ABOUT.md", "cohorts": "panels", "tooling": "runbooks"}


def sh(root, *args):
    return subprocess.run(args, cwd=root, capture_output=True, text=True)


def tracked(root, rel):
    return sh(root, "git", "ls-files", "--error-unmatch", rel).returncode == 0


def main():
    argv = [a for a in sys.argv[1:] if a != "--dry-run"]
    dry = "--dry-run" in sys.argv
    if not argv:
        print(__doc__.strip().splitlines()[0])
        print(f"\n    usage: {Path(sys.argv[0]).name} <project-root> [--dry-run]")
        return 2
    root = Path(argv[0]).resolve()
    if not (root / ".git").exists():
        print(f"not a git repository: {root}")
        return 2
    if not dry and sh(root, "git", "status", "--porcelain").stdout.strip():
        print("the tree is dirty — commit or stash first, so the migration is its own diff")
        return 2

    moves = []  # (src_rel, dst_rel)

    def claim(src_rel, dst_rel):
        if (root / src_rel).exists():
            moves.append((src_rel, dst_rel))

    claim("config.md", "_ops/config.md")
    for d in ENTITY_DIRS:
        claim(d, f"_ops/{d}")
    claim("cohorts", "_ops/panels")
    for f in DOCS_FILES:
        claim(f"docs/{f}", f"_ops/{RENAMES.get(f, f)}")
    claim("docs/tooling", "_ops/runbooks")
    claim("docs/map", "_ops/map")
    for sub in ("research", "audience", "design-system", "brand"):
        claim(f"docs/{sub}", f"_ops/{sub}")
    claim("scripts/preflight.sh", "_ops/scripts/preflight.sh")
    claim(".opsinist-checkout", "_ops/.checkout")
    claim(".index", "_ops/.index")

    conflicts = [(s, d) for s, d in moves if (root / d).exists()]
    moves = [(s, d) for s, d in moves if (root / d).exists() is False]

    if not moves and not conflicts:
        print("nothing to migrate — the layout is already `_ops/`, or was never flat")
        return 0

    for s, d in moves:
        print(f"  {s}  →  {d}")
        if dry:
            continue
        (root / d).parent.mkdir(parents=True, exist_ok=True)
        if tracked(root, s) or sh(root, "git", "ls-files", s).stdout.strip():
            r = sh(root, "git", "mv", s, d)
            if r.returncode != 0:
                print(f"  git mv failed: {r.stderr.strip()}")
                return 1
        else:
            (root / s).rename(root / d)

    # The pre-commit hook is outside git, so a moved preflight would orphan it.
    hook = root / ".git" / "hooks" / "pre-commit"
    if not dry and hook.is_file():
        body = hook.read_text()
        if "scripts/preflight.sh" in body and "_ops/scripts/preflight.sh" not in body:
            hook.write_text(body.replace("scripts/preflight.sh", "_ops/scripts/preflight.sh"))
            print("  .git/hooks/pre-commit  →  path rewritten to _ops/scripts/preflight.sh")

    # .gitignore entries for the untracked machinery follow their files.
    gi = root / ".gitignore"
    if not dry and gi.is_file():
        body = gi.read_text()
        fixed = (body.replace(".index/", "_ops/.index/")
                     .replace(".opsinist-checkout", "_ops/.checkout")
                     .replace("_ops/_ops/", "_ops/"))
        if fixed != body:
            gi.write_text(fixed)
            sh(root, "git", "add", ".gitignore")
            print("  .gitignore  →  entries follow their files")

    leftovers = sorted(p.name for p in (root / "docs").iterdir()) if (root / "docs").is_dir() else []
    if leftovers:
        print(f"  left in docs/ as possibly the craft's own: {', '.join(leftovers)}")

    for s, d in conflicts:
        print(f"  CONFLICT: {s} not moved — {d} already exists; merge by hand")

    if not dry:
        print("moved — review the staged renames, then commit them as one migration commit")
    return 1 if conflicts else 0


if __name__ == "__main__":
    sys.exit(main())
