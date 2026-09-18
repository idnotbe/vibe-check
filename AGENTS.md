# vibe-check Project Rules

This repository develops the vibe-check Codex skill as an independent project.

## Source of truth

- The canonical skill bundle is .agents/skills/vibe-check/.
- The shipped entrypoint is .agents/skills/vibe-check/SKILL.md.
- Keep the canonical bundle installable on its own.
- Do not maintain a second copy under src/, the repository root, or another skill directory.
- docs/design.md and docs/evaluation.md record project decisions and checks; they do not replace the shipped skill instructions.
- temp/ is scratch space for local notes, logs, and experiments. Never stage it.

## Change rules

- Preserve the skill's explicit contract unless the requested change includes a contract change.
- Keep the discovery description short and specific.
- Add references only for branch-specific guidance that does not belong in every invocation.
- Add scripts only for deterministic work that would otherwise be repeated.
- Treat static validation as structural evidence, not proof that the skill improves task outcomes.
- Inspect the final bundle and its diff before claiming completion.
