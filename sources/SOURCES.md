# Sources register

The evidence behind the skill's slow-rotting claims. Every claim the skill makes about the
outside world that will **not** change week to week has an entry here; *"where did you get this?"*
is answered from this file, in any phrasing (skills/advisor/SKILL.md → the laws).

**What belongs here — and what never does.** The register holds **slow-rotting canon only**:
findings, methods and standards that age in years. **Fast-rotting facts never enter** — a price, a
current API limit, a competitor's live feature stay *fetch-at-decision-time* rules, quoted with
their check-date at the moment of use, never cached here to rot.

**One fixed form per entry**, so a wrong entry is visibly wrong:
**id · full citation · live URL/DOI/arXiv · archive link · licence · one-paragraph distillate
(our words) · check-date · cited-by**.

**Cited-by names files, never line numbers.** A line number is wrong the next time anything above
it is edited, and every entry here once pointed at a line — in files that no longer exist. The
durable form is the file that carries the claim; the id is greppable when the exact place is
wanted.

**Licence tiers** (they decide what we may hold): **free** — an open licence (MIT, CC, a public
standard); a copy may be carried later. **copyrighted** — citation + archive link + our own
distillate, never the text itself. **math** — a formula recorded by name, which is not
copyrightable. Each entry states its tier.

**Upkeep.** `scripts/fetch-source.py` builds and checks these entries: `--resolve <doi|arxiv|url>`
prints a skeleton, `--archive <url>` triggers a Wayback snapshot, `--verify` walks every live URL.
`--verify` runs at every release (AGENTS.md → The release ritual).

---

## Strategy and discovery frames — the canon behind the catalogue rows

### torres-ost · Torres, Opportunity Solution Trees
- **Citation:** Torres, T. "Opportunity Solution Trees: Visualize Your Discovery." Product Talk; and *Continuous Discovery Habits* (2021).
- **Live:** https://www.producttalk.org/opportunity-solution-trees/
- **Archive:** not pinned yet — pin at the next audit
- **Licence:** copyrighted — cite + our distillate
- **Distillate:** One desired outcome → the opportunity space (customer needs, mapped before features) → solutions → assumption tests. The layer teams skip is opportunities; the failure mode is jumping insight-to-solution. The tree is the discovery spine for outcome-oriented teams.
- **Check-date:** 2026-08-06
- **Cited-by:** process-discovery.md · catalogue.md · templates/SPEC-template.md

### helmer-7powers · Helmer, 7 Powers
- **Citation:** Helmer, H. *7 Powers: The Foundations of Business Strategy* (2016).
- **Live:** https://7powers.com
- **Archive:** not pinned yet — pin at the next audit
- **Licence:** copyrighted — cite + our distillate
- **Distillate:** Seven durable sources of differential margin — scale economies · network economies · counter-positioning · switching costs · branding · cornered resource · process power. The current firm-level canon for "why does this position endure"; each power has a benefit and a barrier, and a claim without the barrier named is not a power.
- **Check-date:** 2026-08-06
- **Cited-by:** catalogue.md

### morningstar-moats · Morningstar's economic moats (Stoffel's teaching table)
- **Citation:** Morningstar's five-moat taxonomy (intangibles · switching costs · network effect · cost advantage · efficient scale), widely circulated via Brian Stoffel's wide/narrow/no-moat table.
- **Live:** https://www.morningstar.com/investing-definitions/economic-moat
- **Archive:** not pinned yet — pin at the next audit
- **Licence:** copyrighted — cite + our distillate
- **Distillate:** The older valuation lens: five moat types graded wide/narrow/none per company. Useful as a shared vocabulary and a checklist; weaker than 7 Powers at explaining *why* a moat holds. Source of the "no moat" honesty: name recognition without pricing power is not a moat.
- **Check-date:** 2026-08-06
- **Cited-by:** catalogue.md · templates/COMPETITORS-template.md

