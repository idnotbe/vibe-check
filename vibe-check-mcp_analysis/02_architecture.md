# Vibe Check MCP Server - 아키텍처 분석

## 1. 디렉토리 구조

```
vibe-check-mcp-server/
├── src/
│   ├── index.ts              # 메인 진입점 (18,596 bytes)
│   ├── cli/
│   │   ├── index.ts          # CLI 메인 (19,679 bytes)
│   │   ├── env.ts            # 환경변수 처리 (8,573 bytes)
│   │   ├── doctor.ts         # 진단 도구 (1,664 bytes)
│   │   ├── diff.ts           # 차이점 비교 (320 bytes)
│   │   └── clients/          # 클라이언트별 설정
│   ├── tools/
│   │   ├── vibeCheck.ts      # vibe_check 구현 (2,313 bytes)
│   │   ├── vibeLearn.ts      # vibe_learn 구현 (4,543 bytes)
│   │   ├── constitution.ts   # constitution 관리 (1,409 bytes)
│   │   └── vibeDistil.ts     # (미사용, 10 bytes)
│   └── utils/
│       ├── llm.ts            # LLM 통합 (10,989 bytes)
│       ├── storage.ts        # 파일 저장소 (4,871 bytes)
│       ├── state.ts          # 상태 관리 (1,668 bytes)
│       ├── jsonRpcCompat.ts  # JSON-RPC 호환 (2,598 bytes)
│       ├── anthropic.ts      # Anthropic 유틸 (1,279 bytes)
│       ├── httpTransportWrapper.ts  # HTTP 래퍼 (1,035 bytes)
│       └── version.ts        # 버전 정보 (479 bytes)
├── docs/                     # 문서
├── examples/                 # 사용 예제
├── tests/                    # 테스트
└── scripts/                  # Docker 등 스크립트
```

---

## 2. 핵심 컴포넌트

### 2.1 index.ts - 서버 진입점

```
┌─────────────────────────────────────────────────────────────┐
│                      index.ts                                │
├─────────────────────────────────────────────────────────────┤
│  createMcpServer()                                          │
│    ├── MCP 서버 생성 ("Vibe Check")                         │
│    ├── 히스토리 로드                                         │
│    └── 요청 핸들러 등록                                      │
│         ├── tools/list - 도구 목록 조회                      │
│         └── tools/call - 도구 실행                           │
├─────────────────────────────────────────────────────────────┤
│  startHttpServer()                                           │
│    ├── Express 앱 생성                                       │
│    ├── POST /mcp - MCP 요청 처리                            │
│    └── GET /healthz - 헬스 체크                              │
├─────────────────────────────────────────────────────────────┤
│  main()                                                      │
│    ├── 전송 방식 결정 (stdio/http)                           │
│    └── 서버 시작                                             │
└─────────────────────────────────────────────────────────────┘
```

### 2.2 도구 등록 (5개)

| 도구 | 구현 파일 | 설명 |
|------|----------|------|
| `vibe_check` | vibeCheck.ts | 메타인지 질문 생성 |
| `vibe_learn` | vibeLearn.ts | 실수/패턴 학습 |
| `update_constitution` | constitution.ts | 규칙 추가 |
| `reset_constitution` | constitution.ts | 규칙 교체 |
| `check_constitution` | constitution.ts | 규칙 조회 |

---

## 3. 데이터 흐름

### 3.1 vibe_check 호출 흐름

```
클라이언트 요청
      │
      ▼
┌─────────────────┐
│   index.ts      │ ← tools/call 핸들러
│   (MCP Server)  │
└────────┬────────┘
         │
         ▼
┌─────────────────┐
│  vibeCheck.ts   │
│  vibeCheckTool()│
└────────┬────────┘
         │
    ┌────┴────┐
    │         │
    ▼         ▼
┌───────┐  ┌───────────┐
│state.ts│  │  llm.ts   │
│히스토리│  │LLM 호출   │
└───────┘  └─────┬─────┘
                 │
    ┌────────────┼────────────┐
    │            │            │
    ▼            ▼            ▼
┌────────┐  ┌────────┐  ┌──────────┐
│ Gemini │  │ OpenAI │  │ Anthropic│
└────────┘  └────────┘  └──────────┘
```

### 3.2 vibe_learn 호출 흐름

```
클라이언트 요청 (mistake, category, solution)
      │
      ▼
┌─────────────────┐
│  vibeLearn.ts   │
│  vibeLearnTool()│
└────────┬────────┘
         │
    ┌────┴────────────┐
    │                 │
    ▼                 ▼
┌───────────┐    ┌───────────┐
│ 입력 검증  │    │ 유사도    │
│ 정규화     │    │ 검사      │
└─────┬─────┘    └─────┬─────┘
      │                │
      └────────┬───────┘
               │
               ▼
        ┌─────────────┐
        │ storage.ts  │
        │ 파일 저장   │
        └─────────────┘
```

---

## 4. 상태 관리

### 4.1 저장 위치
```
~/.vibe-check/
├── history.json   # 대화 히스토리
└── log.json       # 학습 기록
```

### 4.2 데이터 구조

**history.json (state.ts)**
```typescript
interface Interaction {
  input: VibeCheckInput;
  output: string;
  timestamp: number;
}
// 세션별 최대 10개 유지
Map<sessionId, Interaction[]>
```

**log.json (storage.ts)**
```typescript
interface LearningEntry {
  type: 'mistake' | 'preference';
  category: string;
  mistake: string;
  solution?: string;
  timestamp: number;
}
```

### 4.3 Constitution 메모리 관리
- 인메모리 Map 사용
- 세션별 최대 50개 규칙
- 1시간 TTL (자동 정리)

---

## 5. LLM 통합 (llm.ts)

### 5.1 프로바이더 우선순위
1. 명시적 지정 (modelOverride)
2. 환경변수 (DEFAULT_LLM_PROVIDER)
3. 기본값: Gemini

### 5.2 프롬프트 구조
```
System Prompt (meta-mentor 역할)
│
├── 학습 이력 컨텍스트 (있을 경우)
├── Constitution 규칙 (있을 경우)
└── 사용자 요청 + 현재 계획
```

### 5.3 에러 처리
- 401/403: 인증 실패
- 429: 레이트 제한
- 기타: 폴백 질문 생성
