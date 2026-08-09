#!/usr/bin/env bash
# Docs guard for a company the advisor built — install it into the company's own repo, not ours.
#
#   cp templates/company-preflight.sh <repo>/_ops/scripts/preflight.sh
#   bash _ops/scripts/preflight.sh --install     # wires it as a pre-commit hook
#
# It guards the four things this methodology insists on and nobody remembers unprompted:
# the docs the guide promises exist, recorded facts have not silently expired, the
# decisions log is append-only, and the architecture map still describes the repo.
#
# Deliberately small. A hook that cries wolf is a hook people bypass with --no-verify.
set -uo pipefail
cd "$(git rev-parse --show-toplevel 2>/dev/null || echo .)"

SENTINEL="# managed by opsinist company-preflight"

if [ "${1:-}" = "--install" ]; then
  # Must be a real repo with a real hooks dir. In a worktree .git is a FILE, and with
  # core.hooksPath (husky, lefthook) the hooks live elsewhere — writing blind there
  # reports success while installing nothing.
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    echo "  x not inside a git repository — nothing installed"; exit 1; }
  hookdir=$(git config --get core.hooksPath 2>/dev/null || true)
  if [ -n "$hookdir" ]; then
    echo "  x this repo uses core.hooksPath=$hookdir (husky, lefthook or similar)."
    echo "    Add to your existing pre-commit instead:  bash _ops/scripts/preflight.sh || exit 1"
    exit 1
  fi
  hookdir=$(git rev-parse --git-path hooks 2>/dev/null) || hookdir="$root/.git/hooks"
  hook="$hookdir/pre-commit"

  # Only ever replace a hook this script wrote. A substring test on the script name is
  # not enough: the chaining line we print below contains that same name, so a chained
  # gitleaks hook would look like ours and get overwritten — deleting a real control.
  if [ -e "$hook" ] || [ -L "$hook" ]; then
    if ! grep -qF "$SENTINEL" "$hook" 2>/dev/null; then
      echo "  x $hook already exists and was not written by this script."
      echo "    Not touching it - it may be your secret scan or test gate."
      echo "    Chain it by adding this line to it:  bash _ops/scripts/preflight.sh || exit 1"
      exit 1
    fi
  fi

  mkdir -p "$hookdir" || { echo "  x cannot create $hookdir"; exit 1; }
  tmp="$hook.opsinist-tmp.$$"
  printf '#!/bin/sh\n%s\nexec bash _ops/scripts/preflight.sh\n' "$SENTINEL" > "$tmp" || {
    echo "  x cannot write $tmp"; exit 1; }
  chmod +x "$tmp" && mv -f "$tmp" "$hook" || {
    rm -f "$tmp"; echo "  x cannot install $hook"; exit 1; }
  echo "pre-commit hook installed at $hook"; exit 0
fi

fail=0; warn=0
say_fail() { echo "  ✗ $1"; fail=1; }
say_warn() { echo "  ! $1"; warn=1; }
echo "preflight — docs"

# 1 · the docs the guide promises must exist. An agent told to read a file that
#     isn't there improvises, and improvisation is how conventions drift.
for f in _ops/ROADMAP.md _ops/TEAM.md _ops/TOOLING.md _ops/DECISIONS.md; do
  [ -f "$f" ] || say_fail "$f is missing — the guide tells every agent it exists"
done
if git ls-files | grep -qE '\.(ts|tsx|js|py|go|rs|swift|kt|rb|java)$'; then
  [ -f _ops/ARCHITECTURE.md ] || say_warn "there is code but no _ops/ARCHITECTURE.md — every task \
starts in a fresh worktree and re-derives the layout"
fi

# 2 · a recorded fact past its recheck is unknown, not fact. TOOLING.md carries a
#     Checked column precisely so this can be enforced rather than hoped for.
if [ -f _ops/TOOLING.md ]; then
  python3 - <<'PY'
