# Vibe Check MCP Server - 도구 상세 분석

## 1. vibe_check 도구

### 1.1 인터페이스

```typescript
interface VibeCheckInput {
  goal: string;           // 사용자 목표
  plan: string;           // 현재 계획
  modelOverride?: string; // 모델 오버라이드 (예: "openai:gpt-4")
  userPrompt?: string;    // 추가 사용자 프롬프트
  progress?: string;      // 진행 상황
  uncertainty?: string;   // 불확실한 부분
  taskContext?: string;   // 작업 컨텍스트
  sessionId?: string;     // 세션 식별자
}

interface VibeCheckOutput {
  questions: string;      // 메타인지 질문들
}
```

### 1.2 실행 로직

```
vibeCheckTool(input: VibeCheckInput)
│
├── 1. 세션 히스토리 요약 추출 (getHistorySummary)
│       └── 최근 5개 상호작용의 요약
│
├── 2. 메타인지 질문 생성 (getMetacognitiveQuestions)
│       ├── LLM 호출 (llm.ts)
│       ├── Constitution 규칙 주입
│       └── 학습 이력 컨텍스트 주입
│
├── 3. 결과를 히스토리에 기록 (addToHistory)
│
└── 4. 질문 문자열 반환
```

### 1.3 폴백 메커니즘

LLM 호출 실패 시 기본 질문 제공:
```typescript
function generateFallbackQuestions(goal: string, plan: string): string {
  return `
1. 사용자 요청과 현재 계획이 일치합니까?
2. 더 간단한 방법이 있습니까?
3. 어떤 가정을 하고 있습니까?
4. 이 계획에서 무엇이 잘못될 수 있습니까?
  `;
}
```

---

## 2. vibe_learn 도구

### 2.1 인터페이스

```typescript
interface VibeLearnInput {
  mistake: string;     // 필수: 실수 설명
  category: string;    // 필수: 분류 카테고리
  solution?: string;   // 선택: 해결책
  type?: 'mistake' | 'preference';  // 선택: 유형
  sessionId?: string;  // 선택: 세션 ID
}

interface VibeLearnOutput {
  added: boolean;           // 새 항목 추가 여부
  currentTally: number;     // 해당 카테고리 누적 개수
  alreadyKnown: boolean;    // 중복 여부
  topCategories: Array<{    // 상위 3개 카테고리
    category: string;
    count: number;
  }>;
}
```

### 2.2 실행 로직

```
vibeLearnTool(input: VibeLearnInput)
│
├── 1. 입력 검증
│       ├── mistake 필수 확인
│       └── category 필수 확인
│
├── 2. 문장 정규화 (enforceOneSentence)
│       ├── 개행 제거
│       ├── 첫 문장만 추출
│       └── 마침표 추가
│
├── 3. 카테고리 표준화 (normalizeCategory)
│       └── 5개 표준 카테고리로 매핑
│
├── 4. 유사성 검사 (isSimilar)
│       └── 60% 이상 단어 일치 시 중복 판정
│
├── 5. 저장 (addLearningEntry)
│       └── 신규 항목만 저장
│
└── 6. 통계 반환
```

### 2.3 표준 카테고리 (5개)

| 카테고리 | 설명 |
|---------|------|
| Complex Solution Bias | 복잡한 해결책 선호 |
| Feature Creep | 기능 범위 확대 |
| Premature Implementation | 조급한 구현 |
| Assumption Error | 가정 오류 |
| Communication Gap | 소통 문제 |

### 2.4 유사도 검사

```typescript
function isSimilar(a: string, b: string, threshold = 0.6): boolean {
  const wordsA = new Set(a.toLowerCase().split(/\s+/));
  const wordsB = new Set(b.toLowerCase().split(/\s+/));

  let overlap = 0;
  for (const word of wordsA) {
    if (wordsB.has(word)) overlap++;
  }

  const similarity = overlap / Math.max(wordsA.size, wordsB.size);
  return similarity >= threshold;
}
```

---

## 3. Constitution 도구들

### 3.1 데이터 구조

