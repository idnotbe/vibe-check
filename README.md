# Vibe Check - Agent Skills

Metacognitive sanity checks for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating.

## Overview

This is an **Agent Skills** implementation of the [vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server). While the original provides the same functionality via MCP (Model Context Protocol), this version implements it as Claude Code Skills.

### Key Differences from MCP Version

| Aspect | MCP Server | Agent Skills |
|--------|------------|--------------|
| Runtime | External Node.js process | Native Claude integration |
| LLM Calls | External API (Gemini, OpenAI, etc.) | Claude itself acts as meta-mentor |
| Installation | npm package | Copy skills directory |
| Dependencies | Node.js, API keys | None |

## Features

Based on research showing **+27% improvement in success rates** and **-41% reduction in harmful actions**, this tool provides:

- **Metacognitive Feedback**: Challenge assumptions and prevent tunnel vision
- **Pattern Recognition**: Identify common pitfalls (over-engineering, feature creep, etc.)

## Installation

### Quick Setup

1. Copy the skills directory to your project:
   ```bash
   cp -r .claude/skills/ /path/to/your/project/.claude/skills/
   ```

2. Skills are now available in Claude Code!

### Directory Structure

```
your-project/
  .claude/
    skills/
      vibe-check/        # Metacognitive feedback
```

## Usage

### /vibe-check - Metacognitive Sanity Check

Use before important decisions or when feeling uncertain:

```
/vibe-check My goal is to add user authentication. My plan is to implement
OAuth2 with JWT tokens, set up Redis for session storage, and create a
custom middleware layer.
```

Claude will analyze your plan and provide:
- Quick assessment (on track / slightly off / needs revision)
- Key questions to consider
- Pattern warnings (if applicable)
- Clear recommendations

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

## Testing

Run the structural validator:

```bash
bash tests/validate_skill.sh
```

This checks SKILL.md for correct frontmatter, required sections, provider/model
documentation, parameter docs, and configuration examples (28 checks total).

**Test files:**

| File | Type | Status |
|------|------|--------|
| tests/validate_skill.sh | Automated (bash) | Passes all 28 checks |
| tests/test_scenarios.md | Manual plan | Korean, not yet executed |
| tests/api_provider.test.ts | TypeScript | Dead code -- no Node.js scaffolding |

The TypeScript test file cannot run (no package.json or tsconfig.json). See
TEST-PLAN.md for cleanup recommendations.

## Credits

- Original MCP Server: [PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)
- Research basis: Chain-Pattern Interrupts (CPI)
- Skills standard: [Agent Skills](https://agentskills.io)

## License

MIT License - See [LICENSE](LICENSE) for details.
