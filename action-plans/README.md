# Action Plans

Execution plan management directory.

## Structure
- Root `.md` files = active plans (not-started, active, blocked)
- `_done/` = completed plans
- `_ref/` = reference/historical documents

## Frontmatter Rules
All plan files must have YAML frontmatter at the top:

```yaml
---
status: not-started    # not-started | active | blocked | done
progress: "Not started"  # Current progress (free text)
---
```

## Status Values
- **not-started**: Work has not begun
- **active**: Currently in progress
- **blocked**: Waiting on unresolved dependencies
- **done**: Completed -> **must** move to `_done/`

## Action Plan File Structure
Action plan files must contain ordered actions (phase1, phase2... or step1, step2...).

Each step must have a progress checkmark:
- `[v]` = done
- `[ ]` = not started
- `[/]` = in progress

Example:
```markdown
## Phase 1: Initial Setup
- [v] Configure environment
- [v] Install dependencies

## Phase 2: Implementation
- [/] Develop core feature
- [ ] Write tests
```

When all steps are marked `[v]`, the entire plan is done. Update frontmatter to `status: done` and move the file to `_done/`.

## Lifecycle (Full Execution Protocol)

Every action plan follows this **mandatory multi-phase lifecycle**. Unless explicitly classified as a **Lightweight plan** (see below), skipping any phase is a blocking error.

### Phase 0: Docs-Plan Alignment (GATE -- must complete before any plan execution)

1. **Read current docs**: `README.md`, `ARCHITECTURE.md`, `CLAUDE.md`, `.claude/skills/vibe-check/SKILL.md`, `.claude-plugin/plugin.json`, `tests/`, `research/` -- architecture, requirements, constraints, fact registry.
2. **Diff against plan**: Compare docs requirements/architecture with plan goals. Produce a **gap list**:
   - New requirements (not in docs)
   - Changed requirements (docs and plan conflict)
   - Removed requirements (plan deprecates)
3. **Impact assessment**: Per gap, estimate change scope, affected documents/systems, and risk.
4. **Draft planned doc changes** in `temp/{plan-name}-phase0-drafts.md`. Do NOT mutate live docs at this stage -- keep all proposed content in working memory (`temp/`) until Phase F-1 finalization. If the plan has no documentation impact, record "No documentation impact" in the alignment doc -- a separate drafts file is not required.
5. Write gap list and impact assessment to `temp/{plan-name}-phase0-alignment.md`.
6. **Gate check**: Alignment doc must exist (and drafts, if documentation changes are planned) before Phase 1.

### Phase 1--N: Execution

- Standard lifecycle: `status: active`, update progress, mark `[v]/[/]/[ ]` per step.
- If changes affect **another active plan**, add: `> WARNING -- IMPACT: {this-plan-name} changed {document/workstream}. Review required.`
- Use `temp/` as **working memory**: intermediate analysis, verification results, shared docs.
- If SKILL.md or `tests/validate_skill.sh` is touched, run `bash tests/validate_skill.sh` before closing the phase.

> **Blocked plans**: Plans with `status: blocked` should document: (a) unblock condition, (b) next review date. Plans blocked >90 days should be reviewed for archival or dependency resolution.

### Phase F-1: Docs Sync (GATE -- must complete before commit)

1. **Apply planned doc changes**: Integrate content from `temp/{plan-name}-phase0-drafts.md` (and any execution-phase updates) into live docs (`README.md`, `ARCHITECTURE.md`, `CLAUDE.md`, `SKILL.md`).
2. **Docs-plan consistency**: Verify all live docs match the completed plan state exactly.
3. **SKILL.md ↔ ARCHITECTURE.md sync**: If SKILL.md frontmatter (`description:`, `argument-hint:`) changed, update the verbatim YAML block in ARCHITECTURE.md (under "Skill Specification → YAML Frontmatter") per CLAUDE.md.
4. **Validator alignment**: If parameters were added/removed in SKILL.md, update `tests/validate_skill.sh` to match.
5. **Cross-plan check**: Confirm changes don't break other active plans' assumptions; update if needed.
6. **Staleness check**: If the plan was blocked or dormant for >2 weeks, re-verify `temp/` drafts against current live docs before applying.
7. **Final validation**: Run `bash tests/validate_skill.sh` -- must exit 0.

### Phase F: Commit & Push (GATE -- final)

1. Frontmatter -> `status: done`, update `progress` to final summary. Move plan file to `_done/`.
2. `git add` -- only the changed files (docs + plan file + supporting artifacts). Avoid `git add -A`/`git add .` to prevent staging sensitive files.
3. `git commit` -- message includes plan name and completed phases.
4. `git push` -- push to remote (only when explicitly authorized by the user).

