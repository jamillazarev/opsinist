# Diagrams — the shapes, drawn once

**Load when:** explaining this system to someone, or checking that a flow you are about to
change still matches the picture.

**Every node here names something the corpus defines.** A diagram that introduces a box with no
file behind it is a second source of truth, and the one that ages first — so if a shape below
stops matching its file, the file wins and the diagram is wrong.

---

## The front door

Read from the ground, never asked. Doors exist for every branch below; none of them is how a
route is chosen.

```mermaid
flowchart TD
  A[a greeting, a situation, a question] --> B{is a repo here?}
  B -- no --> C[start a project<br/>starting.md · /init]
  B -- yes --> D{is it theirs?}
  D -- yes --> E[enter as a guest<br/>entering.md · /join]
  D -- no --> F{a backlog elsewhere?}
  F -- yes --> G[import it<br/>importing.md · /import]
  F -- no --> H[take it over<br/>entering.md · /join]
  A --> I{anything to build?}
  I -- no --> J[consult<br/>consulting.md · /consult]
  I -- one job --> K[a quick job<br/>quick.md]
```

---

## The cascade

One resolution shape for every setting. Each setting declares which rungs it has; the resolved
value is recorded on the run.

```mermaid
flowchart LR
  P[project] --> T[team] --> R[role] --> K[task]
  K --> V[[resolved value<br/>recorded on the run]]
  A[advisor's own model] -. outside the cascade .-> V
```

The advisor is the session, so nothing here sets its model — it is read and recorded, never
stored → `hiring.md`.

---

## The six layers, and the cut

One position on a ladder, not six switches. Above the line goes to the repository; below it
stays with you.

```mermaid
flowchart TD
  subgraph meaning[ordered by what they mean without agents]
    L1[1 documentation]
    L2[2 work]
    L3[3 conversation]
    L4[4 team]
    L5[5 telemetry]
    L6[6 results]
  end
  L1 --> L2 --> L3 --> L4 --> L5
  L6 -. destination dictated by the artifact .-> X[(wherever it is made)]
  CUT{{the cut}} -. above .-> REPO[(repository)]
  CUT -. below .-> STORE[(your store)]
```

→ `storing.md`

---

## Stage and wave are different things

A stage orders the ladder. A wave orders the children.

```mermaid
flowchart LR
  subgraph pipeline[stages: one task travels these]
    S1[build] --> S2[review] --> S3[accept]
  end
  subgraph waves[waves: a barrier between siblings]
    W1A[child A] --- W1B[child B]
    W1A --> BAR{{wave 2 starts<br/>when wave 1 is done}}
    W1B --> BAR
    BAR --> W2A[child C]
  end
```

**Nothing transitions itself** — the barrier lifting surfaces the next wave as ready; it does
not start it → `decomposing.md`.

---

## The decision loop

Every real decision runs this, named once so it is followed rather than reinvented.

```mermaid
flowchart LR
  F[frame] --> S[search, don't recall] --> C[compare, each claim sourced]
  C --> D[choose and say why] --> W{survives being wrong?}
  W -- no --> U[say it is undecided]
  W -- yes --> R[record in DECISIONS] --> A[act]
```

---

## Two evidence pyramids, never pooled

```mermaid
flowchart TB
  subgraph world[about the world]
    M[measured] --> CI[cited] --> RE[recalled] --> JU[judgement]
  end
  subgraph people[about people]
    LI[live] --> TW[twin] --> VA[validated persona] --> PR[proto]
  end
  world -. never summed with .-> people
```

Three live interviews and twenty synthetic runs are never "23 responses" → `audience.md`.

---

## Four kinds route to the owner

The gate belongs to the action rather than the actor, which is why the advisor is not exempt.

```mermaid
flowchart TD
  ACT[any action] --> Q1{spends?}
  Q1 -- yes --> OWN[the owner]
  Q1 -- no --> Q2{leaves the repo?}
  Q2 -- yes --> OWN
  Q2 -- no --> Q3{destroys?}
  Q3 -- yes --> OWN
  Q3 -- no --> Q4{changes the shape of the team?}
  Q4 -- yes --> OWN
  Q4 -- no --> GO[proceed]
```

