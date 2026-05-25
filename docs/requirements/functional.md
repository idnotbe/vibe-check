# Vibe Check — Functional Requirements

This document enumerates the functional behaviors the `vibe-check` skill MUST exhibit. Each requirement has a stable ID, a normative statement, a rationale, and a "Verified by" line pointing at the validator check (in `tests/validate_skill.sh`) and/or the relevant line range of `.claude/skills/vibe-check/SKILL.md`. Requirements trace back to the high-level IDs in `overview.md`.

The plugin is prompt-only. "MUST" therefore means the prompt instructs Claude to behave this way and the validator (where applicable) protects the documented contract.

---

## 1. Input Parameters

The skill accepts input either as a structured block of `key: value` lines or as natural language; in either case the prompt instructs Claude to extract the parameters below (SKILL.md:13-54).

**REQ-FN-INPUT-001**
The skill MUST document and accept a required `goal` parameter describing what the user is trying to accomplish.
- Rationale: Without an explicit goal, no alignment check is possible.
- Verified by: Check 5a (`validate_skill.sh` lines 128-134); SKILL.md:19-22.

**REQ-FN-INPUT-002**
The skill MUST document and accept a required `plan` parameter describing the strategy/approach.
- Rationale: The plan is the artifact under review.
- Verified by: Check 5b; SKILL.md:19-22.

**REQ-FN-INPUT-003**
The skill MUST document and accept an optional `progress` parameter (tasks already completed or current stage).
- Rationale: Lets the meta-mentor distinguish "before starting" from "course correction mid-flight".
- Verified by: Check 5c; SKILL.md:24-30.

**REQ-FN-INPUT-004**
The skill MUST document and accept an optional `uncertainties` parameter (comma-separated or multi-line free text).
- Rationale: Surfaces user-known unknowns to focus the diagnosis.
- Verified by: Check 5d; SKILL.md:24-30.

**REQ-FN-INPUT-005**
The skill MUST document and accept an optional `taskContext` parameter (tech stack, constraints, environment).
- Rationale: Many pattern diagnoses (e.g., Overtooling) depend on environmental fit.
- Verified by: Check 5e; SKILL.md:24-30.

**REQ-FN-INPUT-006**
The skill MUST accept input in three forms: a structured `key: value` block, a natural-language sentence, and a minimal "goal / plan" slash-separated form.
- Rationale: Lowers the friction of invoking the skill mid-flow; the prompt explicitly instructs Claude to infer parameters from natural language (SKILL.md:64).
- Verified by: SKILL.md:34-54 (Input Format Examples) and SKILL.md:62-64 (parsing instruction). No validator check.

**REQ-FN-INPUT-007**
The skill MUST surface arguments via the `$ARGUMENTS` placeholder so that any invocation form is parsed by the same prompt path.
- Rationale: Single parsing surface keeps the contract minimal.
- Verified by: SKILL.md:62.

---

## 2. Output Structure

The prompt mandates a fixed-shape output block (SKILL.md:124-151). Every section listed below is mandatory.

**REQ-FN-OUTPUT-001 — Output Block Header**
The output MUST begin with the heading `## Vibe Check Results`.
- Rationale: Stable anchor for downstream parsing and for the user to recognize the skill's output.
- Verified by: SKILL.md:129.

**REQ-FN-OUTPUT-002 — Quick Assessment**
The output MUST contain a `### Quick Assessment` section: one sentence stating whether the plan is on track, slightly off, or needs major revision.
- Rationale: Gives a single-line verdict before details.
- Verified by: SKILL.md:131-132.

**REQ-FN-OUTPUT-003 — Key Questions to Consider**
The output MUST contain a `### Key Questions to Consider` section with exactly four numbered questions; the fourth MUST address alignment with the original intent.
- Rationale: Forces breadth (four angles) and explicitly preserves the alignment check.
- Verified by: SKILL.md:134-138.

**REQ-FN-OUTPUT-004 — Pattern Watch**
The output MUST contain a `### Pattern Watch` section naming any of the five pitfall patterns that apply (or stating none apply).
- Rationale: Connects the diagnosis back to the named taxonomy.
- Verified by: SKILL.md:140-141; pattern list at SKILL.md:87-91.

**REQ-FN-OUTPUT-005 — Recommendation (one of three forms)**
The output MUST contain a `### Recommendation` section whose value is one of:
1. `Proceed as planned`
2. `Proceed with adjustments: <what to change>`
3. `Pause and rethink: <what's unclear>`
- Rationale: Constrains the recommendation surface to three known continuation paths.
- Verified by: SKILL.md:143-144.

