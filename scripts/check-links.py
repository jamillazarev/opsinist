#!/usr/bin/env python3
"""Cross-reference validator: does the file exist, and does the section inside it?

The existing structure check verifies that a file exists. It cannot tell that
`ROLES.md → Skill load` points at a section that was renamed, or that `REFERENCE §7`
survived a split. With the corpus cut into ~36 companions those references multiply by an
order of magnitude, and moving a rule between files is the whole job — so this runs before
the recut, not after.

Output: path:line: LEVEL: [RULE] message

  LINK001  FAIL  markdown link target does not exist
  LINK002  FAIL  prose reference names a file that does not exist
  LINK003  FAIL  prose reference names a section the target file does not have
  LINK004  WARN  backticked repo path does not exist (may be an example)

Exit 1 on any FAIL. WARNs never fail the run — a checker that cries wolf gets bypassed,
and then none of it is enforced.

Usage: python3 scripts/check-links.py [root]
"""

import re
import pathlib
import sys
import unicodedata
from pathlib import Path

ROOT = Path(sys.argv[1] if len(sys.argv) > 1 else ".").resolve()

# Paths that belong to the *user's* project, created at init — never ours to resolve.
FOREIGN_PREFIXES = ("docs/", "process/", "tasks/", "roles/", "teams/", "pipelines/",
                    "requests/", "threads/", "releases/", "milestones/", "automations/",
                    "resources/", "skills/", "events/", ".claude/", "~/")

# Bare filenames that name a file in the *user's* project, not in this repo.
FOREIGN_NAMES = {"TEAM.md", "TOOLING.md", "DECISIONS.md", "LATER.md", "ROADMAP.md",
                 "ARCHITECTURE.md", "UPGRADES.md", "BUDGET.md", "ECONOMICS.md",
                 "COMPANY.md", "BACKLOG.md", "FIELD-NOTES.md", "DASHBOARD.md",
                 "CONVENTIONS.md", "assets.md", "config.md", "CLAUDE.md",
                 # Someone else's repo, met in guest mode — never ours to resolve.
                 "CONTRIBUTING.md",
                 # The two files a record is opened with, in the user's own store.
                 "record.md", "runs.md"}

# The changelog records history: it names sections that existed when it was written.
SKIP_FILES = {"CHANGELOG.md"}

FENCE = re.compile(r"^\s*(```|~~~)")
MD_LINK = re.compile(r"\[[^\]]*\]\(([^)\s]+)(?:\s+\"[^\"]*\")?\)")
# FILE.md → Section Title   ·   FILE → Section Title
PROSE_ARROW = re.compile(r"\b([A-Z][A-Za-z0-9_-]*(?:\.md)?)\s*(?:→|->)\s*([A-Za-z][^,.;·|)\n]{2,60})")
# FILE §7   ·   FILE.md §7.2
PROSE_SECTION = re.compile(r"\b([A-Z][A-Za-z0-9_-]*(?:\.md)?)\s*§\s*(\d+[0-9.]*)")
BACKTICK_PATH = re.compile(r"`([A-Za-z0-9_./-]+\.(?:md|py|sh|json))`")
# FILE.md:123 — a citation into a file at a line. Twenty-one of these sat in the sources
# register pointing at files deleted in the restructure, because no pattern here matched them.
PROSE_LINE = re.compile(r"\b((?:[A-Za-z0-9_-]+/)*[A-Za-z][A-Za-z0-9_-]*\.md):(\d+)\b")
HEADING = re.compile(r"^#{1,6}\s+(.*?)\s*#*\s*$")

findings = []


def add(level, rule, path, line, msg):
    findings.append((level, f"{path}:{line}: {level}: [{rule}] {msg}"))


INLINE_CODE = re.compile(r"`[^`]*`")


def strip_code_spans(text):
    """Blank out inline code so an example is not read as a link.

    Documenting a link format necessarily writes one: `![alt](relative/path.png)` inside
    backticks is a demonstration, not a reference, and reporting it dead teaches people to
    stop documenting formats.
    """
    return INLINE_CODE.sub(lambda m: " " * len(m.group(0)), text)


def strip_fences(lines):
    """Return (lineno, text) for lines outside fenced code blocks."""
    out, inside = [], False
    for i, raw in enumerate(lines, 1):
        if FENCE.match(raw):
            inside = not inside
            continue
        if not inside:
            out.append((i, raw))
    return out


def norm(s):
    s = unicodedata.normalize("NFKD", s).lower()
    return re.sub(r"[^a-z0-9]+", " ", s).strip()


def headings_of(path):
    """Normalized heading texts of a markdown file, plus their leading numbers."""
    texts, numbers = set(), set()
    try:
        lines = path.read_text(encoding="utf-8").splitlines()
    except (OSError, UnicodeDecodeError):
        return texts, numbers
    for _, raw in strip_fences(lines):
        m = HEADING.match(raw)
        if not m:
            continue
        title = m.group(1)
        texts.add(norm(title))
        n = re.match(r"\s*(\d+[0-9.]*)\s*[.·)]?\s", title)
        if n:
            numbers.add(n.group(1).rstrip("."))
    return texts, numbers


