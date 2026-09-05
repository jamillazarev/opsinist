# {{name}} — {{the craft, in the project's own words}}

**Type**: {{worker · expert · persona · human · advisor}} · **Grade**: {{junior · mid · senior}}
**Model · effort**: {{unset — inherits the project default}} · **May dispatch**: {{no}}

> [!NOTE]
> **Unset is a real answer and usually the right one.** A role that names its own model pins a
> choice the cascade would otherwise make correctly, and the resolved value is recorded on every
> run anyway — so `project → team → role → task` stays one law rather than nine settings.

## What it is for

{{One paragraph. The craft it holds, and the kind of work that should reach it.}}

## Bars

- **Ready when** work reaches it: {{what must be true before it can start}}
- **Done when** work leaves it: {{the craft gates this role is accountable for}}

> [!CAUTION]
> **These are locked** — proposed to a human, never edited by whoever works under them
> (`permissions.md`). A role that can move its own bar is measured against nothing.

## Skills attached

> **The guard reads this table and the `**Type**` line above it.** `_ops/scripts/preflight.sh`
> counts the rows under a `Skills attached` heading of any depth, and refuses a second advisor.
> A file written as YAML frontmatter (`type:` / `skills:`) is still read, as the legacy shape; it
> appears in no template and no example, so this is the form to write. **Until 0.2.15 only the
> YAML shape was read** — and miscounted — so a role written the way this template instructs met
> neither check, which is why a project may meet both for the first time on upgrading.

| Skill | Why this role needs it |
|---|---|
| {{name}} | {{the step it covers}} |

> [!WARNING]
> **Every one loads on every run this role makes**, needed or not — the load budget is a share of
> the window. Past about eight, the signal is usually a missing hire rather than a busy role.

## Trust

**Gates it clears without asking**: {{none at first}} · **Evidence**: {{the runs behind that}}

> [!CAUTION]
> Trust moves both ways on the record, **a role never loosens its own gate**, and no history buys
> the four owner-gated kinds: spend, anything leaving the repository, anything destructive, and
> anything that changes the shape of the team.