```typescript
interface ConstitutionEntry {
  rules: string[];        // 규칙 배열
  updatedAt: number;      // 마지막 업데이트 시간
}

// 메모리 저장소
const constitutions = new Map<string, ConstitutionEntry>();
```

### 3.2 update_constitution

```typescript
function updateConstitution(sessionId: string, rule: string): void {
  // 기존 규칙 가져오기 또는 새로 생성
  const entry = constitutions.get(sessionId) ?? { rules: [], updatedAt: 0 };

  // 규칙 추가
  entry.rules.push(rule);

  // 최대 50개 유지 (FIFO)
  if (entry.rules.length > 50) {
    entry.rules.shift();
  }

  entry.updatedAt = Date.now();
  constitutions.set(sessionId, entry);
}
```

### 3.3 reset_constitution

```typescript
function resetConstitution(sessionId: string, rules: string[]): void {
  // 50개로 제한하여 완전 교체
  constitutions.set(sessionId, {
    rules: rules.slice(0, 50),
    updatedAt: Date.now()
  });
}
```

### 3.4 check_constitution

```typescript
function getConstitution(sessionId: string): string[] {
  const entry = constitutions.get(sessionId);

  if (entry) {
    // TTL 리셋
    entry.updatedAt = Date.now();
    return entry.rules;
  }

  return [];
}
```

### 3.5 자동 정리 메커니즘

```typescript
const SESSION_TTL_MS = 60 * 60 * 1000; // 1시간

function cleanup(): void {
  const now = Date.now();
  for (const [sessionId, entry] of constitutions) {
    if (now - entry.updatedAt > SESSION_TTL_MS) {
      constitutions.delete(sessionId);
    }
  }
}

// 백그라운드 정리 (메모리 누수 방지)
setInterval(cleanup, SESSION_TTL_MS).unref();
```

---

## 4. 도구 파라미터 스키마 (MCP 형식)

### vibe_check

```json
{
  "name": "vibe_check",
  "description": "Metacognitive questions to challenge assumptions and prevent tunnel vision",
  "inputSchema": {
    "type": "object",
    "properties": {
      "goal": { "type": "string", "description": "User's stated goal" },
      "plan": { "type": "string", "description": "Current plan or approach" },
      "modelOverride": { "type": "string", "description": "Optional: provider:model" },
      "userPrompt": { "type": "string" },
      "progress": { "type": "string" },
      "uncertainty": { "type": "string" },
      "taskContext": { "type": "string" },
      "sessionId": { "type": "string" }
    },
    "required": ["goal", "plan"]
  }
}
```

### vibe_learn

```json
{
  "name": "vibe_learn",
  "description": "Log mistakes and solutions for pattern recognition",
  "inputSchema": {
    "type": "object",
    "properties": {
      "mistake": { "type": "string", "description": "One-sentence mistake description" },
      "category": { "type": "string", "description": "Error category" },
      "solution": { "type": "string", "description": "Optional: how it was resolved" },
      "type": { "type": "string", "enum": ["mistake", "preference"] },
      "sessionId": { "type": "string" }
    },
    "required": ["mistake", "category"]
  }
}
```

### update_constitution

```json
{
  "name": "update_constitution",
  "description": "Add a session-level rule",
  "inputSchema": {
    "type": "object",
    "properties": {
      "sessionId": { "type": "string" },
      "rule": { "type": "string" }
    },
    "required": ["sessionId", "rule"]
  }
}
```

### reset_constitution

```json
{
  "name": "reset_constitution",
  "description": "Replace all session rules",
  "inputSchema": {
    "type": "object",
    "properties": {
      "sessionId": { "type": "string" },
      "rules": { "type": "array", "items": { "type": "string" } }
    },
    "required": ["sessionId", "rules"]
  }
}
```

### check_constitution

```json
{
  "name": "check_constitution",
  "description": "Get current session rules",
  "inputSchema": {
    "type": "object",
    "properties": {
      "sessionId": { "type": "string" }
    },
    "required": ["sessionId"]
  }
}
```
