# Action Plans

실행 계획 관리 디렉토리.

## 구조
- root의 .md 파일 = 활성 계획 (not-started, active, blocked)
- `_done/` = 완료된 계획
- `_ref/` = 참고/역사적 문서

## Frontmatter 규칙
모든 plan 파일 상단에 YAML frontmatter 필수:

```yaml
---
status: not-started    # not-started | active | blocked | done
progress: "미시작"      # 현재 진행 상태 (자유 텍스트)
---
```

## Status Values
- **not-started**: 아직 시작 안 함
- **active**: 현재 진행 중
- **blocked**: 의존성 미해결로 대기
- **done**: 완료 → **반드시** _done/으로 이동

## Action Plan 파일 구조
Action plan 파일은 순서화된 작업 단계를 포함해야 한다 (phase1, phase2... 또는 step1, step2...).

각 단계에는 진행 체크마크 필수:
- `[v]` = 완료
- `[ ]` = 미시작
- `[/]` = 진행중

예시:
```markdown
## Phase 1: 초기 설정
- [v] 환경 구성
- [v] 의존성 설치

## Phase 2: 구현
- [/] 핵심 기능 개발
- [ ] 테스트 작성
```

모든 단계가 `[v]`로 표시되면 해당 plan은 완료 상태(done)이다.

## Lifecycle
1. 새 plan 생성 → root에 파일 + frontmatter
2. 작업 시작 → status: active, progress 업데이트
3. 작업 완료 → status: done, _done/으로 이동 (필수)
4. 참고 전환 → _ref/로 이동
