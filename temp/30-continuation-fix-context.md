# Vibe-Check Continuation Fix - Master Context

## Problem
When vibe-check skill is invoked mid-task, the agent treats the skill output
as its final answer and stops. The agent doesn't resume the original task.

## Root Cause
1. **Answer-shaped output** — `### Recommendation`, `### If Adjusting` look like
   a completed report, triggering the agent's task-completion heuristic
2. **No continuation contract** — SKILL.md has no instruction telling the agent
   to resume the original task after outputting the vibe check
3. **Meta-mentor authority gradient** — the agent passively follows the "mentor"
   output instead of synthesizing its own conclusion

## Fix Applied
Added `## After Output` section between line 182 (end of Output Format) and
line 184 (start of Core Questions) in SKILL.md:

```markdown
## After Output

This vibe check is a reflection pause, not a task completion. After generating the analysis above, resume whatever task prompted this check.
```

## Why This Is Sufficient
- Directly addresses the root cause (missing continuation contract)
- Positioned where the agent encounters it right after generating output
- Covers both mid-task use (resume original work) and standalone use (nothing to resume = normal end)
- Minimal change — no output format, persona, or structural changes

## Files
- **Target**: `/home/idnotbe/projects/vibe-check/.claude/skills/vibe-check/SKILL.md`
- **Tests**: `/home/idnotbe/projects/vibe-check/tests/validate_skill.sh`
- **This context**: `/home/idnotbe/projects/vibe-check/temp/30-continuation-fix-context.md`

## Escalation Path (if this fix is insufficient)
1. Line 13 reframing: "You are now acting as" → "Pause your current task and perform a"
2. Add `### Next Action` section to output template
3. MCP tool route: `formatVibeCheckOutput()` with continuation note

## Verification Criteria
1. **Structural**: Section exists, correct heading level, correct position
2. **Content**: Wording is clear, concise, unambiguous
3. **Behavioral**: Fix addresses the root cause without side effects
4. **Compatibility**: Works with both mid-task and standalone invocations
5. **Test**: `validate_skill.sh` still passes (or is updated accordingly)
6. **Ecosystem**: Consistent with how other skills handle post-output continuation
