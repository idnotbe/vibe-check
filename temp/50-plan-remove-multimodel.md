# Plan: Remove apiProvider/model Feature (Option A)

**Status**: FINAL v3 (after clink round 2 — claude/codereviewer). Ready to execute.
**Decision**: Option A — full removal of apiProvider/model parameters, required_environment, and all related validation/documentation. Bump version 0.1.0 → 0.2.0.

## Why removal (not B/C/D)

- Plugin makes zero outbound API calls. The feature only lets Claude "consider" a named model's characteristics — value unverified, likely placebo.
- Hardcoded model names (`gpt-5.2-high`, `gemini-3.0-pro-preview`, `claude-opus-4.5`, etc.) rot fast. Maintenance cost is real; benefit is speculative.
- README already says "Dependencies: None" with footnote excuse. SKILL.md `required_environment` contradicts that. Removing both ends the contradiction.
- MCP-parity argument is hypothetical: no evidence of active migration users; this repo is v0.1.0 with no CI and unexecuted manual tests.
- User trigger: when a maintainer reads SKILL.md and asks "왜 있는 거야?", that's a design smell — the feature fails its own justification.
- **Why not `required_environment: []`?** Preserves dead schema surface without runtime or user value, and keeps the same "why is this here?" confusion alive.

## Scope of changes (file-by-file)

### 1. `.claude/skills/vibe-check/SKILL.md` (core artifact)

Remove:
- Frontmatter `argument-hint`: drop `apiProvider: [...] model: [...]` portion → use `argument-hint: goal: [goal] plan: [plan] (free-form text also works)`
- Frontmatter `required_environment:` block (lines 5-8) — entire field
- Optional Parameters table rows for `apiProvider` and `model` (lines 35-36)
- "Supported API Providers and Models" table (lines 38-44)
- `apiProvider`/`model` lines from Structured Format example (lines 56-57)
- Entire "API Provider and Model Processing" section (lines 70-105) including Default Behavior, Provider Characteristics, Configuration, Validation subsections

Add:
- One-line legacy compatibility note **as a markdown blockquote immediately under the Optional Parameters table** (placement decision — round 2). Exact wording:
  ```markdown
  > `apiProvider` and `model` (v0.1.x) are accepted but ignored.
  ```
  Rationale: users with stale invocation patterns read Optional Parameters first; Special Cases is too far down to be discoverable.

Keep everything else verbatim — Core Questions, Output Format, Evaluation Framework, Tone Guidelines, remaining Special Cases, Context block, Your Role.

### 2. `tests/validate_skill.sh`

**Strategy**: don't only shrink to positive checks — add NEGATIVE checks so legacy tokens cannot silently re-appear.

Remove:
- Test 3 (required_environment + 3 keys) — 4 positive checks
- Test 4 (provider names) — 3 positive checks
- Test 5 (model names) — 6 positive checks
- Test 8 (environment_variables, settings.json refs) — 2 positive checks
- Test 9 (provider-model mapping table) — 1 positive check
- From Test 6 (parameters): drop `apiProvider` and `model` — 2 positive checks

Keep:
- Test 1 (existence) — 1 check
- Test 2 (frontmatter, name, description) — 3 checks
- Test 6 reduced (goal, plan, progress, uncertainties, taskContext) — 5 positive checks
- Test 7 (deprecated `modelOverride` absence) — 1 check (already a negative check; keep)

Add NEGATIVE checks (new Test 8: "Legacy feature absence"):
- `required_environment:` field absent in frontmatter — 1 check (anchor: `^required_environment:`)
- `apiProvider` and `model` absent **as parameter-table rows** — 2 checks (anchor: `^\| \`apiProvider\``, `^\| \`model\``). Critical: do NOT use any-position backtick match — the legacy compat blockquote (which legitimately backtick-wraps these param names per markdown convention) would self-defeat the check. Anchoring to the table-row pattern allows the prose mention to coexist.
- Provider-model mapping table header `| Provider | Models | Environment Variable |` absent — 1 check
- Hardcoded API key names (`OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`) absent — 3 checks. Trade-off: a future contributor writing "no `OPENAI_API_KEY` is needed" would trip this. Add an inline bash comment explaining this is intentional for a no-CI repo.

**Net**: 28 checks → 10 positive + 7 negative = 17 checks. Renumber sections.

**Implementation style — MANDATORY**: all new negative checks must use the existing `if grep -q ...; then ... else ... fi` pattern (cf. validate_skill.sh:45-50). Do NOT use `! grep -q ... && pass || fail` inversion — under `set -e` it can silently swallow failures. Inversion compared to positive checks: `then fail; else pass`.

