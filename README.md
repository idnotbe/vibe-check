# vibe-check

A portable Agent Skill and skills-only plugin for Claude and ChatGPT/Codex.

## Install

```sh
npx skills@latest add idnotbe/vibe-check --skill vibe-check --agent codex claude-code --copy
```

See [installation and distribution](INSTALL.md) for project/global scope, Windows
and Linux, both plugin marketplaces, update/rollback, and verification boundaries.

## Purpose

This repository is the working home for improving, testing, and packaging vibe-check.
The skill helps the assistant decide whether the next unit of work should proceed,
be narrowed, or stop when cost, evidence, authority, or risk matters.

## Canonical bundle

The editable and packageable skill bundle is `.agents/skills/vibe-check/`.
That directory is the single source of truth. Both plugin manifests refer to it;
there is no separate source copy or generated install copy.

## Repository layout

```text
.agents/skills/vibe-check/
  SKILL.md                     Skill entrypoint and behavior contract
  agents/openai.yaml           Optional Codex UI metadata
.claude-plugin/plugin.json      Claude plugin manifest
.codex-plugin/plugin.json       OpenAI plugin manifest
INSTALL.md                      Installation and shared distribution contract
tools/distribution.py           Structural and real-installer checks
tests/test_distribution.py      Adversarial checker regression tests
docs/design.md                  Architecture and evolution decisions
docs/evaluation.md              Behavior-check guidance
AGENTS.md                       Repository-specific working rules
```

## Development loop

1. Read the current bundle and relevant project documents.
2. Make the smallest change addressing an observed need.
3. Run `python -B -m unittest discover -s tests -v` and `python -B tools/distribution.py`.
4. Run the explicit installer evaluation documented in INSTALL.md. Test behavior in
   a fresh authenticated host session when triggering or decisions change.
5. Review the final file list and diff. Keep scratch evidence under `temp/` and out
   of the committed runtime bundle.

A structurally valid or successfully installed skill is still only a candidate
until behavior is observed in its intended host. Installer checks do not establish
reasoning quality, implicit selection, or authenticated model performance.

The original candidate was copied from the global vibe-check skill. Improve this
canonical bundle first, then deliberately install or publish a reviewed revision.
