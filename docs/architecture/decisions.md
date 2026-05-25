# Architecture Decisions (ADR-lite)

Lightweight Architecture Decision Records for the `vibe-check` plugin.
Each ADR captures one significant choice, why it was made, and what it
costs. For the broader architecture context, see
[`./overview.md`](./overview.md) and [`./components.md`](./components.md).
For the original migration narrative, see
[`../../ARCHITECTURE.md`](../../ARCHITECTURE.md). REQ IDs cited below
refer to the catalog under [`../requirements/`](../requirements/).

---

## ADR-001: Prompt-only skill (no runtime code, no API calls)

- **Status**: Accepted (2026-05-02)
- **Context**: v0.1.x of vibe-check was an MCP server that proxied prompts
  to external LLM providers (OpenAI / Gemini / Anthropic). It required
  API keys, environment variables, and a running Node process. The cost
  of that design was: per-call latency, a billable second model call,
  and a configuration surface (`apiProvider`, `model`,
  `required_environment:`, three API key env vars) that frequently
  drifted from documentation.
- **Decision**: Convert the project to a Claude Code Skill. The plugin
  becomes a single Markdown file (`SKILL.md`) loaded into the host model's
  context on `/vibe-check`. Claude itself plays the meta-mentor role.
  No runtime, no network, no env vars, no compiled assets.
