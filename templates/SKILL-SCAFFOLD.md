# Skill scaffold — the modular shape every skill is born with

*Used by the skill lifecycle (`/opsinist skill create`, the guide, tooling skills). A skill made
inside a project follows this from day one — modularity is cheap at birth and expensive at
500 lines.*

## The shape

```
<skill>/
  SKILL.md          # the CORE — always loaded, budgeted, mostly a router
  <topic-1>.md      # companions — loaded only when their trigger fires
  <topic-2>.md
  scripts/          # optional: checks and helpers (never required reading)
```

## The core (SKILL.md) — a router, not a manual

- **Set the line budget at creation** and write it in the frontmatter (`core_budget: N`).
  Guidance: 100 lines for a tool skill, 200 for a role skill, 500 only for a full
  methodology. The budget is a *cost decision* — the core is paid by every run of every
  agent that carries the skill.
- Contents: **when to act** (triggers), **the rules that govern every use**, and a
  **routing table** — `| Load… | …when |` — pointing at companions. Procedures, examples,
  reference tables live in companions, never in the core.
- **Full at birth is a design smell.** If the first draft hits the budget, the skill wants
  a companion or wants splitting.

## Companions

- One topic per file, named for the trigger ("when X happens, read Y").
- A companion may be long — it is only paid when its trigger fires.
- Cross-reference by filename; never duplicate a rule between core and companion (one home,
  the other points).

## A prompt-shaped body: identity → steps → output

Where a companion (or a whole small skill) *instructs a run* rather than documents a rule,
its body keeps one order — **who is speaking and to what end · the steps, in the order they
are performed · what the output must look like** — because the three failure modes of a prompt
body are exactly a muddled voice, steps out of order, and an unstated output shape. (The
shape is Fabric's, MIT, proven across 200+ patterns; the provenance rule applies as ever.)
Rules-documentation keeps its own shape; this section is for the bodies that are prompts.

## When the budget is hit later

Move, don't squeeze: the newest rarely-needed block becomes a companion, and the core keeps
one pointer line. Compression (`/opsinist skill optimize`) is the second resort, deletion the
third; raising the budget is a decision with a stated cost, not a reflex.

## Growing out

A companion that other agents want on its own = a candidate for its own skill. A skill that
proved itself across projects = a candidate for release (PLAYBOOKS → Release). This scaffold
makes both cheap: the seams already exist.