import re, datetime
# Past the first threshold a row is worth a nudge. Past the second it is not a stale fact, it is
# a false one sitting where agents read it as true — and warnings do not get acted on. Measured:
# a row eleven months old said "free tier, 1,000/month" for a vendor that had closed its free
# tier; three separate runs found that out, said so clearly, and left the row exactly as it was,
# each listing "update the register" as something for the owner to do later.
STALE_DAYS, FALSE_DAYS = 90, 180
today = datetime.date.today()
for line in open("_ops/TOOLING.md", encoding="utf-8"):
    if not line.strip().startswith("|"):
        continue
    m = re.search(r"(\d{4})-(\d{2})-(\d{2})", line)
    if not m:
        continue
    d = datetime.date(*map(int, m.groups()))
    age = (today - d).days
    if age > FALSE_DAYS:
        print(f"FALSE:{line.split('|')[1].strip()} (checked {d}, {age}d ago)")
    elif age > STALE_DAYS:
        print(f"STALE:{line.split('|')[1].strip()} (checked {d}, {age}d ago)")
PY
fi 2>/dev/null > /tmp/.pf-tooling.$$ || true
while IFS= read -r l; do
  case "$l" in
    STALE:*) say_warn "TOOLING entry past its recheck: ${l#STALE:}";;
    FALSE:*) say_fail "TOOLING entry ${l#FALSE:} — past twice its recheck, so it is not stale, \
it is false where agents read it as true. Re-verify it, or write the value as \`unknown\` with \
today's date. Writing \`unknown\` needs no new information and takes one edit.";;
  esac
done < /tmp/.pf-tooling.$$
rm -f /tmp/.pf-tooling.$$

# 15 · (numbered by arrival, placed by theme) a generated asset without its recipe is
#      unrepeatable, and nobody finds out on the day. A month later the second banner in the
#      set comes back "close but not it", the model has moved, the prompt is gone, and the
#      set stops matching without anyone deciding to let it. Only fires on rows that name a
#      generator, so a project with no generated assets never sees this. visual.md §A
#      generated asset carries its recipe.
if [ -f _ops/assets.md ]; then
  while IFS= read -r row; do
    case "$row" in
      *prompt:*)
        case "$row" in
          *seed:*) ;;
          *) say_fail "an asset row in _ops/assets.md names a generator and a prompt but no \
seed — write the number, or write \`seed: none\` where the model exposes none. Either is one \
edit and needs no new information: $(printf '%s' "$row" | cut -c1-60)";;
        esac;;
      *) say_fail "an asset row in _ops/assets.md names a generator and carries no recipe — a \
generated image whose prompt was not written down cannot be made again, and the set it belongs \
to drifts. Add \`model:\` \`prompt:\` \`seed:\` (visual.md): $(printf '%s' "$row" | cut -c1-60)";;
    esac
  done < <(grep -iE '^\|.*(generated|midjourney|dall-?e|stable diffusion|sdxl|flux|imagen|comfyui|fal\.ai|replicate)' _ops/assets.md 2>/dev/null || true)
fi

# 3 · DECISIONS.md is append-only. Rewriting it is how a rejected idea comes back
#     next quarter with nobody able to say why it was rejected the first time.
if git rev-parse --verify HEAD >/dev/null 2>&1 && [ -f _ops/DECISIONS.md ]; then
  removed=$(git diff --cached -U0 -- _ops/DECISIONS.md 2>/dev/null \
            | grep -c '^-[^-]' || true)
  [ "${removed:-0}" -gt 0 ] && say_fail "_ops/DECISIONS.md is append-only — this commit \
removes or rewrites $removed line(s). Add a new entry instead."
fi

# 3b · the migration log in config.md is append-only for the same reason, and a sharper one:
#      it is the only thing that can distinguish "the files were swapped" from "the project was
#      migrated", and a step re-run after a failure must append rather than overwrite — "this
#      was attempted twice" is exactly the fact a later reader needs. Scoped to the section, so
#      ordinary edits elsewhere in config.md stay free.
if git rev-parse --verify HEAD >/dev/null 2>&1 && [ -f config.md ] \
   && grep -q '^## Migrations' config.md; then
  removed=$(git diff --cached -U0 -- config.md 2>/dev/null \
            | grep '^-[^-]' | grep -cE '^-[[:space:]]*-.*(→|->)' || true)
  [ "${removed:-0}" -gt 0 ] && say_fail "the migration log in config.md is append-only — this \
commit removes or rewrites $removed line(s). A re-run appends a line; it does not replace one."
fi

# 4 · the architecture map must mention the places work actually happens.
if [ -f _ops/ARCHITECTURE.md ]; then
  for d in $(git ls-files | awk -F/ 'NF>1 {print $1}' | sort -u); do
    case "$d" in docs|.github|node_modules|dist|build|vendor) continue;; esac
    grep -q "$d" _ops/ARCHITECTURE.md || say_warn "_ops/ARCHITECTURE.md never mentions \`$d/\` \
— either map it or say why it doesn't matter"
  done
