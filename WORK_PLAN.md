# Vibe Check Agent Skills - Work Plan

## Project Overview

**목표**: [vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)의 기능을 Claude Code Agent Skills로 변환

**원본 프로젝트**: MCP(Model Context Protocol) 서버로 AI 에이전트에게 메타인지적 피드백 제공
**변환 대상**: Claude Code Agent Skills (SKILL.md 기반)

---

## Key Questions & Decisions

### Q1: Fork가 필요한가?

**결론: Fork 불필요**

이유:
1. 원본은 TypeScript/Node.js MCP 서버 → 완전히 다른 아키텍처
2. Skills는 SKILL.md 파일 기반 → 새로 작성 필요
3. 코드를 재사용하는 것이 아니라 기능/개념을 재구현
4. 원본은 참고용으로만 사용

### Q2: MCP vs Skills 핵심 차이

| 측면 | MCP Server | Agent Skills |
|------|------------|--------------|
| 실행 방식 | 외부 프로세스 | Claude 내부 지침 |
| 언어 | TypeScript/Node.js | SKILL.md (Markdown + YAML) |
| LLM 호출 | 직접 API 호출 | Claude 자체가 수행 |
| 상태 관리 | 메모리/DB | 파일 기반 |
| 배포 | npm 패키지 | 디렉토리 구조 |

### Q3: 어떤 도구들을 변환해야 하는가?

원본 MCP 서버의 5가지 도구:
1. **vibe_check** - 메타인지적 피드백 제공
2. **vibe_learn** - 실수/해결책 기록
3. **update_constitution** - 세션 규칙 설정
4. **reset_constitution** - 규칙 리셋
5. **check_constitution** - 규칙 확인

---

## Implementation Approach

### Phase 1: 분석 (Analysis)
- [ ] 원본 MCP 서버 소스코드 상세 분석
- [ ] 각 도구의 입력/출력/로직 파악
- [ ] CPI(Chain-Pattern Interrupts) 개념 이해
- [ ] LLM 프롬프트 패턴 추출

### Phase 2: 설계 (Design)
- [ ] Skills 디렉토리 구조 설계
- [ ] 각 skill의 SKILL.md 구조 설계
- [ ] 상태 관리 방법 결정 (파일 기반)
- [ ] 셸 스크립트 필요 여부 결정

### Phase 3: 구현 (Implementation)
- [ ] 프로젝트 구조 생성
- [ ] vibe-check skill 구현
- [ ] vibe-learn skill 구현
- [ ] constitution 관련 skills 구현
- [ ] 지원 스크립트/템플릿 생성

### Phase 4: 검증 (Verification)
- [ ] 각 skill 테스트
- [ ] 문서화
- [ ] 코드 리뷰 및 개선

---

## Project Structure (Proposed)

```
vibe-checking/
├── .claude/
│   └── skills/
│       ├── vibe-check/
│       │   ├── SKILL.md
│       │   └── templates/
│       ├── vibe-learn/
│       │   ├── SKILL.md
│       │   └── scripts/
│       ├── vibe-constitution/
│       │   ├── SKILL.md
│       │   └── scripts/
│       └── vibe-status/
│           └── SKILL.md
├── data/
│   ├── learnings.json
│   └── constitution.json
├── WORK_PLAN.md (this file)
├── WORKING_MEMORY.md
├── README.md
└── LICENSE
```

---

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| Skills가 MCP만큼 강력하지 않을 수 있음 | High | Claude 자체 능력 활용, 창의적 접근 |
| 상태 지속성 문제 | Medium | 파일 기반 저장, JSON 활용 |
| LLM 호출 차이 | Medium | Claude가 직접 메타인지 수행하도록 설계 |

---

## Timeline & Progress

- [x] 원본 레포지토리 분석 (개요 수준)
- [x] Skills 개념 이해
- [x] 작업 계획 수립
- [ ] 상세 소스코드 분석
- [ ] 설계 완료
- [ ] 구현
- [ ] 테스트 및 검증
- [ ] 커밋 및 푸시

---

## References

- 원본: https://github.com/PV-Bhat/vibe-check-mcp-server
- Agent Skills Spec: https://agentskills.io
- Claude Code Skills Docs: https://code.claude.com/docs/en/skills.md
