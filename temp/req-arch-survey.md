# Vibe Check - Requirements & Architecture Survey

**Date**: 2026-05-02
**Plugin Version**: 0.2.0
**Repo**: /home/idnotbe/projects/vibe-check

---

## SECTION A — Inventory

### Significant Files (Root + One Level Deep)

vibe-check/
  ARCHITECTURE.md           # Architecture design; covers skill spec, testing, migration
  CLAUDE.md                 # Project rules: no CI, English-only, testing/action-plan conventions
  README.md                 # User docs: install steps, usage examples, pattern table
  LICENSE                   # MIT License
  .gitignore                # Git ignore
  on_notification.wav       # Audio asset
  on_stop.wav               # Audio asset

  .claude/
    plugin-dirs
    ccyolo.md
    settings.json
    statusline.sh
    guardian/                # Guardian security rules
    skills/
      vibe-check/
        SKILL.md            # CORE: entire skill implementation (prompt-only)

  .claude-plugin/
    plugin.json             # Plugin manifest (name, version, skills path, metadata)
    marketplace.json        # Marketplace manifest (enables /plugin marketplace add idnotbe/vibe-check)

  tests/
    validate_skill.sh       # Bash validator: 17 structural checks (10 positive + 7 negative)
    test_scenarios.md       # Manual test plan (not yet executed)

  action-plans/
    README.md               # Action-plans convention documentation
    test-infrastructure-roadmap.md  # Prioritized roadmap (status: active)
    _done/                  # (empty; completed plans)
    _ref/                   # (empty; reference/archived plans)

  docs/
    architecture/           # (empty; reserved for split docs)
    requirements/           # (empty; reserved for split docs)

  research/                 # (empty)

---

## SECTION B — SKILL.md Interface (The "API" of This Plugin)

**File**: .claude/skills/vibe-check/SKILL.md (lines 1-192)

### Frontmatter (lines 1-5)

---
name: vibe-check
description: Metacognitive sanity check for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating. Helps prevent tunnel vision, over-engineering, and goal misalignment.
argument-hint: goal: [goal] plan: [plan] (free-form text also works)
---

### Required Input Parameters

| Parameter | Description |
|-----------|-------------|
| goal | What you are trying to accomplish |
| plan | Detailed strategy/approach |

### Optional Input Parameters

| Parameter | Description |
|-----------|-------------|
| progress | Tasks already completed or current stage |
| uncertainties | Concerns or unknowns (comma-separated or multi-line) |
| taskContext | Tech stack, constraints, environment |

### Deprecated/Legacy Parameters

**Line 32**: "Legacy apiProvider and model keys are accepted but ignored."

These keys (v0.1.x) remain for backward compatibility but have no functional effect.

### Output Format (Lines 124-151)

Mandatory sections:
- ## Vibe Check Results
- ### Quick Assessment
- ### Key Questions to Consider (4 numbered)
- ### Pattern Watch
- ### Recommendation
- ### If Adjusting
- ### Next Action (mandatory; never omit)

**Critical**: The closing marker is NOT a stop signal. Turn continues immediately with Next Action step.

### Core Questions (Lines 155-169)

1. Does this plan actually solve what the user asked for?
2. Is there a simpler alternative?
3. What assumptions might be limiting the thinking?
4. How closely does this align with the original intent?

### Continuation Requirement (Lines 109-154)

**Behavioral Mandate**:
- Vibe check output is NOT the end of turn
- Do not stop after output block
- Do not wait for user acknowledgement
- Continue immediately based on Recommendation
- Exception: If no goal/plan, ask user — that IS the next step

**Next Action (Line 150)**: Mandatory. One sentence stating which step resumes immediately after.

### Intervention Level / Response Type Taxonomy (Lines 96-101)

1. **Technical Guidance**: For solid plans needing minor refinement
2. **Gentle Questioning**: For plans heading astray
3. **Stern Redirection**: For plans missing the mark
4. **Validation**: For plans that are actually good

---

## SECTION C — Plugin Manifest

**File**: .claude-plugin/plugin.json (21 lines)

**Components Declared**: One skill at ./.claude/skills/vibe-check

**Metadata**:
- name: "vibe-check"
- version: "0.2.0"
- description: "Metacognitive sanity checks for agent plans..."
- author: { name: "idnotbe", url: "https://github.com/idnotbe" }
- homepage: "https://github.com/idnotbe/vibe-check"
- repository: "https://github.com/idnotbe/vibe-check"
- license: "MIT"
- keywords: ["vibe-check", "metacognition", "sanity-check", "agent-safety"]

### Marketplace Manifest

**File**: .claude-plugin/marketplace.json (15 lines)

Purpose: enables installation via `/plugin marketplace add idnotbe/vibe-check` in Claude Code.

Fields:
- name: "vibe-check"
- description: "Metacognitive sanity checks for agent plans."
- owner.name: "idnotbe"
- plugins: single entry with name "vibe-check", source "./", and a description matching plugin.json's intent.

---

## SECTION D — Validator

**File**: tests/validate_skill.sh (209 lines)

