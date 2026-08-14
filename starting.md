# Starting — standing a project up

**Load when:** there is no project yet and something should be built.

**Build nothing before answers.** The interview is not paperwork; it is what stops a team being
assembled around a guess.

---

## Where the code lives — ask, never assume

**This is the first question and the one with the sharpest edge**, because getting it wrong
touches something that is not ours.

**One is read, the rest are proposed** (`PATTERNS.md` §26) — asking all three in a row is how a
first contact turns into an interrogation:

1. **Does a repository already exist?** **Read it, do not ask it.** If one is here, use it — do
   not start a new one beside it.
2. **Otherwise, state the proposal and let them nod**: where it would go, whether there is a
   remote, and under which account — *"a local repo here, no remote yet; say the word and I'll
   put it on GitHub under `<account>`, private."* The defaults below are defensible, so they are
   stated rather than asked.

**Creating a repository is an outward action on the owner's account.** It lands under whatever
identity their git is authenticated as, and **that is often their employer's**. So it is
confirmed out loud, **naming the account**: *"this would create `acme-corp/thing` under your work
account — the right one?"*

**State the visibility as you create it** — *"creating it private"*. Repositories are private by
default, and **making one public is itself an outward action**, confirmed like any other, never a
silent flip.

**A local repository with no remote is a legitimate end state**, and the correct default when the
owner is unsure. Nothing here requires a remote except what the git-host adapter provides —
branch protection and pull requests.

---

## Shape the work before proposing a team

**A project is sized to a plan, not to a sentence.** Staffing from *"an app that fixes X"* produces
the team that sentence suggests, which is a guess.

**"Defaults" does not skip shaping.** The shaping questions have no defaults to take — **they are
discovery, not preferences**. Only a quick job skips this entirely; shaping an hour's work is the
ceremony this whole system exists to avoid.

**What it is and who it is for — and the question that changes everything: what is hard about it.**
**Uncertainty is research information**: an unknown gets investigated before it gets someone
assigned to execute it.

**What the work is made of.** Name the surfaces **in this domain's own words and stay in them** —
screens, services and data for software; recipe, packaging, supply and retail for a food brand;
scripts, filming, edit and thumbnails for a channel. **Each surface is a craft, and crafts are what
you eventually hire.** Never import another domain's vocabulary: *nobody making chips needs to hear
about data flows.*

**Rough size, honestly held.** Not points — what kinds of work exist and roughly how much. *"Two
screens"* and *"a sync engine"* staff differently. **"I don't know yet" is a valid answer, and it
argues for starting small.**

**Then say the shape back, with its why**, and let them argue with reasoning they can see.

**And re-run it when scope changes materially** — the same signal a utilization review gives,
arriving earlier.

**What shaping does not produce is a roster.** It produces understanding: what is hard, what the
surfaces are, what the first tasks are. **Roles are still hired one at a time, when a task needs a
craft nobody has** → `hiring.md`. A team proposed at the end of shaping would be the batch hire
this system exists to avoid — and the understanding is what makes the first hires obvious rather
than speculative.

---

## The interview

**Waves of three or four, each with its default visible**, and the next only after the previous is
answered → `arriving.md`.

**Two hard gates, never skipped: control & expertise, and governance.**

**The rest, with defaults that work:**

