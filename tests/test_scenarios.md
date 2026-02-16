# Vibe Check Test Scenarios

This document defines test scenarios for the vibe-check skill.

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
goal: Implement user authentication
plan: OAuth2 + JWT token approach
apiProvider: openai
model: gpt-5.2-high
```

**Expected**: Successfully parse all parameters

### 2.2 Natural Language Format

```
/vibe-check I want to implement user auth with OAuth2 using OpenAI's gpt-5.2-high model.
```

**Expected**: Parse goal and plan from context, extract apiProvider and model

### 2.3 Mixed Format

```
/vibe-check
goal: Design REST API
plan: Based on OpenAPI spec
apiProvider: anthropic
model: claude-opus-4.5
uncertainties: Versioning strategy
```

**Expected**: Successfully parse all specified parameters

## 3. Provider-Specific Tests

### 3.1 OpenAI Tests

```yaml
Test: OpenAI GPT-5.2-High Feedback
Input:
  apiProvider: openai
  model: gpt-5.2-high
  goal: Build large-scale data processing pipeline
  plan: Apache Spark + Kafka combination
Expected:
  - Feedback considers GPT-5.2-High reasoning capabilities
  - Analysis reflects model's strength in complex problem solving
```

```yaml
Test: OpenAI Codex-5.2-High Feedback
Input:
  apiProvider: openai
  model: codex-5.2-high
  goal: Refactor legacy codebase
  plan: Incremental migration
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
  goal: Develop multimodal application
  plan: Vision API + Text integration
Expected:
  - Feedback considers Gemini's balanced performance
  - Cost-effective recommendations included
```

```yaml
Test: Google Gemini-3.0-Flash Feedback
Input:
  apiProvider: google
  model: gemini-3.0-flash-preview
  goal: Implement simple chatbot
  plan: Template-based responses
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
  goal: Auto-generate API documentation
  plan: Parse OpenAPI spec
Expected:
  - Feedback leverages Sonnet's efficiency
  - Quick iteration recommendations
```

```yaml
Test: Anthropic Claude-Opus-4.5 Feedback
Input:
  apiProvider: anthropic
  model: claude-opus-4.5
  goal: Design complex system architecture
  plan: Microservices + event-driven
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