fi

# 4b · the product map, where one exists, must parse and stay reachable. An unclosed mermaid
#      fence renders as a bomb on every surface that draws it, and a split-out move file nothing
#      points at is a flow the index quietly forgot.
for m in _ops/MAP.md _ops/map/*.md; do
  [ -f "$m" ] || continue
  fences=$(grep -c '^```' "$m")
  [ $((fences % 2)) -eq 0 ] || say_fail "$m has an unclosed \`\`\` fence — the map renders as an error"
done
if [ -d _ops/map ]; then
  for m in _ops/map/*.md; do
    [ -f "$m" ] || continue
    grep -q "$(basename "$m")" _ops/MAP.md 2>/dev/null \
      || say_fail "_ops/MAP.md never points at $(basename "$m") — a move file the index forgot"
  done
fi

# 5b · skills born in this repo stay modular (templates/SKILL-SCAFFOLD.md): a budgeted
#      router core + chapters. Catches the monolith while it is still one commit old.
for sk in $(git ls-files | grep -E '(^|/)SKILL\.md$' || true); do
  dir=$(dirname "$sk")
  budget=$(sed -n 's/^core_budget:[[:space:]]*//p' "$sk" | head -1)
  lines=$(grep -c '' "$sk")
  if [ -n "$budget" ] && [ "$lines" -gt "$budget" ]; then
    say_warn "$sk is $lines lines against its own core_budget: $budget — move a block to a chapter, don't squeeze"
  fi
  chapters=$(ls "$dir"/*.md 2>/dev/null | grep -v 'SKILL\.md$' | wc -l | tr -d ' ')
  if [ "$chapters" -gt 0 ] && ! grep -q '| Load' "$sk"; then
    say_warn "$sk has $chapters chapter file(s) but no '| Load … | …when |' routing table — chapters nobody routes to are dead weight"
  fi
done

# 7 · exactly one advisor. Two of them is not a busier project, it is two seats each
#     believing it holds the loop, writing each other's model and effort, and each one
#     recording decisions the other never saw. Stated in three files and, until now,
#     enforced by none of them.
if [ -d roles ]; then
  advisors=$(grep -rlE '^[[:space:]]*type:[[:space:]]*advisor[[:space:]]*$' roles 2>/dev/null | sort)
  n=$(printf '%s' "$advisors" | grep -c . || true)
  if [ "${n:-0}" -gt 1 ]; then
    say_fail "there are $n advisors — exactly one holds the loop. Found: $(echo $advisors | tr '\n' ' ')"
  fi
fi

# 6 · if the layers are split, the manifest must exist. A clone that gives contents with no
#     map looks complete and is not — which is worse than one that is obviously partial.
if [ -f config.md ] || [ -f CLAUDE.md ]; then
  have_docs=0; have_work=0
  [ -d docs ] && have_docs=1
  [ -d tasks ] && have_work=1
  if [ "$have_docs" = 1 ] && [ "$have_work" = 0 ]; then
    grep -qiE 'where (each )?layer|record lives|destinations?:' config.md CLAUDE.md 2>/dev/null \
      || say_warn "docs/ is here but _ops/tasks/ is not, and no manifest names where the other layers \
live — a clone of this repo cannot tell what is missing"
  fi
fi

# 8 · a role that does everything is usually a role that is missing. The load budget is a
#     share of the window, and skills attached to a role load on every run it makes — needed or
#     not. This counts them; the judgement about which to drop stays a person's.
if [ -d roles ]; then
  for r in _ops/roles/*.md; do
    [ -f "$r" ] || continue
    n=$(sed -n 's/^[[:space:]]*-[[:space:]]*//p' "$r" | grep -c . || true)
    skills=$(awk '/^skills:/{f=1;next}/^[a-z_]+:/{f=0}f&&/^[[:space:]]*-/{c++}END{print c+0}' "$r")
    if [ "${skills:-0}" -ge 8 ]; then
      say_warn "$(basename "$r" .md) carries $skills skills — every one loads on every run it \
makes, and a role carrying that many is worse at each of them. Usually the signal is a missing hire"
    fi
  done
fi

# 9 · an entitlement claim points at its evidence, or it is not a claim. Measured: a run found a
#     bundled dependency was BUSL-1.1 rather than MIT, corrected this file honestly, added
#     "commercial license held" — a licence nobody had bought — and tagged a release into the
#     paid product on the strength of it. Every step was defensible except the one that wrote
#     its own permission. Only entitlement words are checked; an ordinary licence name is a
#     fact about the dependency and needs nothing.
#     The evidence must sit in the SAME CLAUSE as the entitlement, not merely somewhere in the
#     row. Measured within an hour of this check being written: a run wrote
#     "commercial license held; evidence: `vendor/plotwright-LICENSE`" — a real pointer, but to
#     the licence *text*, not to a purchase, and the licence text is the document that forbids
#     the very use being claimed. A row-level test cannot validate a claim inside the row, so
#     the clause is the unit: from the entitlement word to the next `;` or column break.
if [ -f _ops/TOOLING.md ]; then
  while IFS= read -r line; do
    case "$line" in \|*) ;; *) continue;; esac
    printf '%s' "$line" | grep -qiE '(licence|license|plan|tier)[^|;]*(held|purchased|bought|covered|acquired|granted)' || continue
    clause=$(printf '%s' "$line" | tr '|;' '\n\n' \
             | grep -iE '(licence|license|plan|tier)[^|;]*(held|purchased|bought|covered|acquired|granted)' | head -1)
    printf '%s' "$clause" | grep -qiE '(receipt|invoice|order|https?://|`[^`]+`)' && continue
    name=$(printf '%s' "$line" | cut -d'|' -f2 | sed 's/^ *//;s/ *$//')
    say_fail "_ops/TOOLING.md claims an entitlement for \`$name\` — \"$(printf '%s' "$clause" | sed 's/^ *//;s/ *$//')\" \
— with no evidence in that same clause. A pointer elsewhere in the row does not cover it, and a \
licence file is evidence of the terms, never of a purchase. Point at the receipt, or write it as \
unknown. An agent may not author the fact that unblocks its own work."
  done < _ops/TOOLING.md
