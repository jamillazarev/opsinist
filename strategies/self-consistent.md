# self-consistent — independent passes, and the spread is the signal

```yaml
name: self-consistent
mode: protocol
passes: 3
cost: ~3x
applies_to: any-tier
protocol: |
  Dispatch the same task N times (default 3) with no shared thread between the runs, then
  reduce: the pick, why, and the spread — where the runs disagreed and about what. The spread
  is carried into the record as a confidence signal; it is never averaged away, because three
  answers that agree and three that scatter are different findings wearing the same pick.
```

**For decisions with real consequences — and priced before it runs.** At ~N× a single pass
this is the one strategy the selector may not switch on silently outside the classes the
project agreed to in config (`decide` with consequences is the stock one): anywhere else it is
offered in one line with its cost, and the owner's nod is the switch (`PATTERNS.md` §24, §21).
The reduction is performed by the dispatcher, not by a fourth run asked to summarise three.
