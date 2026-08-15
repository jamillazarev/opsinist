# Later — deferred, each with a moment that reopens it

**This project's own deferred list**, kept by the rule it gives everyone else: **a revisit trigger
that is a moment, not a date**. A deferral with no trigger is an abandonment wearing better
clothes, and this file exists so the ones here can be told apart from the ones nobody wrote down.

**What belongs here:** something real, understood, and consciously not done now. Not a wish, not
an idea — those go to the backlog or nowhere. **What does not belong here:** anything that stops
work now, which is a task with a blocker instead.

---


## `diagrams.md` is at its budget, and the capability bar keeps asking for diagrams

**Measured 2026-08-15**: the file stood at **499 lines of a 500-line chapter budget** before this
release added one, and `self-maintenance.md` §What-a-capability-owes requires a diagram for every
new mechanic. Those two rules meet at the next mechanic, not at some point in the future.

This release resolved its own case by putting the diagram in `cost.md`, the chapter it illustrates
— which is arguably where it always belonged, and `consulting.md` already carried its own. So the
question is not "where does this one go" but **whether `diagrams.md` is a chapter or an index**: a
gallery that must hold every diagram will keep hitting 500, while a chapter that holds the ones
which cross several rules can stay small if the rest live beside their rules.

**Revisit trigger:** the next new mechanic that owes a diagram. If its natural chapter has room,
put it there and this becomes the convention; if it does not, the budget or the gallery has to give,
and that is a decision about what `diagrams.md` is for.

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

---

## A tripwire for work bypassing the machinery wholesale

**The evidence:** a live project split into two eras at one commit — before it, six honest run
records and twelve tasks with done-definitions; after it, **0 of 33 commits touched `_ops`** while
the site shipped, decisions changed unrecorded (domain, language count, act format), and the
board froze at "created". The guard fired on every commit and had nothing to say, because no
check reads *work advancing while the record stands still*. The shape of the form: the project
preflight warns — never fails — when the last N commits carry zero `_ops/` paths in a repo whose
guide declares an operator. **Warn, not fail, and once**: site work is legitimate; the record
going dark is the smell. **Revisit when:** the next takeover audit or field report shows a second
project with a dark era — twice is the threshold everywhere here.

## A channel that reaches the owner who is away

**Requests age in files, and nothing tells an owner who is not at the terminal.** Evaluated
2026-08-14: Agent-Reach (71k★, MIT) — declined; despite the name it is **inbound only** (agents
reading platforms via cookie scrapers, ToS-gray, churn-prone), it contains no notification
surface at all. The honest candidates remain the harness's own push notifications and a
Telegram-bot shelf row (one token, owner-controlled, off-terminal). **Revisit when:** a request
ages past its threshold unseen in a real project — that is the moment the need names the row.

## A market-recon distillate template for `research/`

**The folder exists with no named shape** (`project-layout.md` — "studies and their
distillates"), and a live project's recon produced clean per-study documents with nowhere agreed
to converge. The substance worth keeping from the 2026-08-14 gap analysis: analogs land in the
competitor register (now with stage/outcome) · what-to-borrow and risks-and-failures as
distillate sections citing register rows · the delta is the positioning brief, homed in
`BRAND-template.md` §Positioning. **Revisit when:** the next real market-recon study is
commissioned — a template written before its second use is a guess.

## The advisor-side half of the doors: nothing forces wiring at stand-up

**Measured 2026-08-14, N89 at 0/3** (2 of its 5 runs voided): every graded day-one run stood the project up ad hoc — no
guard wired, no doors, no type file — so the guard's new doors check (the wired-project form,
landed the same day) never gets its chance. The prose instruction alone does not survive
contact, which is this corpus's oldest measurement. The candidate form: the plugin's own
SessionStart hook already delivers the migration fact in operated projects — the same mechanism
can say, once, *"this operated project has no wired guard and no doors"*. **Revisit when:** the
next round re-measures N89 with the wired-project form in the field — if ad-hoc stand-ups
persist, the hook line is built; a second round with no passes is the threshold — the next full round after 0.2.7.

## The council has a field but no gate, and a document has no seam to hold one

**Named 2026-08-14, at the release that shipped it.** The capability bar has four clauses and
says *no exceptions for small ones*; the council shipped with the showcase trio and a declared
field (`angles · voices · provider`), and **without the other two — no form where it can fail,
no mutation test, and therefore no dated measurement of the field ever appearing**. This is
written here rather than implied met.

**Why no form today.** A council is a consultation: zero standing footprint, so its synthesis is
an answer in a conversation, and there is no artifact for a gate to read. Every enforceable rule
in this corpus keys on a file — a staged commit, a row, a request. The declaration is real
guidance and unenforced guidance, which is the class this corpus keeps measuring at ~0/5.

**Revisit when** either becomes true: a council's synthesis is written to a file (the owner asks
to keep it, or a research flow persists one) — that file is the seam, and the gate is a
missing-declaration refusal with its mutant · **or** the next full round measures whether a
council fires with its price and its declaration at all, which would give the claim its date. If
a round shows the field is simply not written, the honest repair is to delete the sentence rather
than repeat it louder.