**REQ-FN-OUTPUT-REC — Recommendation as continuation directive**
The Recommendation MUST be phrased as a continuation directive and MUST NEVER be phrased as a stop instruction.
- Rationale: The output block is consumed in-turn by the agent; a stop-phrased recommendation would defeat the skill's purpose.
- Verified by: SKILL.md:144 ("Always phrased as a continuation directive, never as a stop instruction.").

**REQ-FN-OUTPUT-006 — If Adjusting**
The output MUST contain an `### If Adjusting` section; it is "Optional" in the sense that it may be empty when no adjustment is needed, but the heading itself is part of the schema.
- Rationale: Keeps a stable slot for concrete adjustment suggestions.
- Verified by: SKILL.md:146-147.

**REQ-FN-OUTPUT-007 — Next Action (mandatory)**
The output MUST contain a `### Next Action` section: one sentence naming the step the agent will resume immediately after the block. This section MUST NEVER be omitted.
- Rationale: Names the concrete continuation, eliminating ambiguity about what happens after the block.
- Verified by: SKILL.md:149-150 ("This is mandatory — never omit it.").

**REQ-FN-OUTPUT-008 — Closing fence is not a stop signal**
The closing code fence of the output block MUST NOT be treated as the end of the turn. The prompt explicitly states that stopping after `### Next Action` constitutes a failure of the skill.
- Rationale: Prevents the model from confusing the output schema's terminator with a control-flow stop.
- Verified by: SKILL.md:153.

---

## 3. Behavioral Mandate (Continuation)

The "Continuation Requirement" section of `SKILL.md` (lines 109-153) is the load-bearing behavioral contract.

**REQ-FN-CONT-001 — In-turn consumption**
After emitting the output block, the agent MUST consume it as internal feedback within the same turn rather than treating it as a deliverable to return to the user.
- Rationale: SKILL.md:74 frames the output as "metacognitive scaffolding for the *ongoing* task — not a standalone deliverable".
- Verified by: SKILL.md:74, SKILL.md:111.

**REQ-FN-CONT-002 — No stopping**
After the block, the agent MUST NOT stop, MUST NOT wait for user acknowledgement, and MUST NOT ask "should I proceed?".
- Rationale: The Recommendation already answers that question.
- Verified by: SKILL.md:115-116.

**REQ-FN-CONT-003 — Recommendation-driven continuation**
The agent MUST translate the Recommendation into a concrete next step in the same turn:
- `Proceed as planned` → execute the next step of the original plan.
- `Proceed with adjustments` → apply the adjustments, then execute the next step.
- `Pause and rethink` → restate the revised understanding and take a concrete next step (clarifying tool call or single targeted question), not silence.
- Rationale: Ties each Recommendation form to an observable continuation action.
- Verified by: SKILL.md:117-120.

**REQ-FN-CONT-004 — Next Action realized**
The step named in `### Next Action` MUST be realized as the actual tool call, file edit, or targeted question — not as a narration of what the agent is about to do.
- Rationale: Prevents "I will now do X" stalls.
- Verified by: SKILL.md:153.

**REQ-FN-CONT-MISSING — Special case: missing goal/plan**
If neither `goal` nor `plan` was provided, the agent MUST set the Next Action to a clarifying question asking the user for what they are trying to accomplish, their current approach, and any concerns. This question IS the next step.
- Rationale: Without inputs the meta-mentor has nothing to evaluate; the only valid continuation is to obtain them.
- Verified by: SKILL.md:122 (Continuation exception); SKILL.md:181-185 (Special Cases).

---

## 4. Evaluation Framework

The skill mandates a four-dimension analysis (SKILL.md:76-107).

**REQ-FN-EVAL-001 — Four dimensions of analysis**
The meta-mentor MUST analyze the plan across four named dimensions:
1. Situational Analysis — true nature of the problem, fit of approach, prior context.
2. Diagnostic Assessment — pattern recognition, assumption check, intervention level.
3. Response Type Selection — choice of tone.
4. Course Correction — reminders, alternatives, refocusing questions.
- Rationale: A named multi-dimensional checklist resists tunnel vision in the meta-mentor itself.
- Verified by: SKILL.md:78-107.

**REQ-FN-EVAL-PATTERNS — Pattern Watch categories**
The diagnosis MUST consider these five pitfall patterns by name:
- Complex Solution Bias — choosing unnecessarily complex solutions.
- Feature Creep — adding unrequested functionality.
- Premature Implementation — coding before understanding.
- Misalignment — drifting from the user's actual intent.
- Overtooling — using too many tools/libraries.
- Rationale: The named taxonomy is the vocabulary that the Pattern Watch output section uses (REQ-FN-OUTPUT-004).
- Verified by: SKILL.md:87-91.