→ `permissions.md`

---

## What actually holds a gate

Only one of these moves between runtimes.

```mermaid
flowchart LR
  G[a gate] --> RQ[request<br/>a human answers]
  G --> VD[validator<br/>a script refuses]
  G --> HK[hook<br/>the plugin's own script refuses,<br/>in a repo that carries no preflight]
  G --> GH[git-host<br/>branch protection]
  G --> HN[harness<br/>the runtime refuses]
  G --> PO[prose-only<br/>nothing enforces it]
  HN -. absent here .-> PO
  HK -. no hooks here .-> PO
```

**The downgrade is announced at dispatch, not discovered** → `runtimes.md`.

---

## Recovery reads the repository, not the session

```mermaid
flowchart TD
  DEAD[a run that died] --> INV[state inventory]
  INV --> C1[committed: git says so]
  INV --> C2[applied: in the tree, not committed]
  INV --> C3[remains: neither]
  C1 --> SKIP[never redone]
  C2 --> LAND[landed as it is]
  C3 --> DO[done now]
```

→ `recovering.md`

---

## Three arrangements with an outside tracker

Each names a canonical side. There is deliberately no fourth.

```mermaid
flowchart LR
  IM[import<br/>one-time] -->|everything comes across, cord cut| US1[(we are canonical)]
  CO[checkout<br/>ongoing] -->|working set only, status flows back| THEM[(they stay canonical)]
  PU[publish<br/>ongoing] -->|nothing comes back| US2[(we are canonical)]
```

→ `importing.md`

---

## How much of a repository to read

Measuring is nearly free; reading is not. The recommendation is filled in, and all three stay open.

```mermaid
flowchart TD
  M[measure first — inline:<br/>readable lines, languages, shape] --> T{over read_threshold_lines?}
  T -- no --> U[recommend: everything<br/>· base-only still offered]
  T -- yes --> O[say what a full read costs<br/>· recommend: corridor]
  U --> D{the owner picks —<br/>the only part that waits}
  O --> D
  D --> C[corridor: this work's area<br/>+ the coarse shape of the whole]
  D --> B[base only: coarse shape,<br/>each task opens what it needs]
  D --> E[everything: cost stated first]
  C --> BG[the read is dispatched, a tier down]
  B --> BG
  E --> BG
  BG --> W[what went unread is named in<br/>docs/ARCHITECTURE.md]
  W --> K[a claim about unread ground<br/>is unknown]
  W --> X{a task reaches past<br/>what was read?}
  X -- yes --> Y[say so, read further,<br/>update the map]
  X -- no --> Z[keep going]
```

**A guest reads less, not more** → `entering.md`.

---

## The two bars a task passes

Ready to start and ready to finish are different bars, held by different hands. Collapsing them
is how work starts unstartable and finishes undone.

```mermaid
flowchart LR
  B[backlog] --> R{ready?<br/>workable from itself ·<br/>outcome writable ·<br/>the type's ready-when}
  R -- no --> Q[back as a question —<br/>held by whoever picked it up]
  R -- yes --> S[started]
  S --> D{done?<br/>deliverables at their named places ·<br/>evidence in the thread ·<br/>the type's craft gates}
  D -- no --> S
  D -- yes --> REV[review — never the author]
  REV -- send back --> S
  REV -- pass --> A[acceptance moves the status —<br/>also never the author]
```

**Done is checked against the list, never against the feeling of doneness** → `writing-work.md`.

---

## The product map, and how a flow climbs into it

Two maps answer two questions; only one of them is about the tree. The map holds what shipped.

```mermaid
flowchart TD
  D[discovery draws a current flow<br/>and a target flow] --> T[the task body:<br/>the working draft, dead ends and all]
  E[entering: the corridor read<br/>learns the coarse shape] --> M
  T -- the work is accepted --> M[docs/MAP.md — moves and things,<br/>current state only]
  M --> N[every node names<br/>something that exists]
  M --> U[what is not mapped yet —<br/>a claim there is `unknown`]
  R[docs/ROADMAP.md] -. points at nodes<br/>it will change, never drawn on the map .-> M
  W[a task touching a move] --> DD[names the nodes it changes<br/>and the ones it creates]
  DD --> DoD[map updated in the same task —<br/>it is in the DoD, and review bounces without it]
  DoD --> M
```