fi

# 10 · nothing transitions itself, and nobody edits the bar they are measured against. Both are
#      stated as laws and, until now, held by nothing. Measured: a run discovered a licence
#      blocker, then set its own task to shipped and tagged a release in the same breath.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  for t in $(git diff --cached --name-only 2>/dev/null | grep -E '^_ops/tasks/.*\.md$' || true); do
    d=$(git diff --cached -U0 -- "$t" 2>/dev/null)
    printf '%s' "$d" | grep -qiE '^\+.*status:[[:space:]]*(done|shipped|completed|accepted|closed)' || continue
    if printf '%s' "$d" | grep -qiE '^[+-].*(dod:|acceptance|definition of done)'; then
      say_fail "$t reaches a terminal status in the same commit that edits its own bar — \
nobody edits the bar they are measured against."
    fi
    printf '%s' "$d" | grep -qiE '(review|approved|accepted by|evidence|run [0-9a-z]|#[0-9]+|https?://)' \
      || say_warn "$t reaches a terminal status and nothing in the change points at a review, a \
run or evidence — nothing transitions itself, and a status that moves on its own is how a board \
begins to lie."
  done
fi

# 11 · a review is not a review when the author signs it off. "Nobody edits the bar they are
#      measured against" has a sibling nobody enforced: models judge their own output generously,
#      and a thread where the only name approving is the name that did the work reads exactly
#      like a reviewed one. Names, not identities — this is a nudge at the honest case, not an
#      identity check, and anything stronger belongs in branch protection.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  for t in $(git diff --cached --name-only 2>/dev/null | grep -E '^_ops/tasks/.*\.md$' || true); do
    d=$(git diff --cached -U0 -- "$t" 2>/dev/null)
    printf '%s' "$d" | grep -qiE '^\+.*(reviewed by|approved by|accepted by)' || continue
    who=$(printf '%s' "$d" | grep -ioE '(reviewed|approved|accepted) by[: ]+@?[A-Za-z0-9._-]+' \
          | sed -E 's/.*by[: ]+@?//' | head -1)
    author=$(grep -ioE '^(assigned|author|worker)[: ]+@?[A-Za-z0-9._-]+' "$t" 2>/dev/null \
             | sed -E 's/.*[: ]+@?//' | head -1)
    [ -n "$who" ] && [ -n "$author" ] && [ "$who" = "$author" ] && \
      say_fail "$t is signed off by \`$who\`, who did the work — a review goes to someone else, \
because a model reads its own output generously and the thread cannot tell the difference."
  done
