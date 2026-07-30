# Dispatching — sending work out and recording what happened

**Load when:** starting work on a task, running several things at once, or answering *"what did
this actually cost"*.

**Assignment and dispatch are different acts.** Writing `assignee:` into a file is an edit and
costs nothing. **Dispatch is what spends** — a run starts, tokens move, and a line is appended to
the task's history. Keeping them separate is what makes it safe to bring in four hundred imported
tasks and decide ownership afterwards.

---

## Resolving what to run with

Model, effort and fast mode resolve by the one cascade — **project → team → role → task**, most
specific wins — and **the resolved values are recorded on the run**, so *"why did it cost that"*
has an answer later (`PATTERNS.md` §1). They land in the harness's own fields, so the resolution
ends in the runtime rather than in a private mechanism.

**Every task may resolve to a different model, and that is the ordinary case.** The advisor runs
on whatever the session runs on; a worker resolves its own at dispatch; a per-task override is one
dispatch and does not rewrite the role. So a project can have a top tier writing the specification,
a cheap tier doing the repetitive half of it, and a persona at low effort reacting to the result.

**They never talk to each other, which is what makes that safe.** Agents do not hold a
conversation — **one writes to a thread in a file and another reads it later**, so nothing depends
on two of them being alive at once, on the same provider, or on the same runtime. A handoff is a
commit. That is also why a mixed team survives one of its models being unavailable: the thread is
still there.

**What travels between them is the text and its rung, never the reasoning.** Agent B reads what
agent A wrote and the evidence rung attached to it — and **may not promote a `recalled` to
`measured` by quoting it**, which is the most common way a guess becomes a fact inside a team.

**Which models exist is the fastest-rotting fact this system depends on**, and it is the one the
corpus must never hold. A roster written into a file is wrong within weeks — a new tier lands, a
name changes, one is retired — and a role pointing at a model that no longer exists fails at
dispatch rather than at review.

**Ask the runtime first; it is the only authority on what you can actually run.** A provider's
announcement says a model exists; the runtime says whether *this* account, on *this* plan, can
reach it — and those differ often enough that the second is the one that matters. Its own listing
or `--help` is the register here, and this is `look inward first` applied to a moving target.
**Only when the runtime cannot answer does the question go outward**, to the provider's current
documentation, fetched rather than recalled.

**Reuse within a session is not caching; persisting is.** A figure fetched twenty minutes ago in
this same conversation may be used again — **carrying the timestamp of the fetch, never of the
reuse** — and a thread that already holds the answer with its date is the cheapest place to find
it. What is forbidden is the durable version: a model roster, a price or a limit written into a
project file as a current fact. If it lands in a file at all it lands as a **dated snapshot**,
which is a `cited` claim and honest exactly as long as it says when.

**Re-fetch when the answer would change the decision, not when someone insists.** Choosing a tier
for a role, quoting a price, or telling the owner a model exists are all decisions that turn on
it. *"What did we say last week"* is not. And **the date travels with the figure every time it is
quoted**, so the owner can judge its age without asking.

**Model and effort interlock.** They are two dials, not one: the tier decides how capable the
reasoning is, the effort how much of it is spent. **A cheaper model at high effort often beats a
dearer one at default** — which is why effort is set alongside the model, not later.

**Effort levels are per model, and the same lookup answers this.** A role can declare a level its
model does not have, and **the fallback is silent** — which is exactly why it must be warned about: *a role that believes it
runs at the top level and does not is a lie in a file*. A model the table does not know is
**unknown, never unsupported**; project-local aliases are the normal case.

**Record what answered, not what was asked for.** The same silence, one layer down: a gateway's
selling point is **falling back to another provider when one is down**, so a run can request one
model and be served by a different one. Write the requested name into the record and it says a
thing that did not happen — **and nothing detects it**, because the request is the only place
anyone looked.

**Three things break together when it does.** *"Why did you decide that"* is answered from a record
naming the wrong model. **Cost is computed at the wrong rate**, so the ledger and the invoice
disagree with no visible cause. And **trust is earned per role from its own run record**
(`permissions.md`), so the evidence a role is judged on is attributed to something that did not
produce it.

**The fix is to read the response rather than assume the request.** A gateway reports the model
that actually ran; take the name from there. **Where the response does not say, the record says
`unknown`** — never the requested name, which is a guess wearing a measurement's clothes.

**Effort runs backwards for personas.** For a worker, more effort is a quality lever. For a
persona it is a **realism lever pointing the other way** — a real user does not deliberate for
thirty seconds over a landing page; they skim and leave. A persona at maximum effort writes a
thoughtful review no actual user would write: a tidy falsehood. Default **low**, raised only when
the thing being simulated genuinely is a considered decision.

**For experts, effort behaves as it does for workers** — they produce judgement, and thinking
improves judgement. The trap there is different: **effort is not a substitute for sources.** An
expert at maximum effort with nothing to cite produces very convincing invention, which is why
the bar for an expert is the sourcing rule, not the dial.

---

## Running several things at once

**Parallelism is the wave, not the task list.** Children in the same wave are genuinely
independent and run together; the numbers order **dependencies, not tasks** → `decomposing.md`.

