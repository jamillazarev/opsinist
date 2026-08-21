#!/usr/bin/env bash
# The shell-exec checker, exercised on its mutants and its twins — the form the capability bar
# asks for and the file shipped without.
#
# Two things are tested, and the second is the one that mattered:
#
#   1 · the CHECKER answers correctly — a `$( … )` in command position and an orphaned heredoc
#       terminator are refused, and the ordinary shapes this repository writes are not;
#   2 · the GATE is wired — a defect planted in a clone makes `scripts/preflight.sh` exit
#       NON-ZERO. Shipped, it did not: the block's refusals were printed in red and preflight
#       exited 0, because the `say_fail` calls sat on the right of a pipe (subshell, so `FAIL=1`
#       died with it) and the compensating line set lowercase `fail`, which nothing reads.
#       A checker whose findings do not change an exit code is a checker nothing runs.
#
# Recursion guard: case 2 runs preflight inside a clone; CORPUS_PF_TEST makes the clone's
# preflight skip its suite battery, so the depth is exactly two.
[ -n "${CORPUS_PF_TEST:-}" ] && { echo "check-shell-exec: 0 passed, 0 failed"; exit 0; }
set -uo pipefail
cd "$(dirname "$0")/.." || exit 1
T=$(mktemp -d); trap 'rm -rf "$T"' EXIT
pass=0; fail=0
ok(){ pass=$((pass+1)); }; bad(){ fail=$((fail+1)); echo "  ✗ $1"; }

CHK="python3 scripts/check-shell-exec.py"

# _rc <file> — the checker's exit code, captured BEFORE any pipe.
_rc(){ $CHK "$1" > "$T/out" 2>&1; echo $?; }

# refuses <fixture-name> <why> — the mutant direction. Also asserts the fixture is real bash,
# because a shape `bash -n` already rejects is not the shape this checker exists for.
refuses(){
  local f="$T/$1.sh" why="$2"
  bash -n "$f" 2>/dev/null || { bad "$1: the fixture is not valid bash, so it proves nothing"; return; }
  [ "$(_rc "$f")" = 1 ] && ok || bad "$why"
}
# passes <fixture-name> <why> — the twin direction.
passes(){
  local f="$T/$1.sh" why="$2"
  bash -n "$f" 2>/dev/null || { bad "$1: the fixture is not valid bash, so it proves nothing"; return; }
  [ "$(_rc "$f")" = 0 ] && ok || bad "$why — $(sed -n '1p' "$T/out")"
}

# ---------------------------------------------------------------- mutants: must be refused

# the accident itself: a `$( … )` at the start of a line, outside any heredoc
printf '#!/usr/bin/env bash\necho before\n$(cat /etc/hostname)\n' > "$T/m1.sh"
refuses m1 "a command substitution in command position was accepted"

# its backtick spelling
printf '#!/usr/bin/env bash\necho before\n`cat /etc/hostname`\n' > "$T/m2.sh"
refuses m2 "a backtick in command position was accepted"

# the other half of the same accident: the body and terminator left behind by the cut
printf '#!/usr/bin/env bash\necho before\n  ls -la\nLINKS\necho after\n' > "$T/m3.sh"
refuses m3 "an orphaned heredoc terminator was accepted"

# the same orphan with the COMMONEST delimiter there is. Shipped, `EOF` was excluded by name,
# with no comment saying why — so the accident was invisible for the delimiter most scripts use.
printf '#!/usr/bin/env bash\necho before\n  ls -la\nEOF\necho after\n' > "$T/m4.sh"
refuses m4 "an orphaned EOF terminator was accepted — the commonest delimiter is the blind spot"

# a phantom opener in a TRAILING comment. Real shell strips the comment and opens nothing; a
# scanner that reads the raw line opens a heredoc that never closes and goes blind to the rest
# of the file — so the `$( … )` below is swallowed and the file reports clean.
printf '#!/usr/bin/env bash\necho setup # see the docs about <<NOTE syntax\n$(cat /etc/hostname)\n' > "$T/m5.sh"
refuses m5 "a heredoc opener inside a trailing comment blinded the scanner"

# a phantom opener inside a double-quoted STRING, same consequence
printf '#!/usr/bin/env bash\necho "pipe <<DATA into it"\n$(cat /etc/hostname)\n' > "$T/m6.sh"
refuses m6 "a heredoc opener inside a quoted string blinded the scanner"

