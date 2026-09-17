# Visual work — structure before pixels, and a system that follows solutions

**Load when:** designing anything seen — screens, a landing page, an identity, packaging,
thumbnails, a deck.

**The failure this exists to stop:** asked to design an app, a worker went straight to high
fidelity and produced gradient placeholders — **because it skipped the structure and skipped the
real tools**.

---

## Structure first

**Run process discovery before drawing anything** → [`process-discovery.md`](process-discovery.md). For an interface it
typically surfaces: information architecture → user flows → low-fidelity wireframes → **the owner
approves the structure** → high fidelity → design system. **Discovered per project, not
hardcoded**, and the owner cuts or adds steps.

**Low fidelity comes first on purpose.** Approving structure on cheap artifacts saves the tokens
and the days that redrawing finished screens costs — and it is **where the owner's taste enters
while changing it is still cheap**.

**Tool each step by its function, and write `gap` where there is none.** A flow library for
journeys, a wireframing approach for low fidelity, a component library for high fidelity. *The
flows step going silent because the skill list only covered high fidelity is exactly the miss the
gap column catches.*

**Ask the design intake up front — never guess it.** Before a pixel: **style and mood · colour
direction · references the owner likes · anti-references, which are hard nos**. A worker that asks
only *"what stack?"* and starts drawing has skipped the questions that decide whether the output is
theirs or generic.

**One of the references is a precedent, not a picture.** A surface with a known genre — a table, a
filter, a dashboard, an onboarding, an empty state, a pricing page, a settings screen — has decades
of argument behind it, and **a plausible version of it can always be generated, which is exactly why
it gets generated**. So before drawing one, the worker reads how it is usually built
([`catalogue.md`](catalogue.md) → *The pattern for one surface* · *UX guidance & rationale* · *Design systems*), and the
reference list says which item is the precedent. **The point of knowing the pattern is to be able to
say which part of it you are breaking on purpose** — a design that departs from the genre without
knowing it is not bold, it is uninformed, and the cost is paid by every person who uses it
afterwards. Where a project does this often, it belongs on the type as a gate: `fields:
[references, anti-references]` with the precedent named inside the first.

**And arrive with candidates rather than with a blank question.** *"Send me some references"* hands
the research back to the owner, who asked for design precisely because they did not want to do it;
**an advisor proposes**, out of [`catalogue.md`](catalogue.md) → *Research & reference galleries*, three or four named
examples with one line each on what carries the feeling — then asks which are right and, just as
usefully, which are the hard nos. The owner's *no* is the cheapest signal in the whole exchange and
the one a blank question never gets. Where the project already ran style discovery, the references
are in `_ops/brand/` and `_ops/design-system/` and the proposal starts from those.

**The bar that holds this is a field on the type, not a paragraph here.** Measured on a live project
2026-09-16: design work proceeded with no references recorded anywhere and nothing asked for any —
because a sentence in a chapter is read by whoever happens to load it. A project that does design
declares it on the type and the door enforces it ([`pipelines.md`](pipelines.md)):

```yaml
stages: [design, build, review, accept]
terminal: [accept]
gates:
  design -> build:
    fields: [references, anti-references]
  review -> accept:
    review_by: non-author
```

`transition.py` refuses the move out of `design` while either field is empty, naming it. **Both
fields are required, and the empty answer is a value**: `anti-references: none stated` is a fact
about a conversation that happened; a blank is a conversation that did not.

**Compose, don't hand-draw.** Screens are assembled from a component library, not written as
one-off markup. Hand-written screens are **both slower and worse**: a library makes a screen a
composition rather than a generation.

**So the project declares where the ready-made things are, once, and nobody searches again.** The
failure this prevents has a name now — a generated interface that looks like every other generated
interface, because the worker reached for markup instead of for the kit. Three declarations, and
they are the same three every other dependency gets ([`tooling.md`](tooling.md) → *What the project needs from the
machine*):

| Declared in | What it says |
|---|---|
| `_ops/design-system/` | **the kit this product is built from** — the component library, its version, and the components already fitted to this brand |
| `_ops/TOOLING.md` | a row per source with **its licence and its ceiling** — a paid block library and a free component set are different rows and different risks |
| `_ops/brand/` | the references and anti-references style discovery produced, so a new screen argues against something |

**A worker that finds those three filled does not invent a hero section.** A worker that finds them
empty says so and asks, rather than generating — and the advisor proposes candidates out of
[`catalogue.md`](catalogue.md) → *Component libraries* and *Websites, interfaces and the small surfaces*, which is what
that shelf is for.

---

