# Glossary — one word, one meaning

Every term this skill uses, with the one file that owns it. A word that appears here means
**exactly this** everywhere in the corpus; a word that does not appear here is ordinary English.

**Why this file exists.** A methodology accumulates near-synonyms faster than it accumulates
rules, and two words for one thing costs less than one word for two things. The pairs section
below is the expensive half: each of those collisions was found by hand, late, and each one
would have shipped.

**Rule for adding a term:** it enters here when a second file needs it. A term used in one file
is that file's business; a term used in two is canon, and canon lives here.

---

## Confusable pairs — the expensive half

| These look alike | …and are not | The test |
|---|---|---|
| **pipeline** · **automation** | a pipeline is the **stage sequence a task travels**; an automation is **recurring or triggered work that starts something** | does it *describe a path* or *fire*? |
| **stage** · **wave** | a stage is a **named step of a pipeline**; a wave is the **barrier grouping sibling children** | does it order *the ladder* or *the children*? |
| **team** · **cohort** | a team holds **workers** and its routing produces an **assignee**; a cohort holds **experts, personas and humans** and its routing produces a **respondent** | can a member be *assigned work*? |
| **team** (ours) · **agent team** (the harness) | ours is a **durable group with a routing rule**, a file in the repo, invisible to the runtime; the harness's is the **ephemeral set of live sessions**, kept outside the repo and deleted when the session ends | does it survive the session? |
| **advisor** · **team lead** (the harness) | the same thing seen from two sides: the session that spawns and does not hold the work. **Not** the squad leader we removed — that was a role in an org chart, and routing replaced it | is it a *seat* or a *rung*? |
| **segment** · **cohort** | a segment is a **property of one persona** (SMB, enterprise, novice); a cohort is a **named composition for a run** ("5 SMB, 3 enterprise, 2 churned") | is it *an attribute* or *a group* ? |
| **release** · **milestone** | a release **ships, has a version and gets measured**; a milestone is **a checkpoint that may ship nothing** | does it leave the building? |
| **migration** · **adoption** | a migration moves what a project **already has** onto a newer shape; an adoption is taking up something it **never used**, which a release can make load-bearing. The first is applied on approval, the second is **offered with its price and may be declined for good** | is there something to convert, or something to start? |
| **takeover audit** · **migration audit** | the first reads **a repository you have not operated** and produces a **debt list** — blocking or deferrable, against the invariants (`entering.md`); the second reads **a project you already operate** and produces a **delta against a version** — needs no answer · needs an answer · needs nothing (`upgrading.md`) | is the yardstick **the invariants** or **a version**? |
| **record** · **work** | the record documents **how the work was produced**; the work is **what it produced** | delete it — is the shipped thing now wrong or incomplete? |
| **guest** · **successor** | a guest does **one bounded piece and leaves nothing of ours behind**; a successor **becomes the project's operator** | are their conventions *binding* or *weighable*? |
| **import** · **checkout** · **publish** | import is **one-time, we become canonical, the cord is cut**; checkout is **ongoing, they stay canonical, only the working set**; publish is **ongoing, we stay canonical, nothing comes back** | which side is canonical, and does anything return? |
| **layer** · **cut** | a layer is **one of the six kinds of thing a project accumulates**; the cut is **where the ladder is divided between the repository and you** | a *what*, or a *where*? |
| **the store** · **the record** | the store is **a place — a directory of ordinary git repositories**; the record is **the content, which may live there or in the repository** | a container, or what is in it? |
| **complete** · **canonical** | the local copy is **always complete** so the graph resolves; **canonical** is declared per destination and does not move | can I read it here, or does it decide? |
| **skill** · **resource** · **source** | a skill is **a procedure the agent follows**; a resource is **a place it goes to look**; a source is **the evidence behind a claim it makes** | follow it · consult it · cite it |
| **module** · **companion** | a module is an **optional product capability** (design system, brand, theatre); a companion is a **loadable part of this skill** | is it *the project's* or *ours*? |
| **our register** · **the project's register** | *"what patterns / decisions / sources do we have"* is ambiguous: `PATTERNS.md` and `sources/` are **this skill's**, while the project keeps its own decisions, tooling and resources | answer the one they meant, and say which you read |
| **threshold** · **cap** | a threshold **asks before an action**; a cap **stops when a total is reached** | before each, or at the sum? |
| **update** · **upgrade** | update = **new bytes arrive**; upgrade = **the project moves onto them** | did anything change *here*? |
| **addressing** · **assignment** | addressing is **the ask, and it may go to a group**; assignment is **accountability, and it is always exactly one** | can the target be a group? |
| **capability** · **gate** | a capability is **what the runtime can do** (delegate, restrict tools, isolate a worktree); a gate is **what stops a transition**. A gate whose capability is absent is not a weaker gate — it is a rule | is it *possible here*, or *blocked here*? |
| **gate** · **hook** | a gate **blocks a transition until something is true**; a hook **acts when a transition happens** | does it stop, or does it do? |
| **terse** · **readable** | terse **trims words** (`caveman`, applies to reasoning and agent-to-agent exchange); readable **shapes words to scan** (product-page style, applies to anything a human reads) | who is the reader? |
| **attention** · **escalation** | attention is **when work stops and asks** — configured, cascading; escalation is **where a stuck agent goes** — a chain, not a setting | is it a setting or a path? |
| **flow** (dial) · **flow** (procedure) | **avoid the second meaning.** The dial `flow: manual \| auto` stays; a named procedure is a **capability**, never "a flow" | — |
| **verified/recalled/unknown** · **measured/cited/recalled/judgement** | **one scale, not two** — see *evidence rung* below. The three-way labelling is retired | — |