# `<<<` is a here-STRING and opens nothing. The lookahead rejected only the first `<`, so the
# scanner re-matched at the second and opened a phantom body named after the word.
printf '#!/usr/bin/env bash\nwc -l <<< hello\n$(cat /etc/hostname)\n' > "$T/m7.sh"
refuses m7 "a here-string was read as a heredoc opener and blinded the scanner"

# `$(( 1 << n ))` is arithmetic, not a heredoc
printf '#!/usr/bin/env bash\nx=$((1<<n))\n$(cat /etc/hostname)\n' > "$T/m8.sh"
refuses m8 "an arithmetic left-shift was read as a heredoc opener and blinded the scanner"

# a hyphenated delimiter is legal bash; a delimiter class that stops at the hyphen never sees
# the terminator, so everything after the body is swallowed
printf '#!/usr/bin/env bash\ncat <<END-OF\nbody\nEND-OF\n$(cat /etc/hostname)\n' > "$T/m9.sh"
refuses m9 "a hyphenated heredoc delimiter swallowed the rest of the file"

# ---------------------------------------------------------------- twins: must pass

# `$( … )` at the start of a line is ORDINARY inside a heredoc body — it is expanded into text.
printf '#!/usr/bin/env bash\ncat <<BODY\n$(date)\nBODY\necho done\n' > "$T/t1.sh"
passes t1 "a command substitution inside a heredoc body was refused"

# a double-quoted string still open from an earlier line: this repository's own refusal texts
printf '#!/usr/bin/env bash\necho "a long message\n$(this is text) and more"\necho done\n' > "$T/t2.sh"
passes t2 "a command substitution inside an open double-quoted string was refused"

# a WHOLE-line comment may talk about `<<WORD` in prose
printf '#!/usr/bin/env bash\n# the old form was <<CONF and it is gone\ncat <<CONF\n$(date)\nCONF\n' > "$T/t3.sh"
passes t3 "a heredoc opener named in a full-line comment was treated as real"

# a heredoc opened INSIDE a command substitution still opens a body
printf '#!/usr/bin/env bash\nv=$(python3 - <<PYX\nprint(1)\nPYX\n)\necho "$v"\n' > "$T/t4.sh"
passes t4 "a heredoc opened inside a command substitution was mis-tracked"

# an argument wrapped onto the next line with a backslash is not command position
printf '#!/usr/bin/env bash\necho the time is \\\n  $(date)\n' > "$T/t5.sh"
passes t5 "a line continuation was reported as command position"

# an element of a multi-line array literal is not command position
printf '#!/usr/bin/env bash\nfiles=(\n  $(ls /tmp)\n)\necho "${files[@]}"\n' > "$T/t6.sh"
passes t6 "an element of a multi-line array literal was reported as command position"

# the corpus itself: every shell script this repository ships must pass, or the checker is
# unusable and gets deleted as noisy — which is how the 2026-08-16 accident became possible.
$CHK templates/*.sh scripts/*.sh > "$T/corpus" 2>&1 \
  && ok || bad "the repository's own shell scripts do not pass: $(grep -c '✗' "$T/corpus") report(s)"

# ---------------------------------------------------------------- the gate is wired

# A clone of HEAD, a defect planted in it, and the SHIPPED preflight run over it. This is the
# assertion the range needed and did not have: not "does the checker answer", but "does its
# answer change preflight's exit code".
git clone -q --local . "$T/c" 2>/dev/null || { bad "could not clone for the gate test"; }
if [ -d "$T/c" ]; then
  ( cd "$T/c" && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) >/dev/null 2>&1 \
    && ok || bad "the untouched twin clone failed preflight"

  printf '#!/usr/bin/env bash\n$(cat /etc/hostname)\n' > "$T/c/scripts/zz-planted.sh"
  ( cd "$T/c" && CORPUS_PF_TEST=1 bash scripts/preflight.sh ) > "$T/g" 2>&1 \
    && bad "a script that executes text passed preflight — the gate prints in red and exits 0" || ok
  grep -q "COMMAND POSITION" "$T/g" \
    && ok || bad "preflight's refusal does not name the command-position fault"
fi

echo "check-shell-exec: $pass passed, $fail failed"
exit "$fail"
