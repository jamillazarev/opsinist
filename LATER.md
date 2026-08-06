# Later — deferred, each with a moment that reopens it

**This project's own deferred list**, kept by the rule it gives everyone else: **a revisit trigger
that is a moment, not a date**. A deferral with no trigger is an abandonment wearing better
clothes, and this file exists so the ones here can be told apart from the ones nobody wrote down.

**What belongs here:** something real, understood, and consciously not done now. Not a wish, not
an idea — those go to the backlog or nowhere. **What does not belong here:** anything that stops
work now, which is a task with a blocker instead.

---

## ~~Measure what the day-one cut actually bought~~ — run 2026-08-01, partly falsified

**Closed by measurement, and the verdict is split.** The **ordering** claim confirmed: the first
task is now written second, before every document, where it used to arrive after the scaffolding.
The **volume** and **time** claims **falsified** against the criteria written below before the
run: still ten to thirteen files, and turn two still at four hundred seconds against a stated
threshold of three hundred. `evals/RUNS.md` carries the table.

**What it taught, and the next thing to try:** the gate could see *order* and enforced it; it
cannot see *emptiness*, so once the task exists every document passes. **The corpus says day one
is four things and the hook enforces something narrower — the gap between them is the thirteen
files.** The predicate that would close it is *refuse a document whose body is a heading and a
template's braces*: checkable, a commission, and the shape that has worked twice. **Not
attempted**, because the criterion comes first.

**The original entry, kept because the criteria are what made the verdict possible:**

## Measure what the day-one cut actually bought

**Deferred because** the account stood at **92% of its seven-day allowance** on `2026-08-01`, and
an honest measurement of this change is three runs on the tier an owner actually uses — the tier
where the problem was found and the only one where the answer means anything.

**What to run:** `S2` on the strong tier, three runs, three turns, `defaults` answered — the exact
shape of the diagnostic that produced the numbers being compared against. **The baseline is
recorded**: `11–13 minutes` of advisor time across three turns, `10–13` files before any work
existed, the first task arriving in turn two of one run and turn three of the other
(`evals/RUNS.md`).

**What would falsify the fix:** the first task still arriving after the scaffolding, or the second
turn still running past five minutes. **What would confirm it:** a task in turn one or two, and
four files where there were thirteen.

**Revisit when** the seven-day allowance resets, or sooner if the owner who reported the
forty minutes comes back — **their session is worth more than a synthetic one**, and the fix was
made for them.

---

## The forty-minute report itself is still a single account

**Deferred because** one owner's experience is a finding, not a rate — and the runs that measured
it were synthetic, answering *"defaults"* to everything rather than thinking about the answers.

**Revisit when** that owner replies, or when a second report of the same shape arrives. **Two
occasions is the bar this project sets everywhere else**, and it applies to its own evidence
first.

---

## ~~A wave's failure policy~~ — carried in 2026-08-06, with its second occasion

**The bar was met, then the shelf was cleared**: Dify's iteration modes were the first
occasion, the conveyor case named at carry-in (a batch where one corrupt source must not hold
thirty) the second, and the owner took it into the release — `on_child_failure` on the
parent's wave plan, default `escalate` unchanged (`decomposing.md`).

## ~~A `pack` mode for the inventory script~~ — deleted 2026-08-06, by the owner's call

**Removed unrequested rather than reopened**: no dispatch had hit a context ceiling, and the
owner chose deletion over shelf-keeping. The idea survives in one sentence — the inventory's
CLI is shaped so `pack` could arrive as a second mode — and if a real ceiling ever shows up,
that sentence is the door back.

## ~~A nested layout — the machinery under one root directory~~ — carried in 0.2.0, by the owner's call

**The deferral said** flat `tasks/`-shaped paths were load-bearing across every validator,
hook, fixture and chapter, so nesting was a whole-stack format migration paid twice — once by
us, once by each owner. **The owner re-counted and overrode it**: the real path-logic surface
was ~10 points in three scripts, the rest plain text substitution — and the residue the entry
itself had named honest, the **name collision** with a project's own `tasks/` or `docs/`, was
the argument *for* moving. So it landed exactly as the entry priced it: a major-version
migration with its own map (`scripts/migrate-layout.py`), the machinery under `_ops/` — named
to sort first and to collide with nothing — and a flat-root fallback in the door so an
unmigrated project fails toward the notice, not a stack.

## A generated Opportunity-Solution-Tree view over the specs

**Deferred because** the data half landed on 2026-08-06 — the spec's `Opportunity` field names
the need and cites its insight, so every new spec feeds the tree — and only the generator
remains: mermaid between markers (`PATTERNS.md` §6, same shape as `touched by:`), a day of
work with no requester yet. A view nobody reads is furniture; the field is not, because a
solution with no opportunity above it now fails a read even without the picture.

**Revisit when** the first project running product discovery asks to *see* the tree, or a
review finds a solution shipped with no opportunity above it.

## `starts: webhook` — an external trigger the automation can declare

**Reopened as a live candidate 2026-08-06 — the listener now exists somewhere real.** OpenClaw
was measured on this machine: a resident WebSocket gateway, `cron`, agent hooks — the first
runtime that could actually *hold* a declared trigger, where every earlier survey found only
serverless sessions. The shape stays settled: `webhook:<name>` beside `schedule:<cron>`,
executed by the host that has a listener, under the schedule's own law — *one that silently
did not run is worse than one that says it was late*.

**Revisit when** the first automation actually needs an external event — and the first step
then is verifying OpenClaw's trigger surface (its cron/gateway API), not building one.

## ~~Project-local skills must survive an upgrade that ships a same-named stock skill~~ — reopened 2026-08-05, taken into the release

**Its own trigger fired the day it was written**: the owner read the entry and took it into the
spec-format release (batch 6, beside the screener work). The rule it called for is the one being
added: **local wins, upgrade never overwrites it, and the collision is surfaced rather than
silent.** Kept here because the check that produced it is evidence: `upgrading.md` protects the
owner's *conventions*, and nothing protected their *files of the same name* until this.
