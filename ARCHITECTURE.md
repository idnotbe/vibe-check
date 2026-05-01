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
    validate_skill.sh            # Structural validator (17 checks: 10 positive + 7 negative)
    test_scenarios.md            # Manual test plan
  ARCHITECTURE.md                # Architecture design document (this file)
  CLAUDE.md                      # Claude Code project instructions
  action-plans/                  # Action plans (실행 계획 관리)
  research/                      # Research materials
  README.md                      # User-facing documentation
  LICENSE                        # MIT License
  .gitignore                     # Git ignore rules
```

The `.claude-plugin/plugin.json` manifest defines plugin metadata (name: `vibe-check`, version: `0.2.0`, skills path, author, homepage, repository, license, keywords) for plugin distribution. The `.claude/skills/vibe-check/SKILL.md` file is the sole functional artifact.

---

## Skill Specification

### vibe-check Skill

**Purpose**: Provide metacognitive feedback on agent plans.

**YAML Frontmatter:**
```yaml
name: vibe-check
description: Metacognitive sanity check for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating. Helps prevent tunnel vision, over-engineering, and goal misalignment.
argument-hint: goal: [goal] plan: [plan] (free-form text also works)
```

Note: The above YAML frontmatter is reproduced verbatim from SKILL.md. The plugin makes no outbound API calls and requires no environment variables.

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
| `uncertainties` | No | Concerns or unknowns (comma-separated or multi-line) |
| `taskContext` | No | Background context (tech stack, constraints) |

> Legacy `apiProvider` and `model` keys (v0.1.x) are accepted but ignored. See SKILL.md.

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
- No genuine multi-model perspective; feedback is always from Claude

---

## Testing Architecture

### Structural Validation

`tests/validate_skill.sh` performs 17 automated checks across 5 test groups (10 positive + 7 negative):

1. **Existence** (1 positive): SKILL.md file exists
2. **Frontmatter** (3 positive): Delimiters (`---`), name (`vibe-check`), description present
3. **Parameters** (5 positive): Parameter names documented (`goal`, `plan`, `progress`, `uncertainties`, `taskContext`)
4. **Deprecated Parameters** (1 negative): `modelOverride` absent
5. **Legacy Feature Absence** (7 negative): Guards against silent reintroduction of the removed `apiProvider`/`model` feature -- `required_environment:` frontmatter field absent, `apiProvider` and `model` parameter-table rows absent, provider-model mapping table header absent, and the three legacy API key names (`OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`) absent

### Other Test Files

- `tests/test_scenarios.md`: Manual test plan. Has never been executed.

See action-plans/test-infrastructure-roadmap.md for the full test infrastructure roadmap.

---

## Migration Path

For users migrating from the MCP server ([PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)):

1. Remove MCP server configuration from your project
2. Copy `.claude/skills/` directory into your project (or install via plugin manifest)
3. Use `/vibe-check` in Claude Code instead of the MCP tool invocation

Key differences after migration:
- External model calls are replaced by Claude's own meta-analysis
- No npm dependencies or external processes needed
- No API key environment is required; legacy `apiProvider`/`model` keys in invocations are accepted but ignored

---

## Version Considerations

- Plugin version: 0.2.0 (defined in `.claude-plugin/plugin.json`)
- Original MCP server reference: [PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)
- Specification: [Agent Skills](https://agentskills.io) standard with Claude Code extensions
