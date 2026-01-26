# Working Memory - Vibe Check Skills Development

> 이 파일은 작업 중 발견한 사항, 결정사항, 주의점 등을 기록하는 working memory입니다.

---

## Session Log

### 2026-01-26 - Initial Analysis

#### 발견 사항

**원본 MCP 서버 구조:**
- TypeScript 기반
- src/index.ts - 메인 진입점
- src/utils/llm.ts - LLM 제공자 통합
- src/utils/state.ts - 세션 상태 관리
- src/utils/storage.ts - 학습 데이터 영속적 저장

**주요 기능 (5가지 도구):**
1. `vibe_check` - 에이전트 가정에 도전하는 메타인지 피드백
2. `vibe_learn` - 미래 반영을 위한 실수/해결책 기록
3. `update_constitution` - 세션별 행동 규칙 설정
4. `reset_constitution` - 세션 규칙 초기화
5. `check_constitution` - 활성 규칙 검사

**특징:**
- CPI (Chain-Pattern Interrupts) - 연구 기반 "일시 정지" 메커니즘
- 다중 LLM 제공자 지원 (Gemini, OpenAI, Anthropic, OpenRouter)
- 세션 히스토리 연속성

---

## Critical Decisions

### Decision 1: Fork 여부
- **결정**: Fork 하지 않음
- **이유**: 완전히 다른 기술 스택, 기능 재구현 필요
- **대안**: 원본 코드 참조하여 개념/로직 추출

### Decision 2: Skills 구조
- **결정**: 멀티 skill 구조 (도구별 분리)
- **이유**: 각 기능의 독립성 유지, 관리 용이
- **구조**:
  - `/vibe-check` - 메인 피드백 skill
  - `/vibe-learn` - 학습 기록 skill
  - `/vibe-constitution` - 규칙 관리 통합 skill

---

## Questions to Resolve (ANSWERED)

- [x] 원본 LLM 프롬프트 패턴은 어떻게 되어 있는가?
  - **답변**: "meta-mentor" 역할, 4가지 차원으로 평가 (상황분석, 진단, 응답유형, 경로수정)
  - Fallback 질문: 실제 요청 부합 여부, 단순 대안, 가정 점검, 의도 정렬

- [x] CPI의 구체적인 구현 방식은?
  - **답변**: Chain-Pattern Interrupts = 위험 순간에 멈추고 재정렬하는 "일시정지점"
  - 메타인지 질문을 통해 에이전트의 터널 비전 방지

- [x] 세션 상태는 어떻게 관리하는가?
  - **답변**: `~/.vibe-check/history.json`에 저장
  - sessionId별 Map<string, Interaction[]>
  - 세션당 최대 10개 상호작용 유지 (rolling buffer)

- [x] constitution 규칙의 형식은?
  - **답변**: 세션당 최대 50개 규칙 (문자열 배열)
  - 메모리 내 저장, 1시간 비활성시 자동 삭제
  - updateConstitution: 규칙 추가, resetConstitution: 전체 교체

---

## Detailed Source Analysis (2026-01-26)

### vibe_check 도구 상세

**입력 파라미터:**
- `goal` (필수): 현재 목표
- `plan` (필수): 상세 전략
- `modelOverride`: LLM 모델 지정
- `userPrompt`: 사용자 프롬프트
- `progress`: 진행 상황
- `uncertainties`: 불확실성 목록
- `taskContext`: 작업 맥락
- `sessionId`: 세션 ID

**핵심 로직:**
1. 세션 히스토리 조회 (getHistorySummary)
2. LLM에 메타인지 질문 요청
3. 결과를 세션에 저장
4. 질문 반환

**Fallback 질문 (API 실패시):**
1. 계획이 사용자의 실제 요청을 해결하는가?
2. 더 단순한 대안이 있는가?
3. 어떤 가정이 사고를 제한하는가?
4. 접근법이 원래 의도와 얼마나 일치하는가?

### vibe_learn 도구 상세

**입력 파라미터:**
- `mistake` (필수): 한 문장 설명
- `category` (필수): 카테고리 enum
- `solution`: 해결책 (선택)
- `type`: 'mistake' | 'preference' | 'success'
- `sessionId`: 세션 ID

**카테고리 목록:**
- Complex Solution Bias (복잡한 솔루션 편향)
- Feature Creep (기능 확장)
- Premature Implementation (조기 구현)
- Misalignment (불일치)
- Overtooling (과도한 도구 사용)

