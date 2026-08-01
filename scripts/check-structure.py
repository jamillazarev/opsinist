#!/usr/bin/env python3
"""Structural integrity of the docs. Every check here exists because the defect it
looks for actually shipped once — see the 2.1.0 entry. Prints FAIL:/WARN: lines
for preflight to render; deterministic classes fail, heuristic ones warn."""
import glob, os, re, shutil, subprocess, sys

os.chdir(os.path.join(os.path.dirname(os.path.abspath(__file__)), ".."))  # the skill corpus

DOCS = sorted(set(glob.glob("*.md")) | set(glob.glob("templates/*.md")) | set(glob.glob("evals/*.md")))
# Repo furniture lives two levels up; the README carries counts about the corpus, so it is
# scanned like a document — but never counted as one.
DOCS += [p for p in ("README.md",) if os.path.exists(p)]
out = []
def fail(m): out.append("FAIL:" + m)
def warn(m): out.append("WARN:" + m)

def strip_code(t):
    return re.sub(r"```.*?```", "", t, flags=re.S)

def cells(line):
    """Pipe count that ignores escaped pipes and pipes inside inline code —
    `/upgrade [skill\\|all]` is one cell, not two."""
    l = re.sub(r"`[^`]*`", "`", line).replace(r"\|", "")
    return l.count("|")

for f in DOCS:
    t = open(f, encoding="utf-8").read()
    lines = t.split("\n")
    body = strip_code(t)

    # a · a markdown table row must have the column count its header declares.
    # Fifteen STACKS rows silently lost their free-tier column this way.
    cols, in_tbl = None, False
    for i, l in enumerate(lines, 1):
        s = l.strip()
        if not s.startswith("|"):
            cols, in_tbl = None, False
            continue
        if re.match(r"^\|[\s\-:|]+\|$", s):
            cols = cells(lines[i - 2]) if i >= 2 else None
            in_tbl = True
            continue
        if in_tbl and cols and cells(l) != cols:
            fail(f"{f}:{i} table row has {cells(l)-1} cells, header declares {cols-1}")

    # b · a list item's continuation must stay indented, or it falls out of the list.
    in_list = False
    for i, l in enumerate(lines, 1):
        if re.match(r"^\s*([-*]|\d+\.) ", l):
            in_list = True
            continue
        if in_list:
            if not l.strip() or l.lstrip().startswith(("|", ">", "```", "#")):
                in_list = False
            elif not l.startswith("  "):
                fail(f"{f}:{i} list continuation lost its indent — renders as a stray paragraph")
                in_list = False

    # b2 · a heading swallowed by the sentence above it. An insert that replaces part of a
    # block and leaves the rest is the signature defect of repeated rewriting, and it hides
    # from the Contents check because the heading no longer exists on either side.
    for i, l in enumerate(lines, 1):
        if re.search(r"[a-z,)]\d+\.\s+[A-Z]", l) and not l.lstrip().startswith(("|", ">", "-", "#")):
            fail(f"{f}:{i} looks like a heading absorbed into prose — '{l.strip()[:60]}'")

    # b3 · section numbers must be contiguous: a missing §N means one was eaten or dropped.
    nums = [int(m.group(1)) for m in re.finditer(r"^## (\d+)\.", t, re.M)]
    if nums and nums != list(range(nums[0], nums[0] + len(nums))):
        missing = sorted(set(range(nums[0], nums[-1] + 1)) - set(nums))
        if missing:
            fail(f"{f}: section numbering skips {missing} — a heading was lost")

    # c · a line ending in a hyphen is a word a reflow tool broke in half.
    for i, l in enumerate(lines, 1):
        if re.search(r"[a-z]-$", l):
            fail(f"{f}:{i} line ends mid-word on a hyphen")

    # d · "Three loops:" must be followed by three of them.
    words = dict(one=1, two=2, three=3, four=4, five=5, six=6, seven=7, eight=8)
    for i, l in enumerate(lines, 1):
        m = re.search(r"\b(one|two|three|four|five|six|seven|eight|\d+)\s+(?:\w+\s+){0,2}"
                      r"(loops?|kinds?|rules?|blocks?|passes|things?|levers?|guardrails?|"
                      r"options?|origins?|shapes?|questions?|steps?)\b[^.]*:\s*$", l, re.I)
        if not m:
            continue
        want = words.get(m.group(1).lower(), None) or (int(m.group(1)) if m.group(1).isdigit() else None)
        if not want:
            continue
        got, j = 0, i
        while j < len(lines):
            nl = lines[j]
            # a list belonging to a different section is not this sentence's count —
            # stop at the next heading (any level) or horizontal rule, whichever comes first.
            if re.match(r"^#{1,6}\s", nl) or re.match(r"^ {0,3}(-{3,}|\*{3,}|_{3,})\s*$", nl):
                break
            if re.match(r"^\s*([-*]|\d+\.) ", nl):
                got += 1
            elif nl.strip() and not nl.startswith("  ") and got:
                break
            j += 1
        if got and got != want:
            warn(f"{f}:{i} says {m.group(1)} {m.group(2)} but {got} follow")

    # e · the same long sentence twice in one file is a copy-paste that will drift apart.
    seen = {}
    for s in re.split(r"(?<=[.!?])\s+", body):
        n = " ".join(s.split())
        if len(n) > 110:
            if n in seen:
                warn(f"{f} repeats a sentence verbatim: “{n[:60]}…”")
            seen[n] = 1