**Isolation is the runtime's, not ours** — and **not every runtime has it** → `runtimes.md`.
Where it does, parallel work runs in its own worktree, so two workers editing different areas
never collide; where it does not, **a wave serialises** rather than quietly sharing one tree. What remains ours is the rule that makes a wave safe:
**two children in the same wave never own the same file.** Ownership is assigned at decomposition,
not discovered at merge.

**A worktree sees committed state, so the brief must be committed before the dispatch.** A task
file written and left uncommitted does not exist for the worker sent to do it, and the failure
arrives disguised: *"I cannot find my task"* reads as a broken dispatch rather than a missing
commit, and the obvious next move — writing the file again — does not fix it either. **Commit the
task, then dispatch**, and where a wave is dispatched together, commit the whole wave first.

**A task that needs the live checkout declares itself `exclusive`** and takes a lock. Exclusive
tasks serialise with each other **and with nothing else**.

**A turn cap belongs on the role.** The runtime enforces it, and it stops a runaway long before a
budget notices — a budget measures money after the fact, a cap stops the loop.

**Width has a ceiling that is judgement, not a limit.** Past roughly three to five concurrent
workers, coordination costs more than it returns. The same number appears independently in the
harness's own guidance, which is mild evidence it is about coordination rather than about either
system.

**Dispatch what would otherwise block the conversation — and this is every agent's rule, not the
advisor's.** Asked something in a thread or a direct conversation whose answer needs twenty
minutes of reading, an agent **says it is going to look and comes back with the answer**, rather
than leaving a question sitting unanswered while it works. A reply that arrives late with
substance beats a silence that looked like a reply being typed.

The advisor is the owner's only session, so work that runs for minutes belongs in a worker even
when a worker is not strictly needed — **the point is not parallelism, it is that nobody is
held**. Say what was sent,
roughly how long, and how to see it; the result surfaces where results surface rather than
interrupting whatever the conversation moved on to.

**A subprocess is tiered by its own work, never by its parent's.** An agent on the top tier
spawning a helper to grep a directory should not spawn it on the top tier — **capability does not
inherit downward, it is chosen each time**. Verification, search, extraction and bulk
transformation go a tier down or further; only the reasoning the parent could not do itself earns
the parent's tier. **The default of "same as me" is the most expensive default available**, and it
is invisible in the bill because it looks like ordinary work.

**Two things do not go to the background.** Work whose answer the next sentence depends on —
sending it away only to wait for it is the same block with extra steps. And **anything holding a
gate**: a run that will stop for a decision has not saved the owner a wait, it has moved the wait
somewhere they are not looking.

**When it overruns, say so before being asked.** An estimate is a promise about attention: *"this
is past the two minutes I said — it is on the third file of five, still moving."* **Having
estimated and then gone quiet is worse than never estimating**, because the owner now has a
contradiction to interpret and the cheapest reading is that something broke.

**A task must fit one run.** Work that cannot finish in one is **decomposed, not hoped through**.

---

## The run record

Every dispatch appends one line to the task's history.

| Field | Why |
|---|---|
| started · ended · duration | the shape of the work |
| role · **model · effort · fast** | the resolved cascade — the answer to "why did it cost that" |
| trigger | a person, a schedule, an event, an automation |
| outcome | `completed` · `failed` · **`interrupted`** · `canceled` |
| reason | when it is not `completed` |
| attempt | the price of not getting it right the first time |
| commits · checkpoint | where the work landed, and where to resume from |
| **tokens as four numbers** | `input` · `output` · `cache_read` · `cache_write` |
| tool uses | shape, not content |
| **`skills_available[]` · `skills_used[]`** | declared against used |

**Four numbers, not one total.** Cache reads are the overwhelming majority of tokens, and a
single sum hides exactly that — which means it also hides the one lever that actually moves cost.

**Declared against used is the point.** A skill attached for months and never used is dead weight
in every brief that carries it, and this field is the **evidence** for saying so rather than an
opinion about it.

**The numbers come from the harness's own transcript**, harvested by script and written into the
repo. The transcript is a **source, not a dependency**: only the result is committed, so
`project = f(repo)` holds. One detail that bites: **the transcript path is derived from the
working directory**, so an isolated worker writes somewhere else.

**A run that never returned is marked `interrupted`, and the task visibly regresses** →
`recovering.md`. A board that "went backwards overnight" is reporting a failure, not somebody's
edit.

---

**What the record is *for* is a different question** — the slices, the envelope, the two bills
and what actually moves the number → `cost.md`. This file writes the atoms; that one reads them.

---

## Terseness

Compressed reasoning is a real lever and it **cascades like everything else**, down to the task,
because the same role writing a commit message and writing a status report wants different
verbosity.

**One boundary, or it goes wrong immediately: terseness applies to reasoning and to exchanges
between agents. Anything a human reads follows the writing rule instead** — first line is the
point, lists over prose, **readability rather than brevity**. Terse trims words; readable shapes
them to be scanned. A status report arriving in compressed notation is the failure this boundary
prevents → `writing-for-humans.md`.
