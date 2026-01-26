# Vibe Check Test Scenarios

이 문서는 vibe-check skill의 테스트 시나리오를 정의합니다.

## 1. Parameter Validation Tests

### 1.1 API Provider Validation

| Test Case | Input | Expected Result |
|-----------|-------|-----------------|
| Valid OpenAI provider | `apiProvider: openai` | Pass |
| Valid Google provider | `apiProvider: google` | Pass |
| Valid Anthropic provider | `apiProvider: anthropic` | Pass |
| Invalid provider | `apiProvider: azure` | Error: Unsupported provider |
| Empty provider | `apiProvider:` | Use default (current session) |

### 1.2 Model Validation

| Test Case | Provider | Model | Expected Result |
|-----------|----------|-------|-----------------|
| Valid OpenAI model | openai | gpt-5.2-high | Pass |
| Valid OpenAI codex | openai | codex-5.2-high | Pass |
| Valid Google pro | google | gemini-3.0-pro-preview | Pass |
| Valid Google flash | google | gemini-3.0-flash-preview | Pass |
| Valid Anthropic sonnet | anthropic | claude-sonnet-4.5 | Pass |
| Valid Anthropic opus | anthropic | claude-opus-4.5 | Pass |
| Invalid model for provider | openai | claude-opus-4.5 | Error: Model not supported |
| Provider without model | openai | (empty) | Error: Model required |
| Model without provider | (empty) | gpt-5.2-high | Error: Provider required |

### 1.3 Environment Variable Validation

| Test Case | Provider | Env Var | Expected Result |
|-----------|----------|---------|-----------------|
| OpenAI with key | openai | OPENAI_API_KEY set | Pass |
| OpenAI without key | openai | OPENAI_API_KEY not set | Warning: API key not configured |
| Google with key | google | GEMINI_API_KEY set | Pass |
| Google without key | google | GEMINI_API_KEY not set | Warning: API key not configured |
| Anthropic with key | anthropic | ANTHROPIC_API_KEY set | Pass |
| Anthropic without key | anthropic | ANTHROPIC_API_KEY not set | Warning: API key not configured |

## 2. Input Format Tests

### 2.1 Structured Format

```
/vibe-check
goal: 사용자 인증 기능 구현
plan: OAuth2 + JWT 토큰 방식
apiProvider: openai
model: gpt-5.2-high
```

**Expected**: Successfully parse all parameters

### 2.2 Natural Language Format

```
/vibe-check OpenAI의 gpt-5.2-high 모델로 사용자 인증을 OAuth2로 구현하려고 합니다.
```

**Expected**: Parse goal and plan from context, extract apiProvider and model

### 2.3 Mixed Format

```
/vibe-check
goal: REST API 설계
plan: OpenAPI 스펙 기반
apiProvider: anthropic
model: claude-opus-4.5
uncertainties: 버전 관리 전략
```

**Expected**: Successfully parse all specified parameters

## 3. Provider-Specific Tests

### 3.1 OpenAI Tests

```yaml
Test: OpenAI GPT-5.2-High Feedback
Input:
  apiProvider: openai
  model: gpt-5.2-high
  goal: 대규모 데이터 처리 파이프라인 구축
  plan: Apache Spark + Kafka 조합
Expected:
  - Feedback considers GPT-5.2-High reasoning capabilities
  - Analysis reflects model's strength in complex problem solving
```

```yaml
Test: OpenAI Codex-5.2-High Feedback
Input:
  apiProvider: openai
  model: codex-5.2-high
  goal: 레거시 코드 리팩토링
  plan: 점진적 마이그레이션
Expected:
  - Feedback leverages Codex's code-specific capabilities
  - Analysis includes code-level recommendations
```

### 3.2 Google Tests

```yaml
Test: Google Gemini-3.0-Pro Feedback
Input:
  apiProvider: google
  model: gemini-3.0-pro-preview
  goal: 멀티모달 애플리케이션 개발
  plan: Vision API + Text 통합
Expected:
  - Feedback considers Gemini's balanced performance
  - Cost-effective recommendations included
```

```yaml
Test: Google Gemini-3.0-Flash Feedback
Input:
  apiProvider: google
  model: gemini-3.0-flash-preview
  goal: 간단한 챗봇 구현
  plan: 템플릿 기반 응답
Expected:
  - Feedback acknowledges Flash's speed advantage
  - Recommendations suitable for simpler tasks
```

### 3.3 Anthropic Tests

```yaml
Test: Anthropic Claude-Sonnet-4.5 Feedback
Input:
  apiProvider: anthropic
  model: claude-sonnet-4.5
  goal: API 문서 자동 생성
  plan: OpenAPI 스펙 파싱
Expected:
  - Feedback leverages Sonnet's efficiency
  - Quick iteration recommendations
```

```yaml
Test: Anthropic Claude-Opus-4.5 Feedback
Input:
  apiProvider: anthropic
  model: claude-opus-4.5
  goal: 복잡한 시스템 아키텍처 설계
  plan: 마이크로서비스 + 이벤트 드리븐
Expected:
  - Feedback leverages Opus's advanced analytical capabilities
  - Deep architectural insights and considerations
```

## 4. Edge Case Tests

### 4.1 Missing Required Parameters

```yaml
Test: No goal provided
Input:
  apiProvider: openai
  model: gpt-5.2-high
  plan: Some plan
Expected: Prompt user to provide goal
```

```yaml
Test: No plan provided
Input:
  apiProvider: anthropic
  model: claude-opus-4.5
  goal: Some goal
Expected: Prompt user to provide plan
```

### 4.2 Fallback Behavior

```yaml
Test: No apiProvider or model specified
Input:
  goal: Simple task
  plan: Simple approach
Expected: Use current Claude Code session's default model
```

## 5. Integration Tests

### 5.1 End-to-End Flow

```yaml
Test: Complete vibe-check with external model
Steps:
  1. User invokes /vibe-check with apiProvider and model
  2. System validates parameters
  3. System checks environment variable for API key
  4. System processes request using specified model's perspective
  5. System returns structured feedback
Expected: Complete flow without errors
```

### 5.2 Error Recovery

```yaml
Test: Invalid configuration recovery
Steps:
  1. User provides invalid apiProvider
  2. System returns helpful error message
  3. User corrects to valid provider
  4. System processes successfully
Expected: Graceful error handling with guidance
```

## Test Execution Checklist

- [ ] All parameter validation tests pass
- [ ] All input format tests pass
- [ ] All provider-specific tests pass
- [ ] All edge case tests handled
- [ ] Integration tests complete
- [ ] Error messages are helpful and actionable