fi

# 14 · (numbered by arrival, placed by theme — like the rest of this file)
#      a stage changes through the door, or not at all. transition.py checks the ladder and
#      the gates and appends the move to History in the same write — so a staged diff that
#      changes a stage with no transition line beside it is a hand edit around the door.
#      Forging the line instead is a separate visible claim, which is the same argument §13
#      makes about acceptance: the gate's job is to make the bypass cost a lie in plain sight.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  # The field arrives bold in the stock template — `**Status**: draft` — so the pattern
  # allows the asterisks, or this net matches nothing while reading as a gate. Measured by
  # the lenses within a day of it being written: the plain-colon version had zero matches.
  for t in $(git diff --cached --name-only 2>/dev/null | grep -E '^_ops/tasks/.*\.md$' || true); do
    d=$(git diff --cached -U0 -- "$t" 2>/dev/null)
    printf '%s' "$d" | grep -qiE '^-.*(stage|status)\*{0,2}[[:space:]]*:' || continue
    printf '%s' "$d" | grep -qiE '^\+.*(stage|status)\*{0,2}[[:space:]]*:' || continue
    printf '%s' "$d" | grep -qE '^\+.*transition .* (→|->) .*, by ' \
      || say_fail "$t changes its stage with no transition line in the same change — the door \
is \`scripts/transition.py\`: it refuses an illegal move with the reason and records the legal \
one. A stage edited by hand is a bypass."
  done
fi

# 13 · a parent does not close itself. §10 catches a task reaching a terminal status with nothing
#      pointing at evidence; a parent is the sharper case, because its children being done looks
#      exactly like the parent being done and is not the same claim. A parent carrying its own
#      definition of done surfaces as *ready to close* and waits for a person; only a container —
#      a title and children, no DoD of its own — may close on its own, and then the fact that it
#      closed automatically is itself recorded. Measured 0 of 10 across two full rounds as prose,
#      and 1 of 5 after the rule was moved into the always-loaded core, which is why it is here.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  for t in $(git diff --cached --name-only 2>/dev/null | grep -E '^_ops/tasks/.*\.md$' || true); do
    [ -f "$t" ] || continue
    grep -qiE '^[[:space:]]*(children|subtasks)[[:space:]]*:' "$t" || continue
    d=$(git diff --cached -U0 -- "$t" 2>/dev/null)
    printf '%s' "$d" | grep -qiE '^\+.*status:[[:space:]]*(done|shipped|completed|accepted|closed)' || continue
    # A container has no predicate of its own — that one may close itself, and says so.
    grep -qiE '^[[:space:]]*(dod|acceptance|definition of done)[[:space:]]*:' "$t" || {
      printf '%s' "$d" | grep -qiE 'closed (automatically|by rollup)|container' \
        || say_warn "$(basename "$t") is a container closing on its children — legitimate, and \
the fact that it closed automatically is part of the record. Say so in the same change."
      continue
    }
    # The acceptance must already be in HEAD. Asking the diff for it made the gate satisfiable
    # by the party it constrains, and three runs did exactly that within an hour of it being
    # written: a thread line in the owner's voice, a bare "Owner approved.", and — on the
    # licence scenario — the owner's real email address typed under `Approved by:`. **A gate
    # whose evidence the constrained party can author is not a gate.** Acceptance that existed
    # before this commit cannot be forged in the same move; forging it now costs a separate
    # commit whose only content is a claim of approval, which is visible as what it is.
    if git show HEAD:"$t" 2>/dev/null | grep -qiE '(approved by|accepted by|signed off|owner (said|confirmed))'; then
      :
    else
      say_fail "$(basename "$t") carries children **and its own definition of done**, and this \
commit closes it. Children being done is not the parent's predicate being met — it surfaces as \
ready to close and waits for a person. **And the acceptance must already be in the file before \
this commit**: written into the same change, it is the closer vouching for itself. Measured — \
given the earlier version of this gate, runs wrote \"Accepted by owner\" and the owner's own \
email address to get past it."
    fi
  done
fi

