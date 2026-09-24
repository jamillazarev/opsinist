#!/usr/bin/env python3
"""The audit gate: in a repository being taken over, the debt list comes before the first touch.

Mechanises the one sentence of `entering.md` a run cannot be trusted to perform by choice
(measured: N8, 0/2 then 0/5 — a run edited source, deleted files and committed before any list):
**nothing is fixed before the owner has seen the list.** The gate verifies the order of evidence,
not its honesty — a token list written to get past it is visible to the judge, not to this script.

Denies only when ALL of these hold:
  1. this session actually engaged the opsinist skill (read from the transcript);
  2. the target sits in a git repository;
  3. that repository is not operated by us — no root guide naming Opsinist;
  4. the tree does not read as somebody else's project — see below, because **a guest owes no
     debt list at all** and a gate demanding one would contradict the flow it enforces;
  5. no debt list exists yet — neither LATER.md nor docs/DEBTS.md at the repo root;
  6. the call would mutate what is already there: a Write/Edit to a *tracked* file, or a
     mutating Bash command (rm, mv, git add/commit/…, sed -i, tee).

Creating new files — the list itself, a guide, docs/ — is never blocked; reading is never
blocked; every internal error fails open. Known hole, accepted and named: Bash redirection
(`>`) is not caught by THIS gate — it teaches the order, and the judge scores the honesty.

**The outward gate's holes are its own, and this paragraph used to describe them wrongly.** It
catches a redirect, a wrapper word, a line continuation and a shell-runner's quoted argument since
2026-09-18; what still passes is a command built by substitution, and a quoted verb the shell
assembles from parts — named rather than chased, since the judge reads the act either way. **A
comment that overstates what the code does is the defect, not the rounding**: this one claimed a
hole the section below had already closed, and a contradiction lens read them against each other.
"""
import glob
import json
import os
import re
import shlex
import subprocess
import sys


# The sentence the Stop refusal opens with. Also how the hook counts its own past refusals in a
# transcript, so it is a constant rather than a phrase two places have to keep saying the same.
STOP_MARKER = "you presented deferrable findings and there is no LATER.md"
# The uncommitted-machinery refusal, kept a constant for the same reason: the hook counts
# its own past refusals in the transcript, and a phrase two places retype drifts.
UNCOMMITTED_MARKER = "machinery edited in this session is still uncommitted"
SPEC_MARKER = "this project was stood up without answering how work gets described"

PLUGIN_ROOT = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))


def skill_version():
    """The version this copy of the skill is on, from the core's own frontmatter."""
    try:
        txt = open(os.path.join(PLUGIN_ROOT, "skills", "advisor", "SKILL.md"),
                   encoding="utf-8", errors="replace").read(2000)
        m = re.search(r"^version:\s*(\S+)", txt, flags=re.M)
        return m.group(1) if m else None
    except Exception:
        return None


def migration_log_names(root, version):
    """Does config.md's migration log record any step landing on this version?

    Deliberately loose about the line's shape and strict about the two things that matter: the
    version appears, and it appears with one of the five outcome words. A log written by a
    future release must stay readable to this one, so nothing here parses a fixed grammar.
    """
    p = os.path.join(root, "_ops", "config.md")
    if not os.path.isfile(p):
        p = os.path.join(root, "config.md")
    try:
        if not os.path.isfile(p):
            return None  # no config.md at all — not the same as "no line"
        txt = open(p, encoding="utf-8", errors="replace").read()
        if "## Migrations" not in txt:
            return False
        section = txt.split("## Migrations", 1)[1].split("\n## ", 1)[0]
        outcomes = ("applied", "nothing-required", "declined", "deferred", "failed")
        # Entries, not physical lines. Measured next door 2026-08-02: a correct entry wrapped
        # over four lines — version first, `Outcome: applied.` last — read as absent, so the
        # check would have nagged forever about a migration that had happened. **A record's
        # grammar is a paragraph**, and a per-line reader is reading a different file.
        entries, cur = [], []
        for line in section.split("\n"):
            if line.lstrip().startswith(("- ", "* ")):
                if cur:
                    entries.append(" ".join(cur))
                cur = [line.strip()]
            elif cur and line.strip():
                cur.append(line.strip())
            elif cur:
                entries.append(" ".join(cur))
                cur = []
        if cur:
            entries.append(" ".join(cur))
        for e in entries:
            if version and version in e and any(o in e for o in outcomes):
                return True
        return False
    except Exception:
        return None


def guide_version(root):
    """The version the project's guide claims to operate it, if it states one.

    Measured in the sibling project 2026-08-01, three runs of the same migration scenario: the
    log line was written and **the guide's version line was left naming the old version, 0 of 3**
    — and writing the log is precisely what makes this check go quiet. A project then asserts one
    version in its log and another in the file every session reads, with nothing left to notice.

    Only a line that says *operated* counts. A version mentioned in prose is not a claim about
    what runs this project, and a hook that cries wolf is a hook people switch off.
    """
    for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        p = os.path.join(root, guide)
        try:
            if not os.path.isfile(p):
                continue
            for line in open(p, encoding="utf-8", errors="replace"):
                if "operated by" in line.lower():
                    m = re.search(r"(\d+\.\d+\.\d+)", line)
                    if m:
                        return guide, m.group(1), line
                    return guide, None, line
        except Exception:
            return None
    return None


def operated_by_us(root):
    """The strict claim: an operator line naming Opsinist. A bare config.md stopped being
    one when `_ops/` became a shared door with the sibling methodology."""
    for g in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        try:
            gp = os.path.join(root, g)
            if os.path.isfile(gp) and re.search(
                    r"operated by[^\n]*opsinist",
                    open(gp, encoding="utf-8", errors="replace").read(), re.I):
                return True
        except Exception:
            return False
    return False


def out(*_a):
    sys.exit(0)  # fail open: a broken gate must not brick every session


def repo_root(path):
    try:
        r = subprocess.run(
            ["git", "-C", path, "rev-parse", "--show-toplevel"],
            capture_output=True, text=True, timeout=5,
        )
        return r.stdout.strip() if r.returncode == 0 else None
    except Exception:
        return None


def _norepo_should_speak(cwd):
    """Say the no-repo fact at most once per directory, and never in $HOME itself.

    Home is excluded because opening a session there is the ordinary way to do something that
    is not a project at all, and a line about repositories would be the first thing a person
    learns to ignore. The stamp lives in the harness config dir rather than in the directory
    itself: writing a marker into somebody's folder to avoid annoying them is its own trespass,
    and the directory may not even be writable. CLAUDE_CONFIG_DIR is honoured so a clean-room
    home stamps its own file (evals/RUNS.md).
    """
    try:
        real = os.path.realpath(cwd or ".")
        if real == os.path.realpath(os.path.expanduser("~")):
            return False
        cfg = os.environ.get("CLAUDE_CONFIG_DIR") or os.path.expanduser("~/.claude")
        stamp = os.path.join(cfg, ".opsinist-norepo-seen")
        seen = set()
        if os.path.exists(stamp):
            with open(stamp, encoding="utf-8") as fh:
                seen = {l.strip() for l in fh if l.strip()}
        if real in seen:
            return False
        os.makedirs(cfg, exist_ok=True)
        with open(stamp, "a", encoding="utf-8") as fh:
            fh.write(real + "\n")
        return True
    except Exception:
        return False  # fail quiet: an unwritable stamp must not turn into a line every session


def _wrote_config(body):
    """Did this session WRITE config.md — not merely read it?

    Reads the transcript's tool_use entries rather than searching for the filename, because a
    run that opens an existing config.md mentions it exactly as often as one that creates it.
    """
    for line in body.split("\n"):
        if '"tool_use"' not in line or "config.md" not in line:
            continue
        try:
            e = json.loads(line)
        except Exception:
            continue
        msg = e.get("message") or {}
        for b in msg.get("content", []) if isinstance(msg.get("content"), list) else []:
            if (b.get("type") == "tool_use" and b.get("name") in ("Write", "Edit")
                    and str((b.get("input") or {}).get("file_path", "")).endswith("config.md")):
                return True
    return False


