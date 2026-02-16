# Vibe Check Agent Skills - Architecture Design

## Design Philosophy

### Core Principles: MCP to Skills Conversion

1. **Claude as Meta-Mentor**: The original MCP server called external LLMs to generate feedback. In the Skills version, Claude itself acts as the meta-mentor -- no external process or API calls required.
2. **Instruction-Based Approach**: Detailed instructions in SKILL.md guide Claude's behavior, replacing the external runtime logic of the MCP server.

---

## Plugin Structure

```
vibe-check/
  .claude/
    skills/
      vibe-check/
        SKILL.md                 # Core skill prompt (the entire "implementation")
  .claude-plugin/
    plugin.json                  # Plugin manifest (name, version, skills path, author, etc.)
  tests/
    validate_skill.sh            # Structural validator (28 checks across 9 test groups)
    api_provider.test.ts         # Dead code (no Node.js scaffolding)
    test_scenarios.md            # Manual test plan (Korean)
  ARCHITECTURE.md                # Architecture design document (this file)
  CLAUDE.md                      # Claude Code project instructions
  TEST-PLAN.md                   # Test infrastructure roadmap
  README.md                      # User-facing documentation
  LICENSE                        # MIT License
  .gitignore                     # Git ignore rules
```

The `.claude-plugin/plugin.json` manifest defines plugin metadata (name: `vibe-check`, version: `0.1.0`, skills path, author, homepage, repository, license, keywords) for plugin distribution. The `.claude/skills/vibe-check/SKILL.md` file is the sole functional artifact.

---

## Skill Specification

### vibe-check Skill

**Purpose**: Provide metacognitive feedback on agent plans.

**YAML Frontmatter:**
```yaml
name: vibe-check
description: Metacognitive sanity check for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating. Helps prevent tunnel vision, over-engineering, and goal misalignment.
argument-hint: goal: [목표] plan: [계획] apiProvider: [openai|google|anthropic] model: [모델명] (또는 자유 형식 텍스트)
required_environment:
  - OPENAI_API_KEY
  - GEMINI_API_KEY
  - ANTHROPIC_API_KEY
```

Note: The above YAML frontmatter is reproduced verbatim from SKILL.md, including Korean text in the `argument-hint`. The Korean portions translate as: `[목표]` = "[goal]", `[계획]` = "[plan]", `[모델명]` = "[model name]", `(또는 자유 형식 텍스트)` = "(or free-form text)". `required_environment` is metadata for provider/model documentation. The plugin makes no outbound API calls and functions without these keys for basic usage.

**Core Capabilities -- 4-Dimension Evaluation:**
1. **Situational Analysis**: Nature of the problem, appropriateness of approach
2. **Diagnostic Assessment**: Pattern recognition, assumption checking, intervention level
3. **Response Type Selection**: Technical guidance / gentle questioning / stern redirection / validation
4. **Course Correction**: Best practice reminders, simpler alternatives, refocusing questions

**Core Meta-Mentor Questions:**
1. Does this plan actually solve what the user asked for?
2. Is there a simpler alternative?
3. What assumptions might be limiting the thinking?
4. How closely does this align with the original intent?

**Pattern Watch Categories:**
- Complex Solution Bias
- Feature Creep
- Premature Implementation
- Misalignment
- Overtooling

### Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `goal` | Yes | What the user is trying to accomplish |
| `plan` | Yes | Detailed strategy or approach |
| `progress` | No | Current progress -- work completed so far |
| `uncertainties` | No | Concerns or unknowns |
| `taskContext` | No | Background context (tech stack, constraints) |
| `apiProvider` | No | Provider: `openai`, `google`, or `anthropic` |
| `model` | No | Model name (must match chosen provider) |

### API Provider and Model Architecture

The `apiProvider` and `model` parameters allow users to request feedback that considers a specific model's characteristics. **These do not trigger external API calls.** Claude remains the model generating feedback -- it incorporates knowledge of the specified model's strengths into its analysis.

**Supported Providers and Models:**

| Provider | Models | Environment Variable |
|----------|--------|---------------------|
| `openai` | `gpt-5.2-high`, `codex-5.2-high` | `OPENAI_API_KEY` |
| `google` | `gemini-3.0-pro-preview`, `gemini-3.0-flash-preview` | `GEMINI_API_KEY` |
| `anthropic` | `claude-sonnet-4.5`, `claude-opus-4.5` | `ANTHROPIC_API_KEY` |

**Validation Rules:**
- If `apiProvider` is specified, `model` must also be specified
- The model must be supported by the chosen provider
- The corresponding API key environment variable must be configured

**Configuration** is done via `~/.claude/settings.json` (see README for example).

---

## Implementation Notes

### Claude as Meta-Mentor

Unlike the MCP server which called external LLMs, the Skills version:
- Has Claude itself perform the meta-mentor role
- Embeds detailed evaluation criteria and questions in SKILL.md
- Leverages Claude's self-reflection capabilities

This is an intentional trade-off with advantages:
- No external API calls (reduced cost and latency)
- Leverages Claude's existing context understanding
- More consistent feedback quality

And limitations:
- No genuine multi-model perspective (Claude simulates model awareness)
- Feedback is always from a single model, regardless of `apiProvider`/`model` settings

### Bilingual Content in SKILL.md

SKILL.md contains bilingual content (English and Korean). Structural elements (evaluation framework, output format, core questions, tone guidelines) are in English. Parameter descriptions, input format examples, and provider configuration instructions are in Korean, reflecting the original development context. This is a known inconsistency with the English-only documentation guideline in CLAUDE.md.

---

## Testing Architecture

### Structural Validation

`tests/validate_skill.sh` performs 28 automated checks across 9 test groups:

1. **Existence**: SKILL.md file exists
2. **Frontmatter**: Delimiters (`---`), name (`vibe-check`), description present
3. **Required Environment**: Section exists, 3 API keys listed
4. **API Providers**: 3 provider names documented (`openai`, `google`, `anthropic`)
5. **Models**: 6 model names documented
6. **Parameters**: 7 parameter names documented (`goal`, `plan`, `progress`, `uncertainties`, `taskContext`, `apiProvider`, `model`)
7. **Deprecated Parameters**: `modelOverride` absent
8. **Configuration Examples**: `environment_variables` reference present (pass/fail), `settings.json` reference present (pass/warn)
9. **Provider-Model Mapping**: Mapping table header present

### Other Test Files

- `tests/api_provider.test.ts`: Dead code -- no Node.js scaffolding exists. Cannot run.
- `tests/test_scenarios.md`: Manual test plan in Korean. Has never been executed.

See TEST-PLAN.md for the full test infrastructure roadmap.

---

## Migration Path

For users migrating from the MCP server ([PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)):

1. Remove MCP server configuration from your project
2. Copy `.claude/skills/` directory into your project (or install via plugin manifest)
3. Use `/vibe-check` in Claude Code instead of the MCP tool invocation

Key differences after migration:
- External model calls are replaced by Claude's own meta-analysis
- No npm dependencies or external processes needed
- API keys are optional metadata, not runtime requirements

---

## Version Considerations

- Plugin version: 0.1.0 (defined in `.claude-plugin/plugin.json`)
- Original MCP server reference: [PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)
- Specification: [Agent Skills](https://agentskills.io) standard with Claude Code extensions
