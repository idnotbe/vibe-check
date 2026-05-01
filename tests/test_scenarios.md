# Vibe Check Test Scenarios

This document defines test scenarios for the vibe-check skill.

## 1. Input Format Tests

### 1.1 Structured Format

```
/vibe-check
goal: Implement user authentication
plan: OAuth2 + JWT token approach
```

**Expected**: Successfully parse `goal` and `plan`, then produce structured feedback per the Output Format.

### 1.2 Natural Language Format

```
/vibe-check I want to implement user auth with OAuth2 but I'm not sure if I need Redis for sessions. Using Express.js with PostgreSQL.
```

**Expected**: Infer `goal`, `plan`, `uncertainties`, and `taskContext` from the prose; produce structured feedback.

### 1.3 Simple Format

```
/vibe-check OAuth2 auth implementation / JWT + Redis session storage
```

**Expected**: Treat the text before `/` as `goal` and after as `plan`; produce structured feedback.

## 2. Optional Parameter Coverage

### 2.1 Progress Field

```
/vibe-check
goal: Migrate monolith to microservices
plan: Strangler fig pattern, extract auth service first
progress: Auth service extracted; user service extraction in progress
```

**Expected**: Feedback explicitly references the reported progress (e.g., acknowledges work already done, focuses critique on the next stage rather than the completed one).

### 2.2 Task Context Field

```
/vibe-check
goal: Add full-text search to product catalog
plan: Self-hosted Elasticsearch cluster
taskContext: Single-region deployment, ~50K products, 2-person team, no existing ES expertise
```

**Expected**: Feedback explicitly references at least one of the stated constraints (team size, scale, or ES expertise gap) when assessing the plan.

### 2.3 Uncertainties Field

```
/vibe-check
goal: Improve API latency
plan: Add Redis caching layer in front of Postgres
uncertainties: Is the bottleneck actually the DB? Cache invalidation strategy? TTLs?
```

**Expected**: Feedback engages with each uncertainty rather than ignoring them; may recommend measurement before implementation.

## 3. Edge Case Tests

### 3.1 Missing Required Parameters

```
/vibe-check
plan: Some plan without a goal
```

**Expected**: Per Special Cases, prompt the user to describe what they're trying to accomplish.

### 3.2 No Input

```
/vibe-check
```

**Expected**: Per Special Cases, prompt the user for goal, current approach, and concerns.

### 3.3 Solid Plan

```
/vibe-check
goal: Add request ID logging across HTTP handlers
plan: Use the framework's built-in middleware to inject a UUID into the request context and log it from existing structured logger
```

**Expected**: Per Special Cases ("If the plan looks solid"), acknowledge it's well-thought-out and approve proceeding without inventing problems.

## 4. Legacy Compatibility

### 4.1 Legacy apiProvider/model Keys Are Ignored

```
/vibe-check
goal: Refactor checkout flow
plan: Extract domain logic into a separate service layer
apiProvider: anthropic
model: claude-opus-4.5
```

**Expected**: Output is generated normally per the Output Format. The `apiProvider` and `model` lines are silently ignored (no error about unknown parameters, no special handling). This verifies the legacy compatibility note in SKILL.md.

## 5. Continuation Behavior

### 5.1 Vibe Check Mid-Task

Invoke `/vibe-check` during an in-progress task (e.g., user asked Claude to refactor a function; Claude pauses to vibe-check the refactor strategy).

**Expected**:
- Output contains a non-empty `### Next Action` line.
- Recommendation line is phrased as a continuation directive ("Proceed as planned", "Proceed with adjustments: ...", or "Pause and rethink: ..."), not a bare verb like "proceed" or "reconsider".
- After the output block, Claude immediately performs the next step of the refactor (tool call, code edit, or follow-up question) within the same turn — does not stop and wait for user input.

### 5.2 "Pause and Rethink" Recommendation

Invoke `/vibe-check` on a plan that has clear flaws (e.g., proposes deleting prod DB to fix a typo).

**Expected**:
- Recommendation is `"Pause and rethink: <reason>"`.
- Claude does not stop. It restates the revised understanding and either asks one targeted clarifying question or proposes a corrected next step in the same turn.

## Test Execution Checklist

- [ ] All input format tests produce structured feedback
- [ ] Optional parameter scenarios show the parameter influencing the feedback
- [ ] Edge case prompts route through the Special Cases section as documented
- [ ] Legacy `apiProvider`/`model` keys do not produce errors and do not change output structure
- [ ] Continuation Behavior tests confirm Claude resumes the original task in the same turn after the vibe-check output
