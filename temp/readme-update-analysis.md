# Action Plans README Update Analysis

## Current State

7개 repo에 action-plans/README.md가 존재. 2가지 변형:

### Korean (5 repos)
- vibe-check, claude-memory, claude-code-guardian, deepscan, prd-creator
- "3. 작업 완료 → status: done (선택: _done/으로 이동)"

### English (2 repos)
- ops: "3. Complete work -> `status: done` (optionally move to `_done/`)"
- daemon: "3. Complete work -- set `status: done` (optional: move to `_done/`)"

## Required Changes

### 1. Action Plan 파일 구조 규칙 추가 (새 섹션)
- 순서화된 작업 단계 필수 (phase1, phase2... 또는 step1, step2...)
- 진행 체크마크 필수: `[v]` 완료, `[ ]` 미시작, `[/]` 진행중

### 2. Lifecycle 3번 수정
- `_done/` 이동: 선택 → **필수**
- Korean: "작업 완료 → status: done, **반드시** _done/으로 이동"
- English: "Complete work -> `status: done`, **must** move to `_done/`"

### 3. Status Values의 done 설명 수정
- Korean: "완료 → _done/으로 이동 가능" → "완료 → 반드시 _done/으로 이동"
- English: "(optionally move to `_done/`)" → "(must move to `_done/`)"

## File Paths
1. /home/idnotbe/projects/ops/action-plans/README.md (EN)
2. /home/idnotbe/projects/claude-memory/action-plans/README.md (KR)
3. /home/idnotbe/projects/claude-code-guardian/action-plans/README.md (KR)
4. /home/idnotbe/projects/vibe-check/action-plans/README.md (KR)
5. /home/idnotbe/projects/deepscan/action-plans/README.md (KR)
6. /home/idnotbe/projects/prd-creator/action-plans/README.md (KR)
7. /home/idnotbe/projects/daemon/action-plans/README.md (EN)
