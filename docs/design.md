# Design notes

## Project boundary

vibe-check is a portable Agent Skill for Claude and ChatGPT/Codex, distributed on its own or through skills-only plugins. The repository exists to evolve the skill's instructions and its supporting distribution metadata.

The `.agents/skills/vibe-check/` bundle directory is the canonical source and remains installable on its own. Keeping one copy avoids drift between development files and a later installed or published copy.

## Current architecture

The canonical skill bundle is intentionally self-contained:

- `SKILL.md` contains the shared gate, decision choices, stop conditions, and output shape.
- `agents/openai.yaml` contains optional Codex interface metadata.
- The bundle contains no references, scripts, assets, or plugin manifests; the current skill is instruction-only at runtime.

At the repository root, `.claude-plugin/plugin.json` and `.codex-plugin/plugin.json` provide Claude and OpenAI compatibility wrappers. Both point `skills` to `./.agents/skills/` and share the same identity and release version. They distribute the canonical bundle without a second skill copy, MCP server, automatic hooks, credentials, or background process.

Repository-level `tools/distribution.py` and `tests/test_distribution.py` check distribution structure and installation; they are not runtime components of the skill. [INSTALL.md](../INSTALL.md) records installation modes, marketplace distribution, update/rollback, and verification boundaries.

## Evolution rules

Add a supporting reference only when a distinct branch needs substantial material that should not load for every invocation. Add a script only when deterministic execution is safer or more repeatable than rewriting the same logic in instructions.

Before changing behavior, identify the request or failure that justifies the change. Preserve the existing contract unless the change explicitly revises it. Keep product-host assumptions separate from the skill's general reasoning contract.

## Evidence boundary

Changes to wording or structure can be checked statically. Installer checks can establish discovery and installed-byte consistency within their tested scope. Claims that the skill triggers correctly or improves decisions require fresh-session behavioral evidence; static validation and successful installation alone are not enough.