HEADING_CACHE = {}


def headings_cached(path):
    key = str(path)
    if key not in HEADING_CACHE:
        HEADING_CACHE[key] = headings_of(path)
    return HEADING_CACHE[key]


def index_tree():
    """Every markdown file in this repo, by exact filename. Case-sensitive on purpose:
    macOS resolves paths case-insensitively, which would make `Ship → Measure` look like a
    file reference to SHIP.md. Prose arrows are the common case; file arrows are the rare
    one, so the burden of proof is on the arrow."""
    idx = {}
    for p in ROOT.rglob("*.md"):
        if ".git" in p.parts:
            continue
        idx.setdefault(p.name, []).append(p)
    return idx


TREE = index_tree()


# Under the plugin's skills/ layout every command is its own `<verb>/SKILL.md`, so the bare
# name `SKILL.md` is ambiguous nineteen ways. A prose reference to it always means the corpus
# core; without this the checker resolved to whichever verb sorted first and reported a
# missing section that was never missing.
CORE = pathlib.Path("skills/advisor/SKILL.md")


def resolve(name, here):
    """A prose reference resolves only to a file that actually exists under that exact name."""
    fname = name if name.endswith(".md") else name + ".md"
    if fname == "SKILL.md" and CORE.exists():
        return CORE
    if fname in FOREIGN_NAMES:
        return None
    candidates = TREE.get(fname)
    if not candidates:
        return None
    if len(candidates) == 1:
        return candidates[0]
    sibling = here.parent / fname
    return sibling if sibling in candidates else candidates[0]


def foreign(target):
    if "://" in target or target.startswith(("mailto:", "#")):
        return True
    if target.strip("…. ") == "":            # placeholder link like [PR #412](…)
        return True
    if Path(target).name in FOREIGN_NAMES:
        return True
    return any(target.startswith(p) for p in FOREIGN_PREFIXES)


def check(md):
    rel = md.relative_to(ROOT)
    lines = md.read_text(encoding="utf-8").splitlines()
    for lineno, raw_text in strip_fences(lines):
        text = strip_code_spans(raw_text)

        for target in MD_LINK.findall(text):
            if foreign(target):
                continue
            anchor = None
            if "#" in target:
                target, anchor = target.split("#", 1)
            if not target:
                continue
            dest = (md.parent / target).resolve()
            if not dest.exists():
                add("FAIL", "LINK001", rel, lineno, f"link target not found: {target}")
                continue
            if anchor and dest.suffix == ".md":
                texts, _ = headings_cached(dest)
                if norm(anchor.replace("-", " ")) not in texts:
                    add("FAIL", "LINK003", rel, lineno,
                        f"{target} has no section matching anchor #{anchor}")

        for name, section in PROSE_ARROW.findall(text):
            if name.lower() in {"the", "this", "note", "why", "rule", "and", "then", "so"}:
                continue
            dest = resolve(name, md)
            if dest is None:
                continue  # not a file reference — ordinary prose using an arrow
            texts, _ = headings_cached(dest)
            wanted = norm(section)
            if not wanted:
                continue
            if not any(wanted in t or t in wanted for t in texts):
                add("FAIL", "LINK003", rel, lineno,
                    f"{dest.name} has no section matching «{section.strip()}»")

        for name, num in PROSE_SECTION.findall(text):
            dest = resolve(name, md)
            if dest is None:
                add("FAIL", "LINK002", rel, lineno, f"referenced file not found: {name}")
                continue
            _, numbers = headings_cached(dest)
            if numbers and num.rstrip(".") not in numbers:
                add("FAIL", "LINK003", rel, lineno,
                    f"{dest.name} has no section §{num}")

        for path, _line in PROSE_LINE.findall(text):
            if foreign(path):
                continue
            if (ROOT / path).exists() or (md.parent / path).exists():
                continue
            if Path(path).name in TREE:
                continue
            add("FAIL", "LINK002", rel, lineno, f"citation into a file that does not exist: {path}")

        for target in BACKTICK_PATH.findall(text):
            if foreign(target):
                continue
            if (ROOT / target).exists() or (md.parent / target).exists():
                continue
            if Path(target).name in TREE:          # exists elsewhere in the tree
                continue
            add("WARN", "LINK004", rel, lineno, f"path not found: {target}")


def main():
    for md in sorted(ROOT.rglob("*.md")):
        if ".git" in md.parts or md.name in SKIP_FILES:
            continue
        check(md)

    fails = [m for lvl, m in findings if lvl == "FAIL"]
    warns = [m for lvl, m in findings if lvl == "WARN"]
    for m in fails + warns:
        print(m)
    print(f"\n{len(fails)} FAIL, {len(warns)} WARN")
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())
