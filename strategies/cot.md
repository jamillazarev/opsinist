# cot — step-by-step, and only where the tier does not already do it

```yaml
name: cot
mode: prefix
passes: 1
cost: ~1x
applies_to: light-tier
prompt_prefix: |
  Work through the task step by step before answering. The report carries the load-bearing
  steps, not the transcript.
```

**A light-tier lever, a reasoning-tier waste.** Reasoning models chain their own thought;
prefixing them with "think step by step" buys tokens and nothing else — so the applicability
lives here as data (`applies_to: light-tier`) rather than as advice, and the selector reads
it: **on a reasoning tier this strategy is never auto-applied**, and an explicit setting that
names it there is honoured but noted on the run as paid noise the owner chose.
