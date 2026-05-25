# Vibe Check — Requirements Overview

## Purpose

Vibe Check is a metacognitive sanity-check skill for Claude Code. It is delivered as a prompt-only Claude Code Skills plugin: the entire behavior lives inside `.claude/skills/vibe-check/SKILL.md`, which instructs Claude to act as a meta-mentor that interrupts an in-flight plan, evaluates it across four dimensions, and emits a structured feedback block that the agent must then consume and act on within the same turn.

The plugin exists to reduce three failure modes in agent behavior: tunnel vision, over-engineering, and goal misalignment. It is invoked before irreversible actions, when uncertainty is high, or when complexity is escalating.

## Operating Flow (informative)

A vibe check is a single in-turn detour, not a separate ceremony. The agent invokes the skill with a `goal` and `plan` (plus optional context), the prompt steers Claude into a meta-mentor persona that produces the structured feedback block, and the agent then immediately consumes that block and resumes the original task. The skill does not return control to the user, does not wait for acknowledgement, and does not create any artifact outside the conversation itself.

## Target Users

- Claude Code agents executing multi-step tasks that would benefit from a self-check before committing to an approach.
- Humans steering Claude Code who want an explicit, structured pause point in the agent loop without halting the turn.

The skill is invoked via the `/vibe-check` slash form and accepts both structured (`goal:` / `plan:` keyed) and free-form natural-language input.

## Scope

### In Scope

- A single Claude Code skill (`vibe-check`) implemented as a behavioral-mandate prompt in `SKILL.md`.
- Producing a fixed-shape output block (Quick Assessment, Key Questions, Pattern Watch, Recommendation, If Adjusting, Next Action).
- A continuation mandate that requires the agent to keep working after the output block — the block is feedback, not a stopping point.
- A structural validator (`tests/validate_skill.sh`) that protects the skill's documented surface.
- Distribution as a Claude Code plugin via `.claude-plugin/plugin.json`, installable through the `idnotbe/claude-plugins` hub.

### Out of Scope

- Any runtime code, compiled assets, or executable artifacts inside the plugin.
- Outbound API calls, network requests, environment variable reads, or API-key configuration.
- Multi-model orchestration, provider selection, or model overrides. The legacy v0.1 `apiProvider` / `model` system was removed in v0.2.0 and is actively guarded against by the validator.
- Node.js tooling, package managers, or any non-shell test infrastructure (no `package.json`, no `node_modules`, no `tsconfig.json`).
- A CI/CD pipeline. None currently exists; adding one is tracked as a P0 item on the test-infrastructure roadmap.[^ci]

## Key Terms

- **Meta-mentor**: The persona Claude adopts when the skill is invoked — an experienced feedback provider that diagnoses dysfunctional patterns and proposes course corrections (SKILL.md:9).
- **Vibe check**: The act of producing the structured feedback block in response to a user's `goal` and `plan`.
- **Intervention level**: One of four response types selected based on diagnosis — Technical Guidance, Gentle Questioning, Stern Redirection, or Validation (SKILL.md:96-101).
- **Continuation requirement**: The behavioral mandate that the closing fence of the output block is *not* a stop signal; the agent must immediately execute the step named in `### Next Action` (SKILL.md:109-153).
- **Pattern Watch**: A named taxonomy of five common agent failure modes — Complex Solution Bias, Feature Creep, Premature Implementation, Misalignment, Overtooling (SKILL.md:87-91).
- **Core Questions**: Four meta-questions that must inform every vibe check (SKILL.md:155-169).

## High-Level Requirements

The detailed requirements live in `functional.md` and `non-functional-and-constraints.md`. The IDs below are stable anchors that the other two files reference.

