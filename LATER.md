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

## A generated Opportunity-Solution-Tree view over the specs

**Deferred because** the layers already have homes — outcome and measures in the spec,
opportunities in the research chain, solutions as specs and tasks, assumption tests in the
plan-per-outcome — and the tree is declared a view over those links
(`process-discovery.md`), which prose can hold until somebody actually asks to *see* it. A
generator (mermaid between markers, `PATTERNS.md` §6, same shape as `touched by:`) is a day
of work with no requester yet, and a view nobody reads is furniture.

**Revisit when** the first project running product discovery asks to see the tree, or a
review finds a solution shipped with no opportunity above it — the miss the view exists to
make visible.

## A `pack` mode for the inventory script — context from declarations, not from the tree

**Deferred because** the spec-format release (2026-08-05) ships `scripts/inventory.py` for the
raw-tree case only — join, migration, import — where no declarations exist yet. The other mode,
assembling a dispatch pack from a task's own declarations (map nodes → files, linked docs), has
no measured need: runtimes read files themselves, and a pack is a context-budget optimisation
nobody has yet hit the ceiling to justify. The CLI is shaped so `pack` can arrive as a second
mode of the same tool, not a second tool.

**Revisit when** a dispatch fails or degrades on context budget on a real task — the second
occasion is the bar — or a runtime lands in `runtimes.md` that cannot walk a tree on its own.

## `starts: webhook` — an external trigger the automation can declare

**Deferred because** there is no server: a declared listener with nothing listening is a
configuration that lies, and the honest version needs a hosting story before the syntax. The
shape is settled — a declaration beside `schedule:<cron>` on the automation, executed by
whatever host has a listener, under the law that already governs schedules: *one that silently
did not run is worse than one that says it was late*. Dify and n8n both landed on
trigger-as-declaration, which confirms the form and nothing else.

**Revisit when** the first project asks for an event-started automation, or a runtime/hosting
in `runtimes.md` grows a webhook surface that could actually hold the listener.

## A wave's failure policy — `continue-on-error` for children

**Deferred because** the current default is right: a failed child escalates and the barrier
stays closed, and nothing proceeds quietly. A declared per-wave policy ("close the barrier
without the failed child, carry the successes") is a real mechanic — Dify's iteration modes are
the one occasion seen — but one occasion is a coincidence, and a setting stocked for a
hypothetical is the drift this file exists to refuse.

**Revisit when** a second real wave needed to continue without a failed child and could not —
twice is the evidence bar.

## ~~Project-local skills must survive an upgrade that ships a same-named stock skill~~ — reopened 2026-08-05, taken into the release

**Its own trigger fired the day it was written**: the owner read the entry and took it into the
spec-format release (batch 6, beside the screener work). The rule it called for is the one being
added: **local wins, upgrade never overwrites it, and the collision is surfaced rather than
silent.** Kept here because the check that produced it is evidence: `upgrading.md` protects the
owner's *conventions*, and nothing protected their *files of the same name* until this.