---

## Terms

### Work

**task** — a unit of work: it has an id, an assignee, a thread, runs and a cost. A checklist
line has none of those. Subtasks are tasks. → `writing-work.md`

**id** — six characters from a 32-symbol alphabet (the digits and every letter but `I`/`L`/`O`/`U`),
immutable, generated once, **never reused**. Links point at the id, never at the name, which is
what makes renaming safe. → `writing-work.md`

**status category** — one of six the system understands: `backlog` · `planned` · `started` ·
`completed` · `canceled` · `triage`. The project names its own stages inside them.
**`blocked` is not a status** — a blocked task is `started` with a blocker. → `pipelines.md`

**triage** — the category raw intake lands in, excluded from boards and planning by default.
Four dispositions: accept · decline (with a reason) · duplicate · snooze. → `writing-work.md`

**stage** — a named step of this task's pipeline (`draft`, `fact-check`, `in dev`). The only
state field. → `pipelines.md`

**wave** — an integer barrier grouping a parent's children. Everything genuinely independent
shares a wave and runs concurrently; **the numbers order dependencies, not tasks**. Two children
in the same wave never own the same file. → `decomposing.md`

**relation** — a typed pair, **one side stored**, the other generated: `blocked_by`↔`blocking` ·
`duplicate_of`↔`duplicated_by` · `related` (its own inverse). → `writing-work.md`

**waiting_on** — a wait that is **not a task**: a person doing a physical thing, hardware, a
delivery, an access grant. Ages like a request. → `writing-work.md`

**priority** — a named scale, `none` (default) · `low` · `medium` · `high` · `urgent`. Opt-in.
**Dates beat priority; priority is not the order.** → `writing-work.md`

**stream** — `product` (default) or `system`. `system` is work on the project's own machinery
and always carries full history regardless of size. → `self-maintenance.md`

**area** — a declared `select` field naming a part of a monorepo (`app`, `site`, `brand`). Not
an entity. → `writing-work.md`

**history** — one append-only table per task recording runs, transitions, assignments and
relation changes. The current value lives in the field; how it got there lives here.
→ `writing-work.md`

### People

**role** — one entity with a `type`, four handles (**name · position · grade · description**)
so the owner can find someone by any of them. → `hiring.md`

