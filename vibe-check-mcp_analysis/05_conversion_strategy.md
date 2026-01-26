# MCP → Agent Skills 변환 전략

## 1. MCP와 Agent Skills 비교

### 1.1 통신 방식

| 항목 | MCP Server | Agent Skills |
|------|-----------|--------------|
| **프로토콜** | JSON-RPC over stdio/HTTP | 직접 함수 호출 |
| **전송** | StreamableHTTPServer, StdioServerTransport | 불필요 |
| **메시지 형식** | MCP 프로토콜 메시지 | 일반 함수 인자 |
| **응답** | Content 객체 배열 | 직접 반환값 |

### 1.2 도구 등록

**MCP 방식**:
```typescript
server.setRequestHandler(ListToolsRequestSchema, async () => ({
  tools: [
    {
      name: 'vibe_check',
      description: '...',
      inputSchema: { /* JSON Schema */ }
    }
  ]
}));

server.setRequestHandler(CallToolRequestSchema, async (request) => {
  switch (request.params.name) {
    case 'vibe_check':
      return vibeCheckTool(request.params.arguments);
  }
});
```

**Agent Skills 방식**:
```typescript
// skills/vibeCheck.ts
export async function vibeCheck(params: VibeCheckInput): Promise<VibeCheckOutput> {
  // 직접 구현
}

// skills/manifest.json
{
  "skills": [
    {
      "name": "vibeCheck",
      "function": "vibeCheck",
      "parameters": { /* ... */ }
    }
  ]
}
```

---

## 2. 변환 대상 컴포넌트

### 2.1 직접 재사용 가능 (변경 최소)

| 컴포넌트 | 파일 | 이유 |
|---------|------|------|
| vibeCheck 로직 | tools/vibeCheck.ts | 순수 비즈니스 로직 |
| vibeLearn 로직 | tools/vibeLearn.ts | 순수 비즈니스 로직 |
| constitution 로직 | tools/constitution.ts | 순수 비즈니스 로직 |
| LLM 호출 | utils/llm.ts | 프로바이더 독립적 |

### 2.2 수정 필요

| 컴포넌트 | 원본 | 변경 사항 |
|---------|------|----------|
| 서버 진입점 | index.ts | MCP 서버 → Skills 매니페스트 |
| 상태 관리 | utils/state.ts | 파일 기반 → 인메모리/DB |
| 저장소 | utils/storage.ts | 파일 기반 → 적합한 스토리지 |

### 2.3 제거 가능

| 컴포넌트 | 이유 |
|---------|------|
| cli/ 폴더 전체 | CLI 인터페이스 불필요 |
| httpTransportWrapper.ts | HTTP 전송 불필요 |
| jsonRpcCompat.ts | JSON-RPC 불필요 |

---

## 3. 변환 단계별 계획

### Phase 1: 프로젝트 구조 설정

```
vibe-check-skills/
├── src/
│   ├── skills/
│   │   ├── vibeCheck.ts
│   │   ├── vibeLearn.ts
│   │   └── constitution.ts
│   ├── core/
│   │   ├── llm.ts
│   │   ├── state.ts
│   │   └── storage.ts
│   ├── types/
│   │   └── index.ts
│   └── index.ts          # Skills 엔트리포인트
├── manifest.json          # Skills 매니페스트
├── package.json
└── tsconfig.json
```

### Phase 2: 타입 정의 통합

```typescript
// types/index.ts
export interface VibeCheckInput {
  goal: string;
  plan: string;
  modelOverride?: string;
  userPrompt?: string;
  progress?: string;
  uncertainty?: string;
  taskContext?: string;
  sessionId?: string;
}

export interface VibeCheckOutput {
  questions: string;
  riskScore?: number;
}

// ... 나머지 타입들
```

### Phase 3: Skills 함수 구현

```typescript
// skills/vibeCheck.ts
import { VibeCheckInput, VibeCheckOutput } from '../types';
import { getMetacognitiveQuestions, generateFallbackQuestions } from '../core/llm';
import { getHistorySummary, addToHistory } from '../core/state';

export async function vibeCheck(input: VibeCheckInput): Promise<VibeCheckOutput> {
  const { goal, plan, sessionId } = input;

  try {
    const historySummary = sessionId ? await getHistorySummary(sessionId) : null;
    const questions = await getMetacognitiveQuestions(input, historySummary);

    if (sessionId) {
      await addToHistory(sessionId, input, questions);
    }

    return { questions };
  } catch (error) {
    return { questions: generateFallbackQuestions(goal, plan) };
  }
}
```