### Lifecycle Summary

```
Phase 0: Docs-Plan Alignment  -->  Gap list + Impact + Drafts in temp/
    |
Phase 1-N: Execution           -->  Document/system changes + temp/ working memory
    |
Phase F-1: Docs Sync           -->  Apply drafts to live docs, verify consistency
    |
Phase F: Commit & Push          -->  status: done, move to _done/, git commit & push
```

> **Migration**: This lifecycle applies to NEW plans created after this README update. Existing active plans adopt the lifecycle at their next major phase boundary or when restarted. Legacy plans are not retroactively non-compliant.

> **Lightweight plans** (single-doc updates, README typo fixes, plans with no SKILL.md or validator impact): Phase 0 may be abbreviated to a brief alignment check, and a single verification round is sufficient. The executing agent determines lightweight eligibility based on these criteria; if uncertain, default to full lifecycle.

## Execution Protocol (메인 ↔ 위임)

복합 작업 전용(다단계·다파일·설계 판단). 단순 작업은 직접 처리.
`pal mcp clink`와 `vibe-check` 반드시 사용하고, "확신"을 이유로 생략 금지.

### 역할
메인 = 계획·위임·추적·승인만 담당. 구현·탐색·리뷰·조사·합성은 전부 위임.

### 위임
- `subagent`: 결과만 필요할 때. 병렬 가능하면 동시 호출, 독립 작업은 `run_in_background: true`
- `team`: teammate 간 토론·검증·합의가 필요할 때
- 항상 명시: 대상 경로, 질문, 산출물, 종료 조건
- 같은 파일 동시 편집 금지
- 여러 결과의 합성도 subagent에 위임. 메인은 승인/기각/수정만

### 작업 기억
메인 스레드에는 결정·리스크·상태만 남긴다.
긴 출력은 `temp/`에 저장하고 보고는 2문장 + 경로만.
`temp/`를 working memory로 적극 활용.
subagent 완료 전 선행 진행 금지.

### 필수 사용: vibe-check
아래 중 하나라도 해당하면 반드시 `vibe-check` 호출 후 계속 자율적으로 진행:
1. 비가역적 행동 직전 (삭제, force push, 배포, 스키마 변경)
2. 추정·가정 기반 결정 직전 또는 설계 대안 선택 직전
3. 3단계 이상 복합 계획 실행 직전

### 필수 사용: pal mcp clink
자기 판단 → `clink` 호출 → 차이 비교 → 합성.
호출 형식은 **`cli_name + default role + prompt + files`** 기준.

다음 시점에는 반드시 호출:
- 설계/방향 확정 직전: 가정·트레이드오프·실패 모드·더 단순한 대안 검토
- 코드·문서 10줄+ 변경 직후: 정확성·회귀·보안·테스트 누락·과설계 점검
- 동일 문제 해결 실패 시: 원인 추정·재현 경로·최소 수정안·다음 실험 1~3개 또는 직접 해결 요구

운영 원칙:
- 긴 맥락은 `temp/` 파일 경로로 전달
- 리뷰/비판 목적이면 프롬프트에 반드시 `read/analyze only, do not modify files` 포함
- 민감 정보(API 키, `.env`, 자격증명, PII) 전달 금지

### 2-Round Independent Verification
최종안 전 2라운드 독립 검증 (독립 보고 → 교차 참조).
각 phase는 **초안 → 독립 검증 1 → 수정 → 독립 검증 2 → 수정** 순서로 완료한 뒤 다음 phase로 넘어간다.

| Round | Performer | Scope |
|-------|-----------|-------|
| Round 1 | `verifier-1` (spawned) | Multi-perspective verification. Includes vibe-check + PAL clink. |
| Round 2 | `verifier-2` (spawned) | **Different perspective** from Round 1. Includes vibe-check + PAL clink. |

Results -> `temp/{plan-name}-verification-round{n}.md`.

## temp/ as Working Memory

`temp/` serves as action plan execution **working memory**:
- Phase 0 alignment docs, gap lists, impact assessments, doc-change drafts
- Shared analysis between teammates
- vibe-check / PAL clink results
- Verification round results
- Intermediate artifacts, drafts, comparative analyses

> `temp/` files may be cleaned after plan completion; move to `_ref/` if worth preserving.

## Lifecycle Summary (단축형)

1. Create new plan -> add file to root with frontmatter
2. Phase 0 -> alignment doc + drafts in `temp/`
3. Phase 1-N -> `status: active`, execute, update `[v]/[/]/[ ]`
4. Phase F-1 -> apply drafts to live docs, run validator
5. Phase F -> `status: done`, move to `_done/`, commit, push (if authorized)
6. Archive as reference (optional) -> move to `_ref/`
