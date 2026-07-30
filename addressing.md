# Addressing — asking someone for something

**Load when:** work needs a craft nobody in it has, a question needs an expert or a real person,
or a task must find an owner.

**Addressing and assignment are different acts.** Addressing is **the ask, and it may go to a
group**. Assignment is **accountability, and it is always exactly one**. A platform that
collapses them needs a leader to convert one into the other; splitting them means a **rule**
does that instead.

---

## Address the group, never the guessed person (`PATTERNS.md` §19)

State **what you need and why**; the group's **routing rule** decides who. Two reasons, and the
second is the load-bearing one:

- The caller should not have to guess who is right for it.
- **The caller should not have to know the roster** — which is what lets the roster change
  without rewriting every mention that ever pointed into it.

**Routing may return several for a question; exactly one for an assignment.** That is where the
**aggregation rule** earns its keep: it is how several answers become one.

**A group whose routing returns everyone is expensive by construction** — each respondent is a
run and a line in the ledger. That is a property of the group, not an accident of the call.

## Groups: teams and cohorts

| | **Team** | **Cohort** |
|---|---|---|
| Holds | workers | experts · personas · humans |
| Routing produces | an **assignee** | a **respondent** |
| Members assignable | yes | **never** |
| Extra field | — | **`made_of`** — `synthetic` · `live` · `mixed`, deciding what may be claimed about the result |

Both carry `routing` (by-craft · round-robin · first-free · all) and `aggregation`. **Neither
has a leader** — routing and aggregation are what the leader used to be, and accountability
sits with the gates.

**A role may not be in two groups of the same kind.** Ambiguous inheritance is worse than
duplication: two parents mean two guides, two skill sets and two background colours.

**These are not the harness's teams.** Ours are durable groups in files, invisible to the
runtime; the harness's are the live sessions of one session, deleted when it ends. Our routing
is read by the advisor, which then spawns a worker — so **our team structure costs nothing at
runtime** (`GLOSSARY.md`).

---

## A mention opens a conversation, not a task

A mention is a **bridge** (`PATTERNS.md` §18): its outcome is open. Most end in an answer and
create nothing. The ones that cross — *"yes, let's do it"* — **seed work and leave the
conversation as it was**. There is no mode to switch and nothing to register.

**A mention carries what you need and why.** Without it the called party reconstructs the
context by opening the task, reading the thread and guessing — **paying in tokens for what one
sentence would have carried**. A bare `@design` is the same failure as a batch line with no
reason.

**The one who agrees creates the subtask.** The owner appears at the moment of agreement rather
than being assigned from outside — which is also how a leaf gets an owner without anyone
deciding on its behalf.

**Participants are discovered by the conversation, not planned.** Halfway in it turns out
someone else is needed, and the next group is mentioned **from the thread**, in a chain as long
as it takes. Three consequences:

- **The list of touched groups is not a field filled at creation.** Requiring it up front means
  requiring knowledge the author does not have — the guess that shaping exists to prevent.
- **It is the same mechanism as the fit-check, from the other side.** The receiver says "not my
  craft, here is a suggested owner"; the caller says "we also need this one". Both turn
  uncertainty into composition instead of into a guess.
- **Discovery has a price and it must be visible.** Each mention is runs and ledger lines. A
  long chain in one thread is legitimate work — and its cost shows where every other cost
  shows.

**Mention only those whose answer changes something at this stage.** "Touches four groups" is
four validation runs, an owner's deliberate choice, and a line in the ledger.

## The same shape everywhere

| Caller → called | Bridge leads to |
|---|---|
| owner → team | a task |
| assignee → another team | a subtask |
| agent → expert | **an answer** — experts are never assigned |
| agent → persona | **a reaction**, direction-only and marked |
| agent → human | **an answer**, on human time |

The type does the enforcing: a mention of an expert or a persona **cannot become work**, because
neither is assignable. → `audience.md`

**Live people answer in days, agents in seconds.** A live consult **must never silently hold a
gate running at agent speed**. Name the trade-off out loud — a separate stage, a deadline, or
"proceed on what we have and revisit when the answer lands" — because the alternative is work
hanging on people **who do not know they are blocking anything**.

## Which container

**Inside a task** → the task thread, which lives in the task file and ends when the task does.
**Outside one** → a DM. There is no third container, and **team-wide broadcast is deliberately
absent**: a task is discussed in its thread, an opinion is asked of someone.

**Attachments dropped in a task thread become task resources** — registered, carrying a `why`,
link-checked, and surviving the thread's rotation — distillation at rotation is `PATTERNS.md` §12. A screenshot that only exists in a rotated
archive is the "private tool became the only place the finding exists" failure.
→ `resources.md`

---

## When the exchange will not converge

**Rounds are bounded.** Past the limit the exchange stops rather than continuing, because the
tokens are real and the disagreement is not converging.

**Try the aggregation rule first** — it exists precisely to make several member outputs into
one, and this is the moment it is for.

**Then escalate, as a request.** Not a louder message in the thread: a request has an age,
lives in the attention view, and can be answered later (`requests.md`).

**And frame it correctly, because this is the part people get wrong:** a third round on one
point is a **spec problem, not a quality problem**. The escalation asks the advisor to **settle
what "done" means here** — not to judge who is right. → `escalating.md`

**The evidence is free.** Thread exchanges are runs, so "this disagreement cost X across N runs"
is an ordinary group-by. The bound holds by **measurement**, not only by counting rounds.

---

## Interrogating well

An agent that receives an ask should **ask enough to know whether it is theirs** before starting
— that is the step before the fit-check's "not my craft, handing back", and it is much cheaper
than handing back half-finished work.

Find the questioning skill in this order, and the order is about gates rather than convenience:
**the project's own skill pool** → the curated sources → a broader search. **A skill from the
pool is already screened, carries provenance and is paid for**; an outside one costs the full
import gate again. → `skills.md`

---

## Naming

**Groups are named by function** — `Design`, `QA`, `Experts` — because a group name is read as a
destination.

**Individuals carry a short human name** plus their position: four handles in all — name ·
position · grade · description — so the owner can find someone by any of them, including "the
one who does landing pages", which resolves through the description.

**Names must be unique, and this is not a preference.** The harness loads subagents by `name`
across the whole tree, and **a collision is resolved silently by filesystem order** — no error,
no warning, and the wrong worker runs. Uniqueness is checked at creation and a duplicate is
refused with an alternative offered.

**Latin characters by default**, because the name becomes a slug and a path. Cyrillic is
possible and is a **known untested area** (`evals/new-scenarios.md`) — a flag, not a ban, and it
is removed by a test rather than by a decision.
