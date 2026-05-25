# Vibe Check — Non-Functional Requirements and Constraints

This document captures the non-functional requirements, packaging constraints, quality gates, and forbidden surfaces for the `vibe-check` plugin. IDs are stable and trace back to `overview.md`.

---

## 1. Distribution and Packaging

**REQ-NF-DIST-001 — Plugin manifest**
The plugin MUST ship a Claude Code plugin manifest at `.claude-plugin/plugin.json` declaring a single skill at `./.claude/skills/vibe-check`.
- Source: survey Section C; manifest version is `0.2.0`.

**REQ-NF-DIST-002 — Hub install (superseded marketplace manifest)**
The plugin is installable only via the `idnotbe/claude-plugins` hub: `/plugin marketplace add idnotbe/claude-plugins` followed by `/plugin install vibe-check@idnotbe`. The previous `.claude-plugin/marketplace.json` standalone manifest has been removed per hub ADR-007 (2026-05-03). This plugin's own ADR-004 is superseded by the hub's ADR-007.
- Source: hub plan 0006; hub ADR-007.

**REQ-NF-DIST-003 — Single skill artifact**
The directory `.claude/skills/vibe-check/` MUST contain only `SKILL.md`. No other files (no `.ts`, `.js`, `.py`, no binaries) are permitted there.
- Rationale: Reinforces the prompt-only contract.

---

## 2. Runtime Constraints

**REQ-NF-RUNTIME-001 — Prompt-only**
The plugin MUST be prompt-only. No code executes at invocation time. `SKILL.md` is the entire behavior-bearing artifact.
- Source: CLAUDE.md ("No runtime dependencies. The plugin is prompt-only; nothing executes.").

**REQ-NF-RUNTIME-002 — No outbound API calls**
The plugin MUST make no outbound API calls and no network requests of any kind.
- Source: CLAUDE.md, README.md, ARCHITECTURE.md all assert this; reinforced by absence of any HTTP/socket invocation in `SKILL.md`.

**REQ-NF-RUNTIME-003 — No environment variables**
The plugin MUST NOT read any environment variable. No API keys are required to invoke or operate the skill.
- Source: CLAUDE.md; guarded indirectly by Check 7a (no `required_environment:` field permitted).

**REQ-NF-RUNTIME-004 — No compiled assets**
The plugin MUST NOT ship compiled assets, bundled JavaScript, or pre-built binaries.
- Source: CLAUDE.md "Key Facts" ("no compiled assets"); reinforced by the absence of any binary in `.claude/skills/vibe-check/` (only `SKILL.md` is present).

**REQ-NF-RUNTIME-005 — No Node.js tooling**
Node.js tooling (e.g., `package.json`, `node_modules`, `tsconfig.json`) MUST NOT be added unless there is a clear, committed need.
- Source: CLAUDE.md ("Do not add Node.js tooling unless there is a clear, committed need.").

---

## 3. Stability and API

**REQ-NF-API-001 — `SKILL.md` is the public API**
`SKILL.md` is the "API" of this plugin. Changes that alter the documented surface (parameters, output schema, core questions) are breaking changes for consumers.
- Source: CLAUDE.md ("Keep SKILL.md stable -- it is the 'API' of this plugin.").

**REQ-NF-API-002 — Output Format preserved**
The mandatory sections of the Output Format block MUST be preserved across changes.
- Cross-reference: functional REQ-FN-OUTPUT-001 through REQ-FN-OUTPUT-008.

**REQ-NF-API-003 — Core Questions preserved**
The four Core Questions MUST be preserved across changes.
- Cross-reference: functional REQ-FN-CORE-Q.

**REQ-NF-API-004 — Frontmatter mirrored in ARCHITECTURE.md**
If the YAML frontmatter of `SKILL.md` (`description:`, `argument-hint:`) changes, the verbatim YAML block in `ARCHITECTURE.md` (under "Skill Specification → YAML Frontmatter") MUST be updated to match in the same change.
- Source: CLAUDE.md.

---

## 4. Quality and Testing

**REQ-NF-TEST-001 — Validator must pass**
`bash tests/validate_skill.sh` MUST exit with code 0 on every change to `SKILL.md`. It is the only runnable test in the repository.
- Total checks: 17 (10 positive + 7 negative).
- Source: CLAUDE.md, survey Section D.

**REQ-NF-TEST-002 — Validator updated when parameters change**
If parameters are added or removed in `SKILL.md`, `tests/validate_skill.sh` MUST be updated in the same change so the parameter checks (Checks 5a-5e) remain accurate.
- Source: CLAUDE.md ("If you add/remove parameters, update validate_skill.sh to match.").

**REQ-NF-TEST-003 — Negative checks guard removed feature**
Seven negative checks (Test Group 5, Checks 7a-7g) MUST guard against silent reintroduction of the v0.1 `apiProvider`/`model` feature. See REQ-NF-FORBID-* below for the full forbidden-token list.

