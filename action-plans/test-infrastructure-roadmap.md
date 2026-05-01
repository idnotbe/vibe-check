---
status: active
progress: "P0 완료 (CI 제외); P1.1 해결됨 (apiProvider/model 제거로 contradiction 소멸, v0.2.0); P1.2 obsolete; P1.3 범위 축소; P2 일부 완료"
---

# Vibe Check -- Test Plan

Prioritized roadmap for improving test infrastructure in this repo.

## Current State

- **1 runnable test**: tests/validate_skill.sh (17 structural checks, all pass)
- **1 manual plan**: tests/test_scenarios.md (Not yet executed)
- **No CI/CD**: No GitHub Actions or any automation
- **No single-command entrypoint**: Each test must be discovered and run manually

### What validate_skill.sh Checks

The validator performs 17 checks across 5 test groups (10 positive + 7 negative).
The negative checks were added in v0.2.0 alongside the removal of the
`apiProvider`/`model` feature, to guard against silent reintroduction.

| # | Test Group | Kind | Checks | What It Validates |
|---|-----------|------|--------|-------------------|
| 1 | Existence | positive | 1 | SKILL.md file exists |
| 2 | Frontmatter | positive | 3 | `---` delimiters present, `name: vibe-check`, `description:` field |
| 3 | Parameters | positive | 5 | Parameter names in backticks: `goal`, `plan`, `progress`, `uncertainties`, `taskContext` |
| 4 | Deprecated Params | negative | 1 | `modelOverride` absent |
| 5 | Legacy Feature Absence | negative | 7 | `required_environment:` frontmatter field absent; `apiProvider` and `model` parameter-table rows absent (anchored to `^\| ` so the legacy compat blockquote is allowed); provider-model mapping table header absent; legacy API key names (`OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`) absent |
| | **Total** | | **17** | (10 positive + 7 negative) |

## P0 -- Critical

### P0.1: Add CI for validate_skill.sh

Add a minimal GitHub Actions workflow that runs the validator on PRs and pushes
to main. This protects SKILL.md from regressions.

Suggested workflow (.github/workflows/validate.yml):

```yaml
name: Validate SKILL.md
on: [push, pull_request]
jobs:
  validate:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - run: bash tests/validate_skill.sh
```

### P0.2: Resolve dead TypeScript test

Done. `tests/api_provider.test.ts` has been deleted. It was dead code with no
Node.js scaffolding (no package.json, tsconfig.json, or node_modules).

### P0.3: Add testing documentation

- CLAUDE.md: Created (documents testing conventions). Done.
- README.md Testing section: Created (documents how to run tests). Done.
- This file (TEST-PLAN.md): Created. Done.

## P1 -- High

### P1.1: Fix README vs SKILL.md contract mismatch

**Status: Resolved (v0.2.0).**

The original mismatch — README claiming "Dependencies: None" while SKILL.md
declared `required_environment` with 3 API keys — was eliminated by removing
`required_environment` from SKILL.md entirely (the "remaining option" listed
in the prior version of this section). validate_skill.sh's environment-key
checks were dropped and replaced with negative checks that guard against
reintroduction.

### P1.2: Eliminate provider/model data duplication

**Status: Obsolete (v0.2.0).**

The `apiProvider`/`model` feature was removed in v0.2.0; no provider or model
lists remain in SKILL.md, validate_skill.sh, or test_scenarios.md to deduplicate.

### P1.3: Execute manual test scenarios

**Status: Scope reduced (v0.2.0).** The provider/model scenario sections were
removed from test_scenarios.md alongside the feature; the surviving plan is
shorter but still unchecked.

tests/test_scenarios.md has the remaining test plan with an unchecked checklist.
Run through it at least once and record results.

## P2 -- Nice to Have

### P2.1: Add testing mention to ARCHITECTURE.md

Done. ARCHITECTURE.md now includes a Testing Architecture section describing
the structural validation approach and test file inventory.

### P2.2: Tighten grep-based checks in validate_skill.sh

Current checks grep the entire SKILL.md file. A token could match in the wrong
section (e.g., a model name in a code block). Improvement: parse frontmatter
specifically (between --- delimiters) for frontmatter checks.

### P2.3: Add plugin.json validation

validate_skill.sh only checks SKILL.md. Consider adding checks for
.claude-plugin/plugin.json:
- Valid JSON (parseable with `jq` or `python -m json.tool`)
- Required fields present: `name`, `version`, `description`, `skills`
- `skills` array references existing directories
- `version` follows semver format
- Optional fields: `author` (with `name` and `url`), `homepage`, `repository`, `license`, `keywords`

### P2.4: Create a single test entrypoint

Add a Makefile or tests/run_all.sh that runs all tests with one command.