**YAML frontmatter validity post-edit**: removing the 4-line `required_environment:` block from SKILL.md frontmatter must leave a clean YAML close. The validator only greps for `^---$`, not full YAML parse. Verify by eye after edit.

### 3. `tests/test_scenarios.md`

**Approach**: trim, don't rewrite from scratch.

Delete sections covering:
- 1.1, 1.2, 1.3 (provider/model/env-var validation matrix)
- 3 (provider+model combination matrix)
- **4.1 lines 159-178** ("Missing Required Parameters" — caught by clink round 2; contains `apiProvider: openai` / `model: gpt-5.2-high` test inputs that survive other deletions and would orphan-reference removed params)
- 4.2 (and any other natural-language extraction of apiProvider)
- 5 (provider/model output influence scenarios)

Keep + augment:
- Existing goal/plan-centric scenarios
- Add at least one new scenario explicitly exercising `progress` and `taskContext` so those parameters retain test coverage after the trim
- Add one scenario verifying legacy `apiProvider:`/`model:` keys are silently ignored (i.e., output is generated normally, no error about unknown params)

### 4. `README.md`

- Comparison table row "Multi-model feedback" (line 21) → rephrase to "Single-model feedback (Claude only)"; remove anchor link
- Footnote `[^1]` (line 23) → remove
- "Limitations Compared to MCP Version" paragraph (line 27) → simplify: "This Skills version provides Claude-only metacognitive feedback. The MCP version offers genuine multi-model perspectives via real API calls; if you need that, use the MCP version."
- "Migrating from MCP Version" sentence (line 31) → drop apiProvider/model from parameter list; add note that legacy apiProvider/model invocations are accepted but ignored
- Features bullet "API Provider/Model Awareness" (line 41) → remove
- "Important: No External API Calls" section (lines 85-89) → keep but simplify; no need to mention `required_environment`
- Parameters table rows for `apiProvider`, `model` (lines 112-113) → remove
- Entire "API Provider and Model Parameters" section (lines 168-213) → remove
- Troubleshooting subsections (lines 241, 243-249) → remove
- Testing section (lines 260-262, 287) → update to reflect new validator scope (10 positive + 7 negative checks)
- **Line 297** (caught by clink round 1): if it mentions `~/.claude/settings.json` API key config — rewrite or delete

### 5. `ARCHITECTURE.md`

- Frontmatter quote of SKILL.md (lines 47-55): update to match new SKILL.md (no `required_environment`, no `apiProvider` in argument-hint)
- Note about `required_environment` being metadata (line 55) → remove
- Parameters table rows for `apiProvider`, `model` → remove
- "API Provider and Model Architecture" section → remove entirely
- Implementation Notes limitations bullets about model awareness → remove
- Testing Architecture: update check counts (28 → 17) and group descriptions
- Migration Path: drop "API keys are optional metadata" line; clarify "API key environment is no longer relevant; legacy keys in invocations are ignored"

### 6. `CLAUDE.md` (project)

- "Key Facts" bullets about `required_environment` and `apiProvider`/`model` (lines 26-32) → remove
- Entire "The apiProvider/model Feature" section (lines 35-43) → remove
- Testing section description (lines 56-57): rewrite — remove "required_environment, API provider docs, model docs, ... config examples, and provider-model mapping". Update check count (28 → 17).
- "When Editing SKILL.md" (lines 67-69): remove "providers, models" from the "If you add/remove" guidance.

### 7. `action-plans/test-infrastructure-roadmap.md`

- Update `progress` in frontmatter
- "What validate_skill.sh Checks" table (lines 19-32): rebuild with new check inventory (10 positive + 7 negative)
- P1.1: mark resolved by removal — note that the contradiction was eliminated by removing `required_environment` rather than reconciling docs
- P1.2: mark obsolete — no provider/model lists remain to deduplicate
- P1.3: scope reduces — fewer scenarios to execute
- P2.2 (grep tightening): still valid for remaining checks

### 8. `.claude-plugin/plugin.json`

Bump `version`: `0.1.0` → `0.2.0`. The removal of documented parameters is a user-visible contract change; pre-1.0 semver convention treats this as a minor bump.

## Sequencing

Per CLAUDE.md workflow, phases proceed: draft → independent verify 1 → fix → verify 2 → fix → next phase.

- **Phase 1 (this file)**: removal plan. Verify with clink × 2 before any code changes.
- **Phase 2**: edit SKILL.md + validate_skill.sh + test_scenarios.md + plugin.json (version bump). Run validator. Verify clink × 2 (codereviewer focus) on the diff. **First commit**: contract change. Commit message must explicitly note "docs consistency follows in next commit" so reviewers don't flag the temporary doc inconsistency window as incomplete work.
- **Phase 3**: edit README.md + ARCHITECTURE.md + CLAUDE.md + action-plans roadmap. Verify clink × 2 (consistency focus) on docs vs SKILL.md. **Second commit**: docs.
- **Phase 4**: final structural pass — validator green, scoped grep sweep (exclude `temp/`), confirm no orphan markdown anchors. Commits both pushed under user confirmation only.

