# Vibe Check Agent Skills - Work Plan

## Project Overview

**목표**: [vibe-check-mcp-server](https://github.com/PV-Bhat/vibe-check-mcp-server)의 핵심 기능을 Claude Code Agent Skills로 변환

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
| 상태 관리 | 메모리/DB | N/A (단순화) |
| 배포 | npm 패키지 | 디렉토리 구조 |

### Q3: 어떤 도구들을 변환해야 하는가?

**vibe_check만 구현** (단순화된 접근):
- **vibe_check** - 메타인지적 피드백 제공

---

## Project Structure

```
vibe-checking/
├── .claude/
│   └── skills/
│       └── vibe-check/
│           └── SKILL.md
├── WORK_PLAN.md (this file)
├── WORKING_MEMORY.md
├── ARCHITECTURE.md
├── README.md
└── LICENSE
```

---

## Timeline & Progress

- [x] 원본 레포지토리 분석
- [x] Skills 개념 이해
- [x] 작업 계획 수립
- [x] 설계 완료
- [x] vibe-check 구현
- [x] 문서화
- [x] 커밋 및 푸시

---

## References

- 원본: https://github.com/PV-Bhat/vibe-check-mcp-server
- Agent Skills Spec: https://agentskills.io