### kaushik-stdc · Kaushik, See-Think-Do-Care
- **Citation:** Kaushik, A. "See, Think, Do, Care: A New Content, Marketing and Measurement Model." Occam's Razor.
- **Live:** https://www.kaushik.net/avinash/see-think-do-content-marketing-measurement-business-framework/
- **Archive:** not pinned yet — pin at the next audit
- **Licence:** copyrighted — cite + our distillate
- **Distillate:** Intent-based content planning: audiences clustered by intent (See — largest addressable, Think — considering, Do — ready, Care — customers) with content and measurement per cluster. The modern reach where an awareness ladder feels dated; frame-level, not persona-level.
- **Check-date:** 2026-08-06
- **Cited-by:** catalogue.md

### perspective-ost-2026 · the starving-tree finding
- **Citation:** Perspective AI. "The Opportunity Solution Tree in 2026: A Practical Guide for Continuous Discovery" (2026).
- **Live:** https://getperspective.ai/blog/opportunity-solution-tree-2026-practical-guide-continuous-discovery
- **Archive:** not pinned yet — pin at the next audit
- **Licence:** copyrighted — cite + our distillate
- **Distillate:** The commonest 2026 failure is not drawing the tree wrong but **starving it**: opportunity spaces refreshed quarterly at best under a weekly-moving market. A vendor's practice guide, not a study — the rung is `cited`, and the claim is carried as the craft's practice literature, not as measurement.
- **Check-date:** 2026-08-06
- **Cited-by:** process-discovery.md

---

## Persona theatre — grounding, fidelity, and the limits of synthetic audiences

### park-self-reports · Park et al., self-report-grounded individual simulation
- **Citation:** Park, J.S., et al. "LLM Agents Grounded in Self-Reports Enable General-Purpose Simulation of Individuals." arXiv:2411.10109 (2024; v1 was "Generative Agent Simulations of 1,000 People").
- **Live:** https://arxiv.org/abs/2411.10109
- **Archive:** http://web.archive.org/web/20260726212521/https://arxiv.org/abs/2411.10109
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Agents built from a person's **own self-reports** reproduce that person's survey answers at **83%** (interview-grounded) / **82%** (survey-grounded) / **86%** (both) of the person's two-week test-retest ceiling, versus **74%** for demographics-only; a free-text "persona paragraph" scores **0.71**, below even the demographics baseline (0.74). Self-report grounding also **reduces accuracy disparities** across racial and ideological groups. The takeaway the skill leans on: the grounding artifact — the interview transcript — *is* the product, not a written bio.
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md · templates/PERSONA-template.md

### park-hai-brief · Park et al., Stanford HAI policy brief
- **Citation:** Park, J.S., et al. "Simulating Human Behavior with AI Agents." Stanford HAI Policy Brief (May 20, 2025).
- **Live:** https://hai.stanford.edu/policy/simulating-human-behavior-with-ai-agents
- **PDF:** https://hai.stanford.edu/assets/files/hai-policy-brief-simulating-human-behavior-with-ai-agents.pdf
- **Archive:** http://web.archive.org/web/20260412141409/https://hai.stanford.edu/policy/simulating-human-behavior-with-ai-agents (PDF: http://web.archive.org/web/20260607042745/https://hai.stanford.edu/assets/files/hai-policy-brief-simulating-human-behavior-with-ai-agents.pdf)
- **Licence:** copyrighted (Stanford HAI, free to read) — cite + archive + our distillate
- **Distillate:** The policy brief frames the **consent machinery** for simulating individuals and legitimizes the **AI-conducted interview** as the grounding step. It matches the v1 ("1,000 People") framing and carries the stronger **"demographic personas amplify stereotype bias"** phrasing that the current peer-reviewed version later softened to "reduces accuracy disparities" — which is why the skill attributes the sharper claim to the brief, not the paper.
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md · templates/PERSONA-template.md

