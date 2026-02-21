# Behavior Review: "After Output" Continuation Fix

**Reviewer**: Agent Behavior Specialist (behavior-reviewer)
**Date**: 2026-02-21
**Verdict**: **PASS** (with one minor concern and one improvement recommendation)

---

## Summary

The 3-line edit adding an `## After Output` section to SKILL.md is **effective
and appropriately scoped**. It directly addresses the two primary root causes
(answer-shaped output triggering completion heuristics, missing continuation
contract) and partially addresses the third (authority gradient). Cross-model
behavioral analysis indicates the fix will work across Claude, GPT, and Gemini
model families. One minor concern exists regarding standalone invocation
wording, but it is low-risk and does not block acceptance.

---

## 1. Root Cause Coverage Analysis

### Root Cause 1: Answer-Shaped Output (ADDRESSED)
The output template ends with `### If Adjusting` followed by closing backticks,
which creates a strong "task complete" signal. The fix counters this with
explicit contrastive framing: **"a reflection pause, not a task completion."**
This directly tells the model that the structured output is NOT a final answer.

**Effectiveness**: High. Contrastive framing ("X, not Y") is one of the
strongest instruction patterns for LLMs because it explicitly disambiguates
the intended interpretation.

### Root Cause 2: Missing Continuation Contract (ADDRESSED)
The original SKILL.md had no instruction about what to do after generating
output. The fix adds an explicit contract: **"resume whatever task prompted
this check."**

**Effectiveness**: High. This is the most direct and important fix. The absence
of any post-output instruction was the primary cause of the stopping behavior.

### Root Cause 3: Meta-Mentor Authority Gradient (PARTIALLY ADDRESSED)
The fix reframes the output as a "pause" rather than a mentor's complete
assessment, which partially reduces the authority gradient. However, the strong
role assignment on line 13 ("You are now acting as a meta-mentor") remains
unchanged.

**Effectiveness**: Medium. The reframing helps, but the persona instruction
still creates a cognitive boundary between "mentor mode" and "doer mode."
This is acceptable for a minimal fix -- the escalation path (softening line 13
to "Pause your current task and perform a...") is documented if needed.

---

## 2. LLM Behavioral Predictions

### How Skill Prompts Are Processed (Critical Context)
A key insight for this analysis: **skill prompts are processed holistically
before generation begins, not sequentially during generation.** When the
model receives the SKILL.md content, it reads ALL sections -- including
`## After Output` -- before planning its response. This means the "After
Output" instruction shapes the generation plan, not just post-generation
behavior.

This is important because Gemini's review raised a concern about the model
emitting stop tokens after the output template. While this concern applies to
purely sequential processing, it does not apply to how skill prompts are
actually consumed. The model knows about the continuation instruction before
it starts generating.

### Claude Models (Opus, Sonnet)
- Strong instruction following and context maintenance
- Claude processes meta-instructions well ("this is not a task completion")
- The contrastive framing aligns with Claude's instruction hierarchy
- **Prediction: Effective.** Claude will process the continuation instruction
  and resume the original task.

### GPT-Series (GPT-5, Codex)
- More template-driven; output structure carries significant weight
- However, explicit instructions override template-based heuristics
- GPT models follow "do X after Y" patterns reliably when clearly stated
- **Prediction: Effective.** The explicit instruction should override the
  template completion signal, though slightly less reliably than with Claude.

### Gemini Models
- Highly structure-sensitive; template completion is a strong signal
- However, the holistic processing argument applies equally
- Gemini's own self-assessment (via pal clink) suggested the fix is
  "structurally vulnerable" but this was based on sequential processing model
- **Prediction: Effective.** The instruction will be processed during planning.
  If empirical testing reveals issues with Gemini specifically, the escalation
  path (in-template `### Next Actions` section) would address it.

---

## 3. Scenario Analysis

### Scenario 1: Mid-Task Invocation (Primary Use Case)
- Agent is working on task X
- Agent invokes /vibe-check to sanity-check its plan
- Agent generates structured vibe check output
- Agent reads "resume whatever task prompted this check"
- Agent returns to task X

**Assessment**: This is the target scenario and the fix directly addresses it.
The original task context remains in the conversation history. The continuation
instruction provides the necessary bridge back to that context.

**Verdict**: WORKS CORRECTLY

### Scenario 2: Standalone Invocation
- User explicitly calls /vibe-check with a goal/plan
- No prior task in context
- "Resume whatever task prompted this check" -- nothing to resume

**Assessment**: The phrase "whatever task prompted this check" is phrased as a
conditional reference. If nothing prompted it, the instruction is vacuous --
there is nothing to resume, so the agent naturally stops.

**Risk**: Low but real. An overly literal model might attempt to infer or
hallucinate a prior task to satisfy the "resume" instruction. This is unlikely
with modern instruction-tuned models but not impossible.

**Verdict**: LIKELY WORKS CORRECTLY (see improvement recommendation below)

### Scenario 3: Vibe-Check During Complex Multi-Step Workflow
- Agent is in step 3 of a 5-step workflow
- Agent invokes vibe-check mid-step
- After vibe-check output, agent should return to step 3

**Assessment**: This works because the conversation context preserves the
workflow state. The continuation instruction triggers the agent to look back
at what it was doing.

**Verdict**: WORKS CORRECTLY

### Scenario 4: Repeated/Consecutive Vibe Checks
- Agent calls vibe-check multiple times in succession
- Each generates output + encounters continuation instruction

**Assessment**: Each invocation is independent. The continuation instruction
applies to the most recent task context, which is correct.

**Verdict**: WORKS CORRECTLY

### Scenario 5: Vibe-Check in Agent-to-Agent Communication
- An agent receives a vibe-check as part of a multi-agent workflow
- After generating output, the continuation instruction fires

