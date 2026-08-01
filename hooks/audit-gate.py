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
(`>`) is not caught — the gate teaches the order, the judge scores the honesty.
"""
import json
import os
import re
import subprocess
import sys


# The sentence the Stop refusal opens with. Also how the hook counts its own past refusals in a
# transcript, so it is a constant rather than a phrase two places have to keep saying the same.
STOP_MARKER = "you presented deferrable findings and there is no LATER.md"
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
    p = os.path.join(root, "config.md")
    try:
        if not os.path.isfile(p):
            return None  # no config.md at all — not the same as "no line"
        txt = open(p, encoding="utf-8", errors="replace").read()
        if "## Migrations" not in txt:
            return False
        section = txt.split("## Migrations", 1)[1].split("\n## ", 1)[0]
        outcomes = ("applied", "nothing-required", "declined", "deferred", "failed")
        for line in section.split("\n"):
            if version and version in line and any(o in line for o in outcomes):
                return True
        return False
    except Exception:
        return None


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
            out()
        # A guest tree gets nothing: no log, no check, no line. Same test as the audit gate.
        for f in ("CODEOWNERS", ".github/CODEOWNERS", "CONTRIBUTING.md", "CONTRIBUTING",
                  ".github/pull_request_template.md"):
            if os.path.exists(os.path.join(root, f)):
                out()
        ours = os.path.isfile(os.path.join(root, "config.md"))
        for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
            p = os.path.join(root, guide)
            try:
                if os.path.isfile(p) and "opsinist" in open(p, encoding="utf-8", errors="replace").read().lower():
                    ours = True
            except Exception:
                out()
        if not ours:
            out()  # not a project we operate — nothing to say
        v = skill_version()
        if not v:
            out()
        named = migration_log_names(root, v)
        if named is True:
            out()  # checked already, and recorded — say nothing
        if named is None:
            sys.stdout.write(
                f"Opsinist {v}: this project has no `config.md`, so nothing records whether it "
                f"was ever migrated — and swapping the plugin's files is not migrating a "
                f"project. Before acting on it, say so, run the migration audit (upgrading.md), "
                f"and open the migration log with its result.\n")
        else:
            sys.stdout.write(
                f"Opsinist {v}: this project's migration log does not name version {v}, so it "
                f"is not recorded as migrated to the version now running it. Before acting on "
                f"it, say so, run the migration audit (upgrading.md) — one list split by "
                f"whether it needs the owner — and append a line to `## Migrations` in "
                f"`config.md`, `nothing-required` included.\n")
        sys.exit(0)

    # The guard against a hook and a model arguing forever. `stop_hook_active` is honoured
    # first — and it is **not** sufficient on its own: measured 2026-08-01, runs were blocked
    # twice with that flag never arriving, so the second guard counts our own refusals in the
    # transcript and stands down after two. A hook that can nag without limit is a hook that
    # can burn a turn budget, and the run it kills looks like a corpus failure.
    if event == "Stop":
        if payload.get("stop_hook_active"):
            out()
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
        cfg_path = os.path.join(root, "config.md")
        cfg = ""
        try:
            if os.path.isfile(cfg_path):
                cfg = open(cfg_path, encoding="utf-8", errors="replace").read()
        except Exception:
            out()

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


    # 3 · not a repo we already operate
    for guide in ("CLAUDE.md", "AGENTS.md", "GEMINI.md"):
        p = os.path.join(root, guide)
        try:
            if os.path.isfile(p) and "opsinist" in open(p, encoding="utf-8", errors="replace").read().lower():
                out()
        except Exception:
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
    if os.path.isfile(os.path.join(root, "LATER.md")) or os.path.isfile(
        os.path.join(root, "docs", "DEBTS.md")
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
