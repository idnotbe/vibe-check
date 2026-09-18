# vibe-check

Independent development repository for the Codex vibe-check skill.

## Purpose

This repository is the working home for improving, testing, and packaging vibe-check. The skill helps Codex decide whether the next unit of work should proceed, be narrowed, or stop when cost, evidence, authority, or risk matters.

## Canonical bundle

The editable and packageable skill bundle is:

    .agents/skills/vibe-check/

That directory is the single source of truth. The project does not keep a separate source copy and a generated install copy.

## Repository layout

    .agents/skills/vibe-check/
      SKILL.md              Skill entrypoint and behavior contract
      agents/openai.yaml    Optional UI metadata

    docs/
      design.md             Architecture and evolution decisions
      evaluation.md         Validation and behavior-check guidance

    AGENTS.md               Repository-specific working rules
    README.md               Project overview
    .gitignore              Local-only and generated-file exclusions

## Development loop

1. Read the current bundle and the relevant project documents.
2. Make the smallest change that addresses the observed need.
3. Run the skill-creator quick validator against .agents/skills/vibe-check when that validator is available.
4. Test behavior in a fresh session with a representative request when the change affects triggering or decisions.
5. Review the final file list and diff. Keep scratch evidence under temp/ and out of the committed bundle.

A structurally valid skill is still only a candidate until its behavior has been observed in the host where it will be used.

## Initial state

The first candidate is copied from the current global vibe-check skill. Future work should improve this repository's canonical bundle first, then install or publish a reviewed revision deliberately.