# f · mermaid blocks must at least be structurally closed.
for f in DOCS:
    for n, blk in enumerate(re.findall(r"```mermaid\n(.*?)```", open(f, encoding="utf-8").read(), re.S), 1):
        for open_c, close_c in "[]", "{}", "()":
            if blk.count(open_c) != blk.count(close_c):
                fail(f"{f}: mermaid diagram {n} has unbalanced {open_c}{close_c}")
        if blk.count("subgraph") != len(re.findall(r"^\s*end\s*$", blk, re.M)):
            fail(f"{f}: mermaid diagram {n} has a subgraph without its end")

# g · every artifact the layout promises a template for must have one. Read from
# project-layout.md's own table rather than a bootstrap file, so the check moves with the doc.
try:
    layout = open("project-layout.md", encoding="utf-8").read()
    for name in sorted(set(re.findall(r"`templates/([A-Za-z-]+)\.md`", layout))):
        if not os.path.exists(f"templates/{name}.md"):
            fail(f"project-layout.md promises templates/{name}.md — it does not exist")
except OSError:
    pass

# h · every template must be reachable: named by some document, not merely present.
def _read(f):
    try:
        return open(f, encoding="utf-8", errors="ignore").read()
    except OSError:
        return ""

for path in sorted(glob.glob("templates/*")):
    name = os.path.basename(path)
    # Named by some *other* document. A file mentioning itself is not a route to it.
    if not any(name in _read(f) for f in DOCS if os.path.abspath(f) != os.path.abspath(path)):
        warn(f"{path} is never named by any document — a file nobody is sent to")

# i · a glossary headword nothing else uses is a definition nobody can find. The corpus is
#     the test of the name: if the term is never written elsewhere, the entry is misnamed.
if os.path.exists("GLOSSARY.md"):
    gl = _read("GLOSSARY.md")
    rest = "".join(_read(f) for f in DOCS if os.path.basename(f) != "GLOSSARY.md")
    for term in re.findall(r"^\*\*([a-z][a-zA-Z _-]*)\*\*(?: \([^)]*\))? —", gl, re.M):
        # Tolerate number and a leading article: "field notes" vs "a field note" is the same
        # word, and a checker that cries wolf over grammar is a checker people switch off.
        base = re.sub(r"^(the|a|an) ", "", term)
        forms = {base, base.rstrip("s"), base + "s"}
        if base.endswith("y"):
            forms.add(base[:-1] + "ies")          # category → categories
        if not any(f in rest for f in forms):
            warn(f"GLOSSARY.md defines “{term}” — a headword no other document uses")