## Named styles — a pointer to references, never a substitute for them

**An owner says `Neo-Brutalism` and means something real.** The words below are the vocabulary the
current market actually uses, and an agent that cannot place them wastes a round asking what the
owner meant. **They are not a taxonomy this system owns** — each one names a *look people point at*,
and what makes it work is always the carriers: type, spacing, colour, depth, motion. So the rule is
unchanged and the shortcut is allowed: **a style name buys you the search terms; the references and
the tokens are still what gets agreed.**

| Family | Names in use | What actually carries it |
|---|---|---|
| **depth and material** | Glassmorphism · Neumorphism · Claymorphism | blur, translucency and layered shadow — **the accessibility cost lives here**: all three fight contrast, and the check is the contrast ratio, not the mood |
| **loud and deliberate** | Neo-Brutalism · Maximalism · Y2K Aesthetic · Cybercore · Cyberpunk · Synthwave | hard borders, unblended colour, visible grid or its deliberate violation, type used as a graphic object; the risk is a look that dates in a season |
| **quiet and structural** | Swiss Design · Minimalism · Editorial Design · Bento Grid | the grid and the type scale carry everything, so the spacing system *is* the design; these age best and punish sloppy hierarchy hardest |
| **hand and texture** | Scrapbook · Conceptual Sketch · Wabi-Sabi · Bohemian · Victorian | irregularity that has to be authored — a grid with jitter reads as broken, not as hand-made, so this family is the most expensive to generate and the most obvious when faked |
| **atmosphere** | Ethereal · Surrealism · Pixel Art · Luxury Typography | one carrier dominates and the rest get out of its way: light, or impossible composition, or a pixel unit, or the face itself |

```mermaid
flowchart LR
  N[a style NAME<br/>Neo-Brutalism · Glassmorphism …] --> S[search terms<br/>into the galleries]
  P[the owner points at<br/>something they like] --> R
  S --> R[3–4 references + the anti-references<br/>one line each on what carries it]
  R --> C[the carriers: type · spacing<br/>colour · depth · motion]
  C --> T[tokens in _ops/design-system/]
  N -. never .-> T
```

**How this is meant to be used, in order**: the owner names a style, **or sends a picture** · the
name becomes search terms in the galleries ([`catalogue.md`](catalogue.md)) · **three or four references come back with
one line each on what carries the feeling**, plus the anti-references · the carriers are extracted
into tokens in `_ops/design-system/`. **The name is never the deliverable.**

**Four rules make this a mechanic instead of a mood**, each read off somebody else's working skill
(2026-09-17, sources in [`catalogue.md`](catalogue.md)):

1. **A look ships its own falsifier.** Beside what it is, write what its presence forbids — *Swiss
   breaks if warm paper, a serif display face, grain or centred typography appears.* A style
   description with no `Breaks if` line cannot be wrong, and a description that cannot be wrong
   cannot be checked against the tokens a project already has.
2. **The name resolves to tokens, and the tokens still face the same gates as everything else.**
   Contrast, focus order, target size: **taste never overrides accessibility**, and the three
   depth-and-material looks are where that bill arrives.
3. **A style read names what it rejected.** *"Clean"*, *"modern"*, *"minimalist"*, *"elegant"* are
   not findings — they are the words people reach for instead of one. A read is accepted when it
   cites the carriers it measured, the plausible alternative it turned down, and **one restraint
   finding**: something comparable work does that this deliberately does not.
4. **A style rule ships as a count with a threshold and one named override, or it is not a rule.**
   *One accent hue · zero radii off the scale · zero emoji in chrome · zero gradients without a
   stated purpose · no duplicate labels* — **a failed count is a fix, not a judgement call**, which
   is what makes it survivable for a worker who has no taste to appeal to. And each carries its one
   legitimate override: the brand explicitly asks for it *and* the reason can be said in a sentence.
   Without the override clause the rule gets broken silently the first time it is wrong; with it,
   breaking it is a visible claim.
5. **Breadth is not fidelity.** A published vocabulary was measured carrying a `glassmorphism` row
   whose only value was a primary colour — no blur, no translucency, the two carriers that define
   it. **A row that names a look and misses its carrier is worse than no row**, because it reads as
   an answer.

**A picture is evidence; the name is a citation.** When the owner sends a screenshot rather than a
word, the order does not change and the first step is not naming: measure the carriers — palette by
role, type classification, radius, shadow construction, spacing base, motion — write them as tokens,
and *then* reach for a name, with a confidence marker and the carriers that did not match. Eyes win
over the DOM where the two disagree.

