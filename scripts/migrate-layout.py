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
    "tasks", "specs", "roles", "teams", "panels", "pipelines", "requests", "threads",
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


def collapse_state_fields(root, dry):
    """0.2.6 tasks carry state twice — a prose `**Status**` and a machine `stage:` — and 0.2.7
    refuses the second home. Without this, a project of twelve tasks meets twelve refusals on
    its next commit and has to be edited by hand; a release that strands its own projects is
    what `upgrading.md` exists to prevent.

    The machine field wins, because it is the one the door moves: measured on a live project,
    `stage:` had advanced on all twelve tasks while the prose copy was stale on two and absent
    on ten. Its value is written into `**Status**` — the shipped shape's one home — and the
    machine line is dropped.
    """
    import re
    tasks = sorted((root / "_ops" / "tasks").glob("*.md")) if (root / "_ops" / "tasks").is_dir() else []
    touched = []
    for tf in tasks:
        text = tf.read_text(encoding="utf-8", errors="replace")
        machine = re.search(r"^[ \t]*(?:stage|стадия)[ \t]*:[ \t]*(.+)$", text, re.M | re.I)
        prose = re.search(r"^(.*\*\*(?:Status|Статус)\*\*[ \t]*:[ \t]*)([^·|\n]*)(.*)$", text, re.M | re.I)
        if not machine:
            continue
        value = machine.group(1).strip()
        if prose:
            body = text[:prose.start()] + prose.group(1) + value + prose.group(3) + text[prose.end():]
        else:
            # no prose home at all — give it one, on the header line where the template puts it
            lines = text.split("\n")
            at = 1
            for i, l in enumerate(lines[:8]):
                if l.startswith("**"):
                    at = i
                    break
            lines.insert(at, f"**Status**: {value}")
            body = "\n".join(lines)
        body = re.sub(r"^[ \t]*(?:stage|стадия)[ \t]*:[ \t]*.+\n?", "", body, flags=re.M | re.I)
        # the comment that introduced the machine block has nothing left to introduce
        body = re.sub(r"^<!--[^>]*(?:transition\.py|машиночитаемо|machine-readable)[^>]*-->\n?", "",
                      body, flags=re.M | re.I)
        # The prose value moves, so the file's stage changes — and §14 reads an unexplained
        # stage change as a hand edit, correctly. This is not a move: it is a stale copy being
        # reconciled with the one the door was already using. Say that, in History, where a
        # later reader will need it, rather than exempting the migration from the gate.
        was = (prose.group(2).strip() if prose else "(none)") or "(none)"
        if was != value:
            # In the door's own vocabulary, because §14 reads this line and because it IS a
            # transition of the recorded value — what did not happen is a move of the work.
            line = (f"- migration — transition {was} -> {value}, by migrate-layout — the two "
                    f"state fields disagreed; the door's `stage:` was already `{value}`, the "
                    f"prose copy said `{was}` and was stale. One home now. No work moved.")
            if re.search(r"^##[ \t]*History", body, re.M):
                body = re.sub(r"^(##[ \t]*History[ \t]*\n)", r"\1" + line + "\n", body,
                              count=1, flags=re.M)
            else:
                body = body.rstrip() + "\n\n## History\n" + line + "\n"
        if body != text:
            touched.append(tf.name)
            if not dry:
                tf.write_text(body, encoding="utf-8")
                sh(root, "git", "add", str(tf.relative_to(root)))
    if touched:
        verb = "would be collapsed" if dry else "collapsed"
        shown = " · ".join(touched[:6]) + (f" … and {len(touched) - 6} more" if len(touched) > 6 else "")
        print(f"  state fields {verb} to one home in {len(touched)} task(s): {shown}")
    return touched


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
    # `_ops/` is a shared door: the sibling methodology names most of the same files.
    # A tree whose guide says another system operates it is that system's workspace —
    # refused whole, moved never.
    for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        gp = root / guide
        if gp.is_file():
            for line in gp.read_text(errors="replace").splitlines():
                if "operated by" in line.lower() and "opsinist" not in line.lower():
                    print(f"{guide} says this tree is operated by another system:")
                    print(f"    {line.strip()}")
                    print("not ours to migrate — handed back untouched")
                    return 2
    if not dry and sh(root, "git", "status", "--porcelain").stdout.strip():
        print("the tree is dirty — commit or stash first, so the migration is its own diff")
        return 2

    # The doors are re-copied at every migration, and this runs BEFORE the "nothing to migrate"
    # exit below — a project already on `_ops/` is exactly the one upgrading into 0.2.7, and it
    # is the one the guard's new refusal would otherwise strand on every commit.
    #
    # This used to be prose in `project-layout.md` ("All three are re-copied at every
    # migration"), with `upgrading.md` silent and this script copying only the guard. On this
    # corpus prose measured 0/5 for exactly this instruction, so it is a step that runs. The
    # source is this file's own directory, which is the only skill path a project can resolve
    # without knowing where its runtime cached the plugin.
    doors_done = []

    def recopy_doors():
        # Called from BOTH exits on purpose. A project already on `_ops/` returns early below,
        # and a flat project only has its guard at `_ops/scripts/` once the moves have run —
        # a single call site would have served one of them and silently skipped the other.
        if doors_done:
            return
        if not (root / "_ops" / "scripts" / "preflight.sh").is_file():
            # Said out loud: a project whose guard is chained from core.hooksPath, or never
            # wired at all, gets no doors here — and `upgrading.md` promises this script
            # brings them, so silence would be the script disagreeing with its own document.
            print("  no guard at _ops/scripts/preflight.sh — doors not placed; wire the guard first")
            return
        here = Path(__file__).resolve().parent
        for door in ("transition.py", "new-id.py"):
            src = here / door
            if not src.is_file():
                print(f"  cannot re-copy {door}: not beside {here} — copy it by hand")
                continue
            dst = root / "_ops" / "scripts" / door
            # Identical bytes are not a re-copy. This file's contract is that a second run
            # finds nothing to do and says so, and a step that reports work every time turns
            # that line into noise — the same reason the guard warns rather than refuses above.
            if dst.is_file() and dst.read_bytes() == src.read_bytes():
                continue
            keep = None
            if dst.is_file() and not dry:
                # Keep what it replaces — and never clobber a previous keep. One fixed slot lost
                # a project's hand-edited door on the second run while the message still said
                # where it was; measured 2026-08-14. The name carries the content hash, so a
                # re-run of the same replacement is a no-op rather than a loss.
                import hashlib
                h = hashlib.sha256(dst.read_bytes()).hexdigest()[:8]
                keep = dst.with_suffix(dst.suffix + f".replaced-{h}")
                if not keep.exists():
                    keep.write_bytes(dst.read_bytes())
            if dry:
                doors_done.append(door)
                continue
            differs = dst.is_file()   # it exists and its bytes differ, or we would have skipped
            dst.parent.mkdir(parents=True, exist_ok=True)
            dst.write_bytes(src.read_bytes())
            dst.chmod(0o755)
            rel = str(dst.relative_to(root))
            r = sh(root, "git", "add", rel)
            staged = sh(root, "git", "diff", "--cached", "--name-only").stdout.split("\n")
            if r.returncode != 0 or rel not in staged:
                # Measured: with `_ops/scripts/*.py` gitignored, or `_ops/scripts` a symlink, the
                # bytes land and nothing is staged — so the guard passes here (it reads the
                # worktree) and a clone of that commit hits the guard's hard refusal instead.
                print(f"  {rel} written but NOT staged"
                      f"{': ' + r.stderr.strip().splitlines()[0] if r.stderr.strip() else ' (ignored, or outside the repo)'}"
                      f" — the commit will not carry the door; `git add -f {rel}` or fix the ignore")
            if differs:
                # The docstring forbids the silent overwrite. A project that edited its door gets
                # told which file was replaced, and where the copy it lost is.
                # `keep` is the file just written. A glob sorted lexicographically picks the
                # max HASH, which named the wrong backup about half the time — the same
                # misdirection the hash naming was introduced to end.
                print(f"  {rel} differed from the shipped door and was replaced"
                      f" — the previous file is at {keep.relative_to(root)}")
            doors_done.append(door)
        if doors_done:
            verb = "would be re-copied" if dry else "re-copied"
            print(f"  doors {verb} beside the guard: {' · '.join(doors_done)}")

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
        recopy_doors()
        collapse_state_fields(root, dry)
        if doors_done:
            if dry:
                print("layout already `_ops/` — nothing moved; the doors above would be re-copied")
            else:
                # Without this the operator gets a green run, a staged change nobody mentioned,
                # and a SECOND run that refuses on the dirty-tree check — against a docstring
                # promising a second run finds nothing to do.
                print("layout already `_ops/` — nothing moved, and the doors above were re-copied "
                      "and staged. Commit them before running this again, or the dirty-tree check "
                      "refuses the next run.")
        else:
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

    recopy_doors()
    collapse_state_fields(root, dry)

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