# j · two entities may not share an id. The corpus calls collisions "structurally, not
#     statistically" prevented — this is the structure, and scripts/new-id.py is the other half.
seen = {}
for path in glob.glob("**/*", recursive=True):
    if not os.path.isfile(path) or ".git" in path:
        continue
    m = re.match(r"([A-Z]-[0-9A-HJKMNP-TV-Z]{6})", os.path.basename(path))
    if not m:
        continue
    seen.setdefault(m.group(1), []).append(path)
for eid, paths in sorted(seen.items()):
    if len(paths) > 1:
        fail(f"id {eid} is used by {len(paths)} entities: {', '.join(sorted(paths))}")

# k · a normative sentence living in two files. AGENTS.md's own reading rule says a rule kept
#     in two places goes stale in one — and the credential register was written out verbatim in
#     permissions.md and security.md for weeks, inside the corpus that names the failure.
#     Only sentences that assert something are compared: a heading or a pointer repeats harmlessly.
def _sentences(text):
    text = strip_code(text)
    text = re.sub(r"^\s*[|#>].*$", "", text, flags=re.M)       # tables, headings, quotes
    text = re.sub(r"[*`_\[\]()]", "", text)
    for raw in re.split(r"(?<=[.!?])\s+|\n\n", text):
        s = " ".join(raw.split()).lower().rstrip(".")
        if len(s.split()) >= 12 and "→" not in s:
            yield s

homes = {}
for f in DOCS:
    # The glossary quotes on purpose. Templates repeat on purpose too: they ship into projects
    # that do not have our companions, so a pointer there resolves to nothing and the sentence
    # has to stand alone. Everything else has one home.
    # facts.md exists to be quoted: its job is to hold the memorable line in a form other
    # writing can lift, so rewording it to satisfy this check would make it worse at the one
    # thing it does. The cost is real and stated in the file — when a rule changes, its line
    # changes with it, and nothing but a reader enforces that.
    if os.path.basename(f) in {"CHANGELOG.md", "GLOSSARY.md", "facts.md"} or f.startswith("templates/"):
        continue
    for s in set(_sentences(_read(f))):
        homes.setdefault(s, set()).add(f)
for s, files in sorted(homes.items()):
    if len(files) > 1:
        warn(f"one sentence, {len(files)} files ({', '.join(sorted(files))}): \u00ab{s[:70]}\u2026\u00bb")

# l · a number written in prose rots silently. "30-odd companions" survived a rise from
#     thirty to forty-one because nothing counts. These are the counts worth stating, so
#     these are the ones checked; anything countable and stated belongs here.
_UNITS = ["", "one", "two", "three", "four", "five", "six", "seven", "eight", "nine"]
_TEENS = {"ten":10,"eleven":11,"twelve":12,"thirteen":13,"fourteen":14,"fifteen":15,
          "sixteen":16,"seventeen":17,"eighteen":18,"nineteen":19}
_TENS = {"twenty":20,"thirty":30,"forty":40,"fifty":50,"sixty":60,"seventy":70,
         "eighty":80,"ninety":90}
# Built rather than listed: a hand-written list silently passes the one number nobody added,
# which is how "fifty companions" slipped through the first time this was tested.
WORDS = dict(_TEENS)
WORDS.update({w: i for i, w in enumerate(_UNITS) if w})
for _t, _tv in _TENS.items():
    WORDS[_t] = _tv
    for _i, _u in enumerate(_UNITS):
        if _u:
            WORDS[f"{_t}-{_u}"] = _tv + _i

def _count(path, pattern):
    try:
        return len(re.findall(pattern, _read(path), re.M))
    except Exception:
        return None

# Anchored on the phrase, never the bare noun: "three shapes" in §26 means three forms of a
# choice, not three patterns, and a checker that cannot tell those apart gets switched off.
# Repo furniture is not the skill. Since the corpus moved to the repository root, these sit in
# the same directory as the companions — so the exclusion list is the only thing telling them
# apart, and it is declared once rather than copied into each claim.
# LATER.md is this project running its own machinery on itself: the deferred list every project
# it stands up gets. It is furniture, not corpus — no run loads it, and counting it would make
# the companion figures drift every time something is deferred.
REPO_FURNITURE = {"README.md", "CHANGELOG.md", "AGENTS.md", "TRADEMARKS.md",
                  "INSTALL.md", "GEMINI.md", "LATER.md"}

