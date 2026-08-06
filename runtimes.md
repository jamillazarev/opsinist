# Runtimes — what the harness provides, and what changes when it does not

**Load when:** starting in an unfamiliar runtime, deciding whether a gate is real here, or asked
whether this works somewhere other than where it was written.

**The packaging travels; the capabilities do not.** This is an Agent Skills package, and that
format is an open standard some thirty tools read — so *installing* is solved and is not what this
file is about. **What differs is what the runtime lets an agent do**, and one of those differences
turns a gate into a sentence.

---

## Detect first, and record what was found

The environment fingerprint already hashes **harness version** as one of its classes
(`drift.md`). Reading *which* runtime this is belongs in the same step, at the same moment: the
six-check ladder on arrival → `arriving.md`.

**Read it, never assume it.** A profile carried in from another machine is a claim about somewhere
else. And **record the profile on the run alongside the resolved cascade** — otherwise *"why did
that gate not fire"* is unanswerable a month later, which is the same reason model and effort are
recorded.

---

## The capabilities that change behaviour

Each row is a question to answer about the runtime in front of you, not a feature to admire.

| Capability | What depends on it | Without it |
|---|---|---|
| **delegation** — spawning a worker that runs on its own | every dispatch | **the advisor advises and does not dispatch.** Roles, tasks and the record still work; nothing runs unattended |
| **tool restriction the runtime enforces** | `enforced_by: harness` | that gate **downgrades to `prose-only`** and joins the named list (`permissions.md`). **And where it is supported it can still be absent for one session**: a registry collected at session start does not contain a role written after it, so a role created and dispatched in the same sitting runs unrestricted → `hiring.md` |
| **per-worker model and effort** | the cascade's whole point | the cascade resolves to **one setting for everything**; say so rather than writing per-role values nothing reads |
| **isolated worktrees** | a wave running in parallel | **waves serialise.** The rule that two children in one wave never own the same file stops being enough, because they now share one tree |
| **lifecycle hooks** | automations that fire on an event, **and the audit gate that holds a takeover to its order** (`entering.md`) | triggers become **manual or scheduled**; an automation with `trigger: on-completion` silently never fires, and the audit gate **downgrades to prose** — the rule stands, nothing performs it. **And the downgrade is per *mode*, not only per runtime — measured 2026-08-07**: in Claude Code's headless print (`claude -p --plugin-dir`) plugin `PreToolUse` hooks do not fire at all while `SessionStart` does — an `Edit` sailed through a gate green in its own suite. Anything dispatching headless workers reads its hook-held gates as prose there, and says so |
| **background or scheduled runs** | anything unattended | **nothing happens while nobody is watching** — which is already true of every runtime when the machine is off |
| **MCP servers** | tools an agent drives directly | external tools reachable **by CLI only**, which is usually fine and occasionally not |

**A missing capability is a stated limitation, never a silent one.** The failure this file exists
to prevent is a project configured with per-role models, tool allowlists and parallel waves, in a
runtime that honours none of the three, where everything looks configured and nothing is enforced.

---

## `enforced_by` is resolved here, not written once

**`enforced_by: harness` is a claim about a runtime, so it resolves per runtime** and the answer
belongs on the run. Everything else on that scale is portable: `request` needs a human, `validator`
needs a script, `git-host` needs a remote, `prose-only` needs nothing. **Only `harness` moves when
the runtime does** — which is the axis this file is about. A row also changes when the *project*
changes: an owner who declines a gate turns a `request` into `prose-only`, and the manifest says so
(`requests.md`). Same scale, different reason, and only one of the two is portable.

**When it resolves to nothing, say it at dispatch.** *"This role's tool allowlist is not enforced
here — it is a rule, not a gate."* Announced before the work, in one line, once. **A gate believed
in but not enforced is worse than a stated rule** (`permissions.md`), and porting a role to a
weaker runtime is the quietest way to produce one.

---

## Mixing runtimes

**The indivisible unit is the run**, and the repository is what passes between them. A task
interrupted in one runtime resumes in another, because recovery reads committed state rather than
a session that no longer exists → `recovering.md`. Children of one wave may run in different
runtimes; a subtask is a task, so nothing about it is special.

**A worker can be sent into a different runtime than the one you are sitting in.** Not as a
subagent — that mechanism is per-runtime — but as a **subprocess**: the other tool's headless mode,
given the task file, writing its result into the same repository. So an advisor running in one
place can hand a task to a worker running in another, and the thread it writes to is the same file
either way.

**The pattern is measured; crossing runtimes is not.** `2026-07-31`: a headless subprocess handed
nothing but *"read `tasks/T-1.md` and do what its definition of done says"* edited the code, wrote
its own run line into the task's thread, and set the status — **the repository was the whole
channel**. The crossing itself could not be exercised on that machine: **Gemini CLI answered
`IneligibleTierError` — the vendor has withdrawn that client for individual accounts and points at
Antigravity — and Codex answered `401` on every transport.** Neither is a defect in this
mechanism, and neither is a reason to write the crossing down as working.

**And the product that message redirects to is not a worker either** (`2026-08-01`). Antigravity
authenticates on the same account that Gemini CLI refuses, so the redirect is real — but
`antigravity-ide chat -m agent` **opens an editor window** with the prompt in its arguments, and
four minutes on, the task file, the code and the status were all untouched. **It has no headless
mode at all**: `chat` offers only window and context flags and prints nothing, and `serve-web`
serves the same interface to a browser. **A runtime can be perfectly available and still not be
dispatchable** — the question for this row is never *can I sign in*, it is **can it be handed a
task file and left alone.**

