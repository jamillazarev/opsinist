# R-{{id}} — {{one line: what is being asked, in the owner's language}}

**kind**: {{approval | review | question | decision | relay}}
**asked**: {{YYYY-MM-DD}} · **by**: {{role or human}} · **of**: {{group, or the owner}}
**blocks**: {{T-XXXXXX, or nothing}}
**status**: open

{{The body differs by kind. Delete the ones that do not apply.}}

## approval · question · decision

**Ask**: {{the question, answerable without opening anything else}}
**What turns on it**: {{what proceeds or stops when this is answered}}
{{For a decision: the options, with what each costs. Two, at most three.}}

## review

**What to look at**: {{path, or the artefact}}
**The bar**: {{what makes it acceptable — the same words the task's definition of done uses}}
**Accept or send back**, and a send-back names what to change.

## relay — one operation the worker cannot perform

**Four fields, and three of them a commit cannot skip** (`templates/company-preflight.sh` §16
refuses a `relay` whose payload, predicate or destination has no value — **a key with nothing
after it counts as missing**). Written in this order on purpose: the predicate comes before the
payload, because a check written after the artefact arrives is written to fit it.

**Predicate**: {{what makes what comes back acceptable — checkable, not "it looks right"}}
**Payload**: {{ready to run, verbatim. The prompt, the command, the exact ask — not a description of it}}
**Destination**: {{where the result lands: the path, the register row, the slide}}
**Return with it**: {{the facts the worker cannot see — for a generated asset, the model and the seed}}

**Worked example** — a launch post needs an image and the connected model draws nothing:

```markdown
# R-4F2K9Q — hero image for the launch post

**kind**: relay
**asked**: 2026-08-09 · **by**: designer · **of**: the owner
**blocks**: T-8F3KQ2
**status**: open

**Predicate**: a slate roof fills the upper third, dusk light, no text anywhere in the frame,
3:2, and the palette stays inside the brand's espresso/crema pair.
**Payload**: `a slate roof at dusk, wet after rain, warm low sun, 3:2, no text, no people`
**Destination**: `assets/posts/launch-hero.png`, and a row in `_ops/assets.md`
**Return with it**: the model and version, and the seed — `seed: none` if it exposes none.
```

**What comes back is checked against the predicate, not against what you meant** — the worker
wrote the payload, and a model judges its own output generously (`requests.md`). The answer is
*accept*, or *what to change in the payload*. Never *close enough*.

**Three attempts, then it is not a payload problem.** A third round on one point means nobody
settled what the thing has to show → `escalating.md`.

---

**Answered requests keep their body and gain the answer**, because the reasoning is the part
worth having later:

**answered**: {{YYYY-MM-DD}} · **by**: {{who}}
**Answer**: {{the decision, and one line of why}}
