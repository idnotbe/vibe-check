# Design notes

## Project boundary

vibe-check is a single Codex skill, not a general-purpose application. The repository exists to evolve the skill's instructions and its supporting package metadata.

The bundle directory is also the canonical source. Keeping one copy avoids drift between development files and a later installed or published copy.

## Current architecture

The current candidate is intentionally self-contained:

- SKILL.md contains the shared gate, decision choices, stop conditions, and output shape.
- agents/openai.yaml contains optional interface metadata.
- No references, scripts, assets, or plugin manifest are included because the current workflow does not need them.

## Evolution rules

Add a supporting reference only when a distinct branch needs substantial material that should not load for every invocation. Add a script only when deterministic execution is safer or more repeatable than rewriting the same logic in instructions.

Before changing behavior, identify the request or failure that justifies the change. Preserve the existing contract unless the change explicitly revises it. Keep product-host assumptions separate from the skill's general reasoning contract.

## Evidence boundary

Changes to wording or structure can be checked statically. Claims that the skill triggers correctly or improves decisions require fresh-session behavioral evidence; static validation alone is not enough.
