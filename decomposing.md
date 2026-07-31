# Decomposing — cutting work into pieces

**Load when:** a task is too big for one run, spans more than one craft, or needs several things
done before one of them can start.

**A task must fit one run.** Work that cannot finish in one is decomposed, **not hoped through**.
That is the first reason to cut, and the only one that is not a judgement call.

---

## Children are tasks

Not checklist lines. The test is unchanged: **a unit of work has an assignee, a thread, runs and
a cost; a checklist line has none of those.** So a child gets the same id, the same fields, the
same history and its own thread — at every depth.

**Flat directory, hierarchy in a field.** `parent` is a value, not a folder, so **re-parenting is
a one-line edit** rather than a file move that breaks every inbound link.

## Depth is allowed, and three things keep it honest

Nest as deep as the work is: a task, a child, a child of that. The old one-level limit came from
a system where the barrier was a number on the child, and depth broke it. Here **the barrier is
the wave and waves are per parent**, progress is the same computation at every level, and the
board is generated — so depth costs nothing structurally.

What it does cost is honesty, and three rules pay for it:

**Every level carries a real definition of done**, or it is a folder pretending to be work. This
is the same test that decides whether a parent may close itself, which is a good sign it is the
right test.

**"Own" and "including children" are labelled, always.** At depth, *"this cost N"* without the
label gets more wrong with every level.

**An audit flags a tree deeper than three as a smell, not a violation.** Usually it means a piece
has outgrown being a piece.

**Promote what outgrew itself; do not nest deeper** (`PATTERNS.md` §23). When a child needs
children of its own and a life of its own, it stops being a child — it becomes a task in its own
right (`templates/TASK-template.md`): remove the parent link and it
is a task. One field, and every link still resolves because links point at the id.

---

## Waves — the barrier

**A wave is a barrier, not a queue.** Everything genuinely independent goes in **the same wave**
and runs together; **the numbers order dependencies, not tasks.**

```
parent: T-8F3KQ2
  wave 1  index the data                    backend
  wave 1  build the acceptance set          analyst
  wave 1  design the empty and error states designer
  wave 2  ranking against the acceptance set backend
  wave 3  review: code                       QA
  wave 3  review: design and accessibility   design lead
```

Wave 1 has three items because none needs the others. Ranking is wave 2 **only because it
genuinely needs the index**. Wave 3 is two rows rather than one because **a gate that can
independently reject the work is its own child with its own single owner** — that is what makes
gates parallel instead of a queue.

**Two children in the same wave never own the same file.** This is what makes a wave safe to run
in parallel, and it is decided **at decomposition**, not discovered at merge.

**Completing a wave does not start the next one.** It **surfaces** as ready and waits, like every
other transition.

**`wave`, not `stage`.** One word cannot mean both the step of a pipeline and the parallel group;
the corpus that used one word for both paid for it.

---

## Who cuts, and who ends up owning

**Decomposition belongs to whoever owns the outcome** — the split is a judgement about the work,
and only the owner of the result has it.

**Children are addressed to groups, and routing runs again** — possibly into other groups
entirely → `addressing.md`.

**Leaves have owners; parents may not.** A parent spanning several crafts is nobody's craft, so
it stays unassigned, and that is the shape rather than a defect. It gives one testable
invariant: **an unassigned leaf is a finding; an unassigned parent with children is normal.**
A group in the `assignee` field means "not decided yet", which is legitimate on a parent and a
finding on a leaf.

**The advisor never holds it.** Where nobody owns the outcome yet, it decomposes and hands each
child to a real owner — then leaves the picture.

---

## The build produces what the review needs

Whatever the reviewer must see to judge it is **produced by the builder**: screenshots
of every state, a recording, the numbers before and after, the command that reproduces it.

Without it the review gate has nothing to review and bounces the work — which costs two runs
instead of one and looks like a quality problem when it is a handoff problem.

**Gate only what a unit of work can violate.** A gate that checks something no single piece
controls will fail on pieces that did nothing wrong, and people learn to route around it.

---

## Sizing

**Too small** and coordination costs more than the work. **Too large** and the piece runs a long
time before anyone can tell whether it is going anywhere. **Right** is a self-contained unit
producing a clear deliverable — a screen, a test file, a review, a decision.

**Start low on grade when difficulty is unclear** and let the review gate return *"needs a higher
grade"* → `hiring.md`. Guessing the grade before the work is a guess; failing the review is
information.
