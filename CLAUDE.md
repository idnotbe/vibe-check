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

## 자율성 (Autonomy)

기본 = 자율 실행. 결과는 1-2줄로 보고. 승인 요청은 아래 "확인 필수"에만 한정.

**판단 기준** — "1줄 명령으로 5분 내에 되돌릴 수 있는가?" → 예: 자율 실행. 아니오: 확인.

**사전 승인 (확인 없이 실행)** — 이 저장소 한정, 가역적인 모든 것:
- 파일 편집/생성/삭제 (tracked), `git add/commit/push` (origin/main 포함)
- 브랜치/태그 로컬 조작, `git revert`, `git restore`
- 테스트·검증·빌드 실행, action-plan 이동 및 status 갱신
- subagent 위임, `pal mcp clink`, `vibe-check` 호출

**확인 필수** — 비가역 또는 외부 blast radius:
- `git push --force` / `--force-with-lease` (특히 공유 브랜치)
- untracked 파일·디렉토리 `rm -rf`, `.git/` 직접 수정
- GitHub PR/issue 생성·코멘트, 외부 메시지·이메일 발송
- 릴리스 태그, npm publish, 배포, 비용 발생 작업
- hook 우회 (`--no-verify` 등), `git config` 수정
- 사용자가 명시적으로 결정권을 요구한 사항

## Action Plans

실행 계획 파일은 `action-plans/`에 있다. 각 파일 상단에 YAML frontmatter로 상태를 관리한다.

- `status`: not-started | active | blocked | done
- `progress`: 현재 진행 상태 (자유 텍스트)

**규칙:**
- plan 파일 작업 시작/완료 시 frontmatter의 status와 progress를 업데이트할 것
- 완료된 plan은 `action-plans/_done/`으로 이동
- `action-plans/_ref/`는 참고/역사적 문서

**Plan 작성 시 자율성 원칙:**
- 기본은 **end-to-end 자율 실행**. "User approval gate", "wait for explicit approval", "surface to user before X" 등 승인 게이트를 넣지 마라
- commit/push는 가역적 — 게이트 금지. 위 "확인 필수" 항목에 해당하는 단계에만 confirm step을 넣고 **옆에 이유 1줄** 명시 (예: `# force push to shared branch — irreversible`)
- 기존 plan에서 "wait for approval" 발견 시: "확인 필수" 사유에 해당하면 유지, 아니면 제거 후 자율 진행

## No CI

There is no CI/CD pipeline. See action-plans/test-infrastructure-roadmap.md P0
for the recommendation to add a GitHub Actions workflow that runs
validate_skill.sh on PRs.
