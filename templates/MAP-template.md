# {{Product}} — the map

**Why this file exists:** every task starts with no memory of how this product is walked, so a
flow not written here is re-derived — or worse, invented — by every agent that touches one.
**Every node below names something that exists**; a node for something being built lives in the
task building it, and lands here in the task that ships it. **Current state only** — the roadmap
points at nodes it will change; nothing planned is drawn here.

## The moves

{{One line per top-level move; a move that outgrows its section becomes `docs/map/<move>.md` and
keeps one line here.}}

### {{move, in the product's own words — "order to pickup", not "checkout funnel"}}

```mermaid
flowchart LR
  A[{{where it starts}}] --> B[{{step}}] --> C[{{where it ends}}]
```

{{Per-node notes where a node needs one: what it is, where it lives, a still or a pointer to the
design file. Delete the section rather than leave it empty.}}

## The things

{{What the product is made of and how the things relate — an entity diagram for software, a plain
list with relations for everything else.}}

```mermaid
erDiagram
  {{THING}} }o--o{ {{OTHER}} : {{relation}}
```

## What is not mapped yet

**A map that does not say where it ends is read as if it ended nowhere.** A claim about anything
listed here is `unknown`.

- {{move or area}} — {{why: "not walked yet", "outside every corridor so far"}}

**Delete an entry in the task that maps it.**
