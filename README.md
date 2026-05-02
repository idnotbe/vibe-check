# Vibe Check - Agent Skills

Metacognitive sanity checks for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating. Helps prevent tunnel vision, over-engineering, and goal misalignment.

> **Version**: 0.2.0 | **License**: MIT | **Author**: [idnotbe](https://github.com/idnotbe)

## Overview

This is an **Agent Skills** implementation of the [vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server). While the original provides the same functionality via MCP (Model Context Protocol), this version implements it as a Claude Code Skill -- a prompt-only plugin with no runtime code.

Claude itself acts as the meta-mentor. There is no external process, no compiled code, and no outbound API calls. The entire plugin is a structured prompt (SKILL.md) that guides Claude's feedback behavior.

### Key Differences from MCP Version

| Aspect | MCP Server | Agent Skills |
|--------|------------|--------------|
| Runtime | External Node.js process | Native Claude integration (prompt-only) |
| LLM Calls | External API (Gemini, OpenAI, etc.) | Claude itself acts as meta-mentor |
| Installation | npm package | Copy skills directory or use plugin manifest |
| Dependencies | Node.js, API keys | None |
| Model Coverage | Multiple (external API calls) | Single (Claude only) |

### Limitations Compared to MCP Version

This Skills version provides Claude-only metacognitive feedback. The MCP version offers genuine multi-model perspectives via real API calls; if you need that, use the MCP version.

### Migrating from MCP Version

For step-by-step migration instructions, see [ARCHITECTURE.md - Migration Path](ARCHITECTURE.md#migration-path). Key steps: remove MCP server configuration, copy the `.claude/skills/` directory, and use `/vibe-check` instead of the MCP tool invocation. Parameter names for `goal`, `plan`, `progress`, `uncertainties`, and `taskContext` are the same in both versions. Legacy `apiProvider` and `model` keys (v0.1.x) are accepted but ignored.

## Features

Based on research into Chain-Pattern Interrupts (CPI) showing **+27% improvement in success rates** and **-41% reduction in harmful actions** (as cited by the [original MCP server](https://github.com/PV-Bhat/vibe-check-mcp-server)), this tool provides:

- **Metacognitive Feedback**: Challenge assumptions and prevent tunnel vision
- **Pattern Recognition**: Identify common pitfalls (over-engineering, feature creep, etc.)
- **4-Dimension Evaluation**: Situational analysis, diagnostic assessment, response type selection, and course correction
- **Structured Output**: Consistent feedback format with actionable recommendations

## Installation

### Method 1: Install via Claude Code plugin marketplace (recommended)

Run these two commands inside Claude Code:

```
/plugin marketplace add idnotbe/claude-plugins
/plugin install vibe-check@idnotbe
```

The first command registers the `idnotbe` plugin marketplace hub; the second installs the `vibe-check` plugin from it. Restart your Claude Code session if `/vibe-check` does not appear immediately.

### Method 2: Manual copy (fallback)

1. Copy the skills directory to your project:
   ```bash
   cp -r .claude/skills/ /path/to/your/project/.claude/skills/
   ```

2. Verify the skill is available by typing `/vibe-check` in Claude Code. If it does not appear, restart your Claude Code session.

### Directory Structure

```
vibe-check/
  .claude/
    skills/
      vibe-check/
        SKILL.md             # Core skill prompt (the entire "implementation")
  .claude-plugin/
    plugin.json              # Plugin manifest (v0.2.0)
  tests/
    validate_skill.sh        # Structural validator (17 checks)
    test_scenarios.md        # Manual test plan
  ARCHITECTURE.md            # Architecture design document
  CLAUDE.md                  # Claude Code project instructions
  action-plans/              # Action plans (실행 계획 관리)
  research/                  # Research materials
  README.md                  # This file
  LICENSE                    # MIT License
  .gitignore                 # Git ignore rules
```

### Important: No External API Calls

This plugin is **prompt-only**. It contains no executable code, makes no network requests, and does not use any API keys at runtime. You do not need to configure any API keys to use `/vibe-check`.

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

> Legacy `apiProvider` and `model` keys (v0.1.x) are accepted but ignored.

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
[One of: "Proceed as planned", "Proceed with adjustments: <what to change>", or "Pause and rethink: <what's unclear>". Always phrased as a continuation directive, never as a stop instruction.]

### If Adjusting
[Optional: Specific suggestions for improvement]

### Next Action
[One sentence stating which step of the original task you will resume immediately after this block. This is mandatory — never omit it.]
```

The **Pattern Watch** section references patterns from the table below. If no concerning patterns are detected, this section may confirm the plan looks solid.

The vibe check is metacognitive scaffolding, not a deliverable: Claude generates the block above and then continues the original task in the same turn, using the **Recommendation** and **Next Action** lines as a self-directive rather than waiting for user acknowledgement.

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

## Testing

Run the structural validator:

```bash
bash tests/validate_skill.sh
```

This validates SKILL.md structure (17 checks total: 10 positive + 7 negative):
file existence, frontmatter, parameter docs, deprecated parameter absence, and
negative checks guarding against silent reintroduction of the removed
`apiProvider`/`model` feature.

**Test files:**

| File | Type | Status |
|------|------|--------|
| tests/validate_skill.sh | Automated (bash) | Passes all 17 checks |
| tests/test_scenarios.md | Manual plan | Not yet executed |

See [test-infrastructure-roadmap.md](action-plans/test-infrastructure-roadmap.md) for the full test infrastructure roadmap.

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
- If you add or remove parameters in SKILL.md, update `tests/validate_skill.sh` to match.
- Do not add Node.js tooling unless there is a clear, committed need.
- All documentation should be in English.

### What Needs Help

- Adding a GitHub Actions CI workflow (see [test-infrastructure-roadmap.md](action-plans/test-infrastructure-roadmap.md) P0.1)

## Updating

If you installed via the plugin marketplace (Method 1), refresh and reinstall:

```
/plugin marketplace update idnotbe
/plugin install vibe-check@idnotbe
```

If you installed via manual copy (Method 2), re-copy the `.claude/skills/vibe-check/` directory from the latest release. The plugin has no local state or configuration to preserve.

## Credits

- Original MCP Server: [PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)
- Research basis: Chain-Pattern Interrupts (CPI)
- Skills standard: [Agent Skills](https://agentskills.io)

## License

MIT License - See [LICENSE](LICENSE) for details.