### Phase 4: 매니페스트 작성

```json
{
  "name": "vibe-check-skills",
  "version": "1.0.0",
  "description": "Metacognitive AI agent oversight skills",
  "skills": [
    {
      "name": "vibeCheck",
      "description": "Challenge assumptions and prevent tunnel vision",
      "function": "vibeCheck",
      "parameters": {
        "goal": { "type": "string", "required": true },
        "plan": { "type": "string", "required": true },
        "modelOverride": { "type": "string" },
        "sessionId": { "type": "string" }
      }
    },
    {
      "name": "vibeLearn",
      "description": "Log mistakes and solutions for pattern recognition",
      "function": "vibeLearn",
      "parameters": {
        "mistake": { "type": "string", "required": true },
        "category": { "type": "string", "required": true },
        "solution": { "type": "string" }
      }
    },
    {
      "name": "updateConstitution",
      "description": "Add a session-level rule",
      "function": "updateConstitution",
      "parameters": {
        "sessionId": { "type": "string", "required": true },
        "rule": { "type": "string", "required": true }
      }
    },
    {
      "name": "resetConstitution",
      "description": "Replace all session rules",
      "function": "resetConstitution",
      "parameters": {
        "sessionId": { "type": "string", "required": true },
        "rules": { "type": "array", "items": { "type": "string" }, "required": true }
      }
    },
    {
      "name": "checkConstitution",
      "description": "Get current session rules",
      "function": "checkConstitution",
      "parameters": {
        "sessionId": { "type": "string", "required": true }
      }
    }
  ]
}
```

---

## 4. 주요 변환 포인트

### 4.1 상태 관리 전략

**옵션 A: 인메모리 (단순)**
```typescript
const sessions = new Map<string, SessionState>();
```
- 장점: 구현 간단, 빠름
- 단점: 서버 재시작 시 손실

**옵션 B: 파일 기반 (원본 방식)**
```typescript
// ~/.vibe-check/ 디렉토리 유지
```
- 장점: 지속성, 원본과 호환
- 단점: I/O 오버헤드

**옵션 C: 외부 저장소**
```typescript
// Redis, SQLite 등
```
- 장점: 확장성, 안정성
- 단점: 의존성 추가

### 4.2 LLM 통합 유지

```typescript
// 기존 로직 대부분 재사용 가능
export async function getMetacognitiveQuestions(
  input: VibeCheckInput,
  historySummary?: string
): Promise<string> {
  const provider = resolveProvider(input.modelOverride);
  const prompt = buildPrompt(input, historySummary);

  return await callLLM(provider, prompt);
}
```

### 4.3 에러 처리 표준화

```typescript
// Skills 환경에 맞는 에러 타입
export class VibeCheckError extends Error {
  constructor(
    message: string,
    public code: 'LLM_ERROR' | 'VALIDATION_ERROR' | 'STATE_ERROR',
    public recoverable: boolean = true
  ) {
    super(message);
  }
}
```

---

## 5. 테스트 전략

### 5.1 단위 테스트
- 각 Skill 함수의 입출력 검증
- LLM 모킹을 통한 로직 테스트
- 에러 케이스 처리

### 5.2 통합 테스트
- Skills 매니페스트 유효성
- 전체 워크플로우 테스트
- 세션 관리 테스트

---

## 6. 마이그레이션 체크리스트

- [ ] 프로젝트 구조 생성
- [ ] 타입 정의 마이그레이션
- [ ] vibeCheck 스킬 구현
- [ ] vibeLearn 스킬 구현
- [ ] constitution 스킬 구현
- [ ] LLM 통합 모듈 마이그레이션
- [ ] 상태 관리 구현
- [ ] 매니페스트 작성
- [ ] 단위 테스트 작성
- [ ] 통합 테스트 작성
- [ ] 문서 작성