**A map known to be stale is worse than no map: it answers confidently** → `mapping.md`.

---

## Taking a project over, in order

Four steps, and skipping one changes the outcome. The debt list is the deliverable, not the audit.

```mermaid
flowchart LR
  I[inventory<br/>shape · conventions · tools<br/>· environment fingerprint] --> G[gap-check<br/>against the invariants only,<br/>never against taste]
  G --> D[interview delta<br/>ask only what the files<br/>do not already answer]
  D --> L[the debt list<br/>every finding blocking or deferrable,<br/>with the consequence named]
  L --> P[present it whole, with costs]
  P --> A[apply in batches they approve]
  L -.->|deferrable| R[LATER.md, with a revisit trigger<br/>that is a moment, not a date]
  G -. "a mutating call before the list<br/>is refused by the hook" .-> L
  R -. "finishing without writing it<br/>is stopped once" .-> R
```

**Nothing is fixed before they have seen the list**, and both ends of that are performed rather
than promised: a mutating call before the list exists is refused, and a run that presented
deferrable findings and wrote no `LATER.md` is stopped once and asked to write them
→ `entering.md`.

---

## An upgrade, in order

Swapping the files is not migrating the project. The log is what tells the two apart.

```mermaid
flowchart TD
  M[the plugin moved] --> R{does the migration log<br/>name this version?}
  R -- yes --> N[nothing to do — say so, write nothing]
  R -- no / no log --> S[say so inline:<br/>both versions, read from disk]
  S --> A[audit in the background<br/>· a tier down · session stays usable]
  A --> L[ONE list, split by:<br/>does this need you?]
  L --> M1[needs no answer<br/>applied on approval, reported]
  L --> M2[needs your answer<br/>ONE batch, native affordance where there is one<br/>· recommendation first · a free answer wins]
  L --> M3[needs nothing<br/>named, so the silence is visible]
  L --> M4[orphans — named, never removed]
  M2 --> W{what is already written?}
  W --> W1[closed — never converted]
  W --> W2[in flight — untouched, converts at its next transition]
  W --> W3[open — converts with the batch]
  W --> W4[on-touch — base now,<br/>the rest refused until converted]
  M1 --> G[append to ## Migrations in config.md:<br/>from → to · date · outcome · who]
  M3 --> G
  W3 --> G
  G --> Z[declined → DECISIONS.md · deferred → LATER.md]
```

**A guest trips none of this**, and *nothing-required* is a line worth writing → `upgrading.md`.

---

## Guest or successor

Two arrivals wearing the same clothes. Ambiguity is guest.

```mermaid
flowchart TD
  ARR[a repo that exists] --> R{whose remote?<br/>CODEOWNERS? PR template?}
  R -- theirs --> GU[guest]
  R -- yours --> SU[successor]
  R -- unclear --> GU
  GU --> G1[no debt list for them]
  GU --> G2[their conventions bind]
  GU --> G3[nothing of ours in their tree]
  GU --> G4[the record still gets made — elsewhere]
  GU --> G5[both takeover gates stand down —<br/>a guest owes no list to demand]
  SU --> S1[audit, then a classified debt list]
  SU --> S2[the gates are armed until the list exists]
```

**The same signals the reading uses are the ones the hooks read** — `CODEOWNERS`, a contributor
guide, a PR template, a history in many hands — and on doubt they stand down, because ambiguity
is guest → `entering.md`.

---

## Before a release

```mermaid
flowchart TD
  W[work looks finished] --> G{gates green?}
  G -- no --> STOP[not a release]
  G -- yes --> CH[health · links · check-dates · evals]
  CH --> EX{does done name<br/>something outside git?}
  EX -- yes --> VER[confirm the referent still exists]
  EX -- no --> LEN
  VER --> LEN[four lenses, by someone who did not write it]
  LEN --> DOOR{every capability has a door?}
  DOOR -- yes --> SHIP[cut it]
```

