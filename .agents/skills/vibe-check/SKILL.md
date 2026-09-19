---
name: vibe-check
description: Unified metacognitive gate for deciding whether to proceed, adjust, or stop. Use when the assistant may be overthinking, overtooling, relying on weak evidence, expanding scope, facing irreversible/destructive/public/external actions, privacy/secret/raw-capture risk, dependency or production config changes, repeated failures, or any point where the assistant must decide whether the next unit of work is worth its cost, allowed, and sufficiently evidenced.
---

# Vibe Check

Use this as a short gate before the next unit of work: thinking, research,
tool use, file editing, external action, or asking the user.

## Core Question

Ask: is the next unit of work worth its cost, allowed, and sufficiently
evidenced?

## Lenses

Check only what matters for the next move:

- Goal: does this directly serve the explicit request?
- Proportionality/depth: is this amount of thinking, tooling, or review worth
  the expected decision value?
- Evidence/uncertainty: what verified fact would change the decision, and is
  the critical premise inspected?
- Boundary/authority: is the action inside accepted scope, paths, tools, and
  approval authority?
- Risk/reversibility: what becomes hard to undo, public, destructive, or
  externally visible if wrong?
- Safe substitute path: can unsafe evidence gathering be replaced with a safer
  equivalent?
- Next move: what is the smallest useful action after the gate?

## Decision

Choose exactly one:

- `Proceed`: the next move is aligned, proportionate, authorized, and evidenced.
- `Adjust`: keep moving, but narrow, reorder, verify one fact first, reduce
  tooling, redact, sample, or request only the missing approval packet.
- `Stop`: ask only when a real blocker prevents safe continuation.

After `Proceed` or `Adjust`, immediately take the next move.

## Stop Rules

Stop when the next move would require missing approval, cross forbidden scope,
perform destructive/public/irreversible action, expose secrets or private data,
use unsafe raw captures, mutate an external system, change dependencies or
production config without authority, or depend on a critical unverified premise
that could make the action materially wrong.

## Safe-Evidence Fallback

When the current path is unsafe, substitute the least invasive evidence that can
answer the decision: read-only inspection, metadata-only summary, redaction,
representative sample, or an explicit approval request. Do not collect raw
prompts, raw tool output, secrets, `.env*`, browser/session captures, DB
contents, or unnecessary personal data when a safer substitute is enough.

## Output Shape

```text
Unified gate: <Proceed|Adjust|Stop>
Reason: <one sentence grounded in goal, cost, evidence, boundary, or risk>
Correction: <none, or the concrete narrowing/substitution/blocker>
Next move: <smallest useful action to take now, or exact approval/blocker>
```
