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
import os
import subprocess
import sys
from pathlib import Path

# Entity directories the machinery owns at a flat root. `scripts/` is absent on
# purpose: at a project root it is usually the craft's own; only the one file we
# ship there (the preflight) is claimed, below.
ENTITY_DIRS = [
    "tasks", "specs", "roles", "teams", "panels", "pipelines", "requests", "threads",
    "releases", "milestones", "automations", "resources",
    "runbooks", "research", "audience", "design-system", "brand", "process",
]

# `skills/` is claimed CONDITIONALLY, for the same reason `scripts/` is not claimed at all: at a
# project root the name is not ours by right. Reported 2026-09-05 from a live migration where
# `skills/` held one README pointing at an unrelated repository — someone else's entity, moved
# silently into `_ops/` and put back by hand. `docs/` already takes only the names it knows and
# prints what it left; this is that same care, arrived at three directories late.
# The test is the shape a pool actually has: a subdirectory carrying a `SKILL.md`.
def looks_like_skill_pool(d):
    # **A symlinked subdirectory is not evidence of a pool — it is the case this exists to stop.**
    # `is_dir()` follows symlinks, so `skills/theirs -> /elsewhere/theirs/` carrying a `SKILL.md`
    # made the whole directory look like ours and swept it into `_ops/`: the exact failure the
    # check was written against, one symlink away. Measured 2026-09-05. `is_symlink()` is asked
    # first, and the one `except` covers both an unreadable directory and a missing one.
    try:
        return any((sub / "SKILL.md").is_file()
                   for sub in d.iterdir() if sub.is_dir() and not sub.is_symlink())
    except OSError:
        return False

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
            # **Never write through a link that leaves the repository.** `write_bytes` follows a
            # symlink, so a door path pointing outside the tree meant this silently overwrote
            # somebody else's file: measured 2026-08-23, a 35-byte personal file replaced by 19 KB
            # of door, with the only notice being "the previous file is at …" — a backup written
            # INSIDE the repo, naming a path whose original was not. The tool was asked to place a
            # door in a repository and instead modified something outside it.
            #
            # This catches a symlinked ANCESTOR — `_ops/scripts` itself pointing out of the tree.
            # A symlinked door is caught earlier, by the second-name check below, and for a truer
            # reason: it does not matter where the other name lives, only that there is one. A door there cannot
            # be carried by any commit either, so refusing costs nothing that was going to work.
            try:
                _root_real = root.resolve()
                _dst_real = dst.resolve() if dst.exists() or dst.is_symlink() else (dst.parent.resolve() / dst.name)
                _outside = _root_real not in _dst_real.parents
            except OSError:
                _outside = True
                _dst_real = dst
            # **A hardlink has no target to resolve, and `resolve()` is the whole test above.** So a
            # door hardlinked to a file outside the tree passed containment and was written through
            # exactly as a symlink used to be — measured 2026-08-27, a 36-byte file outside the
            # repository replaced by 19 KB of door, reported as success at exit 0. Same outcome the
            # symlink fix was written to stop, one link type over. There is nothing to resolve, so
            # the test is the link COUNT: more than one name for these bytes means writing here
            # writes somewhere else too, and this command was pointed at one repository.
            # **A symlink whose target is INSIDE the repository is still a second name for other
            # bytes.** The containment test only asks whether the target leaves the tree, and this
            # link-count test skipped symlinks entirely — so `_ops/scripts/transition.py ->
            # ../../tools/mine.py` was written straight through, replacing a tracked 30-byte file
            # with 19 KB of door and naming a backup that was not it. Measured 2026-08-27. The
            # question is not where the other name lives; it is that there IS another name, and
            # this command was pointed at one path.
            _links, _via = 0, ""
            try:
                if dst.is_symlink():
                    _links, _via = 2, f"a symlink to {os.readlink(dst)}"
                elif dst.is_file():
                    _links = dst.stat().st_nlink
                    if _links > 1:
                        _via = f"a hard link with {_links} names"
            except OSError:
                _links = 0
            if _links > 1:
                print(f"  {door} is {_via} — writing it here would rewrite the other name too, "
                      f"and this command was pointed at one path. Refusing, so nothing is lost. "
                      f"To put the door here instead, `rm _ops/scripts/{door}` and run this again — "
                      f"that removes the LINK, never what it points at, so the other file keeps its "
                      f"bytes. **If you want to keep the link there is no way through this command**: "
                      f"place the door at that path by hand and stage it, or point the link at a "
                      f"copy of the shipped door rather than at something else")
                doors_done.append(door)
                _failed.append(door)
                continue
            # **A symlinked ANCESTOR pointing INSIDE the repository defeated both tests above.**
            # `_outside` asks only whether the target leaves the tree, and the link-count test looks
            # at the door itself — but `_ops/scripts -> scripts_real` makes the door an ordinary
            # file with one name, sitting at a path git refuses to stage: *"beyond a symbolic
            # link"*. Measured 2026-08-28: a tracked 45-byte file replaced by 19 KB of door, at
            # exit 0, while the diagnosis printed *"a symlink OUT of the repository"* about a link
            # that pointed in, and prescribed putting it inside — which it already was. The
            # direction was never the point. Any symlink between the root and the door is a second
            # name for the location, and no commit here can carry a file behind one.
            _anc, _anc_to, _anc_in = None, "", False
            try:
                _walk = dst.parent
                while True:
                    if _walk.is_symlink():
                        _anc, _anc_to = _walk, os.readlink(_walk)
                        _w = _walk.resolve()
                        _anc_in = _root_real == _w or _root_real in _w.parents
                    if _walk.resolve() == _root_real or _walk.parent == _walk:
                        break
                    _walk = _walk.parent
            except OSError:
                pass
            if _anc is not None:
                _where = "inside this repository" if _anc_in else "OUT of this repository"
                print(f"  {door} would be written through `{_anc}`, which is a symlink to "
                      f"`{_anc_to}` — {_where}. Refusing, so nothing is lost. Either way git "
                      f"cannot stage a path behind a symlink (*pathspec ... is beyond a symbolic "
                      f"link*), so no commit here could carry the door, and the bytes it would "
                      f"overwrite belong to a path this command was not pointed at. The direction "
                      f"the link points does not change either of those. To place the door here, "
                      f"replace that link with a real directory and run this again")
                doors_done.append(door)
                _failed.append(door)
                continue
            if _outside:
                print(f"  {door} would be written to {_dst_real}, which is OUTSIDE this "
                      f"repository — refusing. Something on the path `_ops/scripts/{door}` is a "
                      f"symlink leading out of the tree, so writing the door would modify a file "
                      f"this command was never pointed at, and no commit here could carry it "
                      f"anyway. Replace the link with a real directory or file inside the "
                      f"repository, then run this again")
                doors_done.append(door)
                _failed.append(door)
                continue
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
                # **The same chooser as the write path, and the same `_failed` bookkeeping.**
                # This branch printed the old either/or menu that the write path had just been
                # cured of, and never touched `_failed` — so `doors re-copied beside the guard`
                # printed over two hard refusals and the run exited 0. Measured 2026-08-23 by an
                # adversarial lens, on a repository whose doors were gitignored and untracked.
                _w0 = r0.stderr.strip().splitlines()[0] if r0.stderr.strip() else ""
                if "symbolic link" in _w0:
                    _f0 = ("`_ops/scripts` is a symlink out of the repository, so git cannot stage "
                           "anything through it. Put `_ops/scripts` inside the repository — the "
                           "door has to be a file this commit can carry")
                elif "ignored" in _w0:
                    _f0 = (f"the path is ignored — `git add -f {_rel0}` stages it, and it is worth "
                           f"asking why `_ops/scripts` is in `.gitignore` at all")
                else:
                    _f0 = (f"git gave no reason, so this does not guess at one. Run `git add "
                           f"{_rel0}` yourself and read what it says; check `git ls-files -v "
                           f"{_rel0}` for a `S` or `h` flag, and that `_ops/scripts` is not itself "
                           f"a nested repository")
                print(f"  {_rel0} is on disk with the right bytes and is NOT in the index"
                      f"{': ' + _w0 if _w0 else ''} — the commit will not carry the door. {_f0}")
                doors_done.append(door)
                _failed.append(door)
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

    left_alone = []

    def claim(src_rel, dst_rel):
        if (root / src_rel).exists():
            moves.append((src_rel, dst_rel))

    claim("config.md", "_ops/config.md")
    for d in ENTITY_DIRS:
        claim(d, f"_ops/{d}")
    _sk = root / "skills"
    if looks_like_skill_pool(_sk):
        claim("skills", "_ops/skills")
    elif _sk.is_dir():
        left_alone.append(
            "skills/ — nothing under it carries a SKILL.md, so it does not look like a pool of "
            "the machinery's skills, and it has been left exactly where it was. If it IS one: "
            "`git mv skills _ops/skills`. If a skill lands under it later — any subdirectory with "
            "a SKILL.md — this command claims it on the next run without being asked")
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

    # **Said before the early exit, because it is the whole message when nothing moves.** A repo
    # whose only ambiguity is a foreign `skills/` printed "nothing to migrate" and not a word about
    # it: the line lived after a `return 0` it could not reach. Measured 2026-09-05; the shipped
    # test passed only because its fixture also had something to move.
    for line in left_alone:
        print(f"  left alone: {line}")

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

    # **What this run is about to move is not left behind, and a dry run must not say it is.**
    # `leftovers` read the directory from disk; under `--dry-run` nothing has moved yet, so every
    # file the preview had just promised to move was printed a second time as staying put. The
    # behaviour was right and only the preview lied — in the one place a preview exists for.
    # Reported 2026-09-05. Named it `--dry-run` promises: *show what it would do before it does it*.
    _claimed = {s for s, _ in moves}
    leftovers = sorted(p.name for p in (root / "docs").iterdir()
                       if f"docs/{p.name}" not in _claimed) if (root / "docs").is_dir() else []
    if leftovers:
        print(f"  left in docs/ as possibly the craft's own: {', '.join(leftovers)}")

    for s, d in conflicts:
        print(f"  CONFLICT: {s} not moved — {d} already exists; merge by hand")

    if not dry:
        print("moved — review the staged renames, then commit them as one migration commit")
    return 1 if conflicts else 0


if __name__ == "__main__":
    sys.exit(main())