_pat = _count("PATTERNS.md", r"^\*\*\d+ · ")
CLAIMS = [
    (r"\b(%s|\d+)\s+companions\b", len([f for f in glob.glob("*.md")
        if os.path.basename(f) not in REPO_FURNITURE | {"GLOSSARY.md","PATTERNS.md","SKILL.md"}])),
    (r"\b(%s|\d+)\s+recurring forms\b", _pat),
    (r"\b(%s|\d+)\s+shapes this system reuses\b", _pat),
    # "diagrams", not "mermaid": the guard once watched a phrase nobody writes, so the count in
    # the release notes drifted by two while the check reported clean.
    (r"\b(%s|\d+)\s+(?:mermaid|diagrams)\b", _count("diagrams.md", r"^```mermaid")),
    (r"\b(%s|\d+)\s+evaluation scenarios\b",
        (_count("evals/README.md", r"^## \d+ · ") or 0)
        + (_count("evals/new-scenarios.md", r"^## N\d+ · ") or 0)),
    # Data rows only: separators start "|-", headers start with their own column name. This one
    # was stated in prose and counted by nobody, and it had drifted by six.
    (r"\b(%s|\d+)\s+situations\b",
        _count("use-cases.md", r"^\| (?!Situation\b|When\b|What\b)")),
    # The corpus a reader actually gets: the core, the companions, and the two shared-vocabulary
    # files. Repo furniture (README, CHANGELOG, AGENTS, TRADEMARKS) is not the skill. This one sat
    # in the README unguarded and drifted by four.
    # The palette count is stated in the README and the changelog; the commands directory
    # is the truth, and a verb added without the sentence moving is exactly the drift class.
    (r"\b(%s|\d+)[-\s]verbs?\b",
        # Each command is its own skills/<verb>/SKILL.md; the advisor folder is the corpus,
        # not a verb, so it never counts toward the palette.
        len([d for d in glob.glob("skills/*/SKILL.md")
             if os.path.basename(os.path.dirname(d)) != "advisor"])),
    (r"\b(%s|\d+)\s+markdown files\b",
        len([f for f in glob.glob("*.md")
             if os.path.basename(f) not in REPO_FURNITURE])),
]
_num = "|".join(sorted(WORDS, key=len, reverse=True))
# A count inside a code span is being shown, not claimed — `"fifty companions"` quoted as the
# example of a defect this very check exists to catch must not itself trip it. Same reasoning as
# the link checker, which strips spans before deciding what is a link.
_span = re.compile(r"`[^`]*`")
for f in DOCS:
    for lineno, ln in enumerate(_read(f).split("\n"), 1):
        ln = _span.sub("", ln)
        for tmpl, real in CLAIMS:
            if real is None:
                continue
            for m in re.finditer(tmpl % _num, ln, re.I):
                said = WORDS.get(m.group(1).lower())
                if said is None:
                    try: said = int(m.group(1))
                    except ValueError: continue
                if said != real:
                    fail(f"{f}:{lineno} says “{m.group(0)}” — there are {real}")

# A fixture nobody runs is a tree built for no reason, and a scenario naming a fixture that does
# not exist fails at dispatch rather than at review. Both directions, because only one of them is
# the direction anyone remembers to check.
_fx_src = _read("evals/fixtures.sh")
_built = set(re.findall(r"^build_([a-z]+)\(\)", _fx_src, re.M))
_claimed = {}
for _f in ("evals/README.md", "evals/new-scenarios.md"):
    for _m in re.finditer(r"\*\*Fixture:\*\*\s*`([a-z]+)`", _read(_f)):
        _claimed.setdefault(_m.group(1), []).append(_f)
for _name in sorted(_built - set(_claimed)):
    fail(f"evals/fixtures.sh builds “{_name}” and no scenario names it")
for _name in sorted(set(_claimed) - _built):
    fail(f"a scenario names fixture “{_name}” — fixtures.sh does not build it")

print("\n".join(out))
