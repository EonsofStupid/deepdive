# The lifecycle signal contract

If `DEEPDIVE_SIGNAL_CMD` is set, the skills emit ONE event per workflow transition by invoking:

```
$DEEPDIVE_SIGNAL_CMD fold --phase <phase> --branch <id> [companions…]
```

## Phases (closed vocabulary — a conforming sink REJECTS anything else)

| Phase | When |
|---|---|
| `branch_opened` | a branch/fork session spawned |
| `spur_dispatched` / `spur_folded` | a research side-quest sent out / folded back |
| `decision_established` | a decision landed (`--decision <id> --lane additive\|superseding [--supersedes <prior>]`) |
| `notes_authored` | build-plan notes written/extended |
| `branch_closed` | the close contract met (notes + decision captured) — emitted DELIBERATELY, never by a session merely ending |
| `crystallized` | the terminal fold / the picked-or-hybrid winner |

Companions: `--parent <id> --session <id> --scope <project> --engine <claude|codex|cursor|…>
--memory <path> --notes <path> --model <id> --tokens-in N --tokens-out N --latency-ms F`.

## The queue (when the sink is busy/locked)

Append the exact argument line (everything after the command name) to `${DEEPDIVE_HOME}/signal.queue`:

```
fold --phase branch_opened --branch rh-042-f1 --parent 5112e460 --engine claude
```

Replay later with `drain-queue.sh` — each line re-runs through `$DEEPDIVE_SIGNAL_CMD`, so **validation
happens at replay**: a conforming sink rejects bad lines (they stay in the queue and are reported),
and never inserts an unvalidated row. v1 limitation: args are whitespace-split — no values with spaces.

## The property that makes this worth having

The sink should be TYPED end-to-end: enums (or equivalent) for phase/lane/engine, parse-don't-validate,
unknown value = hard error naming the legal set. Telemetry you can't trust is worse than none.