### ashokkumar-nature · Ashokkumar et al., direction not magnitude
- **Citation:** Ashokkumar, A., Hewitt, L., Ghezae, I., Willer, R. Nature (advance online publication, 2026-07-08). doi:10.1038/s41586-026-10742-x.
- **Live:** https://doi.org/10.1038/s41586-026-10742-x
- **Archive:** pending (Save Page Now triggered 2026-07-27; availability: https://archive.org/wayback/available?url=https://doi.org/10.1038/s41586-026-10742-x)
- **Licence:** copyrighted (Springer Nature) — cite + archive + our distillate
- **Distillate:** Across a large replication set, LLM simulations track the **direction** of experimental effects at about **r≈0.85** while **systematically overestimating their magnitude**. This is the evidence for the theatre's hardest rule: a synthetic verdict may state direction, **never a magnitude** (no "23% would churn").
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md · skills/advisor/SKILL.md (the second pyramid)

### ls-types · Lewis & Sauro, a taxonomy of synthetic users
- **Citation:** Lewis, J., Sauro, J. "What Are the Different Types of Synthetic Users?" MeasuringU (2026-06-23).
- **Live:** https://measuringu.com/what-are-the-different-types-of-synthetic-users/
- **Archive:** http://web.archive.org/web/20260624073122/https://measuringu.com/what-are-the-different-types-of-synthetic-users/
- **Licence:** copyrighted (MeasuringU) — cite + archive + our distillate
- **Distillate:** Names five types of synthetic user — AI proto-persona, demographic-based, persona-based, research-grounded, and digital twin — ordered by the **strength of their tie to real human data**. This is the stage vocabulary the theatre uses (proto vs validated vs twin).
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md

### ls-review · Lewis & Sauro, a review of synthetic-user experiments
- **Citation:** Lewis, J., Sauro, J. "A Review of Experiments with Synthetic Users." MeasuringU (2026-04-14).
- **Live:** https://measuringu.com/review-of-experiments-with-synthetic-users/
- **Archive:** http://web.archive.org/web/20260512065453/https://measuringu.com/review-of-experiments-with-synthetic-users/
- **Licence:** copyrighted (MeasuringU) — cite + archive + our distillate
- **Distillate:** Reviews ~12 recent experiments with synthetic users and finds mixed results, with synthetic responses showing **artificially low variability** and **distorted magnitudes** relative to real respondents — so they can indicate direction but not the size of an effect. (Their framing — low variability and distortion — is what the skill states, *not* "clustering toward neutral.")
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md

<!-- Mahajan restore point: an earlier draft credited a "Mahajan synthetic-users taxonomy" by
     name only. Research (2026-07-27) could not locate any such work in the checked venues
     (ACM Interactions = Russell; MeasuringU = Lewis & Sauro; NN/g = Rosala & Moran), so the
     low-variability / direction-over-magnitude claims were re-attributed to Lewis & Sauro
     (ls-types, ls-review) above. Those claims now live in audience.md. If the original Mahajan
     source ever surfaces, add it as its own entry here and re-attribute them. -->

### sharma-sycophancy · Sharma et al., sycophancy is trained in
- **Citation:** Sharma, M., et al. "Towards Understanding Sycophancy in Language Models." ICLR 2024. arXiv:2310.13548 (2023).
- **Live:** https://arxiv.org/abs/2310.13548
- **Archive:** http://web.archive.org/web/20260725125159/https://arxiv.org/abs/2310.13548
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Sycophancy — telling the user what they want to hear — is a **trained-in property** of RLHF'd assistants, consistent across several models and tasks. A persona built on such a model **inherits that compliance**, which is why the theatre's calibration layer suppresses sycophancy explicitly (a synthetic respondent is a pleaser unless corrected).
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md · skills/advisor/SKILL.md (useful over agreeable)

### tjuatja-biases · Tjuatja et al., LLM response biases ≠ human ones
- **Citation:** Tjuatja, L., et al. "Do LLMs Exhibit Human-like Response Biases? A Case Study in Survey Design." TACL 12 (2024). arXiv:2311.04076 (2023).
- **Live:** https://arxiv.org/abs/2311.04076
- **Archive:** http://web.archive.org/web/20260116061015/https://arxiv.org/abs/2311.04076
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Tests whether LLMs reproduce known **human survey response biases** (acquiescence, question-order effects) and finds their biases **do not reliably mirror human ones** — sometimes absent, sometimes inverted. Caveats how far a synthetic survey respondent can stand in for a human one.
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md

### argyle-silicon · Argyle et al., silicon sampling and its diversity limits
- **Citation:** Argyle, L.P., et al. "Out of One, Many: Using Language Models to Simulate Human Samples." Political Analysis (2023). doi:10.1017/pan.2023.2.
- **Live:** https://doi.org/10.1017/pan.2023.2
- **Archive:** pending (Save Page Now blocked HTTP 523 on 2026-07-27; availability: https://archive.org/wayback/available?url=https://doi.org/10.1017/pan.2023.2)
- **Licence:** copyrighted (Cambridge University Press) — cite + archive + our distillate
- **Distillate:** Introduces **"silicon sampling"** — conditioning an LLM on demographic backstories to simulate human survey samples — and shows it can reproduce some subgroup patterns while **collapsing within-group diversity**. Backs the caution that synthetic samples flatten variety rather than represent it.
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md

### wang-flattening · Wang et al., identity flattening
- **Citation:** Wang, A., Morgenstern, J., Dickerson, J.P. "Large language models that replace human participants can harmfully misportray and flatten identity groups." Nature Machine Intelligence (2025). arXiv:2402.01908.
- **Live:** https://arxiv.org/abs/2402.01908
- **Archive:** http://web.archive.org/web/20260607174738/https://arxiv.org/abs/2402.01908
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence; journal © Springer Nature) — cite + archive + our distillate
- **Distillate:** Finds that using LLMs to replace human participants can **harmfully misportray and flatten identity groups** — reproducing majority stereotypes and erasing within-group variation. This is the direct evidence for the **never-assign-a-bias-from-demographics** rule: a demographic backstory produces a caricature, not a person.
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md

### kapania-simulacrum · Kapania et al., LLMs as qualitative participants
- **Citation:** Kapania, S., et al. "'Simulacrum of Stories': Examining Large Language Models as Qualitative Research Participants." CHI 2025. arXiv:2409.19430 (2024).
- **Live:** https://arxiv.org/abs/2409.19430
- **Archive:** http://web.archive.org/web/20260411143601/https://arxiv.org/abs/2409.19430
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Treating LLMs as **qualitative research participants** yields plausible but hollow "simulacra of stories" that miss the lived specificity of real interviews. Marks the boundary of synthetic personas in qualitative work — a **supplement, never a replacement** for a real transcript.
- **Check-date:** 2026-07-27
- **Cited-by:** audience.md · templates/PERSONA-template.md

## Cost routing — cheap-first, conditional on a good verifier

### frugalgpt · Chen, Zaharia & Zou, FrugalGPT
- **Citation:** Chen, L., Zaharia, M., Zou, J. "FrugalGPT: How to Use Large Language Models While Reducing Cost and Improving Performance." arXiv:2305.05176 (2023).
- **Live:** https://arxiv.org/abs/2305.05176
- **Archive:** http://web.archive.org/web/20260722202256/https://arxiv.org/abs/2305.05176
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** A **cascade** that queries cheaper models first and escalates only on low confidence can **match the best single model's accuracy at up to −98% cost**. The evidence for cheap-first-then-escalate routing at decomposition.
- **Check-date:** 2026-07-27
- **Cited-by:** cost.md · dispatching.md

### routerbench · Hu et al., RouterBench
- **Citation:** Hu, Q.J., et al. "RouterBench: A Benchmark for Multi-LLM Routing Systems." arXiv:2403.12031 (2024).
- **Live:** https://arxiv.org/abs/2403.12031
- **Archive:** http://web.archive.org/web/20260606022825/https://arxiv.org/abs/2403.12031
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** Cascades beat both any individual LLM and a zero-cost router **only when the verifier is good** — judge error **≤0.1**, deteriorating past **0.2**. The load-bearing caveat: cheap-first routing is **conditional on a good verifier**. In the skill, the **review gates are that verifier**, so the condition is already met — the caveat reads as a strength, not a risk.
- **Check-date:** 2026-07-27
- **Cited-by:** cost.md · dispatching.md

## Repository context files

### agentsmd-eth · Gloaguen et al., do AGENTS.md files help?
- **Citation:** Gloaguen, T., Mündler, N., Müller, M.N., Raychev, V., Vechev, M. (ETH Zurich). "Evaluating AGENTS.md: Are Repository-Level Context Files Helpful for Coding Agents?" arXiv:2602.11988 (v2, 2026-06-23).
- **Live:** https://arxiv.org/abs/2602.11988
- **Archive:** http://web.archive.org/web/20260711121106/https://arxiv.org/abs/2602.11988
- **Licence:** copyrighted (author © under arXiv's non-exclusive distribution licence) — cite + archive + our distillate
- **Distillate:** A coding-agent benchmark finds repository-level context files (AGENTS.md) **do not improve task success rates** and add roughly **+20% inference cost**; **LLM-generated** context files perform **slightly worse** than none. The evidence behind "curate the shared guide, don't autogenerate it."
- **Check-date:** 2026-07-27
- **Cited-by:** project-layout.md · AGENTS.md

## Method provenance and standards (references, not evidence claims)

### method-provenance · adapted methods, nothing embedded
- **Citation:** cookiy — `user-research-skill` (MIT). agentman — "Synthetic Persona Creator" skill (concepts only).
- **Live:** https://github.com/cookiy-ai/user-research-skill · https://agentman.ai/agentskills/skill/synthetic-persona-creator (owner-confirmed 2026-07-27; page verified live: three-layer persona architecture — identity foundation · context seeding · response calibration — plus panel distribution)
- **Archive:** http://web.archive.org/web/20260411081018/https://github.com/cookiy-ai/user-research-skill
- **Licence:** free — cookiy's `user-research-skill` is **MIT** (a copy may be carried later; today only the method shape is adapted, nothing embedded). agentman: **no licence stated on the page**; concepts taken, nothing embedded (no code carried, so no licence obligation).
- **Distillate:** Method lineage, not evidence. cookiy's MIT skill supplied the **shape** of the qualitative-research flows (its `qualitative-research-planner` → our persona-interview flow, its `synthesize-research-report` → our QDA step), adapted through the import gate. agentman supplied the **calibration and panel concepts** behind the persona response-calibration layer. Recorded so every adaptation is auditable and no vendor wrapper is smuggled in.
- **Check-date:** 2026-07-27
- **Cited-by:** TRADEMARKS.md · PATTERNS.md

### standards-cluster · named review standards
- **Citation:** Nielsen, J. "10 Usability Heuristics for User Interface Design" (NN/g). W3C, "Web Content Accessibility Guidelines (WCAG)." Wharton, Rieman, Lewis & Polson, "The Cognitive Walkthrough Method" (1994).
- **Live:** https://www.nngroup.com/articles/ten-usability-heuristics/ · https://www.w3.org/WAI/standards-guidelines/wcag/ · (cognitive walkthrough — named method, no single canonical URL)
- **Archive:** http://web.archive.org/web/20260725190416/https://www.nngroup.com/articles/ten-usability-heuristics/ · http://web.archive.org/web/20260726165506/https://www.w3.org/WAI/standards-guidelines/wcag/
- **Licence:** WCAG is a **W3C open standard** (free); Nielsen's heuristics are **copyrighted** (NN/g) — cited, never reproduced; cognitive walkthrough is a **named academic method** (not copyrightable as a procedure).
- **Distillate:** The external rubrics the design lens points at — **not** evidence claims about the world. Nielsen's 10 usability heuristics (the usability lens), WCAG (accessibility), and the cognitive-walkthrough method (first-use flows). Referenced as standards a reviewer applies, never copied into the skill.
- **Check-date:** 2026-07-27
- **Cited-by:** choosing-tools.md · security.md
