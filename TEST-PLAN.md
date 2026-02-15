# Vibe Check -- Test Plan

Prioritized roadmap for improving test infrastructure in this repo.

## Current State

- **1 runnable test**: tests/validate_skill.sh (28 structural checks, all pass)
- **1 dead test**: tests/api_provider.test.ts (TypeScript, no Node scaffolding)
- **1 manual plan**: tests/test_scenarios.md (Korean, never executed)
- **No CI/CD**: No GitHub Actions or any automation
- **No single-command entrypoint**: Each test must be discovered and run manually

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

tests/api_provider.test.ts cannot run -- there is no package.json, tsconfig.json,
or node_modules. Two options:

- **Recommended: Delete it.** This is a prompt-only skill repo with no TypeScript
  runtime. The test validates logic that only exists as prose in SKILL.md. Keeping
  dead code signals false test coverage.
- **Alternative: Scaffold Node.js.** Add package.json with ts-node/jest, tsconfig,
  and wire into CI. Only do this if there is a committed need for TypeScript testing.

### P0.3: Add testing documentation

- CLAUDE.md: Created (documents testing conventions). Done.
- README.md Testing section: Created (documents how to run tests). Done.
- This file (TEST-PLAN.md): Created. Done.

## P1 -- High

### P1.1: Fix README vs SKILL.md contract mismatch

README says "Dependencies: None" (line 16, comparison table). SKILL.md declares
required_environment with 3 API keys (OPENAI_API_KEY, GEMINI_API_KEY,
ANTHROPIC_API_KEY).

Resolution options:
- Clarify in README that "None" means no runtime/code dependencies, while SKILL.md
  documents optional API key metadata for provider features.
- Or remove required_environment from SKILL.md if keys are truly not needed
  (and update validate_skill.sh accordingly).

### P1.2: Eliminate triple-duplication of provider/model data

Provider and model lists are hardcoded in three places:
1. .claude/skills/vibe-check/SKILL.md (source of truth)
2. tests/validate_skill.sh (hardcoded expected values)
3. tests/api_provider.test.ts (hardcoded test data)

If api_provider.test.ts is deleted (P0.2), this reduces to two places. Further
improvement: make validate_skill.sh derive expected providers/models from SKILL.md
rather than hardcoding them.

### P1.3: Execute manual test scenarios

tests/test_scenarios.md has a comprehensive test plan with an unchecked checklist.
Run through it at least once and record results. Consider translating critical
scenarios to English for broader contributor access.

## P2 -- Nice to Have

### P2.1: Add testing mention to ARCHITECTURE.md

ARCHITECTURE.md has no testing section. Add a brief section describing the test
strategy (structural validation of SKILL.md, manual scenario testing).

### P2.2: Tighten grep-based checks in validate_skill.sh

Current checks grep the entire SKILL.md file. A token could match in the wrong
section (e.g., a model name in a code block). Improvement: parse frontmatter
specifically (between --- delimiters) for frontmatter checks.

### P2.3: Add plugin.json validation

validate_skill.sh only checks SKILL.md. Consider adding checks for
.claude-plugin/plugin.json: valid JSON, required fields present, referenced
skill paths exist.

### P2.4: Create a single test entrypoint

Add a Makefile or tests/run_all.sh that runs all tests with one command.
