# Vibe Checking - Agent Skills

Metacognitive sanity checks for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating.

## Overview

This is an **Agent Skills** implementation of the [vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server). While the original provides the same functionality via MCP (Model Context Protocol), this version implements it as Claude Code Skills.

### Key Differences from MCP Version

| Aspect | MCP Server | Agent Skills |
|--------|------------|--------------|
| Runtime | External Node.js process | Native Claude integration |
| LLM Calls | External API (Gemini, OpenAI, etc.) | Claude itself acts as meta-mentor |
| Installation | npm package | Copy `.claude/skills/` directory |
| Dependencies | Node.js, API keys | None |

## Features

Based on research showing **+27% improvement in success rates** and **-41% reduction in harmful actions**, this tool provides:

- **Metacognitive Feedback**: Challenge assumptions and prevent tunnel vision
- **Pattern Recognition**: Identify common pitfalls (over-engineering, feature creep, etc.)
- **Learning System**: Record and learn from mistakes
- **Session Rules**: Set behavioral guidelines for each session

## Installation

### Quick Setup

1. Copy the `.claude/skills/` directory to your project:
   ```bash
   cp -r .claude/skills/ /path/to/your/project/.claude/skills/
   ```

2. Copy the `data/` directory for persistent storage:
   ```bash
   cp -r data/ /path/to/your/project/data/
   ```

3. Skills are now available in Claude Code!

### Directory Structure

```
your-project/
├── .claude/
│   └── skills/
│       ├── vibe-check/        # Metacognitive feedback
│       ├── vibe-learn/        # Learning records
│       └── vibe-constitution/ # Session rules
└── data/
    ├── learnings.json         # Learning entries
    ├── constitution.json      # Session rules
    └── history.json           # Session history
```

## Usage

### `/vibe-check` - Metacognitive Sanity Check

Use before important decisions or when feeling uncertain:

```
/vibe-check My goal is to add user authentication. My plan is to implement OAuth2 with JWT tokens, set up Redis for session storage, and create a custom middleware layer.
```

Claude will analyze your plan and provide:
- Quick assessment (on track / slightly off / needs revision)
- Key questions to consider
- Pattern warnings (if applicable)
- Clear recommendations

### `/vibe-learn` - Record Learnings

Record mistakes, preferences, or successes:

```
/vibe-learn mistake "Used complex custom date parser instead of built-in Date" "Replaced with native Date.parse()"

/vibe-learn preference "User prefers TypeScript over JavaScript"

/vibe-learn success "Breaking large function into smaller ones improved readability"
```

Categories for mistakes:
- `complex-solution-bias` - Unnecessarily complex approaches
- `feature-creep` - Adding unrequested functionality
- `premature-implementation` - Coding before understanding
- `misalignment` - Drifting from user intent
- `overtooling` - Using too many tools/libraries

### `/vibe-constitution` - Session Rules

Set behavioral guidelines for the session:

```
# Add a rule
/vibe-constitution update "Always explain approach before writing code"

# Reset all rules
/vibe-constitution reset "Run tests before commits" "Keep functions under 50 lines"

# Check current rules
/vibe-constitution check
```

## When to Use

- **Before irreversible actions**: deployments, database migrations, API changes
- **When uncertainty is high**: unfamiliar technology, unclear requirements
- **When complexity escalates**: nested conditionals, multiple dependencies
- **After making mistakes**: record them to prevent repetition
- **At session start**: set behavioral guidelines

## Pattern Watch

The tool helps identify these common pitfalls:

| Pattern | Signs | Remedy |
|---------|-------|--------|
| Complex Solution Bias | Custom implementation when built-in exists | Ask "Is there a simpler way?" |
| Feature Creep | Adding "nice to have" features | Focus on explicit requirements |
| Premature Implementation | Writing code before understanding | Read docs, ask questions first |
| Misalignment | Solving different problem than asked | Re-read original request |
| Overtooling | Adding many dependencies | Evaluate necessity of each |

## Credits

- Original MCP Server: [PV-Bhat/vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)
- Research basis: Chain-Pattern Interrupts (CPI)
- Skills standard: [Agent Skills](https://agentskills.io)

## License

MIT License - See [LICENSE](LICENSE) for details.