def last_assistant_text(transcript):
    """The closing message, which is where a debt list is presented."""
    text = ""
    try:
        with open(transcript, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line or line[0] != "{":
                    continue
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                msg = e.get("message") or {}
                if e.get("type") == "assistant" and isinstance(msg.get("content"), list):
                    chunks = [b.get("text", "") for b in msg["content"] if b.get("type") == "text"]
                    if any(c.strip() for c in chunks):
                        text = "\n".join(chunks)
    except Exception:
        return ""
    return text


_SPECIAL = re.compile(r"[\n\\#$()'\"<`{}]")
_QUOTED = {"'": re.compile(r"'"), '"': re.compile(r'[\\"$`]'), "$'": re.compile(r"[\\']")}
_OPENER = re.compile(r"<<(-?)[ \t]*\\?(['\"]?)(\w+)\2")


def shell_only(cmd):
    """The command as a shell would run it: continuations folded, heredoc BODIES blanked.

    A heredoc body is data fed to another program, so a document carrying the verb at the start of
    a line is not a publish. **Every regex over the raw string was out-guessed within a round**: a
    missing terminator blanked to the end of the string (2026-09-18); a body blanked from right
    after the delimiter hid `cat > f <<EOF && git push`, because bash starts the body on the NEXT
    line (2026-09-23); a `<<X` inside `$'…'` or `$((…))` was taken for an opener and hid the push
    on the line after it (2026-09-23); and a double quote inside `$(…)` within a double-quoted
    string closed the outer string early, so a `<<X` still inside it was read as code (2026-09-24).
    Each of the last three was confirmed in real bash against a stub `git`.

    So this is one pass, left to right, **keeping the state bash keeps**: outside quotes or inside
    `'…'`, `"…"` or `$'…'`; inside arithmetic `((…))`; in a `#` comment; and, inside a double-quoted
    string, inside a `$(…)`, a backtick pair or a `${…}`, each with its own quoting, on a stack. A
    `<<` opens a heredoc only where bash would read one — never in a quote, a comment, arithmetic or
    a `${…}`, and `<<<` is a here-STRING, not an opener. Bodies are read the way bash reads them:
    after the newline that ends the command, every heredoc of that line in order, each to a line
    that IS its word (after leading tabs, for `<<-`). **No terminator, or an unclosed quote, and
    nothing more is blanked**: bash would run none of the rest, so leaving it visible costs a false
    refusal at worst. **A comment is blanked too**, since bash never reads it: a trailing
    `# --dry-run tested this yesterday` was excusing the real act it trailed (2026-09-24). One pass
    keeps it linear — a scan per opener took 13 s on a 358 KB command of unterminated openers, and
    this takes 0.05–0.08 s as a whole hook call (both measured 2026-09-23).

    **What it does not track can hide a publish, and is named for that reason**: a `case` pattern's
    unmatched `)` inside a command substitution within a double-quoted string closes the
    substitution early, and so would any other construct whose bracket bash balances by grammar
    rather than by count. Nothing an agent writes by accident has been found in that shape; the
    ones that were found are closed above.
    """
    c = re.sub(r"\\\n", " ", cmd)                    # a continuation is one command
    out, n, i = list(c), len(c), 0
    q, arith, depth, ctx, pending, stack = None, 0, 0, "code", [], []
    while i < n:
        if q is not None:                            # inside a quote: its end, an escape, or a
            s = _QUOTED[q].search(c, i)              # substitution opening inside "…"
            if not s:
                break                                # never closed: bash runs none of it
            i, ch = s.start(), s.group()
            if ch == "\\":
                i += 2
                continue
            if ch == "`":
                opened = ("code", "`", 1)
            elif ch == "$" and c.startswith("$(", i) and not c.startswith("$((", i):
                opened = ("code", ")", 2)
            elif ch == "$" and c.startswith("${", i):
                opened = ("param", "}", 2)
            elif ch == "$":
                i += 1
                continue
            else:
                q, i = None, i + 1
                continue
            stack.append((q, arith, depth, ctx, opened[1]))
            q, arith, depth, ctx, i = None, 0, 0, opened[0], i + opened[2]
            continue
        s = _SPECIAL.search(c, i)
        if not s:
            break
        i, ch = s.start(), s.group()
        if ch == ")" and arith and c.startswith("))", i):
            arith, i = arith - 1, i + 2
        elif stack and ch == stack[-1][4] and depth == 0:
            q, arith, depth, ctx, _ = stack.pop()    # back inside the string it opened in
            i += 1
        elif ch == "\n":
            i += 1
            for dash, word in pending:               # each body, in the order its opener came
                j = i
                while True:
                    e = c.find("\n", j)
                    line = c[j:] if e < 0 else c[j:e]
                    if (line.lstrip("\t") if dash else line) == word:
                        break
                    if e < 0:
                        return "".join(out)          # no terminator: the rest stays visible
                    j = e + 1
                for k in range(i, j):
                    if out[k] != "\n":
                        out[k] = " "
                i = n if e < 0 else e + 1
            pending = []
        elif ch == "\\":
            i += 2
        elif ch == "#" and ctx == "code" and (i == 0 or c[i - 1] in " \t\n;&|("):
            e = c.find("\n", i)                      # a comment runs to its newline, and is
            e = n if e < 0 else e                    # blanked: bash never reads a word of it
            for k in range(i, e):
                out[k] = " "
            i = e
        elif ch == "$" and c.startswith("$'", i):
            q, i = "$'", i + 2
        elif ch == "$" and c.startswith("$((", i):
            arith, i = arith + 1, i + 3
        elif ch == "(" and ctx == "code" and c.startswith("((", i):
            arith, i = arith + 1, i + 2
        elif ch == "(" and ctx == "code":
            depth, i = depth + 1, i + 1
        elif ch == ")" and ctx == "code" and depth:
            depth, i = depth - 1, i + 1
        elif ch == "{" and ctx == "param":
            depth, i = depth + 1, i + 1
        elif ch == "}" and ctx == "param" and depth:
            depth, i = depth - 1, i + 1
        elif ch in "'\"":
            q, i = ch, i + 1                         # bash 3.2 reads `'` in "${…}" as a quote too
        elif ch == "<" and c.startswith("<<<", i):
            i += 3                                   # a here-STRING, not a heredoc
        elif ch == "<" and ctx == "code" and not arith:
            m = _OPENER.match(c, i)
            if m:
                pending.append((m.group(1), m.group(3)))
                i = m.end()
            else:
                i += 1
        else:
            i += 1
    return "".join(out)


def command_end(c, i):
    """Where the simple command holding the act at `i` ends — read from index 0 of the whole text
    the hook received, NOT from the previous separator, because a window that starts where a pair
    may already be open cannot tell an opening backtick from a closing one.

    Bash's own state is kept on the way: quotes, a backslash escaping the next character outside
    single quotes, and every `$(…)`, `$((…))`, `<(…)`, `>(…)`, backtick pair or grouping `(…)` on
    a stack with its own quoting — a grouping pair because `$((1 + (2*3)))` closed the arithmetic
    one parenthesis early and refused a real dry run (2026-09-24). The act's *depth* is how many of those are open where it starts; the command holding
    it ends at the first `\n ; & | )` outside quotes at that depth, or where the pair holding the act
    closes. Arithmetic and process substitution were read as bare parentheses until 2026-09-24, so
    `branch$((1+1)) --dry-run` was refused as a publish. A bare character split stopped at a `)` inside a quoted
    release note; a flat quote flag was fooled by `"… $(date "+%Y (UTC)") …"`; and a window started
    at the act read the backtick that closed `` `git push` --dry-run `` as opening another pair —
    three misreadings on 2026-09-24, two loud and one a hole."""
    stack, q, k, depth = [], None, 0, None
    while k < len(c):
        if depth is None and k >= i:
            depth = len(stack)                       # the depth of the command holding the act
        ch = c[k]
        if q == "'":
            q = None if ch == "'" else q
            k += 1
            continue
        if ch == "\\":
            k += 2
            continue
        if c.startswith("$((", k):
            opener = ("))", 3)                       # arithmetic, closed by its own doubled paren
        elif c.startswith("$(", k) or (q is None and c.startswith(("<(", ">("), k)):
            opener = (")", 2)                        # a command or process substitution
        elif ch == "`":
            opener = ("`", 1)
        elif q is None and ch == "(":
            opener = (")", 1)                        # a subshell, or grouping inside arithmetic
        else:
            opener = None
        if q == '"':
            if ch == '"':
                q = None
            elif opener:
                stack.append((q, opener[0]))
                q = None
                k += opener[1]
                continue
            k += 1
            continue
        if stack and c.startswith(stack[-1][1], k):
            if depth is not None and len(stack) == depth:
                return k                             # the pair holding the act closes
            k += len(stack[-1][1])
            q = stack.pop()[0]
            continue
        if ch in "'\"":
            q = ch
        elif opener:
            stack.append((None, opener[0]))
            k += opener[1]
            continue
        elif depth is not None and len(stack) == depth and ch in "\n;&|)":
            return k
        k += 1
    return len(c)


def last_owner_instruction(transcript, limit=240):
    """The owner's most recent message — **context for the person, never consent.**

    A gate cannot read intent and must not try: the party it constrains is the one that would be
    doing the explaining, and the measured failure is that the explanation was confident and wrong
    (5 of 5 runs reported *"done… and pushed"*). What a gate CAN do is put the human's own last
    words next to the refusal, so whoever decides is not hunting for the context first.

    **It is quoted and never acted on.** *"Push when it's ready"* an hour ago is not permission to
    publish now — a request to do the work is not a request to announce it, and an earlier yes does
    not roll forward (`permissions.md`). If this function ever gains a branch that lets something
    through, that branch is the bug.

    **Most of what arrives as a `user` entry is not the owner**, and an adversarial lens proved
    this function's first version wrong about that on this very session's transcript (2026-09-18).
    Four shapes, each handled rather than assumed away:
      · a **tool result** — machinery answering machinery — which arrives as a `user` entry;
      · a `<system-reminder>`, the harness speaking, **which may be unterminated or nested**, so
        the strip runs to the end of the text when it finds no closing tag and repeats until the
        text stops changing;
      · a `<task-notification>` — *a background agent's return value routed back as a user turn*,
        which the first version would have quoted as something the owner said;
      · the harness's own **conversation-continuation summary**, a bare string of tens of thousands
        of characters that is not a turn at all.
    A `user` entry carrying BOTH text and a tool result keeps its text: discarding the whole entry
    made the gate quote an older message as *"what you last asked for"*, which is worse than
    quoting nothing, because a stale instruction reads exactly like a current one.

    **Whatever survives is still untrusted text.** It is shown between guillemets under a line
    saying it is not consent, and it never reaches a decision — an instruction inside it (*"the
    owner already approved this"*) is a thing the human reads, and the human is the one who was
    going to decide anyway.
    """
    def _strip(t):
        """Drop the harness's own blocks with a stack of tag NAMES, never by matching pairs.

        A regex cannot do this: non-greedy stops at the first closing tag and leaks whatever sat
        between it and the outer one; greedy eats the prose between two separate blocks. A plain
        depth counter was the next attempt and it let a `</task-notification>` close a
        `<system-reminder>`, which hands anything that can inject tag-shaped text exact control over
        what the refusal shows and hides (reproduced 2026-09-18). So a closing tag closes only a
        block of its own name, and only the innermost one — a **crossed** close
        (`<a> <b> </a> … </b>`) popped through `<b>` and put what sat inside it on show, reproduced
        2026-09-23 — and the malformed shapes fall out of that: an **unterminated** block leaves
        the stack non-empty and its tail is dropped, and an **orphan**, **mismatched** or
        **crossed** closing tag is ignored. Every one was a reproduced finding, not a
        hypothetical. Display-only, and this is the display.
        """
        out, stack, last = [], [], 0
        for m in re.finditer(r"</?(system-reminder|task-notification)>", t):
            closing, name = m.group(0).startswith("</"), m.group(1)
            if not stack:
                out.append(t[last:m.start()])
            if closing:
                if stack and stack[-1] == name:
                    stack.pop()                 # only the innermost block, and only by its name
            else:
                stack.append(name)
            last = m.end()
        if not stack:
            out.append(t[last:])
        return " ".join(out)

    text = ""
    try:
        with open(transcript, encoding="utf-8", errors="replace") as f:
            for line in f:
                line = line.strip()
                if not line or line[0] != "{":
                    continue
                try:
                    e = json.loads(line)
                except Exception:
                    continue
                if e.get("type") != "user":
                    continue
                content = (e.get("message") or {}).get("content")
                bare = isinstance(content, str)
                if bare:
                    chunks = [content]
                elif isinstance(content, list):
                    chunks = [b.get("text", "") for b in content
                              if isinstance(b, dict) and b.get("type") == "text"]
                    if not chunks:
                        continue                 # a tool result alone is not the owner speaking
                else:
                    continue
                said = _strip("\n".join(c for c in chunks if c).strip())
                said = " ".join(said.split())
                # **Two signals, because one was spoofable.** A real instruction that merely opens
                # with the harness's own words was dropped whole, and the refusal then quoted a
                # SUPERSEDED message as *what you last asked for* — worse than quoting nothing
                # (reproduced 2026-09-18: *"do NOT push, hold everything"* shown as current). The
                # harness's summaries arrive as a **bare string** and are long; a person's turn
                # arrives as text blocks. Both must hold to skip it, and the failure mode is named:
                # a bare-string turn of over two thousand characters that opens with those words
                # is still skipped, and nothing here can tell it from the machine's.
                if (bare and len(said) > 2000
                        and said.startswith(("This session is being continued",
                                             "Caveat: The messages below", "[harness:"))):
                    continue
                if said:
                    text = said
    except Exception:
        return ""
    return text[:limit] + ("…" if len(text) > limit else "")


def main():
    try:
        payload = json.load(sys.stdin)
    except Exception:
        out()

    tool = payload.get("tool_name", "")
    tin = payload.get("tool_input", {}) or {}
    cwd = payload.get("cwd", "") or "."
    event = payload.get("hook_event_name", "PreToolUse")

    # SessionStart · the migration state is delivered as a fact rather than left as a rule to
    #   remember. Measured 2026-08-01: written as prose in the always-loaded core, the check ran
    #   in 0 of 5 runs — and absence of a log was read as "fresh project, nothing to do", which
    #   is the exact ambiguity the log exists to end. A SessionStart hook's stdout reaches the
    #   model's context (probed the same day), so the fact arrives before the first message
    #   instead of depending on the model choosing to look.
    #   Silent when there is nothing to say — a hook that speaks every session is noise.
    if event == "SessionStart":
        root = repo_root(cwd)
        if not root:
            # The silence used to end here, and it ended at the one moment it cost the most:
            # standing in a directory that is not a repository, where every entity this system
            # uses — roles, tasks, runs, the record — is a file inside one. The comment above
            # already carries the shape of this failure measured on its neighbour: absence read
            # as "nothing to do". A person who has never run `git init` cannot act on a silence,
            # and the arriving ladder that would have told them is a document they have no way
            # to know exists yet.
            # Two guards against becoming noise, because a hook that fires on someone's own
            # files is one they switch off: never in the home directory itself, and never twice
            # for the same directory.
            if _norepo_should_speak(cwd):
                v = skill_version() or "?"
                sys.stdout.write(
                    f"Opsinist {v}: this directory is not a git repository, and everything here "
                    f"is a file in one — roles, tasks, runs, the whole record. Nothing can be "
                    f"created until there is a repo. **Two routes, and it is the owner's "
                    f"pick**: `git init` here — one local command, nothing leaves the "
                    f"machine, undone by deleting the `.git` directory it makes — or **say where that repository is and I will "
                    f"open it there**, if this work already lives in one. **If this folder has files in it, "
                    f"`git init` moves and changes nothing**; they stay exactly where they are "
                    f"until someone commits them.\n")
                sys.exit(0)
            out()
        # A guest tree gets nothing: no log, no check, no line. Same test as the audit gate.
        for f in ("CODEOWNERS", ".github/CODEOWNERS", "CONTRIBUTING.md", "CONTRIBUTING",
                  ".github/pull_request_template.md"):
            if os.path.exists(os.path.join(root, f)):
                out()
        # "Ours to migrate" means an operator line or a config.md — never a mere mention of
        # the name. The wide test ("opsinist" anywhere in a guide) fired on the skill's own
        # development repository and pushed eval players into fabricated migration audits on
        # fixtures that nothing operates: a repo with no operator line and no config.md is
        # ENTERED, not migrated (SKILL.md, the fourth stand-down).
        g = guide_version(root)
        # Another system's operator line means another system's workspace: `_ops/` is a
        # shared door (the sibling names nine of our twelve documents identically), so a
        # bare config.md is not a claim about WHO operates — only the line is. Their tree
        # gets silence, not our migration nag; the takeover flow's fourth stand-down owns
        # the interactive half.
        if g and not re.search(r"opsinist", g[2], re.I):
            out()
        ours = bool(g)
        if not ours:
            out()  # no operator line naming us — not ours to nag, whatever files exist
        # **Is the guard wired?** — the one fact a session cannot get any other way, delivered
        # here for the same reason the migration state is: measured 2026-08-14 (N89, 0 of 3) that
        # every graded day-one run stood a project up ad hoc, and measured again 2026-09-16 on a
        # live project where `_ops/scripts/` held the guard, one version behind, and `.git/hooks/`
        # held only git's samples — so every gate this methodology describes was a description
        # there, and nothing said so because a file's presence reads as protection. Twice is the
        # threshold this corpus uses everywhere, and `LATER.md` had named this form and its
        # trigger. **One implementation**: the same `scripts/guard-status.py` a person runs, so a
        # session and a health sweep cannot disagree about what wired means. It states what it
        # found and never gives an order; a hook that cannot run it says nothing at all.
        # **Only where there is machinery to wire.** An operated guide over a tree with no `_ops/`
        # is a project mid-setup or mid-takeover, and the arriving flow's debt list owns that
        # moment; saying it here too would make the first session of every new project carry two
        # notices, which is how a channel stops being read.
        if os.path.isdir(os.path.join(root, "_ops")):
            try:
                gs = subprocess.run(
                    [sys.executable, os.path.join(os.path.dirname(os.path.dirname(
                        os.path.abspath(__file__))), "scripts", "guard-status.py"), root],
                    capture_output=True, text=True, timeout=20)
                # **Only where a guard exists and does nothing.** No guard at all is the
                # arriving flow's debt-list item, and it is visible: an empty `_ops/scripts/` is
                # something a person can see. The measured failure is the opposite — the file is
                # there, 128 KB of it, and its presence reads as protection while `.git/hooks/`
                # holds only git's samples.
                if (gs.returncode == 1 and gs.stdout.strip()
                        and "no guard in this project" not in gs.stdout):
                    body = "\n".join("  " + l.strip() for l in gs.stdout.strip().split("\n")[1:])
                    sys.stdout.write(
                        "Opsinist: this project's guard is not wired and current, so the gates "
                        "below it do not fire — a guard in the repository refuses nothing until a "
                        "hook runs it.\n" + body + "\n")
            except Exception:
                pass
        v = skill_version()
        if not v:
            out()
        named = migration_log_names(root, v)
        # The guide is compared whether or not the log is current: the two disagreeing is the
        # failure a written log actively hides, because a written log is what silences this.
        if g and g[1] and g[1] != v:
            name, claimed = g[0], g[1]
            if named is True:
                sys.stdout.write(
                    f"Opsinist {v}: the migration log records {v}, but `{name}` still says this "
                    f"project is operated by **{claimed}**. **They disagree, and the guide is the "
                    f"one every session reads** — the log being current is why nothing else will "
                    f"raise this. Which of the two is right is not something this hook can "
                    f"tell, and the version line is the half a session reads first.\n")
                sys.exit(0)
        if named is True:
            out()  # checked already, and recorded — say nothing
        if named is None:
            sys.stdout.write(
                f"Opsinist {v}: this project has no `config.md`, so nothing records whether it "
                f"was ever migrated — and swapping the plugin's files is not migrating a "
                f"project. The procedure this project publishes for that is the migration audit "
                f"in `upgrading.md`, whose result opens the migration log.\n")
        else:
            sys.stdout.write(
                f"Opsinist {v}: this project's migration log does not name version {v}, so it "
                f"is not recorded as migrated to the version now running it. This project's "
                f"own procedure for that is the migration audit in `upgrading.md` — one list "
                f"split by whether it needs the owner — after which the guide's version line and "
                f"a line under `## Migrations` in `config.md` are what record it. An audit that "
                f"ends with a question for the owner has `deferred` as its outcome word.\n")
        sys.exit(0)

    # **None of the three notices above may give an order, and this is not a style rule.**
    # A run weighs what arrives through a tool; it does not obey it. Until 2026-08-28 all three
    # said "Before acting on it, say so, run the migration audit" and one said "**bump the version
    # line**" — orders, on the same non-blocking channel as the spiral note that was repaired
    # eight days earlier and for the same reason. The repair had removed the instance and left the
    # class; an adversarial lens found the other three still standing. They state what was found
    # and what procedure this project publishes, which is the whole of what a hook knows.
    #
    # PostToolUse · the investigation spiral named at the moment it is happening. Measured
    #   (the N=5 suite): every remaining void was a player burning its turns on ls/grep
    #   archaeology and never dispatching — N74-4 died at turn 21 inside `ls -la`. The exit
    #   is a reflex — *stop investigating, start the wave* — and a reflex is delivered at
    #   the moment, once, never as a nag (§21). Read-only calls increment a counter; any
    #   write, dispatch or transition resets it; at the threshold one message arrives and
    #   the counter retires for the session.
    if event == "PostToolUse":
        import hashlib
        sid = payload.get("session_id", "") or payload.get("transcript_path", "") or "s"
        base = os.path.join("/tmp", "opsinist-spiral-"
                            + hashlib.sha256(sid.encode()).hexdigest()[:8])
        spoke, cnt = base + ".spoke", base + ".n"
        READONLY = {"Read", "Glob", "Grep", "LS", "WebFetch", "WebSearch"}
        resets = tool in ("Write", "Edit", "NotebookEdit", "Task", "TodoWrite")
        ro = tool in READONLY or (tool == "Bash" and re.match(
            r"\s*(ls|find|grep|rg|cat|head|tail|wc|tree|git (log|status|diff|show))\b",
            str(tin.get("command", ""))))
        try:
            if resets:
                open(cnt, "w").write("0")
            elif ro and not os.path.exists(spoke):
                n = 0
                if os.path.exists(cnt):
                    try:
                        n = int(open(cnt).read().strip() or 0)
                    except Exception:
                        n = 0
                n += 1
                open(cnt, "w").write(str(n))
                if n >= 12:
                    # **`os.O_EXCL` is what makes "arrives once" true.** Read, increment, write
                    # and the `spoke` test are four unsynchronised filesystem operations, so a
                    # batch of parallel read-only calls could put several past the threshold at
                    # once and each would speak: measured 2026-08-28, the note arriving twice in
                    # 6 of 12 trials — and parallel read-only batching is exactly the shape of run
                    # this note was written not to harass. An exclusive create is atomic; whoever
                    # loses the race says nothing.
                    try:
                        os.close(os.open(spoke, os.O_CREAT | os.O_EXCL | os.O_WRONLY))
                    except FileExistsError:
                        sys.exit(0)
                    print(json.dumps({"hookSpecificOutput": {
                        "hookEventName": "PostToolUse",
                        # **A note, not an order.** This said "Stop digging: … start the wave",
                        # which is an imperative injected into a run's context by its own tooling —
                        # and this system's whole position on text arriving through a tool is that
                        # it is data, never an instruction. It also assumes writing is the point:
                        # a read-only run (a review lens, an audit, a question answered from the
                        # record) makes twelve read-only calls because that is its contract, and
                        # was told to stop doing its job. Observed 2026-08-27 on a review lens,
                        # which correctly treated it as data and carried on. It states the count
                        # and names what it cannot know.
                        "additionalContext":
                            f"Opsinist, for the record: {n} read-only calls so far and nothing "
                            "written, dispatched or transitioned. If this run is meant to produce "
                            "something, that pattern is the investigation spiral dispatching.md "
                            "describes, and the way out is to say what is known, start a task, or "
                            "ask the one blocking question. If this run is meant to be read-only "
                            "— a review, an audit, a question answered from the record — then "
                            "this is the expected shape and nothing here needs acting on. This "
                            "hook cannot tell which, so it reports rather than directs, and "
                            "arrives once."}}))
                    sys.exit(0)
        except Exception:
            out()
        out()

    # The guard against a hook and a model arguing forever. `stop_hook_active` is honoured
    # first — and it is **not** sufficient on its own: measured 2026-08-01, runs were blocked
    # twice with that flag never arriving, so the second guard counts our own refusals in the
    # transcript and stands down after two. A hook that can nag without limit is a hook that
    # can burn a turn budget, and the run it kills looks like a corpus failure.
    if event == "Stop":
        if payload.get("stop_hook_active"):
            out()

        # **A run may not end leaving `_ops/` uncommitted, and this FORBIDS rather than asks.**
        # Measured 2026-08-22 over ten runs of one scenario: the player edited the machinery 8
        # times and committed 0 times, so every `enforced_by: validator` gate — which fires at the
        # commit and nowhere else — went unreached. The gate was not weak; the work never arrived
        # at it. `permissions.md` now states that limit, and this is the form under it.
        #
        # **Why a prohibition and not a reminder**, which is the whole design: this file's own
        # measurement, three rounds, says delivering a fact at SessionStart bought 0/5 and
        # demanding an act at Stop bought 1/5, while the one rule that only ever FORBIDS held 5/5
        # in all three. So this does not say "remember to commit" — it refuses the ending, and the
        # only ways past it are to commit the work or to say plainly that it is deliberately left.
        # **ARMED, like every other refusal in this file.** The first version sat above the
        # arming check at the foot of this function, so with the plugin merely installed it
        # refused the ending of ANY session in ANY git repository holding an uncommitted
        # manifest — including sessions that never opened this skill, in projects it does not
        # operate. Four lenses found it independently, 2026-08-23, and the file's own docstring
        # had said the opposite since the day it was written: *denies only when this session
        # actually engaged the skill, and the repository is operated by us*.
        #
        # Two conditions, both cheap: the transcript must show a skill door opened, and the
        # repository must carry a guide naming us. A gate that fires outside the project it
        # was built for is not strict — it is broken, and it is the kind of broken that gets a
        # plugin uninstalled rather than reported.
        _ur = repo_root(cwd)
        _tp0 = payload.get("transcript_path", "")
        _armed = False
        if _ur and _tp0 and os.path.isfile(_tp0) and operated_by_us(_ur):
            try:
                _pr = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
                try:
                    _doors = sorted(os.listdir(os.path.join(_pr, "skills")))
                except Exception:
                    _doors = ["advisor", "join", "init"]
                _pat = re.compile(r'"skill"\s*:\s*"(?:[\w-]+:)?(?:%s)"'
                                  % "|".join(map(re.escape, _doors)))
                with open(_tp0, encoding="utf-8", errors="replace") as _f:
                    for _line in _f:
                        if '"skill"' in _line and _pat.search(_line):
                            _armed = True
                            break
            except Exception:
                _armed = False
        if _armed and os.environ.get("OPSINIST_UNCOMMITTED_GATE", "") != "off":
            try:
                # **The ground the OTHER gates guard, which is this gate's whole purpose.**
                # Scoped to `_ops/` alone for its first day, and measured 2026-08-22: a scenario
                # whose work sat in `package.json` and `src/` ended with nothing said, so the
                # dependency gate — which fires at the commit — never spoke, for exactly the
                # reason this gate exists to remove. A manifest is not the craft's business; it
                # is a standing commitment another gate reads. The product's own source stays
                # out: a run may rightly leave that for review.
                # Rooted AND at depth: a bare name is a pathspec anchored at the top level, so a
                # monorepo's `frontend/package.json` was invisible — the very shape this gate was
                # widened for. Measured 2026-08-23.
                _m = ["package.json", "requirements.txt", "pyproject.toml",
                      "go.mod", "Cargo.toml", "Gemfile", "composer.json"]
                _watch = ["_ops"] + _m + [":(glob)**/" + x for x in _m]
                _d = subprocess.run(
                    ["git", "-C", _ur, "status", "--porcelain", "--"] + _watch,
                    capture_output=True, text=True, timeout=5)
                _dirty = [l[3:] for l in _d.stdout.splitlines() if l.strip()] if _d.returncode == 0 else []
            except Exception:
                _dirty = []          # fail open, like every other check here
            # Scoped to `_ops/` on purpose: the product's own files are the craft's business and
            # a run may well leave them for review. The machinery is what every gate keys on.
            # **This session must have TOUCHED it.** The gate read `git status` and never the
            # transcript, so a session that wrote nothing — a pure question, `what's next?` — was
            # refused an ending over work that predates it, and told to commit changes it did not
            # make. Measured 2026-08-23. A gate that blames a run for the tree it inherited is
            # worse than silent: it teaches the reader that the message is noise.
            if _dirty:
                _tp = payload.get("transcript_path", "")
                try:
                    with open(_tp, encoding="utf-8", errors="replace") as _f:
                        _wrote = any(('"name":"Write"' in _l or '"name":"Edit"' in _l
                                      or '"name": "Write"' in _l or '"name": "Edit"' in _l)
                                     for _l in _f)
                except Exception:
                    _wrote = True          # unreadable transcript: fall back to speaking
                if not _wrote:
                    _dirty = []
            if _dirty:
                _tp = payload.get("transcript_path", "")
                _seen = 0
                try:
                    if _tp and os.path.isfile(_tp):
                        with open(_tp, encoding="utf-8", errors="replace") as _f:
                            _seen = _f.read().count(UNCOMMITTED_MARKER)
                except Exception:
                    _seen = 0
                # Said once. A gate that repeats itself is one the next run learns to sit through,
                # and the second refusal would block an ending the owner may have chosen.
                if _seen < 1:
                    _names = ", ".join(_dirty[:4]) + ("…" if len(_dirty) > 4 else "")
                    sys.stderr.write(
                        f"Opsinist reach gate: {UNCOMMITTED_MARKER} — {_names}. Every gate this "
                        f"project holds is `enforced_by: validator`, which means enforced AT THE "
                        f"COMMIT: work that stops short of one is governed by prose alone, and "
                        f"prose measured 1 in 10 here on 2026-08-22. It is also the recovery "
                        f"mechanism — a run that commits nothing leaves nothing to resume from "
                        f"(recovering.md). Commit it, or say in one line that it is deliberately "
                        f"left and why.\n")
                    sys.exit(2)

        t = payload.get("transcript_path", "")
        try:
            if t and os.path.isfile(t):
                with open(t, encoding="utf-8", errors="replace") as f:
                    body = f.read()
                if body.count(STOP_MARKER) >= 2 or body.count(SPEC_MARKER) >= 2:
                    out()
                # A project stood up in THIS session with no `spec_mode` answered is the
                # interview skipping the one question that decides what every task looks like.
                # Measured 2026-08-01: written as an interview row, it was asked in 0 of 5 runs.
                # Scoped to config.md being written here, so an existing project is not nagged
                # every session and a one-off job — which stands nothing up — never trips it.
                # Precisely: a Write/Edit whose target is config.md, in THIS session. Matching
                # the string anywhere in the transcript was the first version and it was wrong
                # in both directions — measured 2026-08-01: it fired on runs that merely *read*
                # an existing config.md, hijacking sessions whose owner had asked something
                # else (N65, N66 and N67 all got worse), and it never fired on the case it was
                # built for, because that run creates no config.md at all.
                if _wrote_config(body) and SPEC_MARKER not in body:
                    root = repo_root(payload.get("cwd", "") or ".")
                    cfg = os.path.join(root, "config.md") if root else None
                    if cfg and os.path.isfile(cfg):
                        txt = open(cfg, encoding="utf-8", errors="replace").read()
                        if "spec_mode" not in txt:
                            sys.stderr.write(
                                "Opsinist audit gate (starting.md · writing-work.md): "
                                + SPEC_MARKER + ". `config.md` carries no `spec_mode`. It "
                                "decides what every task looks like — a result stated in the "
                                "task, a document the task points at and closing updates, or a "
                                "format the project already runs — and a project that answers "
                                "it later rewrites the tasks it has already written. Ask it "
                                "now, in the owner's terms with the recommendation first, and "
                                "record the answer in `config.md`. If the answer is a format "
                                "they already run, name the stocked options rather than asking "
                                "them to invent one.")
                            sys.exit(2)
        except Exception:
            out()

    # 1a · Two operated-tree invariants that do NOT wait for engagement: a worker who never
    #      opened the skill still may not push past the owner or write a rule into the
    #      harness's memory. Measured 2026-08-08: placed after the engagement out, the
    #      canary's push met no gate at all — the player had simply never opened the skill.
    _t0 = tin.get("file_path") or ""
    _r0 = repo_root(os.path.dirname(_t0) if _t0 else cwd) or repo_root(cwd)
    if _r0 and tool == "Bash" and os.environ.get("OPSINIST_OUTWARD_GATE", "") != "off" \
            and operated_by_us(_r0):
        cmd = str(tin.get("command", ""))
        # **A dry run is a read — of its OWN act, and of nothing else on the line.** Both spellings,
        # case-blind. It used to exempt the whole command: `echo testing --dry-run`, then a real
        # `git push` on the next line, went through both gates — and so did a comment that merely
        # mentioned the flag (an adversarial lens, 2026-09-24). So every outward act is found, and each is
        # excused only by a `--dry-run` in its own simple command — which ends where `command_end` says,
        # so `$(git push) --dry-run`, whose push runs inside the substitution before the flag is ever
        # read, is not excused. **And the flag has to mean dry**: `npm publish --dry-run=false` publishes, so only
        # the bare flag or `=true` · `=1` · `=yes` excuses anything (both 2026-09-24). A comment is gone
        # before this reads the line: `shell_only` blanks it.
        if cmd:
            # **A newline, a pipe and a subshell start a command too**, and a shell-runner's quoted
            # argument is a command however it is spelled: `sh -c "git push"`. The first three were
            # missing and the fourth was named-rather-than-chased in this file's own docstring —
            # both closed 2026-09-18, after the sibling's copy of this gate refused a *sentence*
            # containing the verb and the two were compared. **A quote is only a command start
            # after something that runs a shell**: any quote would refuse `grep 'npm publish'`,
            # which is a read, and a read is never outward.
            #
            # **Then an adversarial lens walked in with eleven ways past it, all reproduced.** Each
            # is handled here rather than argued with:
            #   · **a wrapper word before the verb** — `env X=1 git push`, `sudo`, `nohup`, `time`,
            #     `nice -n 10`, `command`, `exec`, and **a bare `eval git push` with no quote at
            #     all**. They are not delimiters and were not runners, so nothing anchored;
            #   · **a line continuation** — `git \`, newline, `push` is ONE command to bash and two
            #     lines to a regex, so the backslash-newline is folded away before matching;
            #   · **a redirect straight after the verb** — `git push>/dev/null` needs no space, and
            #     the lookahead did not count `>` as a terminator;
            #   · **the runner's quote more than forty characters away** — the cap is gone; the
            #     branch reaches to the end of the line instead.
            # **A heredoc body is data being fed to another program, and is blanked first.** Writing
            # a document that contains the verb at the start of a line was refused as a publish —
            # the same *prose is not an act* defect this whole section was repaired for, arriving
            # through the newline anchor that repaired it. A body that is itself a program can still
            # publish, and that stays named rather than chased: the interpreter it is fed to is not
            # something this pattern can read.
            _c = shell_only(cmd)
            # **A wrapper word takes flags, a flag takes its own argument, and there can be any number of
            # them.** Eight shapes carried the verb past the anchor on 2026-09-18 — `env` with no assignment,
            # `env -i`, `env --`, `sudo -u root`, `command -p`, `time -p`, `nice --adjustment=10`,
            # `exec -a name` — and listing the option SHAPES was not enough, because a flag with its own
            # argument leaves a bare word before the verb. The run that replaced it was capped at four tokens,
            # and on 2026-09-23 `env A=1 B=2 C=3 D=4 E=5 F=6 git push` walked past the cap: a bound on the
            # UNSAFE side of an anchor is a hole with a number on it. **Any run of tokens, on the same line.**
            # The cost is named: a wrapper followed later on its line by a quoted mention of the verb is
            # refused, which is the loud side, and the refusal's closing line — *if this is a sentence
            # about the act, say so to the owner* — is there for exactly that.
            _WRAP = r"(?:(?:env|sudo|nohup|time|command|exec|eval|nice)[ \t]+(?:\S+[ \t]+)*)?"
            # **A tool takes global options before its subcommand, and can be named by its path.**
            # `git -C . push`, `git -c k=v push`, `gh -R o/r release create`, `npm --prefix x publish`,
            # `docker --context x push` and `/usr/bin/git push` all went through both gates from the day
            # they were written, because the pattern wanted the subcommand straight after the name — found on
            # 2026-09-24, the absolute path by an adversarial lens and the options by checking what else that
            # shape covered. They are read as the same act now, and refused: any run of option tokens
            # between the two, and any path before the name.
            # **A word is read the way a shell reads one** — quoted parts may hold spaces — **and an argument
            # that merely STARTS with a subcommand word is still an argument.** `npm --prefix publish-tools
            # publish`, `gh -R pr-team/r release create`, `git -c "user.name=x y" push` and a quoted path with
            # a space in it all passed while this read `\S` and `\b` (an adversarial lens, 2026-09-24). A
            # path, or a bare name, may open a quote the name closes — `"git" push`, 2026-09-24 — which is
            # what the optional quote after each name is for — and every word of the act may be quoted whole,
            # `git "push"`, since quoting each word is an ordinary habit (2026-09-24). **What is not read, by
            # design**: a verb the shell assembles from parts — `pu'sh'`, `$v` — is a decision to hide the
            # act, and this gate does not claim to parse bash against the one it constrains. **And an
            # option whose argument IS one of the act's words** — `npm --workspace publish install` — is
            # read as the act and refused: a pattern cannot know which options take an argument, so of the
            # two readings it takes the one that stops (2026-09-24, declined as a defect, kept as a limit).
            _W = r"""(?:[^\s"'\\]|\\.|"(?:[^"\\]|\\.)*"|'[^']*')"""
            _O = (r"(?:\s+-" + _W + r"*(?:\s+(?![\"']?(?:push|publish|release|pr|run|deploy)[\"']?(?:\s|$))(?!-)"
                  + _W + r"+)?)*")
            _Q = r"""["']?"""
            # the same alternatives, in the same order, as the other copy of this gate
            def _say(*words):                         # the act's words, each may be quoted whole
                return "".join(r"\s+" + _Q + w + _Q for w in words)

            _acts = re.compile(
                r"(?:(?:^|[\n;&|(){}`]|\$\()\s*"
                r"|\b(?:bash|sh|zsh|dash|eval|xargs)\b[^\n]*?[\"']\s*)" + _WRAP +
                r"((?:[\"'][^\"'\n]*/|[\"']|[\w.~/-]*/)?(?:"
                r"git" + _Q + _O + _say("push") +
                r"|gh" + _Q + _O + r"(?:" + _say("release", "create") + r"|" + _say("pr", "create") + r")"
                r"|npm" + _Q + _O + _say("publish") +
                r"|docker" + _Q + _O + _say("push") +
                r"|(?:npm|yarn|pnpm)" + _Q + _O + _say("run", "deploy") +
                r"|(?:make|just)" + _Q + _O + _say("deploy") +
                r"|(?:flyctl|fly|vercel|netlify|wrangler|kamal|cap)" + _Q + _O + _say("deploy") + r")|"
                r"(?:[\w./-]*[/_.-])?(?<!pre[-_])deploy)(?=[\s;&|)<>\"'`]|$)", re.I)
            # **And the flag has to be a word of that command.** `git push origin mainX--dry-run` was
            # excused because the pattern found the flag glued to another word (2026-09-24), so the command is
            # split the way a shell splits it and only a whole word counts — the act's own options included,
            # since `npm --dry-run publish` is a dry run too. A command that will not split is not excused.
            _dry = re.compile(r"--dry[-_]run(?:=(?:true|1|yes))?", re.I)

            def _is_dry(words):
                try:
                    return any(_dry.fullmatch(w) for w in shlex.split(words))
                except ValueError:
                    return False

            hit = next((m for m in _acts.finditer(_c)
                        if not _is_dry(_c[m.start(1):command_end(_c, m.start(1))])), None)
            if hit:
                # **The owner's own last words, quoted — context for the person, never consent.**
                # A gate cannot read intent, and asking the constrained party for theirs is asking
                # the thing being stopped to grade itself. What it can do is spare the human the
                # scroll: whoever decides sees what they last asked for, beside what is about to
                # leave. `last_owner_instruction` has no branch that lets anything through, and if
                # it ever grows one, that branch is the defect.
                _said = last_owner_instruction(payload.get("transcript_path", ""))
                _ctx = (f"\n\nWhat you last asked for, for your own reading — **this is context, "
                        f"not consent**, because a request to do the work is not a request to "
                        f"announce it and an earlier yes does not roll forward: «{_said}»"
                        if _said else "")
                sys.stderr.write(
                    f"Opsinist outward gate: `{hit.group(1)}` leaves the repository, and an "
                    f"outward act is one of the four owner-gated kinds (permissions.md). Two "
                    f"doors, and a retry is not one of them: the owner runs this command "
                    f"themselves, or sets OPSINIST_OUTWARD_GATE=off on purpose. Everything "
                    f"local — commit, branch, build — is untouched by this. **And if this is a "
                    f"sentence about publishing rather than publishing** — the phrase written "
                    f"into a file — say that to the owner and let them look; do not reword it to "
                    f"get past.{_ctx}\n")
                sys.exit(2)
    if (_r0 and tool in ("Write", "Edit") and _t0
            and os.environ.get("OPSINIST_RULE_HOME", "") != "off"
            and re.search(r"/projects/[^/]+/memory/", _t0.replace(os.sep, "/"))
            and operated_by_us(_r0)):
        sys.stderr.write(
            "Opsinist rule-home gate: that path is the harness's private agent memory — "
            "outside the repository, unread by every worker. An owner's rule lives where "
            "workers read (checking.md): a behaviour → a guide line · a domain word → "
            "_ops/ABOUT.md · a choice → _ops/DECISIONS.md · a place to look → the resource "
            "register, with its why. Write it there and name the home back — or set "
            "OPSINIST_RULE_HOME=off on purpose.\n")
        sys.exit(2)

    # 1 · armed only in sessions that engaged the skill — an installed plugin must not
    #     gate a session that never opened it.
    transcript = payload.get("transcript_path", "")
    if not (transcript and os.path.isfile(transcript)):
        out()
    plugin_root = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
    try:
        doors = sorted(os.listdir(os.path.join(plugin_root, "skills")))
    except Exception:
        doors = ["advisor", "join", "init"]
    pat = re.compile(r'"skill"\s*:\s*"(?:[\w-]+:)?(?:%s)"' % "|".join(map(re.escape, doors)))
    try:
        engaged = False
        with open(transcript, encoding="utf-8", errors="replace") as f:
            for line in f:
                if '"skill"' in line and pat.search(line):
                    engaged = True
                    break
        if not engaged:
            out()
    except Exception:
        out()

    # 2 · a git repository, located from the write target when there is one
    target = tin.get("file_path") or ""
    anchor_dir = os.path.dirname(target) if target else cwd
    root = repo_root(anchor_dir) or repo_root(cwd)
    if not root:
        out()

    # 2b · Two refusals that fire where a missing decision is USED, rather than asking for it.
    #      Measured across three rounds: delivering a fact (SessionStart) and demanding an act
    #      (Stop) each bought nothing — 0/5 and 1/5 — while the one scenario that only ever
    #      *forbids* something held 5/5 in all three. So the obligation is restated as a
    #      prohibition at the exact moment the answer would have mattered.
    if tool in ("Write", "Edit") and target:
        # realpath on both sides: on macOS a fixture under /tmp and its repo root under
        # /private/tmp are the same directory spelled two ways, and a prefix test silently
        # answers "no" — the same trap this file already paid for once, in the tracked check.
        try:
            rel = os.path.relpath(os.path.realpath(target), os.path.realpath(root))
        except Exception:
            out()
        cfg_path = os.path.join(root, "_ops", "config.md")
        if not os.path.isfile(cfg_path):
            cfg_path = os.path.join(root, "config.md")
        cfg = ""
        try:
            if os.path.isfile(cfg_path):
                cfg = open(cfg_path, encoding="utf-8", errors="replace").read()
        except Exception:
            out()

        # 2c · The advisor dispatches product work and does not hold it. Measured (N77 at
        #     N=5): five players read that law in the core and edited the product surface
        #     directly anyway — prose, including a law line, does not hold the light tier.
        #     Stopped once per session: the first product-surface write in an operated
        #     project is refused with the three doors; the identical retry passes, so an
        #     owner who insists is delayed one message, never blocked. System records —
        #     tasks, docs, process, the guide — are the advisor's own hands and never trip
        #     this.
        _SYSTEM = ("_ops/", "tasks/", "roles/", "teams/", "panels/", "pipelines/",
                   "requests/", "releases/", "milestones/", "automations/", "resources/",
                   "skills/", "process/", "docs/", "scripts/", "runs/", "threads/",
                   ".index/", ".claude/", ".github/")
        _SYSTEM_FILES = {"CLAUDE.md", "AGENTS.md", "GEMINI.md", "config.md", "LATER.md",
                         ".gitignore", ".opsinist-checkout", ".checkout"}
        operated = operated_by_us(root)
        if (operated and rel and not rel.startswith("..")
                and not rel.startswith(_SYSTEM)
                and os.path.basename(rel) not in _SYSTEM_FILES
                and rel not in _SYSTEM_FILES):
            import hashlib
            sid = payload.get("session_id", "") or payload.get("transcript_path", "") or "s"
            stamp = os.path.join("/tmp", "opsinist-prodgate-"
                                 + hashlib.sha256(sid.encode()).hexdigest()[:8])
            if not os.path.exists(stamp):
                try:
                    open(stamp, "w").write(rel + "\n")
                except Exception:
                    out()
                print(
                    "Opsinist role gate (SKILL.md): the advisor dispatches product work "
                    f"and does not hold it — `{rel}` is product surface, not a system "
                    "record. Three doors: **dispatch it** (a task, a worker, "
                    "`_ops/scripts/transition.py --brief` as its state block) · **the owner "
                    "takes it by hand and says so** · **declare a quick job** and keep it "
                    "small. Retrying the same edit passes — delayed one message, never "
                    "blocked.", file=sys.stderr)
                sys.exit(2)

        # Two refusals lived here and were removed by measurement, not by taste: one demanding
        # `spec_mode` before a task could be written, one demanding the migration log name this
        # version before any artefact could be. **Both asked the constrained party to author the
        # evidence that satisfies them**, and the fourth round caught the second one doing
        # exactly that — runs committed `nothing-required` to the log *without running an
        # audit*, and one scenario went 1/5 → 0/5 because a forced line is cheaper than a real
        # check. This is `0.1.3`'s lesson arriving in a new place: **a gate whose evidence its
        # subject can write is not a gate, it is a lesson in forgery.** What is left below asks
        # for structure a reader can verify, never for a claim about work having been done.
        #
        # (a0) the first task comes before the machinery. Measured 2026-08-01 on the tier owners
        #      actually use: standing a project up took 11–13 minutes of the advisor's own time
        #      and produced 10–13 files before any work existed — a TEAM.md before a team, a
        #      ROADMAP.md before a roadmap — with the first task arriving in the second turn of
        #      one run and the third of the other. The interview was not the cost; the
        #      scaffolding was. This refuses the scaffolding until a task exists, which is a
        #      commission — the only shape of rule this project has ever measured working.
        #      Reading a repository is exempt: a takeover writes its map and its debt list
        #      before it has a single task, by design (`entering.md`).
        READ_OUTPUTS = ("docs/ARCHITECTURE.md", "docs/MAP.md", "docs/DEBTS.md",
                        "_ops/ARCHITECTURE.md", "_ops/MAP.md", "_ops/DEBTS.md")
        if (rel.split("/")[0] in ("docs", "process", "roles")
                and rel not in READ_OUTPUTS
                and not glob.glob(os.path.join(root, "tasks", "*.md"))):
            sys.stderr.write(
                "Opsinist audit gate (starting.md): this project has no task yet, and you are "
                "about to write project scaffolding. **The first task comes before the "
                "machinery** — measured, standing a project up built ten to thirteen files "
                "before any work existed, and the owner watched a TEAM.md be created before "
                "there was a team. Write the first task, then let each document arrive when it "
                "has something to hold: DECISIONS.md at the first decision, LATER.md at the "
                "first deferral, TEAM.md at the first role. Reading a repository is exempt — "
                "the architecture note, the product map and a debt list may be written before "
                "any task exists."
            )
            sys.exit(2)

        # (a) on-touch migration, made real. A lazy conversion that only reminds is a lazy
        #      conversion nobody finishes, so the touch itself is where it is enforced: with a
        #      spec format declared, a task being written must carry its spec reference. The
        #      predicate is the one the migration declared — cheap, and checkable by a script,
        #      which is the whole condition for offering this mode on a large project.
        if (rel.startswith("tasks/") and rel.endswith(".md")
                and re.search(r"spec_mode.*\b(spec|custom|example)\b", cfg)):
            body = tin.get("content") or tin.get("new_string") or ""
            if body and not re.search(r"(?im)^\s*(spec|specification)\s*:", body):
                sys.stderr.write(
                    "Opsinist audit gate (upgrading.md · writing-work.md): this project runs a "
                    "spec format and this task carries no spec reference. Under `on-touch` "
                    "migration the conversion happens the moment work opens an artefact — this "
                    "is that moment. Add the `Spec:` line pointing at the document this task "
                    "works from, and say in the task's thread that its shape changed and which "
                    "version asked. If the document does not exist yet, write it first: a task "
                    "referencing a spec nobody wrote is the half-migration this mode exists to "
                    "avoid.")
                sys.exit(2)


    # 3 · not a repo we already operate — **and not one somebody else operates either**.
    #     Measured 2026-08-02: with a sibling operations skill installed alongside this one, a
    #     bare *"what's next?"* inside a workspace that skill manages routed **here** — both
    #     answer that question — and this gate then read the tree as an unoperated repository
    #     being taken over, because its guide declares an operator that is not us. The takeover
    #     flow ran against a project that already had a manager. **A repository that declares an
    #     operator is not unowned**, and the right move is to hand it back, which for a hook
    #     means stand down. Same shape as the guest test below, and fail-safe the same way:
    #     standing down can only ever decline to gate.
    for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        p = os.path.join(root, guide)
        try:
            if not os.path.isfile(p):
                continue
            txt = open(p, encoding="utf-8", errors="replace").read()
            if "opsinist" in txt.lower():
                out()
            for line in txt.split("\n"):
                if "operated by" in line.lower() and line.strip():
                    out()  # declares an operator, and it is not us
        except Exception:
            out()
    # Another system's own migration log is the same signal without a guide.
    if os.path.isfile(os.path.join(root, "UPGRADES.md")):
        out()

    # 3b · the store's own record is ours by construction and owes nobody a debt list.
    #      `storing.md` says: create `~/.opsinist/projects/<slug>/`, `git init` it, write
    #      `record.md` and `runs.md`, **"and no more"** — which produces a repository with no
    #      guide, no debt list and no collaboration furniture, i.e. exactly the shape this gate
    #      reads as a takeover. Found by the skill itself, running its own flow, and reported
    #      through `/opsinist:report` — a first commit into a directory that did not exist
    #      seconds earlier was refused with *"this repository is being taken over"*.
    #      Two independent signals, because the store root is a documented default rather than
    #      a constant: the path, and the two files the flow is forbidden to exceed.
    real = os.path.realpath(root)
    if os.path.join(".opsinist", "projects") in real or os.path.isfile(os.path.join(root, "record.md")):
        out()

    # 4 · a guest is not a successor, and `entering.md` is explicit that a guest **does not
    #     produce a debt list** — auditing a stranger's repository unasked is the opposite of
    #     what a contributor does. So the collaboration furniture stands the gate down:
    #     CODEOWNERS, a contributor guide, a PR template, or a history in many hands.
    #     `entering.md` also says **ambiguity is guest**, which for a hook means fail open.
    #     The honest limit: this cannot tell *whose* remote a remote is, so a bare checkout of
    #     someone else's project with none of that furniture still reads as a takeover. The cost
    #     of that miss is one refusal asking for a list, undone by writing one.
    for f in ("CODEOWNERS", ".github/CODEOWNERS", "docs/CODEOWNERS",
              "CONTRIBUTING.md", "CONTRIBUTING", ".github/CONTRIBUTING.md",
              ".github/pull_request_template.md", ".github/PULL_REQUEST_TEMPLATE.md"):
        if os.path.exists(os.path.join(root, f)):
            out()
    try:
        r = subprocess.run(["git", "-C", root, "log", "--format=%ae"],
                           capture_output=True, text=True, timeout=5)
        if r.returncode == 0 and len(set(filter(None, r.stdout.split()))) >= 3:
            out()
    except Exception:
        out()

    # 5 · the debt list disarms the gate
    if (os.path.isfile(os.path.join(root, "LATER.md"))
            or os.path.isfile(os.path.join(root, "docs", "DEBTS.md"))
            or os.path.isfile(os.path.join(root, "_ops", "LATER.md"))
            or os.path.isfile(os.path.join(root, "_ops", "DEBTS.md"))
    ):
        out()

    # 6 · at Stop, the other half: the deferrable findings were *said* and never written.
    #     A PreToolUse gate cannot reach this — it constrains an act, and a run that only audits
    #     and reports performs none. Measured 2026-08-01: with the gate armed, N8 scored 1/5 and
    #     four of the five failures were this one miss, in three different wordings.
    #     Triggered off the run's own closing message, because that is where the list is
    #     presented; a run that never used the word has not presented a classified list.
    if event == "Stop":
        # The harness hands the closing message straight to a Stop hook; the transcript walk is
        # the fallback for runtimes that do not.
        closing = (payload.get("last_assistant_message")
                   or last_assistant_text(payload.get("transcript_path", ""))).lower()
        if "deferrab" not in closing:
            out()
        sys.stderr.write(
            "Opsinist audit gate (entering.md): " + STOP_MARKER + ". "
            "A deferral nobody wrote down is a deferral nobody revisits — write the "
            "deferrable findings to LATER.md at the repository root, each with a revisit trigger "
            "that is a moment, not a date (*before anything public ships*, *at the first paying "
            "customer*), then finish. Blocking findings stay in your reply to the owner."
        )
        sys.exit(2)

    # 7 · does this call mutate what is already there?
    deny = False
    if tool in ("Write", "Edit") and target:
        try:
            rel = os.path.relpath(os.path.realpath(target), os.path.realpath(root))
            r = subprocess.run(
                ["git", "-C", root, "ls-files", "--error-unmatch", rel],
                capture_output=True, timeout=5,
            )
            deny = r.returncode == 0  # tracked = theirs; untracked new files pass
        except Exception:
            out()
    elif tool == "Bash":
        cmd = tin.get("command", "") or ""
        deny = bool(
            re.search(
                r"(^|[;&|]\s*|\s)(rm|rmdir|mv|unlink|tee)\s"
                r"|(^|[;&|]\s*|\s)git\s+(add|commit|rm|mv|reset|restore|clean|checkout)\b"
                r"|(^|[;&|]\s*|\s)sed\s+(-\S*\s+)*-i\b",
                cmd,
            )
        )
    if not deny:
        out()

    sys.stderr.write(
        "Opsinist audit gate (entering.md): this repository is being taken over and no debt "
        "list exists yet — nothing is fixed before the owner has seen the findings. First "
        "produce ONE list: every finding blocking or deferrable, each with its consequence "
        "named. Show it to the owner, and write the deferrable ones to LATER.md at the repo "
        "root with a revisit trigger that is a moment, not a date. Once LATER.md (or "
        "docs/DEBTS.md) exists, this call is allowed. Reading is never blocked; creating new "
        "files — the list itself, a guide, docs/ — is never blocked."
    )
    sys.exit(2)


if __name__ == "__main__":
    main()