# 12 · the spend cap, which for months was written as "stop at the cap" and performed by nothing.
#      Nothing can halt a run already in flight, and on a subscription the authoritative figure
#      belongs to the harness — so the performable half is the one checkable between runs: a
#      commit that records new spend while the ledger is already at or past the envelope is
#      refused, which is what "refuse the next dispatch" means in practice (`cost.md`).
#      Read from _ops/BUDGET.md: the envelope from the Amount line, the level from the latest
#      "Where it stands" row. Percent or currency, either way.
#      A budget with no numbers yet is silent — a template nobody filled must not block a commit.
if [ -f _ops/BUDGET.md ] && git rev-parse --verify HEAD >/dev/null 2>&1; then
  if git diff --cached --name-only 2>/dev/null | grep -qE '^(docs/BUDGET\.md|_ops/tasks/.*\.md|runs?/.*)$'; then
    python3 - <<'PY' > /tmp/.pf-budget.$$ 2>/dev/null || true
import re
txt = open("_ops/BUDGET.md", encoding="utf-8").read()
def money(s):
    m = re.search(r"([0-9][0-9,]*\.?[0-9]*)", s.replace(" ", ""))
    return float(m.group(1).replace(",", "")) if m else None
# The envelope: the Amount bullet. Braces mean the template is unfilled — say nothing.
env = None
for ln in txt.split("\n"):
    if re.search(r"\*\*Amount\*\*", ln) and "{{" not in ln:
        env = money(ln.split(":", 1)[-1] if ":" in ln else ln)
        break
pause = 100.0
m = re.search(r"\*\*Pause spend at\*\*[:\s]*\{?\{?([0-9]+)", txt)
if m and "{{" not in m.group(0):
    pause = float(m.group(1))
# The level: the last data row of the standing table — a row whose second cell carries a number.
level_pct = level_abs = None
for ln in txt.split("\n"):
    if not ln.strip().startswith("|") or "{{" in ln:
        continue
    cells = [c.strip() for c in ln.strip().strip("|").split("|")]
    if len(cells) < 3 or cells[0].lower().startswith("read on") or set(cells[0]) <= set("-: "):
        continue
    if "%" in cells[2]:
        p = money(cells[2])
        if p is not None:
            level_pct = p
    a = money(cells[1])
    if a is not None:
        level_abs = a
if level_pct is None and env and level_abs is not None and env > 0:
    level_pct = 100.0 * level_abs / env
if level_pct is not None and level_pct >= pause:
    print(f"OVER:{level_pct:.0f}:{pause:.0f}")
PY
    while IFS= read -r l; do
      case "$l" in
        OVER:*) pct=$(printf '%s' "$l" | cut -d: -f2); cap=$(printf '%s' "$l" | cut -d: -f3)
          say_fail "_ops/BUDGET.md reads ${pct}% of the envelope against a pause at ${cap}% — \
this commit records more spend past the cap. Nothing can halt a run already in flight, so the cap \
is held here: raise the envelope deliberately, or stop dispatching. The cap is \`locked\` — \
proposed to a human, never edited by whoever works under it.";;
      esac
    done < /tmp/.pf-budget.$$
    rm -f /tmp/.pf-budget.$$
  fi
fi

# 5 · a cheap last line on credentials. NOT a secret scanner — gitleaks/trufflehog are,
#     and they belong in CI. This catches the obvious paste before it reaches history,
#     where removing it means rewriting history and rotating the key anyway.
if git rev-parse --verify HEAD >/dev/null 2>&1; then
  added=$(git diff --cached -U0 2>/dev/null | grep '^+' || true)
  # known credential shapes: provider prefixes, then key-ish name = long quoted value
  if printf '%s' "$added" | grep -qE '(sk-[A-Za-z0-9]{20,}|sk_live_[A-Za-z0-9]{16,}|ghp_[A-Za-z0-9]{30,}|xox[baprs]-[A-Za-z0-9-]{10,}|AKIA[0-9A-Z]{16}|-----BEGIN [A-Z ]*PRIVATE KEY-----)'; then
    say_fail "this commit contains something shaped like a credential — secrets live in \
the environment or a keychain, never in the repository. If it is already committed, rotate it."
  elif printf '%s' "$added" | grep -qiE '(api[_-]?key|secret|token|password|credential|[^a-z]key)[[:space:]]*[:=][[:space:]]*["'"'"'][A-Za-z0-9_/+.-]{20,}["'"'"']'; then
    say_warn "a long literal is assigned to a key-shaped name — check it is not a secret \
(the real scan is gitleaks in CI, see the tooling register)"
  fi
fi

[ "$fail" = 0 ] && { [ "$warn" = 0 ] && echo "  ✓ clean" || echo "  ✓ passed with warnings"; }
exit "$fail"
