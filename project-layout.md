# Project layout — what this creates in your repository

**Load when:** standing a project up, joining one, or asking where something is supposed to live.

**Everything is a file, and the layout is the whole storage design.** There is no database and no
service: the directory structure *is* how the project is stored, which is why it is worth being
deliberate about.

---

## The tree

```
your-project/
  CLAUDE.md              # generated from docs/ + process/ — the guide every worker loads natively
  config.md              # git-host adapter, modules on/off, conventions, schema_version

  tasks/                 # flat. T-8F3KQ2-billing-page.md — hierarchy is a field, not a folder
  roles/                 # one file per role; also generated into .claude/agents/
  teams/                 # members, routing rule, aggregation rule, colour
  cohorts/               # named compositions for a run, each with made_of
  pipelines/             # stages, gates on transitions, default_for, starts
  requests/              # open asks with their ages
  releases/  milestones/ # shipments and checkpoints, orthogonal to each other
  automations/           # trigger, template, contract
  resources/             # places to look, each with its why
  skills/                # the pool — attachment is a field on a role, not on the skill

  process/
    types/               # one per task type: definition of done + default pipeline
    labels.md  gates.md  grants.md

  docs/
    COMPANY.md           # always-loaded context: what this is, for whom, the vocabulary
    DECISIONS.md         # append-only: considered · chose · rejected · because · revisit-if
    LATER.md             # deferred, each with a revisit trigger that is a moment
    BACKLOG.md           # the one hand-kept ordering surface
    BUDGET.md  ECONOMICS.md  ARCHITECTURE.md  MAP.md  TOOLING.md  TEAM.md
    tooling/<tool>.md    # runbooks — how to operate a thing, kept out of the guide
    research/  audience/  design-system/  brand/
    FIELD-NOTES.md       # friction, recorded where it happens, append-only

  scripts/               # a handful of helpers, extended by you as you go
  .index/                # derived caches. gitignored, rebuildable, never a record
```

---

## Rules the layout enforces

**Flat where identity matters.** Tasks and roles are flat because **hierarchy in a field means
re-parenting is a one-line edit** instead of a move that breaks every inbound link. Links point at
ids, so renames are safe.

**`docs/` opens as a vault.** Relative links and diagrams, readable both on the host and in a local
editor. With the repository open in one, the generated board **is** a live board — with two
caveats worth stating: do not keep a generated file open in edit mode during a regeneration, and
query plugins refresh on their own cadence.

**Generated files carry markers and a header**, and only the generator writes between them —
board, roster, progress, children lists, changelog, analytics. **A view, never a source.**

**`.index/` is the boundary of "everything readable in markdown".** A cache is not a record: it is
derived, disposable, and losing it costs nothing. That is why it may be JSON and outside git while
everything else is not.

**`CLAUDE.md` is generated, not hand-written.** Its sources are `docs/COMPANY.md`, `process/` and
the conventions. **Every worker loads it natively**, which is why a thousand tokens added to it is
a thousand tokens on every run of every role, forever.

**Roles are generated into the runtime's own agent directory.** The role file *is* the agent
definition — `model`, `effort`, `tools`, `skills`, `maxTurns`, `isolation`, `color` are its fields.
**Names must be unique across the whole tree**: a collision is resolved silently by filesystem
order, with no error.

**One repository is one project.** Several deliverables inside it are **areas** — a declared field.
Other repositories are **dependencies**: resources of kind `repo`, each with a `why` saying what
changes there require changes here.

---

## What is not here

**No user preferences.** Language, editor, which projects are in which session, favourites — these
live outside any project and **never in it**. A project must not become unopenable because someone
else's preferences are missing.

**No secrets.** Only a register of references: name, purpose, prefix, last used, expiry. Values
live in the environment or a keychain.

**No stored rollups.** Progress, burn and totals are computed from the atoms every time
(`PATTERNS.md` §4).

**Not every layer, necessarily.** Where a layer lives is a project decision, and `config.md`
carries **the manifest — one line per layer, naming its destination**. It stays in the repository
even when most layers do not, because a clone that gives contents without a map is worse than one
that gives a map without contents: the first looks complete → `storing.md`.

**The local store is not the source of truth.** `~/.opsinist/projects/<slug>/` holds a complete
copy so the graph resolves and a move needs no interrogation, but **which side is canonical is
declared per destination and does not move**. A copy is not an authority.

---

## Showing things inside a document

**Standard markdown, never a viewer's dialect.** An image is `![alt](relative/path.png)` and a
link is `[text](relative/path.md)` — those render on the git host, in an editor, in a vault and on
a generated site. **Wiki-style `[[double brackets]]` render in one of those four**, and choosing
them makes the repository readable only inside the tool that was open when someone wrote it.

