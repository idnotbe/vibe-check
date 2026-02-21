# Prompt Engineering Review: `## After Output` Section

**Reviewer**: prompt-eng-reviewer (Claude Opus 4.6)
**Date**: 2026-02-21
**Verdict**: CONCERNS

---

## Summary

The edit addresses the correct root cause (missing continuation contract) and the
intent is sound. However, the current implementation has prompt engineering
weaknesses that reduce its reliability. The fix will work *some of the time* but
is not robust enough to consistently override completion heuristics. Specific
concerns center on positioning, instruction framing, and standalone invocation
handling.

---

## Detailed Analysis

### 1. Wording Effectiveness

**Assessment: Adequate but suboptimal**

The sentence "This vibe check is a reflection pause, not a task completion" uses
**negative framing** -- it defines what the action is NOT rather than what it IS.
Prompt engineering research and practice consistently show that positive,
affirmative directives are more reliably followed by LLMs than negated ones.

- **Current (negative)**: "not a task completion"
- **Stronger (positive)**: "This is an intermediate diagnostic step" or "This is
  a mid-task reflection"

The second clause, "resume whatever task prompted this check," is directionally
correct but vague. "Whatever task" requires the agent to reconstruct context about
what it was doing before the skill invocation. A more explicit instruction like
"continue executing your original plan" or "proceed with the next step of your
current task" may anchor the agent's intent more firmly.

That said, the wording is not *wrong* -- it communicates the right idea. The
question is whether it's *strong enough* to reliably override competing signals.

### 2. Heading Level Consistency

**Assessment: PASS -- correct heading level**

The document's top-level sections use `##` consistently:

```
## Input Parameters (line 17)
## Context (line 109)
## Your Role (line 117)
## Evaluation Framework (line 125)
## Output Format (line 158)
## After Output (line 184)     <-- the edit
## Core Questions (line 188)
## Tone Guidelines (line 204)
## Special Cases (line 212)
```

`## After Output` is correctly a peer of `## Output Format`. This is appropriate
because it is a top-level behavioral instruction, not a subsection of the output
template. The heading level is correct.

### 3. Positioning

**Assessment: CONCERNS -- the key architectural question**

The edit sits at lines 184-186, *after* the Output Format code block closes at
line 182 and *before* Core Questions starts at line 188. This positioning raises
the central question of this review:

**Will the agent process this instruction effectively given its position?**

There are two competing models for how this works:

**Model A (Instructions are pre-processed):** Claude Code processes SKILL.md as
system-level instructions. The agent reads the *entire* document before generating
any output. Under this model, the agent already knows about the continuation
requirement before it starts generating the vibe check output, so positioning
doesn't matter much. The instruction is internalized as part of the behavioral
contract.

**Model B (Completion heuristics dominate):** Even though the agent reads all
instructions upfront, the autoregressive generation process creates strong
statistical pressure toward EOS tokens when completing structured templates. The
agent generates the output template, the output *looks* like a completed report,
and the completion heuristic fires -- either at the model level (EOS token
probability spikes) or at the framework level (the orchestration layer detects
a completed response pattern).

**My analysis**: Both models have truth to them, and the real answer is
context-dependent:

- In Claude Code specifically, skills are expanded inline into the conversation.
  The agent does read the full SKILL.md as instructions. This gives Model A some
  weight.
- However, the vibe-check output template is *answer-shaped* -- it has
  `### Recommendation` and `### If Adjusting` sections that look like final
  deliverables. This is exactly the pattern that triggers premature completion.
- The `## After Output` instruction competes against this answer-shaped output in
  the agent's attention. A brief, single-sentence instruction may lose the
  attention competition against a long, structured template that the agent just
  spent significant tokens generating.

**The strongest mitigation** would be to place the continuation signal *inside*
the output template itself, as a mandatory final section. This forces the agent
to generate continuation intent as part of its structured output, before the
template closes and the completion heuristic activates.

However, I want to note that adding a `### Next Action` section to the output
template changes the character of the vibe-check output itself -- it turns a
reflective analysis into an action-planning document. This is a design tradeoff
the maintainers should consciously evaluate, not just a prompt engineering
optimization.

### 4. Instruction Strength

**Assessment: CONCERNS -- could be stronger**

The current instruction is a descriptive statement ("This vibe check is a
reflection pause") followed by a directive ("resume whatever task"). It reads
as guidance rather than a hard constraint.

Compare instruction strength levels:

| Level | Example |
|-------|---------|
| Descriptive (current) | "This vibe check is a reflection pause, not a task completion." |
| Directive | "After outputting the vibe check, immediately continue with your original task." |
| Imperative | "You MUST resume your original task after outputting the vibe check." |
| Structural | Add `### Next Action` as a mandatory output section |

The current level (descriptive) is the weakest form. For overriding completion
heuristics, at least a directive or imperative level is recommended.

That said, over-strong instructions (CRITICAL, MUST, NEVER) can create their own
problems -- they can cause the agent to prioritize compliance over quality, or
create anxiety-like patterns in generation. The right calibration depends on how
severe the original problem is.

### 5. Interaction with Completion Heuristics

**Assessment: CONCERNS -- partially effective**

The completion heuristic problem has multiple layers:

1. **Token-level**: The model's EOS probability spikes after completing structured
   output. The `## After Output` instruction was read during instruction
   processing, but its influence competes against the statistical weight of
   template completion.

2. **Framework-level**: Claude Code's agent loop evaluates whether the agent has
   completed its turn. A structured vibe-check output with `### Recommendation`
   looks like a complete response. The framework may decide the turn is done
   before the agent generates any continuation text.

3. **Attention-level**: As the conversation grows longer, the relative attention
   weight of the `## After Output` instruction decreases. It's one sentence
   competing against the entire conversation context.

The current fix addresses layer 1 partially (the agent knows about the instruction)
but doesn't robustly address layers 2 and 3. A structural fix (mandatory output
section) would address all three layers because the continuation intent is
embedded in the generated output itself.