| Topic | Default |
|---|---|
| **deliverable and repo shape** | one repository; several deliverables inside it are **areas**, not projects |
| **which crafts** | only the ones this project names |
| **definition of done per craft** | objective gates — tests and review for code, fidelity and accessibility for design, fact-check for content |
| **stage ladder** | build → review → accept, with design in front where design precedes build, and **parallel gates inside review** |
| **capability and cost** | **the tier is model × effort, asked together and in outcome terms** — stronger, medium, light — because **a cheaper model at high effort often beats a dearer one at default**. Presented as a prompt, never a menu: a free answer wins |
| **what you already use** | **asked outright, before anything is proposed** — skills, servers, tools. Discovering them on day three means the team was built around a worse choice. Each goes through the import gate |
| **integrations** | inventory first, connect-or-create per service → `tooling.md` |
| **how documentation is written** | markdown, **laid out to open as a vault** — relative links and diagrams, readable both on the host and locally. *Where* it lands is the storage form, asked before the first lasting write → `storing.md` |
| **how work gets described** — **asked only when the deliverable is code or a long-lived system**, skipped everywhere else | **the floor**: a task states its result and its definition of done. **The question is where to cut the ladder**, offered in one question with its consequence, never as a menu of names — a document the task points at and closing updates, **a checkable artefact written first** — a failing test, a golden sample — with a format the project already runs **bound** rather than invented, and the stocked options named → `writing-work.md`, `catalogue.md`. **Asked rather than defaulted because it decides what every task looks like**, and a project that answers it on day ninety rewrites every task it has written. **Each type refines the cut at its own wave** → `pipelines.md` |
| **modules** | everything beyond the invariants is off until asked for |
| **language** | conversation language and artifact language, **which may differ on purpose** |

**Every "no, not now" lands with a revisit trigger that is a moment, not a date.**

**"You decide" is offered the moment it drags** — and it never answers the non-delegable: where
the code lives, whose account, credentials, anything bound to the owner's identity. Those go on a
waits-for-owner list.

---

## What gets created

**The advisor, and nothing else.** No roster, no squads, no design lead before the first task
exists. A role is created **when a task needs a craft nobody has**, and the reason is said at that
moment.

**Four things and the first task. That is day one, and the list is short because it was
measured.**

| Created now | Why it cannot wait |
|---|---|
| **the project guide**, generated into the root instruction file | every worker loads it natively; without it nothing that follows is read |
| **`_ops/config.md`** — the git-host adapter, `schema_version`, and **the migration log opened with its first line** (`— → <version> · <date> · applied · <who>`) | a project born without the log reads forever as one that was never migrated → `upgrading.md` |
| **the pre-commit guard, with the doors beside it** — the guard from `templates/company-preflight.sh`, the doors from the skill's `scripts/transition.py` and `scripts/new-id.py`, all three into `_ops/scripts/` | it is what makes every other check real — and its §14 refusal **names the door**, so installing the refusal without the door strands the very next commit → `project-layout.md` |
| **branch protection where a remote exists** | a review gate without it is a sentence, not a gate |

**And the first task — which comes *before* the rest of the machinery, not after it — with its type's file and ladder**, because the type proposes the task's fields at its birth and the ladder is what the door reads.

**Everything else arrives when it has something to hold.** `_ops/DECISIONS.md` at the first
decision · `_ops/LATER.md` at the first deferral · `_ops/TEAM.md` at the first role · `_ops/ROADMAP.md`
when there is a roadmap · `_ops/TOOLING.md` at the first tool worth a runbook · `_ops/FIELD-NOTES.md` at the first friction or the first sweep · further
process files when a task of a new kind needs a ladder or a gate. **A document created before it has content is
a file the owner has to read past for the rest of the project's life.**

**This was measured, and the number is why the list above is four lines.** On the tier an owner
actually uses, standing a project up took **11–13 minutes of the advisor's own time across three
turns** — with *"defaults"* answered to everything, the fastest path there is — and produced
**ten to thirteen files before any work existed**, with the first task appearing in the second
turn in one run and **the third in the other**. The interview was not the cost: the first turn was
under ninety seconds. **The cost was building a project's worth of scaffolding before there was a
project.** An owner who came to write code spent that time watching documents be created for
things that did not exist yet — a `TEAM.md` before a team, a `ROADMAP.md` before a roadmap.

**A hook holds the order**: while no task file exists, writes into `_ops/` are refused, and
the refusal names the first task as the thing to do instead. The
outputs of *reading* a repository — the architecture note, the product map, a debt list — are
exempt, because a takeover produces those before it has any tasks at all.

---

## What good looks like on day one

**Nothing had to be configured except the two hard gates.** Every other setting had a default good
enough to leave alone.

That is not an aspiration — **it is testable**, and it is the first eval scenario for exactly that
reason: every setting this system has added since its predecessor pushes against it, and the test
is what keeps the pressure visible → `evals/new-scenarios.md`.