**REQ-FN-EVAL-LEVELS — Intervention levels / response types**
The meta-mentor MUST select exactly one tone from this set, based on the diagnosis:
- Technical Guidance — for solid plans needing minor refinement.
- Gentle Questioning — for plans that might be heading astray.
- Stern Redirection — for plans clearly missing the mark.
- Validation — for plans that are actually good.
- Rationale: Calibrates feedback intensity to severity; prevents both flattery and alarmism.
- Verified by: SKILL.md:96-101.

**REQ-FN-EVAL-COURSE — Course correction outputs**
When the diagnosis indicates a problem, the response MUST offer at least one of: a best-practice reminder, a simpler alternative, or a refocusing question.
- Rationale: The skill is course-correcting, not merely diagnostic.
- Verified by: SKILL.md:103-107.

---

## 5. Core Questions

**REQ-FN-CORE-Q**
Every vibe check MUST be informed by these four meta-questions:
1. Does this plan actually solve what the user asked for? (explicit request, not inferred desire)
2. Is there a simpler alternative? (less complexity, fewer steps, existing solutions)
3. What assumptions might be limiting the thinking? (technical, scope, capability)
4. How closely does this align with the original intent? (drift detection)
- Rationale: These are the goal-alignment, simplicity, assumption-surfacing, and drift-detection lenses that the entire skill is built around. CLAUDE.md elevates them to API stability requirements.
- Verified by: SKILL.md:155-169.

---

## 6. Tone & Special Cases

**REQ-FN-TONE-001 — Tone guidelines**
Feedback MUST be direct but not harsh, validate what works before critiquing, focus on the plan rather than the planner, offer alternatives rather than only criticism, and clearly state when the plan is good.
- Rationale: Keeps the meta-mentor useful instead of demoralizing or sycophantic.
- Verified by: SKILL.md:171-177.

**REQ-FN-SPECIAL-001 — Solid plan path**
If the plan looks solid, the meta-mentor MUST NOT invent problems; it MUST acknowledge the plan, set Recommendation to "Proceed as planned", and continue execution in the same turn.
- Rationale: Closes the false-positive loophole.
- Verified by: SKILL.md:187-188.

**REQ-FN-SPECIAL-002 — High-uncertainty path**
If uncertainty is genuinely high, the meta-mentor MUST acknowledge it and suggest ways to reduce it before proceeding.
- Rationale: Prevents committing to a plan whose risks are not yet legible.
- Verified by: SKILL.md:190-191.

---

## 7. Backward Compatibility

**REQ-FN-COMPAT-001 — Legacy keys silently accepted**
The skill MUST silently accept the legacy `apiProvider` and `model` keys in the input without raising an error.
- Rationale: Old invocations from v0.1.x must not break.
- Verified by: SKILL.md:32 ("Legacy `apiProvider` and `model` keys are accepted but ignored.").

**REQ-FN-COMPAT-002 — Legacy keys trigger no behavior**
The legacy keys MUST trigger no behavior: no provider selection, no model override, no environment-variable read, no outbound call.
- Rationale: The v0.1 multi-model orchestration feature was removed in v0.2.0 and replaced by Claude itself acting as the meta-mentor.
- Verified by: SKILL.md:32; reinforced by Test Group 5 negative checks (Checks 7a-7g) which forbid the keys' surface from re-entering `SKILL.md`. See `non-functional-and-constraints.md` (REQ-NF-FORBID-*) for the full forbidden-token list.

---

## 8. Skill Identity

**REQ-FN-IDENTITY-001 — Skill name**
The frontmatter MUST declare `name: vibe-check`.
- Verified by: Check 3 (`validate_skill.sh` lines 86-100); SKILL.md:2.

**REQ-FN-IDENTITY-002 — Description present**
The frontmatter MUST contain a non-empty `description` field.
- Verified by: Check 4 (`validate_skill.sh` lines 102-123); SKILL.md:3.

**REQ-FN-IDENTITY-003 — Frontmatter delimiters**
`SKILL.md` MUST open and close its YAML frontmatter with `---` delimiters and MUST tolerate UTF-8 BOM and CRLF line endings on read.
- Rationale: Cross-platform editors should not break the skill.
- Verified by: Check 2 (`validate_skill.sh` lines 48-84); SKILL.md:1, SKILL.md:5.

**REQ-FN-IDENTITY-004 — Argument hint**
The frontmatter SHOULD declare an `argument-hint` indicating that both structured and free-form input are accepted.
- Verified by: SKILL.md:4.
