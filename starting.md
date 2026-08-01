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
| **how work gets described** — **asked only when the deliverable is code or a long-lived system**, skipped everywhere else | **outcome-first**: a task states its result and its definition of done. The alternatives are offered in one question with their consequence, never as a menu of names — a spec the task points at and closing updates, or a format the project already runs, in which case the stocked options are named rather than invented → `writing-work.md`, `catalogue.md`. **This one is asked rather than defaulted because it decides what every task looks like**, and a project that answers it on day ninety rewrites every task it has written |
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

**The invariants**, which are small: the project guide, generated into the root instruction file
so every worker loads it natively · **`config.md`, which the layout has always promised and
nothing used to write** — the git-host adapter, which modules are on, the conventions,
`spec_mode`, `schema_version`, and **the migration log opened with its first line**, `— → <this
version> · <date> · applied · <who>`, so a project born here never reads as one that was never
migrated (`upgrading.md`) · **`docs/FIELD-NOTES.md`, so friction has somewhere to go from the
first session** — it is swept at every status check, and a log that appears only once someone
remembers it exists collects nothing from the days that matter most · the process files —
ladders, gates, labels · the documentation
skeleton, only what the interview actually named · **branch protection where a remote exists**,
because a review gate without it is a sentence rather than a gate · the pre-commit guard that
keeps the documentation the guide promises from quietly disappearing.

**And a first task, so the machinery is exercised once while someone is watching.**

---

## What good looks like on day one

**Nothing had to be configured except the two hard gates.** Every other setting had a default good
enough to leave alone.

That is not an aspiration — **it is testable**, and it is the first eval scenario for exactly that
reason: every setting this system has added since its predecessor pushes against it, and the test
is what keeps the pressure visible → `evals/new-scenarios.md`.
