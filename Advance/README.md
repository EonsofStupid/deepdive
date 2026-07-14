# Advance — the organized power layer

The DeepDive and RabbitHole skills run fine bare. **Advance** is everything that upgrades them from
"works" to "instrumented": request-level token metering + optical compression (pxpipe), lifecycle
telemetry with a pluggable sink, and session hooks (branch priming, close logging, non-destructive
compaction dumps). Skills stay minimal; all knobs live here, documented once.

## The environment contract (the only interface)

| Variable | Default | Meaning |
|---|---|---|
| `DEEPDIVE_HOME` | `~/.deepdive` | Landing zone: branch captures, rabbithole workdirs, signal queue, chat dumps |
| `PXPIPE_URL` | unset | If set, spawned sessions route through this proxy (metering / optical compression). Unset = direct API, no metering |
| `DEEPDIVE_SIGNAL_CMD` | unset | If set, lifecycle events are emitted through this CLI. Unset = telemetry silently skipped |

## What's in here

- **`pxpipe/`** — `install-pxpipe.sh` (node check → proxy install → systemd user unit → health check)
  + the unit template. [pxpipe](https://github.com/teamchong/pxpipe) is a third-party MIT local proxy:
  it meters EVERY request through it and optically compresses bulky context for models verified to read
  imaged text. Know its trade-offs before enabling compression; metering alone is loss-free.
- **`telemetry/`** — `SIGNALS.md` (the lifecycle event contract: `branch_opened … crystallized`, the
  queue format for when your sink is busy) + `drain-queue.sh` (replays the queue through
  `DEEPDIVE_SIGNAL_CMD`; the sink must validate — bad lines are rejected at replay, never silently kept).
- **`hooks/`** — Claude Code hook templates + `WIRING.md`: SessionStart (primes forked branch sessions
  with their identity + close contract; inert for normal sessions), SessionEnd (branch event log),
  PreCompact (dumps the full transcript before compaction summarizes it away — compaction becomes
  tiering, not loss).
- **`notes/`** — `CODEX_CAPABILITIES.md` (hands-on verified harness facts, dated + versioned) and
  `TESTING.md` (per-harness verification checklists; nothing in this repo is called verified unless it
  was actually run).

## Example sink

Any CLI satisfying the contract works as `DEEPDIVE_SIGNAL_CMD`. The reference implementation this was
built against is a Rust CLI whose enums reject unknown phase/lane values at parse time — the property
worth copying: **emission through typed builders, ingest through typed parsers; an invalid event is an
error, never a silent row.**
