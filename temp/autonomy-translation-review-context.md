# Translation Review Context

## Goal
Reduce unwanted approval-seeking in Claude Code by codifying autonomy rules in this repo's CLAUDE.md. The user complained that I keep asking for `git push` approval. Two independent reviewers should verify the English translation and the autonomy framework.

## Original Korean (now replaced with English)

### Section 1: ## 자율성 (Autonomy)
```
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
```

### Section 2: action-plan authoring rules (Korean)
```
**Plan 작성 시 자율성 원칙:**
- 기본은 **end-to-end 자율 실행**. "User approval gate", "wait for explicit approval", "surface to user before X" 등 승인 게이트를 넣지 마라
- commit/push는 가역적 — 게이트 금지. 위 "확인 필수" 항목에 해당하는 단계에만 confirm step을 넣고 **옆에 이유 1줄** 명시 (예: `# force push to shared branch — irreversible`)
- 기존 plan에서 "wait for approval" 발견 시: "확인 필수" 사유에 해당하면 유지, 아니면 제거 후 자율 진행
```

## Current English (in CLAUDE.md)
See `/home/idnotbe/projects/vibe-check/CLAUDE.md` lines 66-94.

## Review questions

1. **Translation faithfulness**: Does the English preserve all the nuance of the Korean? Any drift in meaning, omitted clauses, mistranslated terms?
2. **Framework integrity**: Is the "Pre-authorized" / "Confirmation required" partition complete? Are there common operations that fall in neither bucket?
3. **Reversibility test**: Is "undone with one command within 5 minutes" too loose? Too tight? Examples that break it?
4. **Plan authoring rules**: Will these reliably stop the next action-plan from inserting "User approval gate" sections? Loophole risk?
5. **Edge cases**: What gets through this framework that should not? What gets blocked that should not?

Be terse and concrete. Cite line numbers and exact phrasing.