- **Consequences**:
  - Positive: zero install friction (no keys, no Node), zero added
    latency, zero billable second call, dramatically smaller surface.
  - Positive: the "no outbound effects" property is now structurally
    enforceable (see [ADR-002](#adr-002-backward-compatibility-for-legacy-apiprovidermodel-keys)).
  - Negative: feedback comes from the same model running the original
    task -- there is no genuine multi-model perspective. This is called
    out as a known limitation in
    [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) "Implementation
    Notes -- Limitations".
- **Linked**:
  - Requirements: REQ-NF-RUNTIME-002 (no outbound API calls),
    REQ-NF-RUNTIME-003 (no environment variables),
    REQ-NF-RUNTIME-004 (no compiled assets),
    REQ-NF-RUNTIME-001 (prompt-only).
  - Validator checks: Test Group 5 (`tests/validate_skill.sh:145-191`).
  - Source files: [`../../.claude/skills/vibe-check/SKILL.md`](../../.claude/skills/vibe-check/SKILL.md),
    [`../../ARCHITECTURE.md`](../../ARCHITECTURE.md) "Migration Path",
    [`../../CLAUDE.md`](../../CLAUDE.md) "Key Facts".

---

## ADR-002: Backward compatibility for legacy `apiProvider`/`model` keys

- **Status**: Accepted (2026-05-02)
- **Context**: After [ADR-001](#adr-001-prompt-only-skill-no-runtime-code-no-api-calls)
  removed the multi-provider system, two failure modes had to be guarded
  against. First, existing user invocations may still pass `apiProvider:`
  or `model:` arguments inherited from v0.1.x; rejecting these would
  break callers without warning. Second, the legacy schema could be
  silently re-added by a future contributor (frontmatter field, parameter
  table row, env var name) and the resulting plugin would compile but
  reintroduce the removed surface.
- **Decision**: Accept-but-ignore. `SKILL.md:32` documents that legacy
  `apiProvider` and `model` keys are accepted but ignored. Simultaneously,
  [`/tests/validate_skill.sh`](../../tests/validate_skill.sh) Test Group
  5 enforces seven negative checks against the specific tokens that
  would indicate reintroduction (the `required_environment:` frontmatter
  field, the `apiProvider` and `model` parameter-table rows, the legacy
  provider-model mapping table header, and the three legacy API key
  names).
- **Consequences**:
  - Positive: zero-breakage migration for v0.1.x users.
  - Positive: silent reintroduction is structurally impossible -- any
    such change fails CI as soon as CI exists, and fails local validation
    today.
  - Negative: a future doc that legitimately mentions e.g.
    "`OPENAI_API_KEY` is not required" would trip the negative check.
    This trade-off is documented in `validate_skill.sh:154-157` and
    accepted because the prevention value is high.
- **Linked**:
  - Requirements: REQ-FN-COMPAT-001, REQ-FN-COMPAT-002 (legacy keys
    silently accepted/ignored); REQ-NF-FORBID-001 through
    REQ-NF-FORBID-007 (forbidden-token list guarding against silent
    reintroduction).
  - Validator checks: `validate_skill.sh:161-165` (`required_environment`),
    `:167-171` (`apiProvider` row), `:173-177` (`model` row), `:179-183`
    (provider-model header), `:185-191` (three API key names).
  - Source files: [`../../.claude/skills/vibe-check/SKILL.md`](../../.claude/skills/vibe-check/SKILL.md) line 32.

---

## ADR-003: Output Format as a stable contract

- **Status**: Accepted (2026-05-02)
- **Context**: The skill's value comes from being interruptible mid-task:
  it must produce an inspectable, structured feedback block, but the
  agent must continue executing the original plan in the same turn. Two
  failure modes had to be addressed simultaneously. First, freeform
  prose makes the output unparseable and unrecognizable as a "vibe
  check". Second, models tend to treat closing code fences as natural
  stop signals, which would convert this skill into a per-call
  conversation pause and break the mid-task scaffolding intent.
- **Decision**: Define a fixed seven-section output schema (`Quick
  Assessment`, `Key Questions to Consider`, `Pattern Watch`,
  `Recommendation`, `If Adjusting`, `Next Action`, plus the `Vibe Check
  Results` heading itself) and explicitly specify that the closing fence
  is not a stop signal. `### Next Action` is mandatory and names the
  resume step the assistant must immediately execute after the block.
  See `SKILL.md:109-153`.
- **Consequences**:
  - Positive: output is recognizable, parseable, and uniform across
    invocations.
  - Positive: the continuation requirement is stated in-band so the
    assistant cannot treat the schema as a turn boundary.
  - Negative: the output schema is now a cross-version compatibility
    surface -- changing section names or order is a breaking change and
    is constrained by [`../../CLAUDE.md`](../../CLAUDE.md) (the SKILL.md
    stability rules under "Development Guidelines").
- **Linked**:
  - Requirements: REQ-FN-OUTPUT-001 through REQ-FN-OUTPUT-008 (output
    schema, including REQ-FN-OUTPUT-REC); REQ-FN-CONT-001 through
    REQ-FN-CONT-004 and REQ-FN-CONT-MISSING (continuation);
    REQ-FN-OUTPUT-007 (Next Action mandatory).
  - Validator checks: none enforce section presence today; this is a
    known structural-lint gap (output-format coverage).
  - Source files: [`../../.claude/skills/vibe-check/SKILL.md`](../../.claude/skills/vibe-check/SKILL.md) lines 109-153.

---

## ADR-004: Distribute via both `plugin.json` and `marketplace.json`

> Superseded by: hub `idnotbe/claude-plugins` ADR-007 (2026-05-03). The standalone `marketplace.json` for `vibe-check` was removed in hub plan 0006; this plugin is now installable only via the hub.

- **Status**: Superseded by hub ADR-007 (2026-05-03)
- **Context**: Claude Code supports two installation paths for plugins.
  A plugin manifest (`plugin.json`) describes the plugin to the host
  once installed; a marketplace manifest (`marketplace.json`) is what
  the host reads when a user runs `/plugin marketplace add
  <owner>/<repo>`. Supporting only one of these closes off an
  installation route that real users take.
  Note: for `vibe-check` specifically, the direct path
  (`/plugin marketplace add idnotbe/vibe-check`) is the legacy
  installation route, retained for backward compatibility per this ADR;
  the recommended install flow is now
  `/plugin marketplace add idnotbe/claude-plugins` followed by
  `/plugin install vibe-check@idnotbe` via the `idnotbe/claude-plugins` hub.
- **Decision**: Ship both files in `.claude-plugin/`. `plugin.json`
  declares package metadata (name, version, skill paths, author,
  homepage). `marketplace.json` registers the same plugin under the
  `idnotbe` owner, pointing at `source: "./"`. The `name` field is
  mirrored across both files, and the long-form description in
  `plugin.json.description` is mirrored by
  `marketplace.json.plugins[0].description`. `marketplace.json` also
  carries a separate top-level `description` field that is a shorter
  catalog blurb.
- **Consequences**:
  - Positive: both installation paths work; no user is left out.
  - Negative: the mirrored pair (`name` in both files, plus
    `plugin.json.description` ↔ `marketplace.json.plugins[0].description`)
    must be edited in lockstep or the marketplace listing will disagree
    with the installed plugin. There is currently no automated check
    enforcing this -- see [ADR-005](#adr-005-structural-only-automated-testing-plus-manual-scenarios)
    and the `plugin.json` validation gap (P2.3 of the test
    infrastructure roadmap).
- **Linked**:
  - Requirements: REQ-NF-DIST-002 (marketplace manifest enables
    `/plugin marketplace add` install path -- this direct path is the
    legacy install route, retained for backward compatibility per this
    ADR; the recommended path is now via the `idnotbe/claude-plugins`
    hub); REQ-NF-DIST-001 (plugin manifest).
  - Validator checks: none currently cover either JSON file (gap).
  - Source files:
    [`../../.claude-plugin/plugin.json`](../../.claude-plugin/plugin.json).

---

## ADR-005: Structural-only automated testing plus manual scenarios

- **Status**: Accepted (2026-05-02)
- **Context**: The plugin has no runtime, so there is no executable to
  unit-test in the conventional sense. What can fail is the structure
  of `SKILL.md`: missing parameters, frontmatter regressions, silent
  reintroduction of removed features. End-to-end behavior (does the
  assistant continue after the block? does it pick the right response
  type?) is only observable by running the skill against real inputs
  and reading the result.
- **Decision**: Run two tiers. Tier 1 is automated and structural:
  `tests/validate_skill.sh` runs 17 checks (10 positive + 7 negative)
  and fails the build if any structural property of `SKILL.md` is
  violated. Tier 2 is manual and behavioral: `tests/test_scenarios.md`
  is a human-readable test plan that a reviewer can step through. CI is
  explicitly deferred -- the validator is invoked locally and on demand.
  The CI follow-up is tracked as P0.1 in
  [`../../action-plans/test-infrastructure-roadmap.md`](../../action-plans/test-infrastructure-roadmap.md).
- **Consequences**:
  - Positive: the plugin's invariants (no API calls, no env vars, no
    legacy reintroduction) are mechanically enforced today, before any
    CI exists.
  - Positive: behavioral coverage is honestly labeled as manual, not
    pretended-as-automated.
  - Negative: structural-lint coverage has known gaps -- `plugin.json`
    schema validation and presence of the seven required output sections
    are all uncovered. These are tracked in the roadmap.
  - Negative: without CI, the validator depends on contributor
    discipline. [`../../CLAUDE.md`](../../CLAUDE.md) makes this
    discipline explicit ("Always run the validator after changes").
- **Linked**:
  - Requirements: REQ-NF-TEST-001 (validator must pass; structural
    validation), REQ-NF-TEST-004 (manual scenarios documented),
    REQ-NF-PROC-004 (no CI/CD currently).
  - Validator checks: all 17, in
    [`../../tests/validate_skill.sh`](../../tests/validate_skill.sh).
  - Source files:
    [`../../tests/validate_skill.sh`](../../tests/validate_skill.sh),
    [`../../tests/test_scenarios.md`](../../tests/test_scenarios.md),
    [`../../action-plans/test-infrastructure-roadmap.md`](../../action-plans/test-infrastructure-roadmap.md),
    [`../../CLAUDE.md`](../../CLAUDE.md) "Testing".