**advisor** — **the figure this skill's core defines: the session the owner is talking to.**
It introduces itself by the skill's frontmatter `display_name`. Exactly one per
project. Runs the turn loop, dispatches, **is never assigned a
task**, and is the only role that may write other roles' `model`/`effort` and the project
defaults — always as a recorded decision. → `hiring.md`

**worker** — assignable, accountable, counted in capacity. → `hiring.md`

**expert** — consulted, **never assigned**, not in capacity. A synthetic expert cites sources;
a live expert **is** the source. → `audience.md`

**persona** — never assignable, never a team member, output always marked, verdicts
**direction only, never magnitudes**. Effort defaults to `low`. → `audience.md`

**human** — a real person consulted as a source: a live expert, an interview participant.
Never dispatched. Their contribution is the top evidence rung; paying them is spend.
→ `audience.md`

**grade** — junior · mid · senior · principal. **A routing fact, never a character**: it decides
who gets the work and at which tier, and never enters an agent's instructions as an identity.
→ `hiring.md`

**team** — members + a **routing rule** (by-craft · round-robin · first-free) + an
**aggregation rule**. **No leader** — routing and aggregation are what the leader used to be.
A role may not be in two teams. → `addressing.md`

**cohort** — a named composition for a run, with a required **`made_of`** (`synthetic` · `live`
· `mixed`) that decides what the system may claim about the result. → `audience.md`

### Governance

**gate** — something that must be true before a transition. Carries an honest
**`enforced_by`**: `request` · `validator` · **`git-host`** · **`harness`** · `prose-only`.
→ `permissions.md`

**git-host** — where the repository lives: GitHub, GitLab, Gitea, or none. Enforces branch
protection and reviews. An adapter that cannot enforce something **says it cannot**, rather
than pretending. → `permissions.md`

**harness** — the agent runtime this skill runs inside: Claude Code, or another. Enforces tool
allowlists, turn caps and isolation, because those live in the subagent definition. **Not the
same as the git-host** — the two were one word until they collided. → `dispatching.md`

**the four owner-gated kinds** — spend · outward · destructive · shape-of-team. `destructive`
is always ask and cannot be preset away. **A gate is a property of the action, not of who
performs it** — the advisor is not exempt. → `permissions.md`

**grant** — a delegated right with an expiry: `{right, grantee, scope, duration}`. The **only**
way a gate is loosened, because a setting rots quietly and a grant announces its own death.
Expiry is evaluated **at the gate check**, not by a timer. → `permissions.md`

**request** — one entity with a `kind`: `approval` · `review` · `question` · `decision`. A
review routed to a non-author **is** the review gate. The author never answers their own.
Every escalation is a request. → `requests.md`

**attention view** — a computed state in two parts: **needs you** (requests — state, stays until
answered) and **happened** (notifications — events, ages out). Nothing to mark read.
→ `requests.md`

### Evidence

**evidence rung** — one scale for claims about the world: **measured › cited › recalled ›
judgement**, plus `unknown` when no rung applies. A lower rung never borrows a higher one's
authority, and **the rung travels with the claim** across a handoff. → `SKILL.md`

**second pyramid** (audience rung) — for signal about people: **live › twin › validated
persona › proto**. Never pooled with the first. Three live interviews and twenty synthetic runs
are never "23 responses". → `audience.md`

**source** — evidence behind a claim, registered in `sources/` when it is **slow-rotting canon**.
Fast-rotting facts (a price, a current limit) are **fetched at the moment of use**, never cached
here to rot. → `SKILL.md`

### Machinery

**migration log** — the `## Migrations` section of `config.md`: append-only, one line per step,
`from → to · date · outcome · who`, outcome one of `applied` · `nothing-required` · `declined` ·
`deferred` · `failed`. **It is history, not state** — `schema_version` beside it is the state —
and it is the only thing that distinguishes *the files were swapped* from *the project was
migrated*. A guest repository has none. → `upgrading.md`

