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
import re
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


def report_state_fields(root, dry):
    """0.2.6 tasks carry state twice — a prose `**Status**` and a machine `stage:`. This NAMES
    them and the one-line edit each needs. It does not write.

    It used to write, and that was wrong. A lens pass built fixtures against it and found seven
    distinct ways it destroyed content in a project this script does not own — measured
    2026-08-15: it deleted a line out of a fenced example; deleted a line out of a four-space
    indented example and then took the example's value as the task's state; ate a prose sentence
    that happened to begin with the word `stage:`; deleted the WRONG line entirely once an
    insert shifted the indices under it, leaving the duplicate it existed to remove; destroyed a
    neighbouring field when a header used `-` as its separator; corrupted a table row; and
    rewrote a non-UTF-8 byte into a replacement character, irreversibly, with no backup.

    Patching seven holes in a function whose job is to rewrite someone else's prose is how the
    eighth arrives. The class is gone instead: the guard now refuses a commit that ADDS a second
    state home rather than the existence of one, so a project carrying the old shape is not
    stranded and does not need rewriting — and what it does need, its owner can see here and do
    deliberately.
    """
    import re
    tdir = root / "_ops" / "tasks"
    tasks = sorted(tdir.glob("*.md")) if tdir.is_dir() else []
    MACHINE = re.compile(r"^[ \t]*(?:stage|стадия)[ \t]*:[ \t]*(.+?)[ \t]*$", re.I)
    # The value stops at ` - ` and at a double space as well as at `·` and `|`. A header using a
    # hyphen as its separator — `**Status**: doing - **Owner**: me` — was otherwise read as the
    # single value `doing - **Owner**: me`, and the report then told its reader that the field
    # "currently says" that, immediately above an instruction to set it to one word. Following
    # that drops `**Owner**`, which is destruction #5 of the seven this script stopped performing,
    # transcribed into the instruction it prints instead.
    PROSE = re.compile(r"(?:\*\*)?(?:Status|Статус)(?:\*\*)?[ \t]*:[ \t]*(.*?)(?=[·|]| - |  |$)",
                       re.I)
    # A stage is a token, not a sentence. `stage: doing is what we mean when we say it` produced
    # `set **Status**: doing is what we mean when we say it` — an unvalidated prose line offered
    # as the value of a field `transition.py` then reads as the stage.
    STAGE_TOKEN = re.compile(r"^[\w-]+$", re.U)
    found, unreadable = [], []
    for tf in tasks:
        try:
            raw = tf.read_text(encoding="utf-8")
        except (UnicodeDecodeError, OSError):
            # Not ours to read, and certainly not ours to rewrite — but SAID, not dropped. A task
            # with a real two-home disagreement and one invalid UTF-8 byte was omitted while the
            # header still counted the rest and called them all, so a report whose whole purpose
            # is naming what disagrees quietly shrank. Measured 2026-08-15 (pass nine).
            unreadable.append(tf.name)
            continue
        lines, fence, mach, prose, mach_line = raw.split("\n"), False, None, None, 0
        # `enumerate`, because `lines.index(l)` returns the first line EQUAL to this one, not this
        # one. A task carrying a fenced example byte-identical to its real field reported the
        # fenced line as the line to delete — so a reader following the report destroys the
        # example and leaves the duplicate the report exists to remove. That is destruction #1 of
        # the seven, re-created as an instruction; indented and blockquoted duplicates differ
        # textually and reported correctly, which is why it survived.
        for i, l in enumerate(lines):
            if re.match(r"^[ \t]*(```|~~~)", l):
                fence = not fence
                continue
            # `^\s*>` — a blockquote at ANY indent, matching the guard's `/^[[:space:]]*>/`. This read
            # column 0 only, so `  > **Status**: x` was a field here and an example there: the two
            # tools disagreed about a case the comment beside them claimed they agreed on.
            if fence or re.match(r"^\s*>", l) or re.match(r"^(\t| {4})", l):
                continue                  # an example is not a field
            if mach is None and MACHINE.match(l):
                mach = MACHINE.match(l).group(1).strip()
                mach_line = i + 1
            if prose is None and PROSE.search(l):
                prose = PROSE.search(l).group(1).strip()
        if mach is not None and prose is not None:
            found.append((tf.name, prose or "(empty)", mach, mach_line))
    def _say_unreadable():
        if unreadable:
            print(f"  {len(unreadable)} task(s) could not be read as UTF-8 and were not "
                  f"examined — check these by hand: {' · '.join(sorted(unreadable))}")
    if not found:
        _say_unreadable()
        return []
    print(f"  {len(found)} task(s) carry state in two places, and 0.2.7 refuses a commit that "
          f"ADDS a second — these are legacy and are NOT refused, but they disagree:")
    # Per task, the exact edit — not a general instruction. Measured 2026-08-15: the general
    # form ("keep it in **Status**, delete the machine line — by hand") produced a report and a
    # request for permission in FIVE runs out of five; nobody applied it. The refusal that went
    # 5/5 in the same round printed the literal line to paste, per file. This is that shape.
    # TWO COMMITS, in this order, and the order is the whole point. Printed as one act — "delete
    # the line and set **Status**" — it walks into §14: editing a stage by hand is the bypass the
    # guard refuses, so the reader who follows the instruction is refused, and reaching for the
    # door instead is refused too because the door still reads the machine copy. Measured
    # 2026-08-15 (pass nine, cold read) on the shipped N95 fixture: for the two tasks whose
    # copies DISAGREE — the only tasks this report exists for — there was no path through but
    # `--no-verify`. Deleting the machine line alone removes a state home without adding one,
    # which §14 lets past; after that the door reads `**Status**` and the move is a real move.
    for name, prose, mach, line_no in found[:8]:
        print(f"    _ops/tasks/{name}")
        print(f"      1. delete line {line_no} (the machine `stage:` line) and commit THAT ALONE — "
              f"it removes a duplicate and changes no stage, so the guard passes it")
        if STAGE_TOKEN.match(mach):
            if prose != mach:
                # **The door refuses BOTH of the two values this used to offer.** It printed
                # `<{prose}|{mach}>` as a choice: `prose` is where the task already is, and a
                # no-op transition is refused ("already at X"); `mach` is refused whenever it is
                # more than one rung away ("stages are linear — no jumps"). So a reader following
                # the report literally was refused either way, with no third thing named.
                # Measured 2026-08-21 (pass twelve). The remedy now names ONE action — the only
                # one that is ever a move — and says plainly what to do when the rungs are apart.
                print(f"      2. the header already says `{prose}`, so that is where the task IS; "
                      f"the machine line claimed `{mach}`. If the header was right, you are done. "
                      f"If the machine line was right, move it with the door:")
                print(f"           python3 _ops/scripts/transition.py _ops/tasks/{name} "
                      f"{mach} --by <you>")
                print(f"         — and if that is refused as a jump, the ladder is linear: walk it "
                      f"one rung at a time, each its own command, which is also what leaves an "
                      f"honest History. Asking for `{prose}` is refused as a no-op, so it is not "
                      f"offered here.")
            else:
                print(f"      2. nothing else — both copies said `{mach}`, so deleting the machine "
                      f"line is the whole change")
        else:
            print(f"      2. the `stage:` line reads `{mach}`, which is not a stage name. Decide "
                  f"what this task's stage actually is and move it with the door — "
                  f"`python3 _ops/scripts/transition.py _ops/tasks/{name} <stage> --by <you>`. No "
                  f"value is printed here: printing this one would put a sentence where a stage "
                  f"belongs, and `transition.py` would then read it as one.")
    if len(found) > 8:
        # "same two edits each" was the wording the two-commit repair abolished four lines above:
        # the fix is a SEQUENCE of two commits in order, not two edits, and a reader who stops at
        # the overflow line gets the instruction that walks into §14. Measured 2026-08-15 (pass
        # ten) — the line reverted the repair for every task past the eighth.
        print(f"    … and {len(found) - 8} more, each the same two commits in the same order")
    print("  Nothing else in the file changes, and this script makes none of it: it edits nobody's "
          "prose. Do not set **Status** by hand — §14 refuses a stage edited outside the door, "
          "which is why step 2 is the door and not an edit.")
    _say_unreadable()
    return [f[0] for f in found]


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
                # An UNFILLED placeholder is not a declaration. `GUIDE-template.md` line 13 reads
                # `**Operated by:** {{skill display_name}}`, which contains "operated by" and not
                # "opsinist", so a project whose guide was copied from the template and not yet
                # generated was handed back as another system's tree. Measured 2026-08-15 (pass
                # ten) inside the eval harness, where `wired;` copies exactly that template: the
                # `--doors-only` remedy the guard prints as THE fix was refused whole, exit 2, no
                # door copied — the remedy could not run in the harness built to measure whether
                # anyone runs it. It bites real projects the same way, between day one and the
                # first generation of the guide.
                # ...but only when the OPERATOR ITSELF is the placeholder. `{{` anywhere in the
                # line was far too wide: a sibling methodology's own guide template names itself
                # and leaves a placeholder VERSION beside it — `**Operated by <them> {{x.y.z}}.**`
                # — so the skip disarmed the shared door for exactly the tree it exists to protect,
                # and this script would have migrated that workspace. Measured 2026-08-15 (pass
                # eleven): EXIT=0, files moved. Ours puts the placeholder where the NAME goes;
                # theirs puts the name there. That is the whole distinction.
                _after = re.split(r"operated\s+by", line, flags=re.I)[1] if re.search(
                    r"operated\s+by", line, re.I) else ""
                _after = _after.lstrip(" :*\t")
                if _after.startswith("{{"):
                    continue
                if "operated by" in line.lower() and "opsinist" not in line.lower():
                    print(f"{guide} says this tree is operated by another system:")
                    print(f"    {line.strip()}")
                    print("not ours to migrate — handed back untouched")
                    return 2
    # `--doors-only` skips the dirty-tree refusal, and it must, because of WHO prints the command
    # that runs it. The guard's doors refusal is emitted by a pre-commit hook — which is to say,
    # always with work staged — and it offered `migrate-layout.py .` as its first remedy. Measured
    # 2026-08-15 (pass nine): following that instruction literally, at the moment it is printed,
    # got "the tree is dirty — commit or stash first" and no door copied. The first remedy could
    # not work where it was printed, which is a fair share of why that refusal measured 2 of 5.
    # Copying two files the project is missing is not a migration and owes nobody a clean diff.
    doors_only = "--doors-only" in sys.argv
    if not dry and not doors_only and sh(root, "git", "status", "--porcelain").stdout.strip():
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
    _failed = []

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
            #
            # **But bytes on disk are not the whole question, and answering only that one made
            # this print "already in place and current" over a door the commit would not carry.**
            # A door removed from the index while its bytes stay on disk is the third case the
            # refusal below names as measured, and it was the one case the remedy could not
            # reach: this returned early, the guard reads the worktree and saw the file, and
            # nothing anywhere said the commit was about to go out without it. Measured
            # 2026-08-23 by an adversarial lens. So identical bytes still have to be IN the index.
            if dst.is_file() and dst.read_bytes() == src.read_bytes():
                _rel0 = str(dst.relative_to(root))
                _i0 = sh(root, "git", "ls-files", "-s", "--", _rel0).stdout.split()
                _w0 = sh(root, "git", "hash-object", "--", str(dst)).stdout.strip()
                if len(_i0) >= 2 and _w0 and _i0[1] == _w0:
                    continue
                r0 = sh(root, "git", "add", _rel0)
                _i1 = sh(root, "git", "ls-files", "-s", "--", _rel0).stdout.split()
                if r0.returncode == 0 and len(_i1) >= 2 and _i1[1] == _w0:
                    print(f"  {_rel0} was on disk but not in the index — staged it; "
                          f"the commit would not have carried the door")
                    doors_done.append(door)
                    continue
                print(f"  {_rel0} is on disk with the right bytes and is NOT in the index, and "
                      f"`git add` did not put it there"
                      f"{': ' + r0.stderr.strip().splitlines()[0] if r0.stderr.strip() else ''}"
                      f" — the commit will not carry the door. `git add -f {_rel0}` works when the "
                      f"path is IGNORED; when `_ops/scripts` is a symlink out of the repo, place "
                      f"the door inside the repository instead")
                doors_done.append(door)
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
            # **Ask the INDEX, not the difference from HEAD.** `git diff --cached --name-only`
            # lists paths whose index entry differs from the commit — so a door restored to the
            # exact bytes it already has at HEAD is staged correctly and appears nowhere in that
            # list. The message below then fired on the one path where it does the most harm:
            # a maintainer running the remedy the guard just printed, told their door was not
            # staged and pointed at ignored paths and symlinks that were not their problem.
            # Measured 2026-08-23. Comparing the index blob to the file's own hash asks the
            # question actually being asked — is this content in the index — and is true whether
            # or not HEAD already agrees.
            _idx = sh(root, "git", "ls-files", "-s", "--", rel).stdout.split()
            _want = sh(root, "git", "hash-object", "--", str(dst)).stdout.strip()
            in_index = len(_idx) >= 2 and _want and _idx[1] == _want
            if r.returncode != 0 or not in_index:
                # Measured: with `_ops/scripts/*.py` gitignored, or `_ops/scripts` a symlink, the
                # bytes land and nothing is staged — so the guard passes here (it reads the
                # worktree) and a clone of that commit hits the guard's hard refusal instead.
                # **One remedy, chosen from what git actually said** — not a menu ending in
                # "read the reason above and pick accordingly", which pointed at a parenthetical
                # in the same sentence and, when git printed nothing, at an unresolved either/or.
                # Named 2026-08-23 by a cold-read lens asking what it would do at the terminal.
                _why = r.stderr.strip().splitlines()[0] if r.stderr.strip() else ""
                if "symbolic link" in _why:
                    _fix = ("`_ops/scripts` is a symlink out of the repository, so git cannot "
                            "stage anything through it. Put `_ops/scripts` inside the repository "
                            "— the door has to be a file this commit can carry")
                elif "ignored" in _why:
                    _fix = (f"the path is ignored — `git add -f {rel}` stages it, and it is worth "
                            f"asking why `_ops/scripts` is in `.gitignore` at all")
                else:
                    # **Do not diagnose what git did not say.** This branch used to be folded in
                    # with the ignored case (`or not _why`) and asserted the path "looks ignored"
                    # on no evidence — reachable through `skip-worktree`, `assume-unchanged` or a
                    # nested repository, where `git add -f` does nothing. And its sibling ended
                    # "git's reason is above", pointing three words to the left in the same
                    # printed line. Both were the defect this message was rewritten to remove,
                    # one branch deeper. Named 2026-08-23 by two lenses reading the same lines.
                    _fix = (f"git gave no reason, so this does not guess at one. Run `git add "
                            f"{rel}` yourself and read what it says: if it is silent, check "
                            f"`git ls-files -v {rel}` for a `S` or `h` flag (skip-worktree or "
                            f"assume-unchanged) and clear it, and check that `_ops/scripts` is "
                            f"not itself a nested repository")
                print(f"  {rel} written but NOT staged"
                      f"{': ' + _why if _why else ''} — the commit will not carry the door. {_fix}")
                _failed.append(door)
            if differs:
                # The docstring forbids the silent overwrite. A project that edited its door gets
                # told which file was replaced, and where the copy it lost is.
                # `keep` is the file just written. A glob sorted lexicographically picks the
                # max HASH, which named the wrong backup about half the time — the same
                # misdirection the hash naming was introduced to end.
                print(f"  {rel} differed from the shipped door and was replaced"
                      f" — the previous file is at {keep.relative_to(root)}")
            doors_done.append(door)
        _ok = [d for d in doors_done if d not in _failed]
        if _ok:
            verb = "would be re-copied" if dry else "re-copied"
            print(f"  doors {verb} beside the guard: {' · '.join(_ok)}")
        if _failed:
            # A door written to disk and not staged is not a door this repository has. Printing
            # "re-copied" over it read as success directly under two refusals — the same shape
            # `git pull` uses to hide its own failures: it prints `Aborting` and `Updating
            # <old>..<new>` on adjacent lines, and a glance takes the second.
            print(f"  NOT carried by this commit: {' · '.join(_failed)} — see the line(s) above")

    if doors_only:
        # The whole job: put the two doors back and stop. Nothing is moved, nothing is reported,
        # no clean tree is asked for — this exists to be runnable at the exact moment the guard
        # refuses a commit for missing doors, which is the only moment its instruction is read.
        recopy_doors()
        if not doors_done:
            print("  nothing to copy — both doors are already in place and current")
        return 0

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
        report_state_fields(root, dry)
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
    report_state_fields(root, dry)

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