**A diagram is text, in a fenced ```mermaid block.** It diffs, it reviews, an agent can edit it,
and it draws itself almost everywhere a reader will open the file — **natively, no plugin, in the
three places threads actually get read**: the git host, Obsidian (built in since 0.15, in both
reading and live preview) and Notion (checked 2026-07-29). The measured exception is a generated
site, whose generator needs its own mermaid wiring — ours did. **A picture of a diagram is a
diagram nobody can change** — export one only when something must render where mermaid does not.

**What cannot be embedded gets a pointer and a still.** A design file, a video, a 4 GB render: the
thing lives where it is made, and the document carries **a link, a distillate, and an exported
frame or screenshot** so a reader on a plane still knows what is being discussed →
`resources.md`. The still is dated like any other snapshot.

**Paths are relative and inside the repository.** An absolute path is one machine's truth, and a
hotlinked remote image is a page that goes blank when somebody else's account lapses.

**No plugin is required to read a project, and that is a constraint rather than an accident.** If
something genuinely needs one — a diagram format nothing else draws, a preview only one tool
renders — that is a tooling decision with a register entry and a `why`, not a quiet dependency
every future reader inherits → `tooling.md`.

---

## Which template writes which artifact

**A template nobody is sent to is a file, not a template.** Each artifact below has one, and
using it is what keeps the same document recognisable across projects — an agent that invents the
shape each time produces a document only its author can read.

| Artifact | Template |
|---|---|
| the project guide | `templates/GUIDE-template.md` |
| `docs/ARCHITECTURE.md` | `templates/ARCHITECTURE-template.md` |
| `docs/MAP.md` | `templates/MAP-template.md` |
| `process/types/<type>.md` | `templates/TYPE-template.md` |
| `docs/DECISIONS.md` | `templates/DECISIONS-template.md` |
| `docs/ROADMAP.md` | `templates/ROADMAP-template.md` |
| **a task** → `writing-work.md` | **`templates/TASK-template.md`** |
| **a role** → `hiring.md` | **`templates/ROLE-template.md`** |
| **a run record** → `dispatching.md`, `cost.md` | **`templates/RUN-template.md`** |
| `docs/TEAM.md` | `templates/TEAM-template.md` |
| `docs/TOOLING.md` | `templates/TOOLING-template.md` |
| `docs/BUDGET.md` | `templates/BUDGET-template.md` |
| a brand definition | `templates/BRAND-template.md` |
| a design-system component | `templates/COMPONENT-template.md` |
| a persona role → `audience.md` | `templates/PERSONA-template.md` |
| a discovery pass → `process-discovery.md` | `templates/discovery-template.md` |
| a new skill → `skills.md` | `templates/SKILL-SCAFFOLD.md` |
| a change to this system → `self-maintenance.md` | `templates/SELF-MAINTENANCE-brief.md` |
| the project's own release gate → `shipping.md` | `templates/company-preflight.sh` |

**Where a template does not exist, the artifact does not get invented on the spot** — it gets one,
as a task, once the second project needs the same shape (`PATTERNS.md` §22).

**The first three rows are new on `2026-07-31`, and their absence was the loudest silence in this
file.** Eleven artifacts a project writes occasionally each had a template; **the three it writes
constantly — a task, a role, a run — had none**, and their shape lived as field-definition tables
inside the companions. A definition table says what a field *means*; **a template is a file you
copy, where the field you skipped leaves a hole somebody sees.** `cost.md` had already named the
consequence without being able to prevent it: *a run recorded by the worker itself carries a
sentence where four numbers belong, which is how a ledger quietly becomes prose.*

**The last row is the only one that is not a document, and it is the one that must actually be
run.** Copied to `scripts/preflight.sh` and wired with `bash scripts/preflight.sh --install`, it
is what makes three of this system's rules real in this project: a task cannot reach a terminal
status in the same commit that edits its own bar, an entitlement cannot be claimed with nothing
behind it, and the decisions log cannot be rewritten. **Un-wired, all three are `prose-only`
here** whatever `permissions.md` says in general — a gate that lives in an uninstalled file is a
gate nobody has. So it is wired when the project is stood up, and **whether it is wired is worth
one line in the guide**, because the next agent has no way to tell by looking.

---

## Starting small

**Not all of this appears on day one.** A new project gets `CLAUDE.md`, `config.md`, `tasks/`,
`roles/` with one advisor, `process/types/` and the parts of `docs/` the interview actually named.

**The rest appears when something needs it** — the same rule as hiring. A directory created in
advance is a guess, and an empty one is a question every reader has to answer for themselves.
