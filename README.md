# Vibe Check - Agent Skills

Metacognitive sanity checks for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating. Helps prevent tunnel vision, over-engineering, and goal misalignment.

> **Version**: 0.1.0 | **License**: MIT | **Author**: [idnotbe](https://github.com/idnotbe)

## Overview

This is an **Agent Skills** implementation of the [vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server). While the original provides the same functionality via MCP (Model Context Protocol), this version implements it as a Claude Code Skill -- a prompt-only plugin with no runtime code.

Claude itself acts as the meta-mentor. There is no external process, no compiled code, and no outbound API calls. The entire plugin is a structured prompt (SKILL.md) that guides Claude's feedback behavior.

### Key Differences from MCP Version

| Aspect | MCP Server | Agent Skills |
|--------|------------|--------------|
| Runtime | External Node.js process | Native Claude integration (prompt-only) |
| LLM Calls | External API (Gemini, OpenAI, etc.) | Claude itself acts as meta-mentor |
| Installation | npm package | Copy skills directory or use plugin manifest |
| Dependencies | Node.js, API keys | None [^1] |
| Multi-model feedback | Real calls to external models | Claude simulates model-aware feedback (see [API Provider and Model Parameters](#api-provider-and-model-parameters)) |

[^1]: The SKILL.md frontmatter declares `required_environment` with 3 API keys (`OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`). These are **metadata** for the `apiProvider`/`model` feature documentation -- the plugin itself makes no outbound API calls and works without any API keys for basic usage. See [Important: No External API Calls](#important-no-external-api-calls).

### Limitations Compared to MCP Version

The MCP server makes real external API calls to OpenAI, Google, and Anthropic models, providing genuine multi-model perspectives. This Skills version does not call external APIs. When you specify `apiProvider` and `model`, Claude adjusts its feedback style to consider that model's characteristics, but the feedback is still generated entirely by Claude. If you need actual multi-model feedback, the MCP version may be a better fit.

### Migrating from MCP Version

For step-by-step migration instructions, see [ARCHITECTURE.md - Migration Path](ARCHITECTURE.md#migration-path). Key steps: remove MCP server configuration, copy the `.claude/skills/` directory, and use `/vibe-check` instead of the MCP tool invocation. Parameter names for `goal`, `plan`, `apiProvider`, `model`, `progress`, `uncertainties`, and `taskContext` are the same in both versions.

## Features

Based on research into Chain-Pattern Interrupts (CPI) showing **+27% improvement in success rates** and **-41% reduction in harmful actions** (as cited by the [original MCP server](https://github.com/PV-Bhat/vibe-check-mcp-server)), this tool provides:

- **Metacognitive Feedback**: Challenge assumptions and prevent tunnel vision
- **Pattern Recognition**: Identify common pitfalls (over-engineering, feature creep, etc.)
- **4-Dimension Evaluation**: Situational analysis, diagnostic assessment, response type selection, and course correction
- **Structured Output**: Consistent feedback format with actionable recommendations
- **API Provider/Model Awareness**: Optional parameters to tailor feedback style (see [API Provider and Model Parameters](#api-provider-and-model-parameters))

## Installation

### Method 1: Copy Skills Directory

1. Copy the skills directory to your project:
   ```bash
   cp -r .claude/skills/ /path/to/your/project/.claude/skills/
   ```

2. Verify the skill is available by typing `/vibe-check` in Claude Code. If it does not appear, restart your Claude Code session.

### Method 2: Plugin Manifest

This repository includes a `.claude-plugin/plugin.json` manifest. If your Claude Code environment supports plugin installation via manifest, the plugin.json defines:
- Plugin name, version, and description
- Skills path reference (`./.claude/skills/vibe-check`)
- Author, homepage, repository, license, and keywords

Refer to your Claude Code documentation for plugin manifest installation steps.

### Directory Structure

```
vibe-check/
  .claude/
    skills/
      vibe-check/
        SKILL.md             # Core skill prompt (the entire "implementation")
  .claude-plugin/
    plugin.json              # Plugin manifest (v0.1.0)
  tests/
    validate_skill.sh        # Structural validator (28 checks)
    test_scenarios.md        # Manual test plan
  ARCHITECTURE.md            # Architecture design document
  CLAUDE.md                  # Claude Code project instructions
  TEST-PLAN.md               # Test infrastructure roadmap
  README.md                  # This file
  LICENSE                    # MIT License
  .gitignore                 # Git ignore rules
```

### Important: No External API Calls

This plugin is **prompt-only**. It contains no executable code, makes no network requests, and does not use your API keys at runtime. The `required_environment` declaration in SKILL.md frontmatter exists as metadata for the `apiProvider`/`model` feature documentation. Your API keys are never read or transmitted by this plugin.

You do not need to configure any API keys for basic `/vibe-check` usage.

## Usage

### /vibe-check - Metacognitive Sanity Check

Use before important decisions or when feeling uncertain:

```
/vibe-check My goal is to add user authentication. My plan is to implement
OAuth2 with JWT tokens, set up Redis for session storage, and create a
custom middleware layer.
```

### Input Parameters

| Parameter | Required | Description |
|-----------|----------|-------------|
| `goal` | Yes | What you are trying to accomplish |
| `plan` | Yes | Your detailed strategy or approach |
| `progress` | No | Current progress -- what you have already done |
| `uncertainties` | No | Concerns or unknowns (comma-separated or multi-line) |
| `taskContext` | No | Background context (tech stack, constraints, environment) |
| `apiProvider` | No | API provider: `openai`, `google`, or `anthropic` (see below) |
| `model` | No | Model name for the chosen provider (see below) |

### Input Formats

The skill accepts three input styles:

**Structured (key: value pairs):**
```
/vibe-check
goal: Add user authentication
plan: OAuth2 + JWT tokens, Redis for session storage
progress: Not started yet
uncertainties: Is Redis really needed? Token expiry settings?
taskContext: Express.js backend, PostgreSQL DB
```

**Natural language:**
```
/vibe-check I want to implement user auth with OAuth2 but I'm not sure if
I need Redis for sessions. Using Express.js with PostgreSQL.
```

**Simple (goal / plan shorthand):**
```
/vibe-check OAuth2 auth implementation / JWT + Redis session storage
```

### Output Format

The skill provides structured feedback in this format:

```
## Vibe Check Results

### Quick Assessment
[One sentence: Is this plan on track, slightly off, or needs major revision?]

### Key Questions to Consider
1. [Most important question about the plan]
2. [Second question]
3. [Third question]
4. [Fourth question - about alignment with original intent]

### Pattern Watch
[If applicable: Which common pitfall patterns might be at play?]

### Recommendation
[Clear guidance: proceed, adjust, or reconsider]

### If Adjusting
[Optional: Specific suggestions for improvement]
```

The **Pattern Watch** section references patterns from the table below. If no concerning patterns are detected, this section may confirm the plan looks solid.

## API Provider and Model Parameters

The `apiProvider` and `model` parameters let you request feedback that considers a specific model's characteristics. **These parameters do not trigger external API calls.** Claude remains the model generating the feedback -- it incorporates knowledge of the specified model's strengths and characteristics into its analysis.

### How It Works

- Without `apiProvider`/`model`: Claude provides standard metacognitive feedback
- With `apiProvider`/`model`: Claude considers the specified model's characteristics (e.g., code specialization, speed vs depth trade-offs) when framing its feedback

### Supported Providers and Models

| Provider | Models | Environment Variable |
|----------|--------|---------------------|
| `openai` | `gpt-5.2-high`, `codex-5.2-high` | `OPENAI_API_KEY` |
| `google` | `gemini-3.0-pro-preview`, `gemini-3.0-flash-preview` | `GEMINI_API_KEY` |
| `anthropic` | `claude-sonnet-4.5`, `claude-opus-4.5` | `ANTHROPIC_API_KEY` |

### Validation Rules

- If `apiProvider` is specified, `model` must also be specified
- The specified `model` must be one supported by the chosen `apiProvider`
- The corresponding API key environment variable must be configured

### Configuration (Optional)

To configure API key environment variables in `~/.claude/settings.json`:

```json
{
  "environment_variables": {
    "OPENAI_API_KEY": "${OPENAI_API_KEY}",
    "GEMINI_API_KEY": "${GEMINI_API_KEY}",
    "ANTHROPIC_API_KEY": "${ANTHROPIC_API_KEY}"
  }
}
```

### Example with Provider

```
/vibe-check
goal: Optimize database query performance
plan: Add composite indexes, implement query caching with Redis
apiProvider: openai
model: codex-5.2-high
```

## When to Use

- **Before irreversible actions**: deployments, database migrations, API changes
- **When uncertainty is high**: unfamiliar technology, unclear requirements
- **When complexity escalates**: nested conditionals, multiple dependencies

## Pattern Watch

The tool helps identify these common pitfalls:

| Pattern | Signs | Remedy |
|---------|-------|--------|
| Complex Solution Bias | Custom implementation when built-in exists | Ask "Is there a simpler way?" |
| Feature Creep | Adding "nice to have" features | Focus on explicit requirements |
| Premature Implementation | Writing code before understanding | Read docs, ask questions first |
| Misalignment | Solving different problem than asked | Re-read original request |
| Overtooling | Adding many dependencies | Evaluate necessity of each |

## Troubleshooting

**The skill does not appear after installation**
- Verify that `.claude/skills/vibe-check/SKILL.md` exists in your project directory
- Check that the file is not empty and starts with `---` (YAML frontmatter)
- Restart your Claude Code session

**Claude asks for API keys / environment variables**
- The `required_environment` declaration in SKILL.md may cause Claude Code to note missing environment variables. This does not prevent the skill from working for basic usage. You only need API keys if you intend to use the `apiProvider`/`model` parameters.

**Unexpected validation errors with apiProvider/model**
- If `apiProvider` is specified, `model` must also be specified
- The model must be from the supported list for the chosen provider (see table above)
- The corresponding API key environment variable must be set in `~/.claude/settings.json`

**Output looks the same with and without apiProvider/model**
- This is expected. The `apiProvider`/`model` parameters influence how Claude frames its feedback but do not call external models. The difference in output may be subtle -- Claude incorporates the specified model's characteristics into its analysis rather than switching to a different model.

## Testing

Run the structural validator:

```bash
bash tests/validate_skill.sh
```

This validates SKILL.md structure across 9 test groups (28 checks total):
file existence, frontmatter, required_environment, API provider docs, model docs,
parameter docs, deprecated parameter absence, configuration examples, and
provider-model mapping.

**Test files:**

| File | Type | Status |
|------|------|--------|
| tests/validate_skill.sh | Automated (bash) | Passes all 28 checks |
| tests/test_scenarios.md | Manual plan | Not yet executed |

See [TEST-PLAN.md](TEST-PLAN.md) for the full test infrastructure roadmap.

## Contributing

### Getting Started

1. Fork and clone the repository
2. Read [CLAUDE.md](CLAUDE.md) for development guidelines and project conventions
3. Read [ARCHITECTURE.md](ARCHITECTURE.md) for design philosophy and structure
4. Run `bash tests/validate_skill.sh` to verify the baseline passes

### Guidelines

- **SKILL.md is the core artifact.** Treat it as the plugin's API -- changes should be deliberate and backward-compatible where possible.
- **Preserve the Output Format section and Core Questions** in SKILL.md.
- Always run `bash tests/validate_skill.sh` after editing SKILL.md.
- If you add or remove providers, models, or parameters in SKILL.md, update `tests/validate_skill.sh` to match.
- Do not add Node.js tooling unless there is a clear, committed need.
- All documentation should be in English.

### What Needs Help

- Adding a GitHub Actions CI workflow (see [TEST-PLAN.md](TEST-PLAN.md) P0.1)

## Updating

To update to a newer version, re-copy the `.claude/skills/vibe-check/` directory from the latest release. The plugin has no local state or configuration to preserve (API key configuration lives in `~/.claude/settings.json`, which is separate from the plugin).

## Credits

- Original MCP Server: [PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)
- Research basis: Chain-Pattern Interrupts (CPI)
- Skills standard: [Agent Skills](https://agentskills.io)

## License

MIT License - See [LICENSE](LICENSE) for details.