### 6. Unintended Effects

**Assessment: CONCERNS -- standalone invocation risk**

The instruction says "resume whatever task prompted this check" unconditionally.
When vibe-check is invoked standalone (user types `/vibe-check` directly without
a prior task), there is no task to resume. Possible unintended behaviors:

- The agent fabricates/hallucinates a task to resume
- The agent outputs awkward "I don't have a task to resume" text
- The agent ignores the instruction (benign but inconsistent)

The context file (line 28) claims the fix "covers both mid-task use (resume
original work) and standalone use (nothing to resume = normal end)." This is
optimistic. The phrase "resume whatever task prompted this check" is an
unconditional directive -- it doesn't distinguish between mid-task and standalone
invocations.

A conditional construction would be safer:
> "If this check was invoked during an ongoing task, resume that task. Otherwise,
> await further input."

However, this adds complexity to a deliberately minimal fix. The risk of
hallucinated task resumption in standalone mode is low in practice because the
agent's context window will clearly show no prior task context.

---

## External Opinions

### Gemini CLI (gemini-3.1-pro-preview via pal clink)

**Verdict**: The fix is insufficient. Three specific concerns:

1. **High severity**: Completion heuristic fires before `## After Output` is
   processed. Recommends moving the instruction inside the template as a
   `### Next Action` section.
2. **Medium severity**: Negative framing is weak. Recommends positive, concrete
   directives with explicit continuation language.
3. **Medium severity**: Standalone invocation risk. Recommends conditional
   instructions for mid-task vs standalone paths.

### Gemini Pro (gemini-3-pro-preview via pal chat)

**Verdict**: Agrees with the clink review. Key additional insight:

- Acknowledges the counterargument that SKILL.md is processed as system-level
  instructions (Model A above), but argues **probabilistic inertia** still
  dominates. LLMs gravitate toward closure after completing structured templates.
- Frames the template-internal approach as a "cognitive bridge" -- forcing the
  model to plan resumption while it still holds the generation privilege.
- Recommends a `### Resumption Plan` section inside the template.

### Codex CLI (codex-5.3)

**Status**: Unavailable (usage limit reached). No opinion obtained.

### Self Vibe-Check

Applied the vibe-check skill to my own analysis plan. Key feedback:

- Plan is well-structured and on track
- Correctly prioritized positioning and completion-heuristic analysis
- Warned about potential overtooling (8 steps for a 3-line review)
- Highlighted the key tension: the fix is positioned after the template but the
  agent processes SKILL.md as instructions, so positioning may matter less than
  expected

---

## Critical Assessment of External Opinions

The external opinions (both from Gemini family models) are thoughtful but may
overweight the autoregressive/sequential generation model (Model B) relative to
how Claude Code actually works. Key nuances they may miss:

1. **Claude Code skill expansion**: Skills are expanded into the system prompt
   context, not processed as sequential instructions during generation. The agent
   genuinely does read `## After Output` before generating anything.

2. **The `### Next Action` suggestion changes the skill's character**: Adding a
   mandatory action-planning section to the vibe-check output transforms it from
   a pure reflection tool into an action-planning tool. This may be desirable but
   is a design decision, not just a prompt engineering optimization.

3. **Over-engineering risk**: The escalation path in the context file (line 37-39)
   already identifies stronger interventions if this fix is insufficient. The
   minimal fix philosophy is valid -- try the simplest thing first and escalate
   if needed.

4. **Empirical question**: Whether the fix works is ultimately empirical. The
   theoretical arguments about completion heuristics are plausible but not
   definitive. Testing the actual behavior would be more informative than
   theoretical analysis.

---

## Specific Suggestions

If the maintainers want to strengthen the fix while staying minimal:

### Option A: Strengthen wording only (minimal change)

Replace the current text:
```markdown
## After Output

This vibe check is a reflection pause, not a task completion. After generating the analysis above, resume whatever task prompted this check.
```

With:
```markdown
## After Output

This vibe check is an intermediate reflection step. After generating the analysis above, immediately continue executing your original task. If invoked standalone without a prior task, await user input.
```

Changes: positive framing, stronger directive ("immediately continue executing"),
conditional handling for standalone invocations.

### Option B: Add structural reinforcement (moderate change)

Keep `## After Output` as-is AND add to the output template:
```markdown
### If Adjusting
[Optional: Specific suggestions for improvement]

---
*[Vibe check complete -- resuming original task]*
```

The italicized footer inside the template serves as a cognitive bridge without
adding a full `### Next Action` section.

### Option C: Full structural fix (larger change, from escalation path)

Add `### Next Action` to the output template and reframe `## After Output`.
This is the approach recommended by both Gemini reviewers but represents a more
significant change to the skill's output format.

---

## Final Recommendation

**Verdict: CONCERNS -- the fix is directionally correct but has reliability gaps.**

The edit correctly identifies and addresses the root cause (missing continuation
contract). The heading level is correct. The positioning is defensible. However:

1. The **negative framing** should be replaced with positive framing (low effort,
   clear improvement)
2. The **standalone invocation case** should be handled conditionally (low effort,
   prevents edge case issues)
3. The **positioning debate** (inside vs outside template) is the key open
   question. My recommendation is to **try the current approach first** (outside
   template with strengthened wording per Option A) and escalate to Option B or C
   only if empirical testing shows the completion heuristic still fires.

The minimal-fix philosophy in the context file is sound. But the specific wording
should be tightened per Option A at minimum.
