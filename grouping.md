# Grouping — releases, milestones, order and progress

**Load when:** planning what ships together, marking a checkpoint, reordering the backlog, or
answering *"how far along are we"*.

---

## Release and milestone are different things

| | **Release** | **Milestone** |
|---|---|---|
| What it is | a **shipment** | a **checkpoint** |
| Leaves the building | yes | **maybe nothing does** |
| Has a version | yes | no |
| Gets measured afterwards | yes | no |
| Target date | yes | **optional** |

*"Data migrated"* and *"first ten customers onboarded"* are milestones: real progress, nothing
shipped. **Forcing a date onto "when it's done" produces theatre**, so the date is optional and
its absence is not a defect.

**They are orthogonal, not nested.** A task carries a `release` and a `milestone` independently.
Neither contains the other, because containment would create **two paths from a task to a group**
— directly and through the other — and two paths to one fact drift.

**Which releases closed a milestone is derived**, not stored: a generated block lists the
releases its tasks landed in. That gives *"Alpha closed across v0.1–v0.3"* with no second
membership path.

**A milestone that outgrew itself is promoted, not nested** (`PATTERNS.md` §23). Spanning many
releases and months usually means it has become an initiative in everything but name — and
promoting it costs one field, while nesting it costs a level in every rollup forever.

---

## Progress is derived, never stored

**The same computation at every level** — subtask, task, milestone, release, project. Something
with no children has no progress block.

**It counts items and says so.** *"Five of nine"*, never *"56% done"* — **the nine are not
equal**, and a percentage claims they are.

**Canceled and triage leave the denominator.** Work that was dropped is not progress you failed
to make, and intake nobody has decided on was never committed.

**Show what is unassigned.** A denominator that includes work nobody owns reads as progress that
is merely slow.

**Report pace, not position.** *"Three closed this week, six left"* answers a different and better
question than *"56%"*.

**The parent never closes itself** — unless it carries no definition of done of its own, in which
case it is a folder → `decomposing.md`.

**Scope movement is recorded, because otherwise progress appears to go backwards.** Add four
tasks to a milestone and *"5 of 9"* becomes *"5 of 13"*: honest, and unreadable as anything but a
team that stalled. So joining or leaving a group is an entry in the task's history, and the
progress block shows **two numbers**: how much is done, and **how much the total has grown since
it was set**. Closing work and adding work then look like the different things they are.

---

## Order is one hand-kept list

**Priority is not the order** — it is a property of one item; order is a relation between items.
Two sources of order drift within a week and then nobody knows which is true.

So the real order between items lives in **one list the owner keeps**, and everything else —
priority, dates, scores — is input to it rather than a competing answer.

**Dates beat priority, and dates and scores answer different questions.** A score ranks **what is
worth doing**; a date says **when it stops being optional**; an external commitment wins outright.
Say which rule applied, out loud, when they disagree.

---

## Prioritisation is the decision loop with numbers

This is the one place unsourced figures slip in wearing the clothes of rigour.

**Pick the framework per task and say why.** ICE by default. Reach for something else when the
context demands it — a reach-weighted score when the reach is known and the data exists; a
delight-versus-baseline split when the question is what to build at all; a scope negotiation
scale when the conversation is with a client. **A framework the user names is researched and
applied the same way** — the list is seeds, not a ceiling. And if the named one is wrong for this
task, **say so with an alternative**: disagreeing when the evidence disagrees is the same law
here as anywhere.

**Every score cites its basis or is marked a judgement call.** Impact from analytics, tickets or
revenue; ease from comparable past work in the ledger. A number with no basis is an opinion
formatted as data — and formatting is precisely what makes it persuasive.

**Then test whether it survives being wrong: move each score by one.** If the top reorders, the
result is **undecided, and reported as undecided** — not presented as an answer. This is the
decision loop's "check it survives being wrong" step, applied where it is easiest to skip.

**Close the loop when the work lands.** Compare **the impact predicted with the impact that
arrived**. Without that, scoring never improves — it just accumulates.

---

## Releases

**Group tasks into a shipment**, cut it, measure it. The ritual is in `shipping.md`; what belongs
here is the surgery:

**Cutting a release** sends its unfinished items back to the backlog rather than deleting them.
**Extending one** pulls items in explicitly. **Reprioritising** re-runs the scoring pass over the
set. All three are ordinary decisions with reasons, and **a slip is a recorded decision, never a
silent edit to a date**.

**Batch, don't drip** → `shipping.md`. Pool
small changes; ship an urgent one alone.

**Version with meaning:** a patch fixes without changing instructions, a minor adds a capability,
a major means existing projects must do something differently — and **the changelog says which,
because it is the migration map**.

**Non-code work has no branches**: the version is a date or an edition. The batching and the
audience-facing note are identical.