**Editing discipline**: all SKILL.md/README/ARCHITECTURE/CLAUDE edits must be **content-anchored** (search-and-replace on unique strings or whole-section blocks), not line-number-anchored. Plan §1-§7 line numbers are advisory snapshots from baseline; they will drift after the first removal in any given file.

## Risk register

| Risk | Mitigation |
|------|-----------|
| Real users depend on `apiProvider:` argument shape | Legacy compatibility one-liner explicitly documents that those keys are accepted but ignored. Restoring full feature is straightforward via git if wrong. |
| Validator drops checks → silent regression of legacy surface | Add 7 negative checks (Test 8) so reintroduction is detected. |
| Doc edits leave orphan anchor links (e.g., `#api-provider-and-model-parameters`) | Phase 4 grep sweep across shipped artifacts (excluding `temp/`); manual verification of remaining intra-README anchors. |
| Test_scenarios.md becomes thin | Add 1+ scenario exercising `progress` + `taskContext`; add 1 scenario verifying legacy-key tolerance. |
| Repo-wide grep finds historical references in `temp/` and looks like failed cleanup | Phase 4 sweep is **scoped** to shipped artifacts: `.claude/`, `tests/`, `*.md` at repo root, `action-plans/`, `.claude-plugin/`. Explicitly excludes `temp/`. |
| Negative-check regex false-positives on the legacy compatibility note | Negative checks require backtick-wrapping (e.g., grep for `\`apiProvider\``); plain-prose mentions in compatibility note pass through. |
| Two-commit split feels artificial | Commit 1 = SKILL.md + validator + test_scenarios.md + plugin.json (atomic contract change). Commit 2 = docs catch-up. Each commit individually compiles/validates. |
| Original CPI research / "vibe-check-mcp-server" attribution lost | Keep README CPI mention and credit to PV-Bhat. Only feature parity dropped, not historical credit. |
| Backtick-wrapping in legacy compat note self-defeats negative grep | Anchor negative check to table-row pattern (`^\| \`apiProvider\``); never any-position backtick. (Round-2 critical fix.) |
| Line-number drift during multi-pass file edits | All edits use content-anchored search-and-replace. Plan line numbers are advisory snapshots only. |
| YAML frontmatter parse breakage after `required_environment:` block removal | Validator only greps for delimiters; no full YAML parse. After the edit, manually verify frontmatter close is `---` with no dangling list items / extra blank lines inside the block. |
| `set -e` footgun in negative checks (`! grep -q` inversion swallows failures) | Mandate `if grep -q ...; then fail; else pass; fi` style for all negative checks. |
| `test_scenarios.md` Section 4.1 contains stale apiProvider/model inputs | Added explicitly to deletion scope (§3 above). |

## Out of scope

- Changing the core meta-mentor prompt content (Evaluation Framework, Output Format, Core Questions). These are the actual value of the skill.
- Renaming/restructuring directories.
- Adding CI (P0.1 in roadmap) — separate concern.
- Executing the full surviving test_scenarios.md (P1.3 — separate task).

## Open questions — RESOLVED (clink round 1)

| # | Question | Resolution |
|---|----------|-----------|
| Q1 | Empty `required_environment: []` vs full removal? | **Full removal.** Empty preserves dead schema surface and the same confusion. |
| Q2 | Argument-hint wording | `goal: [goal] plan: [plan] (free-form text also works)` |
| Q3 | Single commit or split? | **Two commits**: (1) contract change, (2) docs. Atomic per commit. |
| Q4 | Bump 0.1.0 → 0.2.0? | **Yes.** User-visible contract change deserves a minor bump in pre-1.0 semver. Adds plugin.json to scope. |

## Round 2 — RESOLVED

| # | Question | Resolution |
|---|----------|-----------|
| Q1 | Negative-check approach sound? | **Yes, with table-row anchor fix.** Backtick-only matching would self-defeat against the legacy compat blockquote. Fixed in §2 above. |
| Q2 | Legacy compat note placement? | **Blockquote immediately under Optional Parameters table.** Special Cases too far down for stale-invocation users to find. Fixed in §1 above. |
| Q3 | Two commits or three? | **Two.** Three buys nothing. Commit 1 message must note docs follow. Fixed in Sequencing above. |
| Q4 | Anything else missing? | Section 4.1 of test_scenarios.md (lines 159-178). Added to §3 scope. |

Plan is now FINAL v3. Proceed to Phase 2 execution.