**One file is the source, every machine format is generated from it.** The carriers live once, in
`_ops/design-system/`, in the **[DTCG](https://www.designtokens.org/tr/drafts/format/) token
shape** (`$value` + `$type`, aliases, composite shadow and typography) — and CSS variables, a
Tailwind config, a deck theme and a social template are **emitters**, never second copies. The
format's own `$extensions` clause is what makes this survive: a tool must preserve extension data it
does not understand, so a project's style provenance — which reference, which carriers matched, what
was rejected — rides inside the tokens rather than in a parallel document. **And sync is a check,
not a promise**: a component citing `var(--…)` that the token file does not carry is a defect a
script can find, which is the only version of *"keep the brand consistent"* that ever holds. Two projects saying
`Minimalism` mean different things, and the tokens are where the difference stops being an
argument — which is the same rule the catalogue's own *method, not a baked-in taxonomy* line has
always stated, with a vocabulary attached so nobody has to bluff.

**The gate rejects; it does not rubber-stamp.** A review that passes bad design is not a review. It
checks the work against **the approved structure, the intake, and the design system** — a mismatch
fails it. **The advisor never signs off design itself; the owner does**, at the checkpoint their
control level set. **"It rendered" is not "it's good."**

---

## The design system follows solutions

Any project that ships a repeatable form accumulates one: **tokens** (colour, type, spacing,
motion — or a palette and a cover grid), **components or templates** (interface parts, thumbnail
layouts, packaging, letter formats), and **a catalogue**.

**It is not designed up front. It accumulates from what shipped**, and the curator is the design
lead or the sole designer.

**Reuse-first, at specification time.** Discussing *any* solution, answer explicitly: **covered by
the existing system, or does this need an extension?** Default is reuse; an extension is a
**deliberate, argued decision recorded in the spec** — what is added and why the existing pieces do
not fit. **The system grows by argument, never as a side effect.**

**Three origins — build · adopt · inherit.**

**Building your own** is the default here.

**Adopting a ready-made system** — a platform's guidelines, a franchise brand book, a publisher's
style guide: **the host's guidelines become law**, and the conventions file records **host +
version + our delta layer**. Extensions live in a **separate, documented layer that follows the
host's own philosophy and naming** — **never restyle or reinterpret host semantics, which is
exactly how teams drift away from the host they adopted**. When the host ships a new version, treat
it like an upgrade: **preview the diff and its impact on the delta layer before applying**.

**Inheriting an existing own system** — typical when joining: audit and prepare exactly like a
takeover. Inventory tokens, components and templates; **a verdict per piece — complete, needs
additions, needs rework**; wire the conventions; only then extend.

**Systematize in the same unit of work.** A shipped solution that introduced new patterns gets a
systematization child in **that** piece of work: new tokens documented, one-offs promoted to
components or **marked as deliberate exceptions**, stale pieces pruned.

**Systematization is ordinary work with a review.** Built by whichever craft owns the medium —
code tokens by an engineer, cover templates by a designer, a voice guide by a copywriter — and then
**reviewed by the curator** before it merges into the system. Same pattern in every domain:
whoever systematizes, the curator reviews.

**One component standard, fixed when the system is switched on.** The curator seeds the
conventions: naming, **one props convention** borrowed from the chosen stack's idioms, state names,
and **a single documentation shape per component** — anatomy · properties · variants · states ·
tokens used · do and don't. **Every component, whoever made it, is documented to that shape.**
Mixed conventions — one component in one style, another improvised — are exactly what this kills.

**Consult real-world component catalogues before inventing component names and APIs.** Someone has
already had this naming argument.

**Design QA checks against the system**: implementations use tokens and components, not hardcoded
values; **a deviation is either fixed or argued into the system**.

**An annotated overlay carries its labels on the image itself.** A screenshot with marked
zones — a predicted-attention map, a QA markup — states each zone's kind on the pixels:
`counted` (a contrast ratio, a tap-target) · `predicted` (a model's guess, and which class of
model) · `panel` (personas, direction-only), with the provenance line in a corner. **An image
separated from its prose is a lossy copy of the claim** — forwarded alone, a prediction travels
as a fact — and the label on the pixels is the only rung that survives the forward. A
*continuous* heatmap is a model run, which makes it a tool: it enters through the import gate
like any tool, never silently inside a consultation ([`catalogue.md`](catalogue.md) — visual hierarchy &
predicted attention).

**Assets obey the same conformance.** One icon set, one illustration style, one photographic look,
widening only on a real gap — **mixing reads as amateurish exactly the way hardcoded values do** —
and **every shipped asset is recorded with its licence**.

---

## Brand — systematized, not a folder of moodboards

**Home is the project's brand documentation**, and it does not stay there: **its formal elements
flow into the design system** (palette and type become tokens, formats become templates) and **its
verbal rules flow into the guide**, so every worker writes in the brand voice by default. **Brand
dissolves into two places rather than sitting in one.**

**What is load-bearing in the book:** positioning (for whom · what · against what · why believe) ·
**an archetype — a shorthand workers can act on**, not decoration · personality sliders with
recorded positions · **tone of voice: three to five words plus a sample paragraph per register —
executable examples, not adjectives** · values, short · **references and anti-references, where
anti means hard bans** · tagline and naming rules.

**Workshop artifacts are discovery input, not the book.** Competitor teardowns, *"what we dislike
about the old one"*, metaphor boards — they feed it and are **distilled into it**; they are not it.

**New brand** → discovery → book → **owner approval, because identity is outward** → systematize.

**Existing brand** → **audit first, never rebuild**. Inventory logo, palette, type, voice,
positioning; **a verdict per piece — complete, needs additions, needs rework**; fill only the gaps
the owner confirms. **An existing brand is incumbent convention, and it is respected.**

**Rebrand** gets its own discovery pass, with two devices worth having: **a change-magnitude score
from one to ten** — evolution versus revolution, **and it scopes everything downstream** — and an
explicit **keep/change list**. Then three to five candidate directions, and **the owner picks**.

**A creator or a small brand gets the same structure scaled down**: positioning, voice, a visual
kit, and **material templates** — story, post, cover formats — living in the design system like any
other component.

---

## A generated asset carries its recipe

**A generated image whose recipe was not written down is unrepeatable, and that is how a style
dies quietly.** Nobody notices on the day. A month later somebody needs the second banner in the
set, the model has moved, the prompt is gone, and what comes back is *close but not it* — so the
set stops matching, and no single decision was ever made to let it.

**So a generated row in `_ops/assets.md` says `origin: generated` and carries four things
beside the licence.** The `origin:` is what makes the row findable — `origin: drawn` · `stock` ·
`generated` — and it is the field the commit gate selects on, because a list of model vendors
goes stale between releases while a field does not. **A row that predates this and merely says
*generated* in its source is still caught**, so nothing silently stops being checked:

| | |
|---|---|
| `model` | the exact model or endpoint, version included — `flux-1.1-pro`, not "the fal one" |
| `prompt` | **verbatim, the whole string.** Not a description of it |
| `seed` | the number, or **`seed: none`** where the model exposes none — an honest answer, and the only other one accepted |
| `reference` | the path or url of a style/reference image, where one was used — **this, not a preset name, is what actually makes two images match** ([`catalogue.md`](catalogue.md) → *Style presets*) |

**This is a field, not an instruction to be careful**, and it is enforced where the project can
see it: `templates/company-preflight.sh` refuses a commit whose asset register declares a row
`origin: generated` — or, for a row written before that field existed, merely says *generated* —
and carries no recipe. **The two doors are the same two as everywhere**: write the recipe, or
write `seed: none` — one edit, needing no new information.

**Why a field and not a sentence:** the cheap answer is impossible to write. *"Generated with AI"*
satisfies nothing, and a prompt cannot be reconstructed from memory without visibly being generic
— the same property that made *what did the page say* work where *what did you check* was answered
with three fabricated dates ([`self-maintenance.md`](self-maintenance.md)).

**Recovery, when a recipe is already lost, is the expensive repair** — a vision model reads the
image back into words ([`catalogue.md`](catalogue.md) → *Image → prompt*), and what comes out is a new prompt that
resembles the old one, never the old one. **It is a salvage route, not a substitute for the
field.**

```mermaid
flowchart TD
  ASK[make another one like that] --> Q{does the asset<br/>carry its recipe?}
  Q -- yes --> RUN[model · prompt · seed · reference<br/>run again]
  RUN --> SAME[the same image, or the same family]
  Q -- no --> SALV[read the picture back<br/>into words with a vision model]
  SALV --> NEAR[a prompt that resembles the old one]
  NEAR --> DRIFT[close but not it —<br/>the set stops matching]
  PRE[a style preset name] -. never enough on its own .-> DRIFT
  GATE[[company-preflight §15:<br/>a generated row with no recipe<br/>refuses the commit]] --> Q
```

**The preset is a vocabulary, the recipe is the mechanism, and salvage is the expensive repair.**
This diagram lives here rather than in the gallery because [`diagrams.md`](diagrams.md) is at its line budget —
and a diagram beside the rule it draws is not a worse home for it.