**So check the executor answers before handing it a task.** Both failures above burned time and
produced nothing a task file would record — the second after ten reconnection attempts. **A dead
executor and a slow one look identical from outside**, which is the same shape as every other
silent failure this system guards.

**Count the cost before reaching for it.** A subprocess has none of the runtime's own coordination:
no shared task list, no lock, no completion hook, no turn cap the runtime enforces. What it has is
the repository, which is enough for one whole task and not enough for half of one. **So the rule
does not change** — one run, one runtime, and the handoff is a commit.

**What does not cross the boundary is everything ephemeral**: a shared task list, a mailbox, file
locks, hooks, completion events. Those live inside one runtime. So there is no arrangement where
two runtimes cooperate *within* one run, and proposing one means building the coordination layer
this system deliberately does not own.

---

**What is not a runtime, said once so the question stops returning.** A server platform that
owns execution — the Dify / Flowise / Langflow class: a backend, a database, an admin UI —
cannot host this system, because the premise here is the inverse of theirs: the project is a
function of the repository, sessions own nothing, and a handoff is a commit. Their mechanics
are translated into files where they earn it (`catalogue.md`); the platforms themselves never
join this table.

## Moving a project from one runtime to another

**There is nothing to freeze, and that is the point.** Ending a session properly is the whole
procedure: the tail written to its thread, applied work committed, control returned → `entering.md`.
A session that ends without that is an interrupted run and the next start says so — in **any**
runtime, because the marker is in the repository rather than in the session that set it.

**Then open the project somewhere else.** A session is bound to a working directory, so switching
runtime is the same act as switching project: start one elsewhere. The record, the roles, the
threads and the history are already there.

**The fingerprint will differ, and that is explained rather than alarming.** The harness class is
one of the hashes, so arriving in a different runtime looks exactly like drift until someone
attributes it. **Attribute it once and record the why** (`drift.md`) — otherwise every future
session re-asks a question that was answered the first time.

**Say what changed capability, at the switch rather than at the failure.** This is the moment the
`enforced_by: harness` rows are re-resolved, and the honest line is short: *"no enforced tool
allowlist here — those are rules, not gates, until you go back."* A role written where isolation
exists, run where it does not, has waves that serialise; nothing breaks, and nobody should learn
that from a collision.

**What does not travel:** anything the old runtime held and the repository did not — a queued
background job, a scheduled trigger, an unfinished session. **Those are re-created, not migrated**,
and the giveaway that one existed is an automation whose trigger never fires.

---

**`project = f(repo)` is what makes mixing possible at all** — nothing load-bearing lives in the
session, so the session is replaceable.

---

## What is measured, and what is only read

**Nothing here is assumed from a product's reputation.** These carry rungs like any other claim,
and the fastest way to get this wrong is to write down a capability because it would be convenient.

| Runtime | Profile | Rung |
|---|---|---|
| **Claude Code** | every capability above; the runtime this was written in and run against. **One collision to know about:** it ships its own `TaskCreate` / `TaskGet` / `TaskList` for the assistant's **session to-do list** — in memory, gone at session end, no relation to this system's tasks. A task here is a **file**, `T-18` is `tasks/T-18.md`, and there is no task service to query | **measured** — the behavioural suite runs here (`evals/`), including the collision: told *"it's in `T-18` and `T-21`"*, **2 of 5 runs called `TaskGet(taskId: "T-18")`**, got the empty session list back, and reported finding nothing |
| **Gemini CLI** | agent skills · MCP · hooks · extensions · git worktrees · sandbox · headless · session resume · per-invocation model · a policy engine (the tool-restriction candidate). **Delegation not confirmed.** | **measured** for installation and the surface, `2026-07-28`; **unknown** for behaviour — authentication failed before a run |
| **Codex CLI** | reads the same skill format; subagents reported | **cited**, not measured — it was not on the machine |
| **hermes-agent** | a resident harness, not a per-session console: one gateway process behind messaging channels, built-in cron and webhooks, any model provider. Reads this skill unchanged via `skills.external_dirs`; **the router survives its loader** — a forced load and a persona-driven load both walked `SKILL.md` into chapters. **Unforced discovery missed once on a light tier**, so the always-on persona is load-bearing there, not decoration | **measured** for loading, resident mode and consult, `2026-07-30` — four smoke runs, N=1 each (`evals/RUNS.md`); the suite has not run here |
| **OpenClaw** | a resident gateway: 25+ channels, per-channel isolated agents, eight automation mechanisms with heartbeat on by default. Reads this skill unchanged via a symlink into its skills directory; the agent saw it among fifty-eight. **The load-bearing anchor is an operational trigger rule in the workspace `AGENTS.md`** — a persona section in `SOUL.md` reached the context and was ignored, while the trigger rule fired the front door and both hard gates. A pure question first fell outside the rule's named class, then *"just your take"* was read as licence to skip the manual — both repaired by the trigger's wording, which is therefore part of the machinery | **measured** for loading, anchored mode and consult, `2026-07-30` — four smoke runs, N=1 each, player one tier down (`evals/RUNS.md`); the suite has not run here |
| **CrewAI** | a Python framework, not a console — but its skills are `SKILL.md` with `name`/`description` frontmatter and progressive disclosure (names at setup, body on demand), **the same file shape this repository ships**; agents and crews take skill search directories. Everything else runs opposite to this corpus: memory in a vector store, training as prompt injections from a pickle, state checkpoints instead of a repository | **cited** from docs.crewai.com, `2026-07-30` — whether the router and chapters survive its loader is **unknown**, and the advisor-session premise has no equivalent there |

**Re-verify before relying on a row.** These age like every other recorded fact, and a runtime
gaining delegation is exactly the kind of change that arrives without an announcement reaching
here → the freshness law.