**핵심 로직:**
1. 한 문장 강제 (enforceOneSentence)
2. 중복 감지 (0.6 이상 유사도 = 중복)
3. 카테고리 정규화
4. 항목 추가 및 통계 반환

### constitution 도구 상세

**함수들:**
- `updateConstitution(sessionId, rule)`: 규칙 추가
- `resetConstitution(sessionId, rules[])`: 전체 교체
- `getConstitution(sessionId)`: 규칙 조회

**제한사항:**
- 세션당 최대 50개 규칙
- 1시간 비활성시 자동 삭제

---

## Self-Critique & Improvements

### Round 1: Initial Plan Review

**장점:**
- MCP vs Skills 차이 명확히 이해
- 구조적 접근 계획 수립

**개선 필요:**
- 원본 소스코드 상세 분석 필요
- 각 도구의 실제 프롬프트/로직 파악 필요

**Action Items:**
1. ~~원본 레포 src/ 코드 상세 분석~~ ✅
2. ~~LLM 프롬프트 패턴 추출~~ ✅
3. ~~상태 관리 로직 파악~~ ✅

### Round 2: Architecture Design Review (2026-01-26)

**장점:**
- 명확한 3개 skill 분리 구조
- 파일 기반 상태 관리 방법 정의
- 원본 기능 모두 매핑됨

**잠재적 문제:**
1. **Shell 스크립트 의존성**: 플랫폼 호환성 문제 가능
2. **JSON 파일 관리**: 수동 파싱/업데이트 복잡할 수 있음
3. **세션 ID 관리**: `${CLAUDE_SESSION_ID}` 실제 작동 확인 필요

**대안 고려:**
- 스크립트 대신 Claude의 Read/Write 도구 직접 활용
- 복잡한 JSON 대신 단순 텍스트 형식 고려

**결정:**
- 일단 설계대로 진행하되, 구현 중 문제 발견시 조정
- Shell 스크립트는 최소화하고 Claude 도구 활용 권장

### Round 3: Pre-Implementation Checklist

**필수 확인:**
- [ ] SKILL.md 형식이 올바른가?
- [ ] $ARGUMENTS 치환이 정확한가?
- [ ] 데이터 디렉토리 초기화 방법은?
- [ ] README 업데이트 필요

**품질 기준:**
- 원본 5가지 도구 기능 모두 구현
- 사용자가 쉽게 설치/사용 가능
- 문서화 완전

---

## Notes & Observations

### Skills의 한계점
- Skills는 외부 API 직접 호출 불가
- Claude가 직접 메타인지 역할 수행해야 함
- 이는 오히려 장점이 될 수 있음 (Claude의 추론 능력 활용)

### 핵심 인사이트
> "Skills는 Claude에게 **어떻게** 생각하고 행동할지 가르치는 것"
> MCP 서버가 외부에서 피드백을 제공했다면, Skills는 Claude 스스로 그 역할을 수행하도록 지침 제공

---

## File References

작업 중 참조해야 할 파일:
- `/home/user/vibe-checking/WORK_PLAN.md` - 전체 작업 계획
- 원본 레포: https://github.com/PV-Bhat/vibe-check-mcp-server

---

## Checklist Before Commit

- [x] 모든 SKILL.md 파일 생성 완료
- [x] 데이터 파일 초기화 (learnings.json, constitution.json)
- [x] README.md 업데이트
- [x] 자가 검토 완료
- [x] history.json 제거 (Claude 컨텍스트가 히스토리 역할)
- [x] vibe-check에 constitution 통합 추가

### Self-Review Results (2026-01-26)

**검토 항목:**
1. 프로젝트 구조 ✅ 완전
2. SKILL.md 파일 형식 ✅ 유효한 YAML frontmatter
3. JSON 데이터 파일 ✅ 유효한 JSON
4. 문서화 ✅ 완전

**Critical Review 피드백 처리:**
1. `disable-model-invocation: true` - 정상 (자동 호출 방지, AI 추론 허용)
2. `!`command`` 구문 - Claude Code Skills 유효 구문
3. constitution 통합 - vibe-check에 추가됨 ✅
4. history.json - 불필요하므로 제거됨 ✅

**최종 상태: 커밋 준비 완료**
