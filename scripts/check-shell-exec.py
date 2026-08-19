#!/usr/bin/env python3
"""Refuse a shell script that would execute text as a command.

    python3 scripts/check-shell-exec.py <file.sh> [...]

**Why this exists, with the date.** On 2026-08-16 a check was deleted from
`templates/company-preflight.sh` by cutting from its comment to the first `LINKS\\n` — which was
the OPENING delimiter of `done <<LINKS`, not the closing one. The cut took one line and left the
heredoc's body and terminator behind. The body was a `$( … )` at the start of a line, which in
shell is **command position**: its output is executed. So a markdown link inside a task file became
an argv word that the pre-commit hook RAN, and `LINKS: command not found` went to stderr on every
closing task. `bash -n` passes on that shape, the suite was green for a day, and the file ships
into other people's repositories as their hook.

A lens found it. This is the form, so the next one is found by a run.

**The distinction that makes it subtle**: `$( … )` at the start of a line is completely ordinary
INSIDE a heredoc body, where it is expanded into text. Outside one it is a command. A checker that
cannot tell the two apart is either useless or unusable — the first version of this grep reported
four legitimate heredoc lines in this repository. So heredoc state is tracked.

Two shapes are refused:

  1 · a command substitution or backtick in command position, outside any heredoc body
  2 · a bare word alone on a line that looks like an orphaned heredoc terminator — the other
      half of the same accident, and the thing that printed `LINKS: command not found`
"""
import re
import sys

# `<<` or `<<-`, then an optionally quoted delimiter. `<<<` is a here-STRING and opens nothing.
HEREDOC = re.compile(r"<<-?\s*(?![<])(['\"]?)([A-Za-z_][A-Za-z0-9_]*)\1")
CMD_POS = re.compile(r"^[ \t]*(\$\(|`)")
# A lone ALL-CAPS-ish word: what a heredoc delimiter looks like when its opener is gone. Deliberately
# narrow — a bare lowercase word alone on a line is usually a real command (`done`, `fi`, `esac`).
LONE_WORD = re.compile(r"^[ \t]*([A-Z][A-Z0-9_]{2,})[ \t]*$")


def _quote_state(line, in_dq):
    """Whether a double-quoted string is still open after this line.

    A `$( … )` at the start of a line is TEXT when a double-quoted string opened on an earlier
    line is still running — which is how this file's own refusal messages are written, three of
    them. A checker that cannot see that reports its own repository and gets deleted as noisy,
    which is worse than not having it.
    """
    i, n = 0, len(line)
    in_sq = False
    while i < n:
        c = line[i]
        # A `$( … )` span is skipped WHOLE, at any nesting depth, because the quotes inside it
        # belong to the substitution and not to the string containing it. Without this,
        # `$(cat "$post")` inside an open message closed the string and the next line read as
        # command position — two false reports on this repository's own refusal texts.
        if c == "$" and i + 1 < n and line[i + 1] == "(":
            depth, i = 0, i
            while i < n:
                if line[i] == "(":
                    depth += 1
                elif line[i] == ")":
                    depth -= 1
                    if depth == 0:
                        i += 1
                        break
                i += 1
            continue
        if c == "\\":
            i += 2; continue
        if in_dq:
            if c == '"':
                in_dq = False
        elif in_sq:
            if c == "'":
                in_sq = False
        else:
            if c == "#" and (i == 0 or line[i - 1] in " \t"):
                break                      # a comment ends the line for quoting purposes
            if c == "'":
                in_sq = True
            elif c == '"':
                in_dq = True
        i += 1
    # An open double-quoted string survives to the next line UNCONDITIONALLY — inside quotes a
    # newline is just a newline, and the `\` continuations in this repository's messages are for
    # the source's readability, not for the string. Requiring one closed the guard's own refusal
    # text at its first unescaped line end and reported the next line as command position.
    # An unterminated quote is bash's own syntax error and `bash -n` catches it, so nothing is
    # lost by trusting the state.
    return in_dq


def scan(path):
    faults = []
    try:
        lines = open(path, encoding="utf-8", errors="replace").read().split("\n")
    except OSError as e:
        return [(0, f"cannot read: {e}")]

    pending = []          # delimiters opened on this line, closing in order
    open_delims = []      # the stack of bodies we are inside
    in_dq = False         # a double-quoted string still running from an earlier line
    for n, line in enumerate(lines, 1):
        if in_dq:
            in_dq = _quote_state(line, True)
            continue
        if open_delims:
            # inside a body: only its terminator matters
            if line.strip() == open_delims[0]:
                open_delims.pop(0)
            continue

        stripped = line.lstrip()
        if not stripped.startswith("#"):
            if CMD_POS.match(line):
                faults.append((n, "a command substitution in COMMAND POSITION — its output is "
                                  "executed as a command, so any text it produces runs"))
            m = LONE_WORD.match(line)
            if m and m.group(1) not in ("EOF",):
                faults.append((n, f"`{m.group(1)}` alone on a line — an orphaned heredoc "
                                  f"terminator: something opened with `<<{m.group(1)}` and no "
                                  f"longer does, so its body is live code"))

        if not stripped.startswith("#"):
            in_dq = _quote_state(line, False)
        # openers on this line (comments can carry `<<WORD` in prose, so skip them)
        if not stripped.startswith("#"):
            pending = [mm.group(2) for mm in HEREDOC.finditer(line)]
            if pending:
                open_delims = pending
    return faults


def main():
    if len(sys.argv) < 2:
        print(__doc__.strip().split("\n")[0])
        print(f"\n    usage: {sys.argv[0]} <file.sh> [...]")
        return 2
    bad = 0
    for path in sys.argv[1:]:
        for n, why in scan(path):
            print(f"  ✗ {path}:{n} — {why}")
            bad += 1
    if bad:
        print(f"\n  {bad} place(s) where a shell script would execute text. This is the class that "
              f"made a pre-commit hook run a file named by a link inside a task, 2026-08-16.")
        return 1
    print(f"  shell-exec: {len(sys.argv) - 1} script(s), no text reaches command position")
    return 0


if __name__ == "__main__":
    sys.exit(main())
