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

# `<<` or `<<-`, then an optionally quoted delimiter. `<<<` is a here-STRING and opens nothing —
# and the guard for that is a look-BEHIND, not a look-ahead. The lookahead form rejected only the
# first `<` of `<<<`; the scanner then re-matched at the second and opened a phantom body named
# after the here-string's word, swallowing the rest of the file. Measured 2026-08-21.
# The delimiter class carries `-` because `<<END-OF` is legal bash: a class that stopped at the
# hyphen truncated the delimiter to `END`, so the real terminator never matched and everything
# after the body was read as heredoc.
HEREDOC = re.compile(r"(?<!<)<<-?\s*(['\"]?)([A-Za-z_][A-Za-z0-9_-]*)\1")
CMD_POS = re.compile(r"^[ \t]*(\$\(|`)")
# A lone ALL-CAPS-ish word: what a heredoc delimiter looks like when its opener is gone. Deliberately
# narrow — a bare lowercase word alone on a line is usually a real command (`done`, `fi`, `esac`).
# `EOF` was excluded by name and with no reason given, which blinded this check for the commonest
# delimiter in shell. Removing the exclusion produces no report on this repository's own scripts.
LONE_WORD = re.compile(r"^[ \t]*([A-Z][A-Z0-9_-]{2,})[ \t]*$")


def _code_only(line):
    """The line with quoted spans blanked, same-line `$( … )` spans blanked, and an unquoted
    trailing comment cut.

    The opener scan must run on this, not on the raw line. Three shapes otherwise open a heredoc
    that shell never opens — a trailing comment mentioning `<<WORD`, a `<<WORD` inside a quoted
    string, and `$((1<<n))` arithmetic — and each swallows every following line until a matching
    terminator, so the checker goes silent on the rest of the file and prints that no text reaches
    command position. All three measured 2026-08-21.

    A `$( … )` span is blanked only when it CLOSES on the same line. An unclosed one is a
    multi-line command substitution whose opener may itself carry the heredoc — `v=$(python3 -
    <<BLOCK` is written twice in this repository — and blanking it orphans the terminator below.
    """
    # A QUOTED heredoc delimiter — `<<'EOF'`, the commonest spelling in this repository — is a
    # quoted span that must survive masking, or the opener disappears and the body below it is
    # read as live code. Measured 2026-08-21: blanking quoted spans wholesale produced 24 reports
    # on this repository's own scripts, every one of them the cascade from a lost `<<'EOF'`.
    protected = [m.span() for m in re.finditer(r"<<-?[ \t]*(['\"])[A-Za-z_][A-Za-z0-9_-]*\1", line)]
    out, i, n = [], 0, len(line)
    in_sq = in_dq = False
    while i < n:
        span = next((s for s in protected if s[0] == i), None) if not (in_sq or in_dq) else None
        if span:
            out.append(line[span[0]:span[1]]); i = span[1]; continue
        c = line[i]
        if c == "\\" and not in_sq:
            # keep the backslash itself: a line ENDING in one is a continuation, and blanking it
            # loses the only evidence of that
            out.append("\\")
            if i + 1 < n:
                out.append(" ")
            i += 2; continue
        if not in_sq and not in_dq and c == "$" and i + 1 < n and line[i + 1] == "(":
            depth, j = 0, i
            while j < n:
                if line[j] == "(":
                    depth += 1
                elif line[j] == ")":
                    depth -= 1
                    if depth == 0:
                        j += 1
                        break
                j += 1
            if depth == 0:                      # closed on this line: it is not opener territory
                out.append(" " * (j - i)); i = j; continue
            out.append(line[i:])                # unclosed: leave it visible, opener may be inside
            break
        if in_dq:
            out.append(" " if c != '"' else c)
            if c == '"':
                in_dq = False
        elif in_sq:
            out.append(" " if c != "'" else c)
            if c == "'":
                in_sq = False
        else:
            if c == "#" and (i == 0 or line[i - 1] in " \t"):
                break                            # an unquoted `#` ends the line for shell
            out.append(c)
            if c == "'":
                in_sq = True
            elif c == '"':
                in_dq = True
        i += 1
    return "".join(out)


def _continues(code):
    """Whether this code line ends in an odd run of backslashes — the next line is its argument
    list, not command position. `echo x \\` then an indented `$(date)` was reported as a fault."""
    n = 0
    while n < len(code) and code[len(code) - 1 - n] == "\\":
        n += 1
    return n % 2 == 1


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
    cont = False          # the previous code line ended in a continuation backslash
    depth = 0             # group parens open from earlier lines: `files=(` … `)`
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
            code = _code_only(line)
            # A continuation line carries arguments, and a line inside an unclosed group paren
            # carries list elements — neither is command position. Both were reported as faults
            # on ordinary bash, and a checker that reports ordinary bash is a checker that gets
            # deleted. Accepted with it: inside a multi-line `$( … )` a nested line-leading
            # `$( )` is suppressed too — a true positive traded for the two false ones.
            if CMD_POS.match(line) and not cont and depth <= 0:
                faults.append((n, "a command substitution in COMMAND POSITION — its output is "
                                  "executed as a command, so any text it produces runs"))
            m = LONE_WORD.match(line)
            if m:
                faults.append((n, f"`{m.group(1)}` alone on a line — an orphaned heredoc "
                                  f"terminator: something opened with `<<{m.group(1)}` and no "
                                  f"longer does, so its body is live code"))
            in_dq = _quote_state(line, False)
            # openers on this line, read from the CODE — a `<<WORD` inside a comment or a string
            # or an arithmetic shift opens nothing in shell and must open nothing here
            pending = [mm.group(2) for mm in HEREDOC.finditer(code)]
            if pending:
                open_delims = pending
            depth = max(0, depth + code.count("(") - code.count(")"))
            cont = _continues(code)
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
