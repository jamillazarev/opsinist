# Escalating — where a stuck agent goes

**Load when:** an agent cannot proceed, an exchange will not converge, or the same failure keeps
repeating.

Not a setting — **a chain, with typed fast lanes**. The other sense of the word, *when work stops
and asks the owner*, is configured and cascades → `permissions.md`.

---

## The chain

**agent → expert (optional) → advisor → owner.**

The agent tries the obvious recovery first — retry differently, read the file it skipped, consult
its own resources — then hands up **with a state inventory**: what it tried, what it observed,
what it needs.

**The expert rung is optional and often skipped, and it should not be.** Experts exist precisely
to be consulted; without this rung the owner gets asked things a hired expert was hired to
answer. Where the project has an expert or a cohort covering the domain, the question goes there
before it goes up.

**The advisor is the routing and aggregation owner**, so an unresolved disagreement between two
roles reaches it directly. There is no rung between them, which is a consequence of teams having
no leader — and it makes the path shorter rather than longer.

## Fast lanes — straight to the owner

Because the advisor cannot supply these anyway:

| Class | Why it skips |
|---|---|
| credentials, access, permissions | only the owner can grant them |
| anything destructive | never delegated, in any preset |
| a decision the owner reserved | by definition |
| a limit or quota reset | nothing to do but wait, and whether to wait is the owner's call |

---

## Bounded, not endless

**Three attempts on one task stop it.** Then it is reassigned or escalated — an agent that keeps
trying is spending the budget on the same wall.

The count is **per task, not per "the same error"**. Deciding that two errors are "the same" is a
judgement an agent makes about its own failure — a guess wearing the shape of a fact, and exactly
the bias the output checkpoint warns about. Per task is countable, already recorded as `attempt`,
and therefore `enforced_by: validator` rather than prose.

**A third round on one point is a spec problem, not a quality problem.** This is the most useful
line in the file, because it changes what the escalation *asks for*: not *"who is right"* but
**"settle what done means here"**. Arbitration between two readings produces a winner; settling
the definition produces a task that can finish.

**An exchange in a thread is bounded the same way** → `addressing.md`. Try the team's aggregation
rule first — it exists for exactly this — and only then escalate.

**The evidence is free.** Exchanges and attempts are runs, so *"this cost X across N runs"* is an
ordinary group-by. The bound holds by **measurement**, not only by counting.

---

## Every escalation is a request

Not a louder message in a thread. A **request** (`kind: question` or `decision`) has an age, sits
in the attention view, and can be answered later rather than living in a conversation that
scrolls away → `requests.md`.

This applies to everything that needs an owner's decision, and the places that most often get it
wrong are the ones that produce **reports**: an audit finding, a link that cannot be repaired
unambiguously, a deadline at risk, a proposal to replace a skill. All of them are decisions, and
a decision in a report lives until the end of the scroll.

**And the work must not look alive while it waits.** A task escalated to the owner is `started`
with a blocker, which on a board is indistinguishable from work in progress. It carries a
`waiting_on` so it **ages like a request** rather than sitting there looking busy.

---

## When the answer is "the deadline will slip"

Detection is easy; the temptation is to fix it silently. Two rules:

**Nothing is reprioritised automatically.** Moving other work to protect a date is an automatic
transition and a change to an ordering the owner keeps by hand — two laws at once.

**Propose instead, in one concrete sentence:** *"to hold the 29th, these three would have to
move — approve?"* At most two options. And it is a **request**, not a comment, because a comment
about a slipping deadline is exactly the thing that gets scrolled past.

**A slip itself is a recorded decision**, never a silent edit to a date.