**REQ-NF-TEST-004 — Manual scenarios documented**
A manual test plan MUST be maintained at `tests/test_scenarios.md` for behaviors the structural validator cannot cover. Execution status of the manual plan is tracked but not gated.
- Source: survey Section D.

---

## 5. Compatibility

**REQ-NF-COMPAT-001 — Cross-platform shell**
The validator MUST run under bash on Linux and macOS without additional dependencies.

**REQ-NF-COMPAT-002 — Tolerate UTF-8 BOM**
The validator's frontmatter check (Check 2) MUST tolerate a UTF-8 BOM at the start of `SKILL.md`.
- Source: survey Section D, Check 2 (validate_skill.sh:48-84).

**REQ-NF-COMPAT-003 — Tolerate CRLF line endings**
The validator MUST tolerate CRLF line endings in `SKILL.md`.
- Source: survey Section D, Check 2.

---

## 6. Process Constraints

**REQ-NF-PROC-001 — English-only committed content (project rule)**
Project rule (CLAUDE.md, Development Guidelines): committed content should be in English. The repository contains some pre-existing Korean text (CLAUDE.md "Action Plans" section, parts of `action-plans/`) that predates strict enforcement; new committed content is expected to be English.
- Source: CLAUDE.md "Development Guidelines" line 65 ("All committed content should be in English.").

**REQ-NF-PROC-002 — Action-plan layout**
Active action plans live at `action-plans/*.md`. Completed plans MUST be moved to `action-plans/_done/`. Reference and historical plans live in `action-plans/_ref/`.
- Source: CLAUDE.md.

**REQ-NF-PROC-003 — Action-plan frontmatter**
Every action plan MUST carry YAML frontmatter with `status` (one of `not-started | active | blocked | done`) and a free-text `progress` field; both MUST be updated when work begins, progresses, or completes.
- Source: CLAUDE.md.

**REQ-NF-PROC-004 — No CI/CD currently**
No CI/CD pipeline exists. Adding one is tracked as P0.1 in `action-plans/test-infrastructure-roadmap.md`.[^ci]

---

## 7. Removed and Forbidden Features

The v0.1 `apiProvider` / `model` system was removed in v0.2.0. The skill now relies entirely on Claude itself as the meta-mentor; external model selection is unnecessary. The validator enforces this removal by failing if any of the following tokens reappears in `SKILL.md`.

| ID | Forbidden Token / Surface | Validator Check | Anchor |
|----|---------------------------|------------------|--------|
| REQ-NF-FORBID-001 | `required_environment:` (frontmatter field) | Check 7a | validate_skill.sh:161-165 |
| REQ-NF-FORBID-002 | `apiProvider` parameter-table row | Check 7b | validate_skill.sh:167-171 |
| REQ-NF-FORBID-003 | `model` parameter-table row | Check 7c | validate_skill.sh:173-177 |
| REQ-NF-FORBID-004 | Provider-model mapping table header `\| Provider \| Models \| Environment Variable \|` | Check 7d | validate_skill.sh:179-183 |
| REQ-NF-FORBID-005 | `OPENAI_API_KEY` | Check 7e | validate_skill.sh:185-191 |
| REQ-NF-FORBID-006 | `GEMINI_API_KEY` | Check 7f | validate_skill.sh:185-191 |
| REQ-NF-FORBID-007 | `ANTHROPIC_API_KEY` | Check 7g | validate_skill.sh:185-191 |

**REQ-NF-FORBID-RATIONALE**
These seven anchors are the surface that the removed feature would re-grow from. Forbidding them at validator level guarantees that the v0.1 system cannot be silently reintroduced through, for example, copy-paste from older docs or stale pull requests. The note in `SKILL.md:32` (legacy keys accepted but ignored) covers backward compatibility at the input layer; the validator covers the documentation/configuration layer.

**REQ-NF-FORBID-DEPRECATED-PARAM**
A specific deprecated parameter name `modelOverride` is also forbidden by the validator (Check 6, validate_skill.sh:136-143). Reintroducing it would resurrect the removed model-selection surface under a renamed banner.

---

## 8. Versioning

**REQ-NF-VER-001 — Plugin version**
`plugin.json` declares the plugin version. The current version is `0.2.0`, reflecting the removal of the multi-model orchestration feature.

**REQ-NF-VER-002 — Breaking-change semantics**
Any change that modifies the documented Output Format sections, the Core Questions, or the required input parameter set is considered a breaking change and MUST be reflected in a version bump and in `ARCHITECTURE.md`.

[^ci]: `action-plans/test-infrastructure-roadmap.md` lists adding a GitHub Actions workflow that runs `tests/validate_skill.sh` on PRs as priority P0.1.