**Assessment**: Works as expected. The "task that prompted this check" refers
to whatever the coordinating agent asked for.

**Verdict**: WORKS CORRECTLY

---

## 4. External Opinions

### Self-Assessment (Vibe-Check on Review Plan)
The vibe-check skill assessed this review plan as "well-structured and
thorough" with the appropriate multi-angle approach. It flagged potential
overtooling risk (using too many external sources) and noted that the
single-sentence concern may be overweighted -- brevity can be a strength
for LLM instructions. It recommended prioritizing scenario analysis as the
strongest evidence source.

### Gemini (via pal clink)
Gemini provided a detailed code review with three findings:

1. **HIGH: Fragile Continuation Contract** -- Argued that placing the
   instruction outside the output template makes it vulnerable to stop token
   emission after the template. Recommended adding a `### Next Actions`
   section inside the template.

   **My assessment**: This concern is based on a sequential processing model
   that does not accurately reflect how skill prompts are consumed. However,
   the recommended `### Next Actions` approach is a valid escalation if the
   minimal fix proves insufficient.

2. **HIGH: Inappropriate Continuation Risk** -- Argued the unconditional
   "resume" wording could cause hallucinated continuation during standalone
   use. Recommended conditional wording.

   **My assessment**: Valid concern. The risk is low but the fix is simple.
   See improvement recommendation below.

3. **MEDIUM: Meta-Mentor Authority Gradient** -- Recommended softening the
   mentor persona to reduce context-switching friction.

   **My assessment**: Valid long-term observation. Not blocking for this fix.
   Tracked as escalation path item 1 in the context document.

### Codex (via pal clink)
Codex was unavailable due to rate limiting. Not blocking for this review since
Gemini and the self-assessment provide sufficient external perspective.

### ThinkDeep Analysis (Gemini-backed deep reasoning)
Confirmed high confidence in the fix's effectiveness. Key additional insight:
the expert analysis recommended conditional wording as well, and framed the
authority gradient issue as a "Player-Coach" vs "Mentor" model question --
a useful metaphor for future persona design.

---

## 5. Detailed Wording Analysis

Current text:
> This vibe check is a reflection pause, not a task completion. After generating
> the analysis above, resume whatever task prompted this check.

### Strengths
- **Contrastive framing**: "reflection pause, not a task completion" directly
  disambiguates the output's semantic role
- **Concise**: Two sentences. No room for misinterpretation or attention loss.
- **Task-aware**: "whatever task prompted this check" connects back to the
  agent's prior context
- **Natural fallback**: If no task prompted it, the instruction is vacuous

### Potential Weakness
- **Unconditional "resume"**: The imperative "resume" could be interpreted as
  requiring action even when there is no prior task. This is a minor concern
  but easily fixable.

---

## 6. Side Effect Analysis

### Could this cause agents to inappropriately continue?
**Low risk.** The instruction says "resume whatever task prompted this check" --
it does not say "do something new" or "generate more output." It specifically
refers back to an existing task, which is either present (mid-task) or absent
(standalone). In the absent case, there is nothing to resume.

### Could this cause infinite loops?
**No.** The instruction says "resume" (singular action), not "loop" or "keep
checking." Each vibe-check invocation is a one-shot evaluation.

### Could this interfere with other skills?
**No.** The instruction operates within the vibe-check skill's scope and only
affects post-output behavior within that scope.

---

## 7. Positioning Assessment

The `## After Output` section at line 184 sits between:
- `## Output Format` (lines 158-182) -- the template that causes the problem
- `## Core Questions to Always Ask` (lines 188-203) -- evaluation framework

This positioning is **near-optimal** because:
1. It immediately follows the output template, creating a direct "after you
   do THAT, do THIS" instruction chain
2. It benefits from recency relative to the template (the last thing about
   output before evaluation criteria)
3. It is a `##` level heading, giving it structural prominence
4. It is NOT at the very end of the document, so it is processed as part of
   the main instruction flow rather than an afterthought

### Alternative Positions Considered
- **End of document**: Would benefit from recency bias but would feel
  disconnected from the output format section. Less effective.
- **Inside the output template**: Would be the strongest position (forces
  generation of continuation) but would change the output format, which the
  fix explicitly avoids.
- **Before the output template**: Too early; would not be associated with
  post-output behavior.

---

## 8. Final Recommendation

### Verdict: PASS

The fix is **sound, minimal, and appropriately scoped**. It correctly addresses
the primary root causes of the agent stopping behavior without introducing
significant side effects.

### Improvement Recommendation (Optional, Non-Blocking)

Consider making the continuation instruction explicitly conditional to
eliminate the small risk of hallucinated continuation during standalone use:

**Current:**
> This vibe check is a reflection pause, not a task completion. After generating
> the analysis above, resume whatever task prompted this check.

**Suggested refinement:**
> This vibe check is a reflection pause, not a task completion. If this check
> was invoked during an ongoing task, resume that task after generating the
> analysis above.

This makes the conditional nature explicit rather than implicit, which is
more robust across model families. However, the current wording is acceptable
as-is.

### Escalation Path (If Fix Proves Insufficient)
The context document's escalation path remains valid and ordered correctly:
1. Soften line 13 role assignment ("Pause your current task and perform a...")
2. Add `### Next Actions` section to output template
3. MCP tool route with continuation note

### Test Recommendation
After merging, validate with:
1. Mid-task invocation: Start a coding task, invoke /vibe-check, confirm agent
   resumes the coding task
2. Standalone invocation: Call /vibe-check directly, confirm agent does NOT
   hallucinate a prior task
3. Multi-step workflow: Invoke /vibe-check during step 3 of a 5-step plan,
   confirm agent returns to step 3
