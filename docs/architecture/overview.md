# Architecture Overview

## Elevator Pitch

`vibe-check` is a prompt-only metacognitive skill for Claude Code. It contains
no runtime code, no compiled assets, and no network calls. The entire plugin
is a single structured Markdown prompt (`SKILL.md`) that, when invoked via
`/vibe-check`, instructs Claude itself to act as a meta-mentor: parse the
agent's current goal/plan, run a four-dimension evaluation, emit a fixed
output block, and continue the original task in the same turn. There is no
external service, no IPC, and no second model -- Claude is both the caller
and the meta-mentor, and the "implementation" is the prompt the model reads.

## System Context

```
+---------+        +-------------------+        +-------------------------+
|  User   | -----> | Claude Code agent | -----> | /vibe-check invocation  |
+---------+        +-------------------+        +-------------------------+
                            ^                              |
                            |                              v
                            |                   +-------------------------+
                            |                   |  SKILL.md prompt loaded |
                            |                   |  (frontmatter + body)   |
                            |                   +-------------------------+
                            |                              |
                            |                              v
                            |                   +-------------------------+
                            |                   |  Claude generates the   |
                            |                   |  Vibe Check Results     |
                            |                   |  output block           |
                            |                   +-------------------------+
                            |                              |
                            |                              v
                            |                   +-------------------------+
                            +------------------ |  Continuation: the     |
                              same turn,        |  Next Action step is   |
                              no stop           |  executed immediately  |
                                                +-------------------------+
```

All boxes above run inside a single Claude turn. There is no cross-process
boundary between "skill execution" and "task continuation"; the closing
fence of the output block is explicitly **not** a stop signal. See
`SKILL.md:109-153` for the continuation contract.

## Architecture Style

This is the "skill-as-prompt" pattern: a structured Markdown document with
YAML frontmatter is the entire deliverable, and the host (Claude Code) is
responsible for loading it into context when the skill is invoked. There is
no runtime, no scheduler, and no plugin process to debug.

This contrasts with the v0.1.x design, which was an MCP server that called
external LLM providers (OpenAI / Gemini / Anthropic) over the network and
required API keys. v0.2.0 removed that entire surface; the migration
rationale, key differences, and user-facing migration steps are documented
in [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) under "Migration Path"
and "Implementation Notes". This overview deliberately does not restate
that material -- consult the original document for the full migration
narrative.

## Trust Boundaries and Surface Area

The plugin's outbound effect surface is intentionally empty:

- **No outbound API calls.** No HTTP client, no socket, no MCP tool that
  reaches outside the model.
- **No environment variables.** Nothing is read from `process.env`; no
  `required_environment:` frontmatter field exists.
- **No compiled assets.** `.claude/skills/vibe-check/` contains only
  `SKILL.md`. There is no `package.json`, no `node_modules`, no binaries.
- **No filesystem writes** beyond what the calling agent does as part of
  the original task.

These properties are enforced by the validator's seven negative checks in
`tests/validate_skill.sh` (Test Group 5, lines 145-191), which guard
against silent reintroduction of the removed v0.1 multi-provider system:

1. `required_environment:` frontmatter field absent.
2. `apiProvider` parameter-table row absent.
3. `model` parameter-table row absent.
4. Legacy provider-model mapping table header absent.
5-7. The three legacy API key names (`OPENAI_API_KEY`, `GEMINI_API_KEY`,
   `ANTHROPIC_API_KEY`) absent from the file.

If any of these tokens reappear in `SKILL.md`, the validator exits non-zero.
This is the structural mechanism by which the "no outbound effects" claim
stays true over time.

## Pointers

| Topic | Location |
|-------|----------|
| Component-by-component description | [`./components.md`](./components.md) |
| Architecture decisions (ADR-lite) | [`./decisions.md`](./decisions.md) |
| Original architecture document (philosophy, migration path, version notes) | [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) |
| Project rules and testing conventions | [`../../CLAUDE.md`](../../CLAUDE.md) |
| Requirements documents (REQ-FN-* / REQ-NF-* IDs) | [`../requirements/`](../requirements/) |
| Source-of-truth survey used to write these docs | [`../../temp/req-arch-survey.md`](../../temp/req-arch-survey.md) |
| Active test infrastructure roadmap | [`../../action-plans/test-infrastructure-roadmap.md`](../../action-plans/test-infrastructure-roadmap.md) |
