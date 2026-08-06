# Process discovery — find the process, then the tools

**Load when:** the work is of a kind whose steps are not obvious — designing something, running a
launch, building a content operation, anything where "how is this done well" has an answer nobody
here knows yet.

**The failure this prevents is concrete.** Asked to design an app, a worker searched its skills for
*"designer"*, found nothing usable, and hand-drew gradient placeholders — **two to five minutes per
screen of garbage — while a flow library, a component library and a wireframing tool sat one
rephrase away.**

**And the fix is not a built-in design pipeline.** That is the encyclopedia trap: a hardcoded
ladder is right for one domain and wrong for every other one, and this system is meant to work for
a channel and a bakery too. **The fix is a repeatable step for discovering a process**, which is
why it is named once here and reused everywhere there is a *how* rather than a *what*.

---

## Five steps

**1 · Research how the craft does it well — not from memory.** The web, live documentation,
`awesome-{topic}`, and **the descriptions of skills that already exist**. For *"design a mobile
app"* this surfaces something like information architecture → user flows → low-fidelity wireframes
→ **the owner approves the structure** → high fidelity → design system. For a snack brand it
surfaces something else entirely. **You are finding *this* craft's process, not applying a stored
one.**

**2 · Draft it as a table — one row per step: `step · why · tool-or-gap`.**

The **why** is what lets the owner judge it — *low fidelity before high fidelity because approving
structure on cheap artifacts saves the days that redrawing finished screens costs*.

**The table is the form that cannot skip a step silently: every row must end in a tool line, and a
step with no tool IS a gap — written as `gap` in that cell, never left blank.** A blank cell reads
as "handled"; the word `gap` reads as what it is. This is form doing work that prose cannot.

**3 · Show the owner: cut, add, reorder — in their words.** This is where a designer who skips
wireframes gets caught, and where an owner who wants it faster can say so before rather than after.

**4 · Search a tool per surviving step, by the step's function.** Not one literal string. Use the
broadening ladder: rephrase into **the craft's own English terms** · go one level up to the parent
domain · adjacent crafts · **decompose the step into tasks and search per task**. *"Map the user
journeys"* finds a flow library; *"designer"* finds nothing.

**5 · Name the gaps.** A step with no tool is stated as such — build something for it, or do it by
hand **and say which**. **A gap named is honest; a gap papered over with improvisation is how the
garbage happened.**

---

## Record the process — into the machinery, not beside it

**A discovered process lands as a type and its pipeline.** `_ops/process/types/<kind>.md` carries
the definition of done and the cut on the description ladder — proposed at the type's wave —
and `_ops/pipelines/<name>.md` carries the stages and the gates **as data the door reads**
(`pipelines.md`, `writing-work.md`). So the next run of the same kind of work **starts from it
rather than rediscovering it**, the state block and the transition validator work from day
one, and a better process found later is **a diff to a file rather than a silent drift**.
Prose keeps the why; the files are the process.

That is the same reason decisions are recorded: not to have a record, but so the next person
argues with the previous answer instead of re-deriving it.

## The same five steps, run on a question

**Product discovery — *what do we know about the problem* — is this method pointed at a
question instead of a craft.** Its findings have three homes: **the spec's own fields** —
prior attempts with outcomes, open questions, the cost of doing nothing
(`templates/SPEC-template.md`) — **the interviews**, which walk the JTBD timeline
(`audience.md`), and **the choice**, which runs the decision loop. **A research type's own chain — facts → insights →
opportunities → recommendations, each layer carrying its confidence — arrives from the
craft's standards at the type's wave**, never as a built-in pipeline: the same
anti-encyclopedia law as everywhere in this file. **The opportunity layer is the one teams
skip**: an insight names what is true, an opportunity names a need it opens, and jumping from
insight straight to a solution is how a feature ships with no need under it — the discovery
spine the craft itself now teaches is outcome → opportunities → solutions → assumption tests
(`catalogue.md`, the frames row). **The tree those links form is a view, never a source** —
assembled from the specs' own references (`PATTERNS.md` §6), not drawn beside them.

**And discovery is a cadence, not a phase.** The craft's own practice literature
(`sources/` → perspective-ost-2026, `cited`): the commonest failure is not a wrong tree but
**a starved one** — evidence refreshed quarterly under opportunities that change weekly. Where a project runs product discovery at all, the stock
answer is an automation holding the touchpoint (`automations.md`), and interview evidence
carries its date like every other fact: past its recheck it is `unknown`, not background.

---

## This is one method, used in four places

The interview, the discovery checklist, the role builder and this file are **the same shape**:
research the real thing, draft it with reasons, show it for cutting, then tool each surviving
step.

Naming it once is what stops it being re-invented per situation with slightly different rules each
time — which is the whole argument for `PATTERNS.md`.

---

## When to reach for it

**When the process is not obvious**, and specifically:

- the work is in a craft nobody here has done
- a previous attempt **improvised and the output was bad** — run it on the redo, and it names the
  steps and the tool each needs rather than one worker winging it
- the owner asks *"how should we run this kind of work?"*
- a step keeps producing bounced reviews, which usually means a missing step earlier

**When not to:** a quick job, and anything whose process is already written down and working.
Discovering a process that exists is ceremony.