| ID | Requirement | Detailed in |
|----|-------------|-------------|
| REQ-OV-001 | The plugin SHALL be prompt-only: a single `SKILL.md` is the sole behavior-bearing artifact. | functional.md, non-functional |
| REQ-OV-002 | The skill SHALL accept both structured (`goal:`/`plan:` keyed) and natural-language invocations. | functional.md (REQ-FN-INPUT-*) |
| REQ-OV-003 | The skill SHALL emit a fixed-shape feedback block with seven mandatory sections. | functional.md (REQ-FN-OUTPUT-*) |
| REQ-OV-004 | The Recommendation line SHALL always be a continuation directive, never a stop instruction. | functional.md (REQ-FN-OUTPUT-REC) |
| REQ-OV-005 | The agent SHALL continue the original task in the same turn after emitting the block; the closing fence is not a stop signal. | functional.md (REQ-FN-CONT-*) |
| REQ-OV-006 | The skill SHALL evaluate plans across four named dimensions and select one of four intervention levels. | functional.md (REQ-FN-EVAL-*) |
| REQ-OV-007 | The skill SHALL flag five named pitfall patterns (Complex Solution Bias, Feature Creep, Premature Implementation, Misalignment, Overtooling). | functional.md (REQ-FN-EVAL-PATTERNS) |
| REQ-OV-008 | Four Core Questions SHALL inform every vibe check. | functional.md (REQ-FN-CORE-Q) |
| REQ-OV-009 | If neither `goal` nor `plan` is provided, the Next Action SHALL be a clarifying question to the user. | functional.md (REQ-FN-CONT-MISSING) |
| REQ-OV-010 | Legacy `apiProvider` and `model` keys SHALL be silently accepted and ignored (no behavior triggered). | functional.md (REQ-FN-COMPAT-*) |
| REQ-OV-011 | The plugin SHALL make no outbound API calls, require no environment variables, and ship no compiled assets. | non-functional (REQ-NF-RUNTIME-*) |
| REQ-OV-012 | The 17-check structural validator (`tests/validate_skill.sh`) SHALL pass on every change to `SKILL.md`. | non-functional (REQ-NF-TEST-*) |
| REQ-OV-013 | Seven negative validator checks SHALL guard against silent reintroduction of the removed `apiProvider`/`model` feature. | non-functional (REQ-NF-FORBID-*) |
| REQ-OV-014 | `SKILL.md` is the public API of this plugin; the Output Format and Core Questions SHALL be preserved across changes. | non-functional (REQ-NF-API-*) |
| REQ-OV-015 | All committed content SHALL be in English; action plans SHALL follow the `status` / `progress` frontmatter convention. | non-functional (REQ-NF-PROC-*) |

## Inputs and Outputs at a Glance

Inputs (full contract in `functional.md`):
- Required: `goal`, `plan`.
- Optional: `progress`, `uncertainties`, `taskContext`.
- Legacy (silently ignored): `apiProvider`, `model`.
- Three accepted forms: structured `key: value` block, natural-language sentence, minimal `goal / plan` slash form.

Outputs:
- A single Markdown block headed `## Vibe Check Results` with seven mandatory sections.
- The Recommendation is one of three continuation directives; the closing fence is not a stop signal.
- The skill itself emits no standalone artifact — its output is in-band feedback consumed by the same Claude turn, and the skill makes no outbound network calls. The resumed original task may invoke tools or edit files; that is expected and required by the continuation mandate (REQ-OV-005).

## Document Map

- `overview.md` (this file) — Purpose, scope, key terms, and the high-level requirement IDs other documents anchor to.
- `functional.md` — Detailed functional requirements (REQ-FN-*), each citing `SKILL.md` line ranges and validator checks.
- `non-functional-and-constraints.md` — Packaging, runtime, stability, testing, compatibility, process constraints, and the forbidden-token list (REQ-NF-*).

The architecture-level design rationale (MCP-to-Skills migration, "Claude as meta-mentor" reasoning, etc.) lives in `ARCHITECTURE.md` at the repository root and is intentionally not duplicated here.

[^ci]: See `action-plans/test-infrastructure-roadmap.md` (P0.1).