→ `shipping.md`

---

## How a change to this system travels

The same tasks, gates and history as any other work — and one extra rule.

```mermaid
flowchart LR
  N[a need] --> T[a task on the system stream] --> B[build] --> R[review by someone else]
  R --> P[proposed]
  P --> H{{a human merges}}
  H --> AD[adopted at the next boundary]
  P -. never .-> SELF[self-merged]
```

**Self-editing is proposed, never self-merged** → `self-maintenance.md`.

---

## Nobody waits, and nothing runs at the wrong tier

The two halves of the same decision: whether work leaves the turn, and what it runs on.

```mermaid
flowchart TD
  A[work arrives] --> Q1{longer than ~30s?}
  Q1 -- no --> DO[do it in the turn]
  Q1 -- yes --> Q2{does the next<br/>sentence depend on it?}
  Q2 -- yes --> BLOCK[keep it here — sending it away<br/>to wait is the same block]
  Q2 -- no --> Q3{will it stop at a gate?}
  Q3 -- yes --> BLOCK
  Q3 -- no --> BG[dispatch it · say what and how long]
  BG --> TALK[the conversation continues]
  BG --> OVER{overran the estimate?}
  OVER -- yes --> SAY[say so before being asked]
  BG --> DONE[result surfaces where results surface]
```

```mermaid
flowchart LR
  P[a parent on the top tier] --> W{what does the<br/>helper actually do?}
  W -- grep, extract, verify --> LOW[a tier down, or further]
  W -- reasoning the parent<br/>could not do --> SAME[the parent's tier]
  LOW --> REC[named in the record<br/>with its tier]
  SAME --> REC
```

**"Same as me" is the most expensive default available**, and it hides in the bill as ordinary
work → `dispatching.md`.

**The one tier no setting can raise is the advisor's own**, because the advisor *is* the session:

```mermaid
flowchart TD
  T[work about to start] --> WHO{who performs it?}
  WHO -- a dispatched worker --> CASC[the cascade picks its tier]
  WHO -- the advisor, in this turn --> J{judgement-heavy?<br/>a migration or takeover audit,<br/>cutting up a feature, a real decision}
  J -- no --> GO[just do it]
  J -- yes --> SAY[say so BEFORE starting:<br/>if a stronger tier exists here,<br/>this is the moment to switch]
  SAY --> OWNER{the owner switches?}
  OWNER -- yes --> GO
  OWNER -- no --> GO2[proceed anyway — an offer, never a gate<br/>and the output says where it was unsure]
```

**Named as a tier, never as a product** — the runtime may not be the one this was written on.
**A limitation stated before the work is a choice; the same one stated afterwards is an excuse.**

---

## Where a stuck agent goes

```mermaid
flowchart TD
  A[agent, stuck] --> T[tries the obvious first:<br/>retry differently, read what it skipped]
  T --> S{resolved?}
  S -- yes --> ON[carry on]
  S -- no --> E[the expert rung — often skipped,<br/>and it should not be]
  E --> AD[the advisor: routing and aggregation]
  AD --> OWN[the owner]
  A -. spend · outward · destructive ·<br/>shape of team .-> OWN
  AD --> STOP{third attempt<br/>on the same error?}
  STOP -- yes --> HAND[stop, write down what was tried,<br/>hand to a different agent or grade]
```

**Every escalation is a request with an age**, answerable later rather than living in a
conversation → `escalating.md`.

---

## Trust moves both ways, and never by itself

```mermaid
flowchart LR
  R[(a role's run record)] --> UP[runs without a second attempt ·<br/>reviews passing unchanged ·<br/>approved without edits]
  R --> DOWN[attempts climbing ·<br/>the same objection returning ·<br/>done reopened]
  UP --> PROP[proposed to the owner,<br/>with the evidence]
  DOWN --> PROP
  PROP --> OWNER{the owner answers}
  OWNER --> SET[the gate moves]
  FOUR[spend · outward · destructive ·<br/>shape of team] -. no history buys these .-> OWNER
```

**A role never loosens its own gate**, which is `nobody edits the bar they are measured against`
applied where it is most tempting to skip → `permissions.md`.
