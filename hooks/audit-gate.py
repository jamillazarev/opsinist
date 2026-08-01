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
                    if sum(1 for ln in f if STOP_MARKER in ln) >= 2:
                        out()
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
