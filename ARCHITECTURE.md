# Vibe Check Agent Skills - Architecture Design

## Design Philosophy

### MCP → Skills 변환 핵심 원칙

1. **Claude가 메타멘토 역할**: 원본 MCP 서버가 외부 LLM을 호출해 피드백을 생성했다면, Skills에서는 Claude 자체가 메타멘토 역할 수행
2. **지침 기반 접근**: 구체적인 지침으로 Claude의 행동 가이드

---

## Skills Structure

```
.claude/
└── skills/
    └── vibe-check/
        └── SKILL.md              # 메인 메타인지 피드백 skill
```

---

## Skill Specification

### vibe-check Skill

**목적**: 에이전트 계획에 대한 메타인지적 피드백 제공

**YAML Frontmatter:**
```yaml
name: vibe-check
description: Metacognitive sanity check for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating.
argument-hint: <goal> <plan>
```

**핵심 기능:**
- 계획의 4가지 차원 평가
  1. 상황 분석 (문제의 본질, 접근법)
  2. 진단 평가 (패턴 인식, 가정 점검)
  3. 응답 유형 (기술 가이드 / 부드러운 질문 / 검증)
  4. 경로 수정 (모범 사례 상기 또는 진행 승인)

**메타멘토 질문:**
1. 이 계획이 사용자의 실제 요청을 해결하는가?
2. 더 단순한 대안이 있는가?
3. 어떤 가정이 사고를 제한하고 있는가?
4. 접근법이 원래 의도와 얼마나 일치하는가?

**Categories to Watch (경고 패턴):**
- Complex Solution Bias (복잡한 솔루션 편향)
- Feature Creep (기능 범위 확장)
- Premature Implementation (조기 구현)
- Misalignment (목표 불일치)
- Overtooling (과도한 도구 사용)

---

## Implementation Notes

### Claude의 메타멘토 역할

MCP 서버가 외부 LLM을 호출한 것과 달리, Skills에서는:
- Claude 자체가 메타멘토 역할 수행
- SKILL.md에 상세한 평가 기준/질문 포함
- Claude의 자기 성찰 능력 활용

이는 오히려 장점:
- 외부 API 호출 없음 (비용/지연 절감)
- Claude의 맥락 이해 활용
- 더 일관된 피드백 품질

---

## Migration Path

원본 MCP 서버 사용자가 Skills로 전환시:

1. Skills 설치 (`.claude/skills/` 복사)
2. `/vibe-check` 사용

---

## Version Considerations

- Skills 버전: 1.0.0
- 원본 MCP 서버 참조 버전: 최신 (2026-01)
- Claude Code Skills 스펙 버전: Agent Skills 표준 + Claude 확장
