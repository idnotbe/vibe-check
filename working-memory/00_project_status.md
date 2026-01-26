# Vibe Check MCP → Agent Skills 변환 프로젝트

## 작업 상태 (Working Memory)

**최종 업데이트**: 2026-01-26

---

## 현재 진행 상황

### 완료된 작업 (Phase 1: 분석)
- [x] GitHub 리포지토리 분석 완료
- [x] 소스 코드 구조 파악
- [x] 핵심 기능 및 도구 분석
- [x] Working memory 파일 생성
- [x] 분석 결과 문서화 (6개 문서)
- [x] 자가비판 및 재검토 완료

### 생성된 분석 문서
1. `01_overview.md` - 프로젝트 개요
2. `02_architecture.md` - 아키텍처 분석
3. `03_tools_detail.md` - 도구 상세 분석
4. `04_llm_integration.md` - LLM 통합 분석
5. `05_conversion_strategy.md` - 변환 전략
6. `06_self_critique.md` - 자가비판 보고서

### 예정된 작업 (Phase 2: 구현)
- [ ] Agent Skills 프로젝트 구조 생성
- [ ] 타입 정의 마이그레이션
- [ ] Skills 함수 구현
- [ ] 매니페스트 작성
- [ ] 테스트 작성

---

## 핵심 인사이트

### MCP vs Agent Skills 차이점

| 관점 | MCP 서버 | Agent Skills |
|------|----------|--------------|
| 통신 | stdio/HTTP JSON-RPC | 함수 직접 호출 |
| 상태관리 | 파일 기반 (.vibe-check/) | 메모리/DB |
| 등록 | MCP SDK 사용 | Skills 매니페스트 |
| 트랜스포트 | StreamableHTTPServer | 불필요 |

### 변환 시 유지해야 할 핵심 기능
1. **vibe_check**: 메타인지 질문 생성 (LLM 기반)
2. **vibe_learn**: 실수/해결책 학습 (유사도 검사)
3. **constitution 관리**: 세션별 규칙 (FIFO, 50개 제한)
4. **멀티 LLM 프로바이더 지원** (Gemini, OpenAI, Anthropic, OpenRouter)
5. **세션 히스토리 관리** (최근 10개 유지)

### 재사용 가능한 컴포넌트
- `tools/vibeCheck.ts` - 핵심 로직 재사용
- `tools/vibeLearn.ts` - 핵심 로직 재사용
- `tools/constitution.ts` - 전체 재사용
- `utils/llm.ts` - 대부분 재사용

### 제거/수정 필요 컴포넌트
- `cli/` - 전체 제거
- `utils/httpTransportWrapper.ts` - 제거
- `utils/jsonRpcCompat.ts` - 제거
- `index.ts` - MCP 서버 로직 제거, Skills 엔트리로 교체

---

## 의문점 및 결정 필요 사항

### 해결된 사항
- [x] 프로젝트 구조 → `05_conversion_strategy.md`에 정의됨
- [x] 도구 인터페이스 → `03_tools_detail.md`에 정의됨

### 미해결 사항 (구현 시 결정)
1. **상태 저장 방식**: 인메모리 권장 (단순성)
2. **LLM 프로바이더**: 기존 방식 유지
3. **세션 관리**: sessionId 파라미터 유지

---

## 자가비판 요약

### 분석 신뢰도
| 영역 | 신뢰도 |
|-----|-------|
| 전체 아키텍처 | 높음 |
| 도구 인터페이스 | 높음 |
| 내부 로직 | 중간 |
| 에러 처리 | 낮음 |

### 권장 다음 단계
1. MCP SDK 공식 문서 참조
2. 테스트 코드 상세 분석
3. Skills 플랫폼 문서 확인
4. 프로토타입 구현 및 검증

---

## 참고 링크
- 원본 저장소: https://github.com/PV-Bhat/vibe-check-mcp-server
- npm 패키지: @pv-bhat/vibe-check-mcp
- 버전: v2.7.6
- 라이센스: MIT
