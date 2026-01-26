# Vibe Check Agent Skills - Architecture Design

## Design Philosophy

### MCP → Skills 변환 핵심 원칙

1. **Claude가 메타멘토 역할**: 원본 MCP 서버가 외부 LLM을 호출해 피드백을 생성했다면, Skills에서는 Claude 자체가 메타멘토 역할 수행
2. **파일 기반 상태 관리**: 메모리 내 상태를 JSON 파일로 영속화
3. **Shell 스크립트 활용**: 파일 읽기/쓰기를 위한 보조 스크립트
4. **지침 기반 접근**: 구체적인 지침으로 Claude의 행동 가이드

---

## Skills Structure

```
.claude/
└── skills/
    ├── vibe-check/
    │   ├── SKILL.md              # 메인 메타인지 피드백 skill
    │   └── prompts/
    │       └── meta-mentor.md    # 메타멘토 지침
    │
    ├── vibe-learn/
    │   ├── SKILL.md              # 학습 기록 skill
    │   └── scripts/
    │       ├── add-learning.sh   # 학습 항목 추가
    │       └── get-learnings.sh  # 학습 항목 조회
    │
    └── vibe-constitution/
        ├── SKILL.md              # 규칙 관리 skill
        └── scripts/
            ├── update-rules.sh   # 규칙 추가
            ├── reset-rules.sh    # 규칙 리셋
            └── get-rules.sh      # 규칙 조회

data/
├── learnings.json               # 학습 기록 저장
└── constitution.json            # 세션 규칙 저장
# Note: history.json 불필요 - Claude의 대화 컨텍스트가 히스토리 역할 수행
```

---

## Skill Specifications

### 1. vibe-check Skill

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

### 2. vibe-learn Skill

**목적**: 실수, 선호도, 성공 사례 기록 및 학습

**YAML Frontmatter:**
```yaml
name: vibe-learn
description: Record mistakes, preferences, and successes for future reflection. Use after making errors or discovering better approaches.
argument-hint: <mistake|preference|success> <description> [solution]
```

**입력 형식:**
```
/vibe-learn mistake "한 문장 설명" [해결책]
/vibe-learn preference "선호 사항"
/vibe-learn success "성공 사례"
```

**카테고리:**
- `complex-solution-bias` - 불필요하게 복잡한 솔루션 선택
- `feature-creep` - 요청하지 않은 기능 추가
- `premature-implementation` - 이해 전 구현 시작
- `misalignment` - 사용자 의도와 불일치
- `overtooling` - 과도한 도구/라이브러리 사용

**출력:**
- 추가 여부 확인
- 해당 카테고리 누적 횟수
- 상위 카테고리 통계

---

### 3. vibe-constitution Skill

**목적**: 세션별 행동 규칙 관리

**YAML Frontmatter:**
```yaml
name: vibe-constitution
description: Manage session-specific behavioral rules. Use to set, check, or reset guidelines for the current session.
argument-hint: <update|reset|check> [rules...]
disable-model-invocation: true
```

**명령:**
```
/vibe-constitution update "새 규칙"        # 규칙 추가
/vibe-constitution reset "규칙1" "규칙2"   # 전체 교체
/vibe-constitution check                    # 현재 규칙 확인
```

**제한:**
- 세션당 최대 50개 규칙

---

## Data Schemas

### learnings.json
```json
{
  "mistakes": {
    "complex-solution-bias": {
      "count": 3,
      "examples": [
        {
          "type": "mistake",
          "description": "...",
          "solution": "...",
          "timestamp": 1706284800000
        }
      ],
      "lastUpdated": 1706284800000
    }
  }
}
```

### constitution.json
```json
{
  "default": {
    "rules": ["규칙1", "규칙2"],
    "updated": 1706284800000
  }
}
```

---

## Implementation Notes

### Skills에서 상태 관리

Skills는 외부 프로세스가 아니므로 다음 방법으로 상태 관리:

1. **파일 읽기**: `!`command`` 구문으로 셸 명령 실행
   ```markdown
   현재 학습 기록:
   !`cat data/learnings.json 2>/dev/null || echo "{}"`
   ```

2. **파일 쓰기**: Bash 도구를 통해 JSON 파일 업데이트
   - Claude가 직접 파일 수정 명령 생성

3. **세션 ID**: `${CLAUDE_SESSION_ID}` 변수 활용

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

## Risk Assessment

| 위험 | 영향 | 완화 방안 |
|------|------|----------|
| 파일 동시 접근 | 중간 | 단일 세션 가정, 파일 잠금 미구현 |
| JSON 파싱 오류 | 낮음 | 기본값 반환, 오류 처리 |
| 대용량 파일 | 낮음 | 항목 수 제한 (학습 100개, 규칙 50개) |
| 세션 ID 충돌 | 낮음 | UUID 기반 또는 고정 default 사용 |

---

## Migration Path

원본 MCP 서버 사용자가 Skills로 전환시:

1. 기존 `~/.vibe-check/` 데이터를 `data/` 폴더로 복사
2. Skills 설치 (`.claude/skills/` 복사)
3. `/vibe-check`, `/vibe-learn`, `/vibe-constitution` 사용

---

## Version Considerations

- Skills 버전: 1.0.0
- 원본 MCP 서버 참조 버전: 최신 (2026-01)
- Claude Code Skills 스펙 버전: Agent Skills 표준 + Claude 확장
