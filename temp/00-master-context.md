# Master Context - Vibe Check Documentation Improvement

## Project Overview
- **What**: A prompt-only metacognitive skill plugin for Claude Code
- **Core artifact**: `.claude/skills/vibe-check/SKILL.md` (the skill prompt)
- **No runtime code** - everything is prompt-based

## File Inventory

| File | Purpose | Language |
|------|---------|----------|
| `.claude/skills/vibe-check/SKILL.md` | Core skill prompt (the "implementation") | Mixed (EN/KR) |
| `.claude-plugin/plugin.json` | Plugin manifest | JSON |
| `README.md` | User-facing documentation | English |
| `ARCHITECTURE.md` | Architecture design doc | Korean |
| `CLAUDE.md` | Claude Code project instructions | English |
| `TEST-PLAN.md` | Test infrastructure roadmap | English |
| `tests/validate_skill.sh` | Structural validator (28 checks) | Bash |
| `tests/test_scenarios.md` | Manual test plan | Korean |
| `tests/api_provider.test.ts` | Dead code (no Node.js scaffolding) | TypeScript |
| `LICENSE` | MIT License | English |
| `.gitignore` | Git ignore rules | - |

## Key Implementation Details (from SKILL.md)

### Frontmatter
```yaml
name: vibe-check
description: Metacognitive sanity check for agent plans...
argument-hint: goal: [target] plan: [plan] apiProvider: [openai|google|anthropic] model: [model]
required_environment:
  - OPENAI_API_KEY
  - GEMINI_API_KEY
  - ANTHROPIC_API_KEY
```

### Parameters
- **Required**: `goal`, `plan`
- **Optional**: `progress`, `uncertainties`, `taskContext`, `apiProvider`, `model`

### Supported Providers/Models
| Provider | Models | Env Var |
|----------|--------|---------|
| openai | gpt-5.2-high, codex-5.2-high | OPENAI_API_KEY |
| google | gemini-3.0-pro-preview, gemini-3.0-flash-preview | GEMINI_API_KEY |
| anthropic | claude-sonnet-4.5, claude-opus-4.5 | ANTHROPIC_API_KEY |

### Output Format
Structured feedback: Quick Assessment, Key Questions, Pattern Watch, Recommendation, If Adjusting

### Plugin Manifest (plugin.json)
- version: 0.1.0
- skills: ["./.claude/skills/vibe-check"]
- author: idnotbe
- homepage/repo: https://github.com/idnotbe/vibe-check

## Known Issues (from CLAUDE.md / TEST-PLAN.md)
1. README says "Dependencies: None" but SKILL.md lists 3 API keys (contract mismatch)
2. ARCHITECTURE.md is in Korean (CLAUDE.md says all committed content should be English)
3. test_scenarios.md is in Korean
4. api_provider.test.ts is dead code (no Node.js scaffolding)
5. No CI/CD pipeline
6. Provider/model data is duplicated in 3 places

## CONSTRAINT: Do NOT modify implementation
- Do NOT change SKILL.md
- Do NOT change plugin.json
- Do NOT change tests/validate_skill.sh
- Do NOT change tests/api_provider.test.ts
- Only modify documentation files: README.md, ARCHITECTURE.md, CLAUDE.md, TEST-PLAN.md
- May create new documentation files if needed

## Goal
1. Compare implementation vs documentation, find gaps
2. Write user scenarios (install, config, usage, troubleshooting, etc.)
3. Enhance documentation to faithfully serve those scenarios
