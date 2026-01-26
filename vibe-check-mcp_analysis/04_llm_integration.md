# Vibe Check MCP Server - LLM 통합 분석

## 1. 지원 프로바이더

| 프로바이더 | 초기화 방식 | 기본 모델 | API 키 환경변수 |
|-----------|------------|----------|----------------|
| **Gemini** | 동적 import | gemini-2.5-pro | `GEMINI_API_KEY` |
| **OpenAI** | 동적 import | o4-mini | `OPENAI_API_KEY` |
| **Anthropic** | fetch 기반 | claude-3-5-sonnet | `ANTHROPIC_API_KEY` |
| **OpenRouter** | REST API | 커스텀 지정 | `OPENROUTER_API_KEY` |

---

## 2. 프로바이더 선택 로직

### 2.1 우선순위
```
1. modelOverride 파라미터 (런타임 지정)
   └── 형식: "provider:model" (예: "openai:gpt-4o")

2. 환경변수 설정
   ├── DEFAULT_LLM_PROVIDER
   └── DEFAULT_MODEL

3. 기본값
   └── Gemini (gemini-2.5-pro)
```

### 2.2 파싱 로직

```typescript
function parseModelOverride(override: string): { provider: string; model: string } {
  // "openai:gpt-4o" → { provider: "openai", model: "gpt-4o" }
  const [provider, ...rest] = override.split(':');
  const model = rest.join(':'); // 모델명에 콜론이 포함될 수 있음

  return { provider: provider.toLowerCase(), model };
}
```

---

## 3. 프로바이더별 구현

### 3.1 Gemini

```typescript
async function callGemini(prompt: string, model: string): Promise<string> {
  // 동적 import로 필요할 때만 로드
  const { GoogleGenerativeAI } = await import('@google/generative-ai');

  const client = new GoogleGenerativeAI(process.env.GEMINI_API_KEY!);
  const genModel = client.getGenerativeModel({ model });

  try {
    const result = await genModel.generateContent(prompt);
    return result.response.text();
  } catch (error) {
    // 폴백: gemini-2.5-flash로 재시도
    const fallbackModel = client.getGenerativeModel({ model: 'gemini-2.5-flash' });
    const result = await fallbackModel.generateContent(prompt);
    return result.response.text();
  }
}
```

### 3.2 OpenAI

```typescript
async function callOpenAI(prompt: string, model: string): Promise<string> {
  const OpenAI = (await import('openai')).default;
  const client = new OpenAI({ apiKey: process.env.OPENAI_API_KEY });

  const completion = await client.chat.completions.create({
    model: model,
    messages: [
      { role: 'system', content: SYSTEM_PROMPT },
      { role: 'user', content: prompt }
    ]
  });

  return completion.choices[0]?.message?.content ?? '';
}
```

### 3.3 Anthropic

```typescript
async function callAnthropic(prompt: string, model: string): Promise<string> {
  // fetch 기반 직접 호출
  const response = await fetch('https://api.anthropic.com/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'x-api-key': process.env.ANTHROPIC_API_KEY!,
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: model,
      max_tokens: 1024,
      system: SYSTEM_PROMPT,
      messages: [{ role: 'user', content: prompt }]
    })
  });

  const data = await response.json();
  return data.content[0]?.text ?? '';
}
```

### 3.4 OpenRouter

```typescript
async function callOpenRouter(prompt: string, model: string): Promise<string> {
  const response = await fetch('https://openrouter.ai/api/v1/chat/completions', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${process.env.OPENROUTER_API_KEY}`
    },
    body: JSON.stringify({
      model: model,
      messages: [
        { role: 'system', content: SYSTEM_PROMPT },
        { role: 'user', content: prompt }
      ]
    })
  });

  const data = await response.json();
  return data.choices[0]?.message?.content ?? '';
}
```

---

## 4. 시스템 프롬프트

### 4.1 Meta-Mentor 역할

```typescript
const SYSTEM_PROMPT = `You are a metacognitive mentor for AI agents.
Your role is to help agents reflect on their reasoning and identify potential issues.

When reviewing an agent's plan:
1. Challenge assumptions
2. Identify blind spots
3. Suggest alternative approaches
4. Point out potential risks
5. Ask clarifying questions

Be constructive but critical. Focus on improving the agent's reasoning process.`;
```

### 4.2 컨텍스트 주입

```typescript
function buildPrompt(input: VibeCheckInput, context: Context): string {
  let prompt = '';

  // 학습 이력 주입
  if (context.learningHistory) {
    prompt += `\n## Learning History\n${context.learningHistory}\n`;
  }

  // Constitution 규칙 주입
  if (context.constitution.length > 0) {
    prompt += `\n## Session Rules\n`;
    context.constitution.forEach((rule, i) => {
      prompt += `${i + 1}. ${rule}\n`;
    });
  }

  // 히스토리 요약 주입
  if (context.historySummary) {
    prompt += `\n## Recent Interactions\n${context.historySummary}\n`;
  }

  // 사용자 요청
  prompt += `\n## Current Request\n`;
  prompt += `Goal: ${input.goal}\n`;
  prompt += `Plan: ${input.plan}\n`;

  if (input.progress) prompt += `Progress: ${input.progress}\n`;
  if (input.uncertainty) prompt += `Uncertainties: ${input.uncertainty}\n`;
  if (input.taskContext) prompt += `Context: ${input.taskContext}\n`;

  return prompt;
}
```

---

## 5. 에러 처리

### 5.1 HTTP 상태 코드별 처리

| 상태 코드 | 의미 | 처리 |
|----------|------|------|
| 401 | 인증 실패 | 에러 메시지 + 폴백 |
| 403 | 접근 거부 | 에러 메시지 + 폴백 |
| 429 | 레이트 제한 | 대기 후 재시도 또는 폴백 |
| 500+ | 서버 오류 | 폴백 |

### 5.2 폴백 전략

```
1. Gemini 주 모델 실패
   └── gemini-2.5-flash로 재시도

2. 모든 LLM 호출 실패
   └── generateFallbackQuestions() 사용

3. 완전 실패
   └── 기본 성찰 질문 4개 반환
```

---

## 6. Agent Skills 변환 시 고려사항

### 6.1 유지해야 할 것
- 다중 프로바이더 지원
- 동적 모델 선택
- 시스템 프롬프트 구조
- 폴백 메커니즘

### 6.2 변경 가능한 것
- 동적 import → 정적 import (빌드 시점)
- 환경변수 → Skills 설정 시스템
- fetch 기반 → SDK 기반 통합

### 6.3 주의사항
- API 키 관리 방식
- 에러 처리 표준화
- 응답 형식 일관성
