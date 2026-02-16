# Vibe Check -- Test Plan

Prioritized roadmap for improving test infrastructure in this repo.

## Current State

- **1 runnable test**: tests/validate_skill.sh (28 structural checks, all pass)
- **1 manual plan**: tests/test_scenarios.md (Not yet executed)
- **No CI/CD**: No GitHub Actions or any automation
- **No single-command entrypoint**: Each test must be discovered and run manually

### What validate_skill.sh Checks

The validator performs 28 checks across 9 test groups:

| # | Test Group | Checks | What It Validates |
|---|-----------|--------|-------------------|
| 1 | Existence | 1 | SKILL.md file exists |
| 2 | Frontmatter | 3 | `---` delimiters present, `name: vibe-check`, `description:` field |
| 3 | Required Environment | 4 | `required_environment:` section exists, `OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY` listed |
| 4 | API Providers | 3 | Provider names in backticks: `openai`, `google`, `anthropic` |
| 5 | Models | 6 | Model names present: `gpt-5.2-high`, `codex-5.2-high`, `gemini-3.0-pro-preview`, `gemini-3.0-flash-preview`, `claude-sonnet-4.5`, `claude-opus-4.5` |
| 6 | Parameters | 7 | Parameter names in backticks: `goal`, `plan`, `progress`, `uncertainties`, `taskContext`, `apiProvider`, `model` |
| 7 | Deprecated Params | 1 | `modelOverride` is absent |
| 8 | Config Examples | 2 | `environment_variables` reference present (pass/fail), `settings.json` reference present (pass/warn) |
| 9 | Provider-Model Mapping | 1 | Mapping table header (`\| Provider \| Models \| Environment Variable \|`) present |
| | **Total** | **28** | |

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

README says "Dependencies: None" (comparison table). SKILL.md declares
`required_environment` with 3 API keys (OPENAI_API_KEY, GEMINI_API_KEY,
ANTHROPIC_API_KEY).

The semantic conflict: the SKILL.md field name `required_environment` implies
these keys are required, but the plugin makes no API calls and works without
them for basic usage. The keys are metadata for the `apiProvider`/`model`
feature documentation.

Resolution applied: README comparison table now has a footnote clarifying that
`required_environment` keys are metadata for provider/model documentation. A
dedicated section ("Important: No External API Calls") explains the situation.

Remaining option if the mismatch is still confusing:
- Remove `required_environment` from SKILL.md if keys are truly never needed
  (would require updating validate_skill.sh to remove checks 3.1-3.4).

### P1.2: Eliminate provider/model data duplication

Provider and model lists are hardcoded in three places:
1. `.claude/skills/vibe-check/SKILL.md` (source of truth)
2. `tests/validate_skill.sh` (hardcoded expected values)
3. `tests/test_scenarios.md` (hardcoded in manual test cases)

Improvement: make validate_skill.sh derive expected providers/models from SKILL.md
rather than hardcoding them.

### P1.3: Execute manual test scenarios

tests/test_scenarios.md has a comprehensive test plan with an unchecked checklist.
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
