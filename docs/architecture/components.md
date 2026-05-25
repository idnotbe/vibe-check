# Components

This document describes each artifact in the `vibe-check` repository as a
component: its purpose, location, contract, dependencies, and change risk.
For the high-level system context, see [`./overview.md`](./overview.md).
For decision history, see [`./decisions.md`](./decisions.md).

---

## 1. SKILL.md -- the core artifact

- **Purpose**: The single source of behavioral truth for the plugin. It
  defines the meta-mentor role, parameter contract, evaluation framework,
  output schema, and the continuation requirement.
- **Location**: [`/.claude/skills/vibe-check/SKILL.md`](../../.claude/skills/vibe-check/SKILL.md)
- **Contract -- Frontmatter** (`SKILL.md:1-5`):
  - `name: vibe-check`
  - `description:` -- elevator copy used by the host to advertise the skill.
  - `argument-hint:` -- usage hint shown to the user.
- **Contract -- Input parameters** (`SKILL.md:13-32`):
  - Required: `goal`, `plan`.
  - Optional: `progress`, `uncertainties`, `taskContext`.
  - Legacy `apiProvider` and `model` keys are accepted but ignored
    (`SKILL.md:32`). See [ADR-002](./decisions.md#adr-002-backward-compatibility-for-legacy-apiprovidermodel-keys).
- **Contract -- Output schema** (`SKILL.md:124-153`): the assistant must
  emit a `## Vibe Check Results` block containing, in order, `### Quick
  Assessment`, `### Key Questions to Consider` (4 items), `### Pattern
  Watch`, `### Recommendation`, `### If Adjusting`, `### Next Action`
  (mandatory). The closing fence is explicitly not a stop signal.
- **Contract -- Continuation** (`SKILL.md:109-122, 153`): the assistant
  must continue the original task in the same turn after emitting the
  block. The only exception is the no-goal/no-plan case, in which the
  next step is to ask the user for them.
- **Dependencies**: None at runtime. The host (Claude Code) loads the file
  into context. There is no other code path.
- **Change risk**: HIGH. This file is the API of the plugin. Per
  [`../../CLAUDE.md`](../../CLAUDE.md) (the SKILL.md stability rules
  under "Development Guidelines"), the Output Format section and Core
  Questions are to be preserved. Any frontmatter
  edit must also update [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md)
  (verbatim YAML block) and may require a corresponding update to
  [`/tests/validate_skill.sh`](../../tests/validate_skill.sh).

---

## 2. plugin.json -- plugin manifest

- **Purpose**: Declares the plugin to the Claude Code host: name, version,
  description, author, license, and which skill directories to load.
- **Location**: [`/.claude-plugin/plugin.json`](../../.claude-plugin/plugin.json)
- **Contract**: JSON object with `name`, `version` (`0.2.0`),
  `description`, `author`, `skills` (array of paths -- currently
  `["./.claude/skills/vibe-check"]`), `homepage`, `repository`, `license`,
  `keywords`.
- **Dependencies**: References the skill directory; if that path moves the
  manifest must move with it.
- **Change risk**: MEDIUM. Bumping the version is routine. Renaming the
  skill or moving the directory is breaking for installed users.

---

## 4. validate_skill.sh -- structural validator

- **Purpose**: Catch structural regressions in `SKILL.md` before they ship.
- **Location**: [`/tests/validate_skill.sh`](../../tests/validate_skill.sh)
- **Input**: The path to `SKILL.md`. Defaults to the in-tree file but is
  overridable via the `SKILL_FILE` environment variable so that fixture
  variants (CRLF, BOM) can be validated without touching the canonical
  file (`validate_skill.sh:9-11`).
- **Contract**: 17 checks total -- 10 positive, 7 negative -- in five
  groups:
  1. **Existence** (1 check): the file is present.
  2. **Frontmatter** (3 checks): delimiters parse cleanly with BOM/CRLF
     tolerance; `name: vibe-check` is exactly defined; `description:`
     exists exactly once and is non-empty.
  3. **Parameters** (5 checks): each of `goal`, `plan`, `progress`,
     `uncertainties`, `taskContext` is documented as a backticked token.
  4. **Deprecated parameters** (1 check): `modelOverride` is absent.
  5. **Legacy feature absence** (7 checks): the seven tokens that would
     indicate a silent reintroduction of the removed `apiProvider`/`model`
     system are all absent. See [`./overview.md`](./overview.md#trust-boundaries-and-surface-area).
- **Exit code**: `0` if all 17 checks pass, `1` if any fails.
- **What it does NOT validate**: the `plugin.json` schema (no JSON
  validator runs); documentation/README claim consistency with
  `SKILL.md`; that `Next Action` actually appears in generated outputs
  (this is a runtime behavioral property and is unreachable from a
  structural lint). The `plugin.json` validation gap is tracked as P2.3
  in
  [`../../action-plans/test-infrastructure-roadmap.md`](../../action-plans/test-infrastructure-roadmap.md).
- **Dependencies**: POSIX shell + `awk` + `grep`. No Node, no Python.
- **Change risk**: MEDIUM. Each parameter or schema change in `SKILL.md`
  may require a paired edit here.

---

## 5. test_scenarios.md -- manual test plan

- **Purpose**: A human-readable list of behavioral scenarios a reviewer
  can step through to confirm the skill behaves as documented.
- **Location**: [`/tests/test_scenarios.md`](../../tests/test_scenarios.md)
- **Status**: Manual; not yet executed (per
  [`../../CLAUDE.md`](../../CLAUDE.md) "Test File Status" table). It is
  expected to be executed by a human evaluator, not automated.
- **Change risk**: LOW. Adding scenarios is additive.

---

## 6. ARCHITECTURE.md and README.md -- documentation surfaces

- **Purpose**: Two distinct audiences.
  - [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) is for contributors:
    design philosophy, MCP-to-Skills migration, plugin structure, skill
    spec, testing architecture, version considerations.
  - [`/README.md`](../../README.md) is for end users: install steps,
    invocation examples, headline claims (no API keys, prompt-only).
- **Relationship to these docs**: `ARCHITECTURE.md` is the original,
  monolithic architecture document. The files in `docs/architecture/` are
  a subject-decomposed complement, not a replacement; cross-link rather
  than duplicate.
- **Change risk**: LOW-MEDIUM. The frontmatter YAML in `ARCHITECTURE.md`
  must stay in sync with `SKILL.md`'s frontmatter
  ([`../../CLAUDE.md`](../../CLAUDE.md) "When Editing SKILL.md").

---

## 7. action-plans/ -- process artifact

- **Purpose**: Process management for in-flight work, not a runtime
  component. This is where active plans, their status, and progress live.
- **Location**: [`/action-plans/`](../../action-plans/)
- **Convention** (per [`../../CLAUDE.md`](../../CLAUDE.md) "Action Plans"
  and `action-plans/README.md`):
  - Active plans (`status: not-started | active | blocked`) live at the
    root of `action-plans/`.
  - Completed plans (`status: done`) move to `action-plans/_done/`.
  - Reference / historical documents live in `action-plans/_ref/`.
  - Every plan file has a YAML frontmatter block with `status` and
    `progress` keys.
- **Change risk**: N/A. This is metadata, not behavior.

---

## Data flow within a single invocation

```
[User input or agent context]
        |
        v
[Input parsing] -- the assistant reads $ARGUMENTS, falling back to natural
                   language inference (SKILL.md:60-64). Missing goal/plan
                   triggers the Special Case branch.
        |
        v
[4-dimension evaluation] -- Situational Analysis, Diagnostic Assessment,
                            Response Type Selection, Course Correction
                            (SKILL.md:76-107).
        |
        v
[Response-type selection] -- Technical Guidance / Gentle Questioning /
                             Stern Redirection / Validation
                             (SKILL.md:96-101).
        |
        v
[Output block emission] -- the assistant emits the fenced "Vibe Check
                           Results" block with the seven required sections
                           in the order defined by SKILL.md:124-151.
        |
        v
[Continuation] -- the assistant immediately executes the step named in
                  `### Next Action` within the same turn. The closing
                  fence is not a stop signal (SKILL.md:153).
```

Every stage above happens inside one Claude turn. There is no IPC, no
worker, and no persistence. The "skill" is the prompt; the "runtime" is
Claude reading that prompt.
