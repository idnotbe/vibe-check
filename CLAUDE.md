# Vibe Check -- Claude Code Skills Plugin

## What This Is

A prompt-only metacognitive skill for Claude Code. No runtime code, no compiled
assets -- the entire plugin is a structured SKILL.md prompt that makes Claude
act as a meta-mentor.

## Repo Structure

    .claude/skills/vibe-check/SKILL.md   # The skill prompt (core artifact)
    .claude-plugin/plugin.json            # Plugin manifest
    tests/validate_skill.sh               # Automated structural validator (28 checks)
    tests/api_provider.test.ts            # DEAD CODE -- see Testing notes
    tests/test_scenarios.md               # Manual test plan (Korean)

## Key Facts

- **No runtime dependencies.** The plugin is prompt-only; nothing executes.
- SKILL.md declares required_environment (3 API keys). These are metadata for
  provider/model documentation -- this repo makes no outbound API calls.
- README says "Dependencies: None" while SKILL.md lists required keys. This is a
  known contract mismatch (see TEST-PLAN.md P1).
- ARCHITECTURE.md and test_scenarios.md are written in Korean.

## Testing

All automated tests live in this repo.

### Running Tests

    bash tests/validate_skill.sh

This is the only runnable test. It validates SKILL.md structure: frontmatter,
required_environment, API provider docs, model docs, parameter docs, deprecated
parameter absence, config examples, and provider-model mapping table.
28 checks total; exit code 0 on success, 1 on failure.

### Test File Status

| File | Status | Notes |
|------|--------|-------|
| tests/validate_skill.sh | Runnable | 28 structural checks, bash |
| tests/test_scenarios.md | Manual | Korean, never executed |
| tests/api_provider.test.ts | Dead code | No package.json/tsconfig/node_modules |

The TypeScript test cannot run. There is no Node.js scaffolding in this repo.
It should be deleted or properly scaffolded (see TEST-PLAN.md P0).

### When Editing SKILL.md

Always run the validator after changes. If you add/remove providers, models,
or parameters, update validate_skill.sh to match.

## Development Guidelines

- Keep SKILL.md stable -- it is the "API" of this plugin.
- Preserve the Output Format section and Core Questions.
- Do not add Node.js tooling unless there is a clear, committed need.
- All committed content should be in English.

## No CI

There is no CI/CD pipeline. See TEST-PLAN.md P0 for the recommendation to add
a GitHub Actions workflow that runs validate_skill.sh on PRs.
