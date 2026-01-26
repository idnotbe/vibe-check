# Vibe Check MCP Server - 프로젝트 개요

## 1. 프로젝트 정보

| 항목 | 내용 |
|------|------|
| **이름** | @pv-bhat/vibe-check-mcp |
| **버전** | v2.7.6 |
| **작성자** | PV Bhat (MURST Initiative) |
| **라이센스** | MIT |
| **GitHub** | https://github.com/PV-Bhat/vibe-check-mcp-server |

---

## 2. 프로젝트 목적

### 핵심 문제 해결
AI 에이전트의 두 가지 주요 문제를 해결:
1. **Reasoning Lock-In (RLI)**: LLM이 잘못된 계획을 확신 있게 추구하는 경향
2. **Pattern Inertia**: 외부 교정 없이 패턴을 반복하는 경향

### 솔루션: Chain-Pattern Interrupt (CPI)
연구 기반의 개입 메커니즘으로, 위험 지점에서 에이전트를 일시 중지시켜 재정렬

**연구 결과 (153 평가 런 기준)**:
- 성공률 **~27% 향상**
- 해로운 행동 **~41% 감소**
- 최적 인터럽트 빈도: 작업 단계의 10-20%

---

## 3. 핵심 기능 요약

### 3.1 vibe_check
- **목적**: 가정에 도전하고 터널 비전 방지
- **입력**: 목표, 계획, 진행 상황, 불확실성 등
- **출력**: 메타인지적 성찰 질문
- **위험도 점수** 포함

### 3.2 vibe_learn
- **목적**: 실수와 성공 패턴 기록
- **입력**: mistake, category, solution (선택)
- **출력**: 카테고리 통계, 중복 여부
- **유사도 검사**: 60% 이상 단어 일치 시 중복 판정

### 3.3 Constitution 시스템
- `update_constitution`: 세션별 규칙 추가
- `reset_constitution`: 규칙 전체 교체
- `check_constitution`: 현재 규칙 조회
- **최대 50개 규칙**, 1시간 TTL

---

## 4. 기술 스택

### 언어 및 런타임
- **TypeScript** (72.8%)
- **JavaScript** (23.5%)
- **Node.js** ≥20.0.0

### 핵심 의존성
```json
{
  "@modelcontextprotocol/sdk": "^1.16.0",
  "@google/generative-ai": "^0.17.1",
  "openai": "^4.68.1",
  "express": "^4.19.2",
  "commander": "^12.1.0"
}
```

### LLM 프로바이더 지원
1. **Google Gemini** (기본값)
2. **OpenAI**
3. **Anthropic**
4. **OpenRouter**

---

## 5. 배포 옵션

### STDIO 전송
```bash
npx -y @pv-bhat/vibe-check-mcp start --stdio
```
- MCP 클라이언트 직접 통합 (Claude Desktop, Cursor, Windsurf)

### HTTP 전송
```bash
npx -y @pv-bhat/vibe-check-mcp start --http --port 2091
```
- JSON-RPC를 통한 수동 요청
- Health check: `GET /healthz`
- RPC 엔드포인트: `POST /mcp`

---

## 6. 인식 및 커뮤니티
- PulseMCP "Most Popular" (October 2025)
- Anthropic MCP 공식 저장소 등재
- Smithery.ai 5,000+ 월간 호출
- MSEEP 보안 등급 4.3★/5
- GitHub 457+ stars