**spec mode** — where the authoritative description of the work lives: **a ladder, and the
value names the cut** — `outcome` · `spec` · `example`, cumulative, with a format the project
already runs entering as a **binding**, not a rung. The mechanics — the two exemplar kinds,
the per-type default, what closing does — live in one home → `writing-work.md`. Absent reads
as `outcome`. Not the awareness ladder marketing uses — that one is a craft frame in the
catalogue.

**run strategy** — how a dispatch is run, as distinct from *what model* (tier) and *how hard*
(effort): `standard` · `self-refine` · `self-consistent` · `cot`, files of data in
`strategies/`. Resolves by the one cascade with **a selector at the bottom rung**, lands on
the run with its source, never applies to the advisor's own session. → `strategies/selector.md`

**pipeline** — a linear stage ladder with gates on its transitions, and `starts:`
(`manual` · `on-completion` · `schedule:<cron>`) saying what begins the next unit of work.
→ `pipelines.md`

**automation** — recurring or triggered work: `trigger` · `template` · `dry_run_first` ·
`stop_conditions[]` · `owner_of_failures` · `leaves_trace`. **Creates work; never moves anyone
else's.** Failures are visible. → `automations.md`

**run** — one dispatch, appended to the task's history: started/ended · role · model · effort ·
fast · trigger · outcome · attempt · four token numbers · tool uses · duration ·
`skills_available[]` · `skills_used[]`. The resolved cascade values are recorded here so
"why did it cost that" is answerable afterwards. → `dispatching.md`

**cascade** — the one resolution shape: **project → team → role → task**, most specific wins,
**each setting declares which rungs it has**, and the resolved value is recorded on the run.
→ `PATTERNS.md`

**layer** — one of the six kinds of thing a project accumulates, ordered by what they mean to
someone with no agents at all: **documentation · work · conversation · team · telemetry ·
results**. → `storing.md`

**cut** — where that ladder is divided: above it goes to the repository, below it stays with you.
**One position, not six switches**, asked as a filled-in form before the first lasting write.
→ `storing.md`

**manifest** — one line per layer in `config.md` naming where that layer lives. Stays in the
repository even when the layers do not, because **a clone giving contents without a map is worse
than one giving a map without contents** — the first looks complete. → `storing.md`

**store** — `~/.opsinist/projects/<slug>/`, a directory of **ordinary git repositories, not a
database**: no index, the list is built by scanning. Holds a complete copy so the graph resolves;
identity is a generated id plus an **append-only list of keys**, so the directory name is only a
convenience. → `storing.md`

**skill pool** — every skill the project has. **Attachment is a different question from
existence**: unattached is a normal state. Attachment lives on the role, never on the skill.
→ `skills.md`

**companion** — a loadable part of this skill, **named for its trigger** ("when X happens, read
Y"), never for its topic. A rule has one home; the other file points. → `SKILL.md`

**definition of ready · definition of done** — ready to *start* · ready to *finish*, and the pair
most often collapsed into one word. DoR: workable from the task alone, outcome writable, the
type's *ready when* met — held at the door into `started` by whoever picks the task up. DoD: the
type's craft gates, made concrete by the task's own acceptance criteria and deliverables.
Collapse them and work starts unstartable and finishes undone. → `writing-work.md`

**architecture map · product map** — two maps, two questions. `docs/ARCHITECTURE.md`: where the
implementation lives, a worker's map of the tree. `docs/MAP.md`: how the product is walked — the
moves and the things. Reasoning about a flow from the architecture map lands a change in the
right file and the wrong journey. → `mapping.md`

**generated surface** — markdown between markers, rewritten only by its generator: the board,
the roster, progress, children lists, changelog. **A view, never a source** — no rule lives only
here. → `PATTERNS.md`

**field notes** — friction recorded **the moment it happens**, append-only, one line
(`date · flow · symptom · evidence · fix-candidate`); a correction is a new entry, never an edit.
Swept into the backlog at natural checkpoints. → `self-maintenance.md`

**the four lenses** — deletion · adversarial · contradiction · cold-read, run in that order by
someone who is not the author. The compensating control for every `prose-only` gate. An empty
lens is stated explicitly. → `lenses.md`
