# Vibe Check -- Claude Code Skills Plugin

## What This Is

A prompt-only metacognitive skill for Claude Code. No runtime code, no compiled
assets -- the entire plugin is a structured SKILL.md prompt that makes Claude
act as a meta-mentor.

## Repo Structure

    .claude/skills/vibe-check/SKILL.md   # The skill prompt (core artifact)
    .claude-plugin/plugin.json            # Plugin manifest (v0.2.0)
    tests/validate_skill.sh               # Automated structural validator (17 checks)
    tests/test_scenarios.md               # Manual test plan
    README.md                             # User-facing documentation
    ARCHITECTURE.md                       # Architecture design document
    CLAUDE.md                             # This file -- Claude Code project instructions
    action-plans/                         # Action plans (실행 계획 관리)
    research/                             # Research materials
    LICENSE                               # MIT License
    .gitignore                            # Git ignore rules

## Key Facts

- **No runtime dependencies.** The plugin is prompt-only; nothing executes.
- The plugin makes no outbound API calls and requires no environment variables.
- The legacy `apiProvider`/`model` parameter system (v0.1.x) was removed in
  v0.2.0. SKILL.md retains a one-line compatibility note: legacy keys are
  accepted but ignored. The validator's negative checks (Test 5) guard against
  silent reintroduction.

## Testing

All automated tests live in this repo.

### Running Tests

    bash tests/validate_skill.sh

This is the only runnable test. It validates SKILL.md structure: file existence,
frontmatter, parameter docs, deprecated parameter absence, and negative checks
guarding against silent reintroduction of the removed `apiProvider`/`model`
feature. 17 checks (10 positive + 7 negative); exit code 0 on success, 1 on failure.

### Test File Status

| File | Status | Notes |
|------|--------|-------|
| tests/validate_skill.sh | Runnable | 17 structural checks, bash |
| tests/test_scenarios.md | Manual | Not yet executed |

### When Editing SKILL.md

Always run the validator after changes. If you add/remove parameters, update
validate_skill.sh to match. If you change SKILL.md frontmatter
(`description:`, `argument-hint:`), also update the verbatim YAML block in
ARCHITECTURE.md (under "Skill Specification → YAML Frontmatter").

## Development Guidelines

- Keep SKILL.md stable -- it is the "API" of this plugin.
- Preserve the Output Format section and Core Questions.
- Do not add Node.js tooling unless there is a clear, committed need.
- All committed content should be in English.

## Autonomy

Default = autonomous execution. Report results in 1-2 sentences. Request confirmation only for items under "Confirmation required" below.

**Decision rule** — both must hold to execute autonomously:
1. **Reversible from local state** with a short, well-known sequence (`git revert`, `git restore`, `git mv` back, etc.) — not requiring conflict resolution or reflog archaeology.
2. **No external side effects already in flight** — nothing that has notified humans, triggered CI someone watches, or could already have been pulled/consumed.

If either fails, confirm.

**Pre-authorized (execute without confirmation)** — within this repo, when the decision rule holds:
- File edit/create/delete (tracked), `git add/commit/push` (including `origin/main`)
- Local branch/tag operations, `git revert`, `git restore`
- Running tests, validators, builds; moving action-plans and updating status
- Delegating to subagents; calling `pal mcp clink`, `vibe-check`

**Confirmation required** — irreversible, history-rewriting, destructive, or external blast radius:
- `git push --force` / `--force-with-lease` (especially on shared branches)
- History rewrites on already-pushed commits: `git commit --amend`, `git rebase -i`, `git reset --hard` on shared history
- Workspace destruction outside git's safety net: `git clean -fd`, `rm -rf` on untracked files/directories, direct edits inside `.git/`
- Remote-ref deletion: `git push --delete`, deleting unmerged branches
- Creating/commenting on GitHub PRs/issues, sending external messages or email
- Release tags, `npm publish`, deploys, cost-incurring operations
- Bypassing hooks (`--no-verify` etc.), modifying `git config`
- Anything the user explicitly reserved decision authority over **in this conversation** (plan text alone does not count)

**Default for unlisted operations**: if it touches only local tracked state and is reversible per the decision rule, treat as Pre-authorized. If it rewrites history, deletes untracked work, or has external reach, treat as Confirmation required. When genuinely ambiguous, confirm once and remember the answer for the rest of the session.

## Action Plans

실행 계획 파일은 `action-plans/`에 있다. 각 파일 상단에 YAML frontmatter로 상태를 관리한다.

- `status`: not-started | active | blocked | done
- `progress`: 현재 진행 상태 (자유 텍스트)

**규칙:**
- plan 파일 작업 시작/완료 시 frontmatter의 status와 progress를 업데이트할 것
- 완료된 plan은 `action-plans/_done/`으로 이동
- `action-plans/_ref/`는 참고/역사적 문서

**Plan authoring — autonomy principles:**
- Default is **end-to-end autonomous execution**. Do not insert any pause / checkpoint / review / sign-off / approval / surface-to-user step — regardless of wording — unless it cites the exact "Confirmation required" bullet it maps to.
- commit/push are reversible — never gate them.
- Each gated step must include a citation comment naming the matching bullet, e.g. `# Gate: Confirmation required → "git push --force on shared branches"`. No citation = remove the gate.
- When auditing existing plans, apply the same citation test: any gate without a valid citation is removed before execution proceeds.

## No CI

There is no CI/CD pipeline. See action-plans/test-infrastructure-roadmap.md P0
for the recommendation to add a GitHub Actions workflow that runs
validate_skill.sh on PRs.
