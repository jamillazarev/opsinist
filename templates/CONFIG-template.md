# Project configuration

**What this file is:** the settings a project resolves against, and the log of what has been
migrated. It is read on every session and edited rarely — **the layout has always promised it;
until `0.1.5` nothing wrote it.**

## Conventions

- **Git host:** {{github · gitlab · none}}
- **Modules on:** {{only what the interview named; everything else is off until asked for}}
- **Labels · ladder · naming:** {{the project's own, where it has one — an incumbent convention
  that works is not a defect}}

## Settings

| Setting | Value | Notes |
|---|---|---|
| `spec_mode` | {{outcome}} | **the cut on the description ladder** — `outcome` · `spec` · `example`, **cumulative**: the value names the highest surface, and each type may refine the cut at its own wave. **A binding is written beside the cut, answering its three questions in one line** — e.g. `spec_mode: spec (binding: openspec — changes live at openspec/, a task links its change id, closing archives the folder)`. **Absent reads as `outcome`.** Changing it later puts every task already written in scope → `writing-work.md` |
| `read_threshold_lines` | {{10000}} | past this, reading everything is announced rather than performed → `entering.md` |
| `schema_version` | {{1}} | the format this repository is on |

## Migrations

**Append-only, one line per step, newest last. A re-run appends; it never edits a line.**
Outcome is one of five: `applied` · `nothing-required` · `declined` · `deferred` · `failed`.
A `declined` line's reason lives in `_ops/DECISIONS.md` with its revisit-if; a `deferred` one's
sits in `LATER.md` with a moment for a trigger. → `upgrading.md`

- {{— → 0.1.5 · 2026-08-01 · applied · you@example.com}}