### All Checks Enumerated (17 total: 10 positive + 7 negative)

**Test Group 1: Existence (1 positive)**
- Check 1 (lines 39-46): SKILL.md file exists

**Test Group 2: Frontmatter (3 positive)**
- Check 2 (lines 48-84): Frontmatter delimiters (---) present; tolerates UTF-8 BOM and CRLF
- Check 3 (lines 86-100): Skill name defined correctly as "name: vibe-check"
- Check 4 (lines 102-123): Description field present with non-empty value

**Test Group 3: Parameters (5 positive)**
- Check 5a (lines 128-134): Parameter "goal" documented
- Check 5b: Parameter "plan" documented
- Check 5c: Parameter "progress" documented
- Check 5d: Parameter "uncertainties" documented
- Check 5e: Parameter "taskContext" documented

**Test Group 4: Deprecated Parameters (1 negative)**
- Check 6 (lines 136-143): Deprecated "modelOverride" absent

**Test Group 5: Legacy Feature Absence (7 negative)**
Guards against silent reintroduction of removed apiProvider/model feature.
- Check 7a (lines 161-165): "required_environment:" frontmatter field absent
- Check 7b (lines 167-171): "apiProvider" parameter-table row absent
- Check 7c (lines 173-177): "model" parameter-table row absent
- Check 7d (lines 179-183): Provider-model mapping table header absent
- Check 7e (lines 185-191): OPENAI_API_KEY absent
- Check 7f: GEMINI_API_KEY absent
- Check 7g: ANTHROPIC_API_KEY absent

**Exit Code**: 0 on all 17 pass; 1 on any failure.

---

## SECTION E — User-Facing Docs

### README.md (250 lines)

**Install Steps**:
1. **Method 1**: Copy skills directory with cp -r .claude/skills/
2. **Method 2**: Use .claude-plugin/plugin.json for manifest installation

**Usage Examples**:
- Structured: /vibe-check goal: ... plan: ...
- Natural language: /vibe-check I want to ... but uncertain about ...
- Simple: /vibe-check OAuth2 auth / JWT + Redis

**Key Claims**:
- "Metacognitive sanity checks for agent plans"
- "Use before irreversible actions, when uncertainty high, complexity escalates"
- "Prevents tunnel vision, over-engineering, goal misalignment"
- Research: +27% success improvement, -41% harmful action reduction (Chain-Pattern Interrupts)
- "No runtime dependencies, no external API calls, no API keys required"
- "Prompt-only; Claude itself is the meta-mentor"

### ARCHITECTURE.md (145 lines)

**Headings Map** (Architectural Concerns Covered):
1. Design Philosophy: MCP to Skills Conversion; Claude as Meta-Mentor; Instruction-Based Approach
2. Plugin Structure: Artifact inventory and purposes
3. Skill Specification: YAML Frontmatter (verbatim); 4-Dimension Evaluation; Meta-Mentor Questions; Pattern Watch; Parameters
4. Implementation Notes: Claude as Meta-Mentor; Advantages (no API calls); Limitations (single-model)
5. Testing Architecture: Structural Validation; Validator checks; Test files
6. Migration Path: For MCP users; Key differences post-migration
7. Version Considerations: Plugin 0.2.0; MCP reference; Agent Skills standard

---

## SECTION F — CLAUDE.md Project Rules

**File**: CLAUDE.md (83 lines)

### Concrete Project Rules

**Language & Content**:
- All committed content must be in English.

**No Runtime Dependencies**:
- Plugin is prompt-only; nothing executes.
- Makes no outbound API calls.
- Requires no environment variables.

**Testing**:
- Only runnable test: bash tests/validate_skill.sh
- 17 structural checks; exit code 0 on success, 1 on failure.
- Always run validator after editing SKILL.md.
- If adding/removing parameters, update validate_skill.sh.
- If changing SKILL.md frontmatter, update ARCHITECTURE.md verbatim block.

**Stability Mandate**:
- Keep SKILL.md stable — it is the "API" of this plugin.
- Preserve Output Format section and Core Questions.

**Tooling**:
- Do not add Node.js tooling unless clear, committed need.

**Action Plans Convention**:
- Root .md files = active plans (not-started | active | blocked)
- _done/ = completed plans (move when status: done)
- _ref/ = reference/historical documents
- All files must have YAML frontmatter with status and progress.

**No CI**:
- No CI/CD pipeline.
- See action-plans/test-infrastructure-roadmap.md P0 for GitHub Actions recommendation.

---

## SECTION G — Action Plans Summary

### Active Plans (Root)

**File**: action-plans/test-infrastructure-roadmap.md
**Frontmatter**: status: active
**Topic**: Prioritized roadmap for test infrastructure; CI setup, dead test removal, docs, validator improvements.

**Progress** (translated from Korean): "P0 done (CI excluded); P1.1 resolved (apiProvider/model removed, v0.2.0); P1.2 obsolete; P1.3 scope reduced; P2 partially done."

