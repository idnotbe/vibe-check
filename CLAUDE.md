# Vibe Check -- Claude Code Skills Plugin

## What This Is

A prompt-only metacognitive skill for Claude Code. No runtime code, no compiled
assets -- the entire plugin is a structured SKILL.md prompt that makes Claude
act as a meta-mentor.

## Repo Structure

    .claude/skills/vibe-check/SKILL.md   # The skill prompt (core artifact)
    .claude-plugin/plugin.json            # Plugin manifest (v0.1.0)
    tests/validate_skill.sh               # Automated structural validator (28 checks)
    tests/test_scenarios.md               # Manual test plan
    README.md                             # User-facing documentation
    ARCHITECTURE.md                       # Architecture design document
    CLAUDE.md                             # This file -- Claude Code project instructions
    TEST-PLAN.md                          # Test infrastructure roadmap
    LICENSE                               # MIT License
    .gitignore                            # Git ignore rules

## Key Facts

- **No runtime dependencies.** The plugin is prompt-only; nothing executes.
- SKILL.md declares `required_environment` (3 API keys). These are metadata for
  the `apiProvider`/`model` feature -- this repo makes no outbound API calls.
  The `apiProvider` and `model` parameters let users request feedback that
  considers a specific model's characteristics, but Claude itself generates all
  feedback. No external models are called.
- README clarifies the "Dependencies: None" claim with a footnote explaining
  that `required_environment` keys are metadata, not runtime dependencies.
  See TEST-PLAN.md P1.1 for the full discussion.

## The apiProvider/model Feature

SKILL.md (lines 38-106) defines an `apiProvider`/`model` system supporting 3
providers (openai, google, anthropic) and 6 models. Key points:

- **These do NOT trigger external API calls.** Claude adjusts its feedback style
  to consider the specified model's characteristics.
- Parameters: `apiProvider` (openai|google|anthropic) and `model` (provider-specific)
- If `apiProvider` is specified, `model` must also be specified; model must match provider
- API key env vars are validated as metadata but never used for actual API calls
- Configuration via `~/.claude/settings.json` `environment_variables`

## Testing

All automated tests live in this repo.

### Running Tests

    bash tests/validate_skill.sh

This is the only runnable test. It validates SKILL.md structure: file existence,
frontmatter, required_environment, API provider docs, model docs, parameter docs,
deprecated parameter absence, config examples, and provider-model mapping table.
28 checks across 9 test groups; exit code 0 on success, 1 on failure.

### Test File Status

| File | Status | Notes |
|------|--------|-------|
| tests/validate_skill.sh | Runnable | 28 structural checks, bash |
| tests/test_scenarios.md | Manual | Not yet executed |

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