**Priorities**:
- P0.1: Add CI for validate_skill.sh (not started)
- P0.2: Resolve dead TypeScript test (DONE — deleted)
- P0.3: Add testing documentation (DONE)
- P1.1: Fix README vs SKILL.md mismatch (RESOLVED v0.2.0)
- P1.2: Eliminate provider/model duplication (OBSOLETE; feature removed)
- P1.3: Execute manual test scenarios (SCOPE REDUCED)
- P2.1: Add testing to ARCHITECTURE.md (DONE)
- P2.2: Tighten grep checks (not started)
- P2.3: Add plugin.json validation (not started)
- P2.4: Create single test entrypoint (not started)

### Done Plans

Directory: action-plans/_done/ — currently empty.

### Reference Plans

Directory: action-plans/_ref/ — currently empty.

### Action Plans Convention (from action-plans/README.md)

- Root .md = active plans
- _done/ = completed (must move when status: done)
- _ref/ = reference/historical
- All must have YAML frontmatter with status and progress
- When all steps marked [v], move to _done/ (required)

---

## SECTION H — Removed v0.1 Features (Negative Space)

### Feature Removed in v0.2.0: apiProvider / model System

**Removed Tokens/Keys** (guarded by validator Test 5):

1. Frontmatter Field: required_environment: (Test 7a)
2. Parameter Rows: apiProvider and model (Tests 7b, 7c)
3. Table Header: | Provider | Models | Environment Variable | (Test 7d)
4. API Key Env Vars: OPENAI_API_KEY, GEMINI_API_KEY, ANTHROPIC_API_KEY (Tests 7e-7g)

**Why Removed**:

CLAUDE.md (lines 24-30): v0.1.x required external API keys and selected model provider. This introduced complexity, API cost, and misalignment with "no dependencies" promise.

Rationale: Skills version uses Claude itself as meta-mentor. External model calls unnecessary; replaced by Claude's own analysis.

**Backward Compatibility**: Legacy keys in invocations accepted but ignored (SKILL.md, line 32).

**Validator Guards**: Test 5 (7 negative checks) guards against silent reintroduction. Anchors to specific locations prevent false positives.

---

## SECTION I — Surface Area for Outbound Effects

### Claim: No Outbound API Calls, No Env Vars, No Compiled Assets, No Runtime Dependencies

**Verification**:

1. **No Outbound API Calls**:
   - CLAUDE.md (line 25): "makes no outbound API calls"
   - README.md (line 82): "makes no network requests"
   - ARCHITECTURE.md (line 51): Same claim.
   - Evidence: SKILL.md pure prompt; no HTTP, sockets, external invocations.

2. **No Environment Variables**:
   - CLAUDE.md (line 25): "requires no environment variables"
   - README.md (line 84): "do not need to configure any API keys"
   - Evidence: Validator Test 7a guards required_environment. No env reads in SKILL.md.

3. **No Compiled Assets**:
   - CLAUDE.md (line 25): "no compiled assets — entire plugin is structured SKILL.md"
   - README.md (line 10): "prompt-only plugin with no runtime code"
   - Evidence: .claude/skills/vibe-check/ contains only SKILL.md (no .ts, .js, .py, binaries).

4. **No Runtime Dependencies**:
   - CLAUDE.md (lines 24-25): "no runtime dependencies; plugin is prompt-only"
   - README.md (line 11): "no external process, no compiled code"
   - Evidence: No package.json, requirements.txt, Gemfile, go.mod in root or plugin artifact.

### Negative Space Confirmation

- No Node.js scaffolding: No package.json, node_modules, tsconfig.json.
- No CI/CD: CLAUDE.md (line 78): "There is no CI/CD pipeline."
- No database, CLI, service: Plugin is prompt-only; SKILL.md is entire artifact.

---

## SECTION J — Summary Statistics

| Metric | Value |
|--------|-------|
| Total Validator Checks | 17 (10 positive + 7 negative) |
| Plugin Version | 0.2.0 |
| Skill Name | vibe-check |
| Required Parameters | 2 |
| Optional Parameters | 3 |
| Deprecated Parameters | 2 (apiProvider, model) |
| Meta-Mentor Questions | 4 |
| Response Type Categories | 4 |
| Pattern Watch Categories | 5 |
| Active Action Plans | 1 |
| Manual Test Plans (unexecuted) | 1 |
| CI/CD Present | No |

---

## SECTION K — File References (Absolute Paths)

- **SKILL.md (Core Artifact)**: /home/idnotbe/projects/vibe-check/.claude/skills/vibe-check/SKILL.md
- **Plugin Manifest**: /home/idnotbe/projects/vibe-check/.claude-plugin/plugin.json
- **Validator**: /home/idnotbe/projects/vibe-check/tests/validate_skill.sh
- **CLAUDE.md**: /home/idnotbe/projects/vibe-check/CLAUDE.md
- **ARCHITECTURE.md**: /home/idnotbe/projects/vibe-check/ARCHITECTURE.md
- **README.md**: /home/idnotbe/projects/vibe-check/README.md
- **Action Plans Root**: /home/idnotbe/projects/vibe-check/action-plans/

---

**End of Survey — Generated 2026-05-02**
