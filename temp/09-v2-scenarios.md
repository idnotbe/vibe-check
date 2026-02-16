# V2 UX and Scenario Review

## Summary

**Overall grade: 7 FULLY SERVED / 1 PARTIALLY SERVED / 0 NOT SERVED**

The V1 fixes successfully upgraded Scenario 4 (MCP Migration) from PARTIALLY
SERVED to FULLY SERVED. Scenario 6 (Contributing) remains PARTIALLY SERVED
due to friction points that require implementation-file changes (dead TypeScript
test, Korean test files, no CI), which are outside the scope of documentation-only
fixes.

Compared to V1 (6 FULLY / 2 PARTIALLY), this is a net improvement of +1 scenario
upgraded to FULLY SERVED.

### V1 Fix Verification

| Fix | V1 Issue | Status | Verification |
|-----|----------|--------|--------------|
| P1 | Migration steps only in ARCHITECTURE.md | VERIFIED | README now has "Migrating from MCP Version" section (line 29-31) with cross-reference to ARCHITECTURE.md |
| P4 | "Phantom configuration" not in Troubleshooting | VERIFIED | README Troubleshooting has "Output looks the same with and without apiProvider/model" entry (lines 255-256) |
| P5 | No parameter mapping for MCP migrators | VERIFIED | README migration section states "Parameter names for goal, plan, apiProvider, model, progress, uncertainties, and taskContext are the same in both versions" (line 31) |

All three V1 UX fixes are confirmed present in the current documentation.

---

## Per-Scenario Results

### Scenario 1: First Discovery and Installation

- **Grade: FULLY SERVED** (unchanged from V1)

**Persona walkthrough (P1: Newcomer):**

1. Developer lands on README. The opening sentence is clear: "Metacognitive
   sanity checks for agent plans." Immediately understood.
2. Overview section explains what it is (prompt-only), what it is not (no
   external process, no API calls), and its relationship to the MCP version.
3. Two installation methods documented: Method 1 (copy skills directory) and
   Method 2 (plugin manifest).
4. Directory structure shown so the newcomer understands repo layout.
5. "Important: No External API Calls" section proactively addresses the trust
   question before the newcomer encounters the API provider section.
6. Footnote [^1] on comparison table addresses "Dependencies: None" vs
   `required_environment` contradiction.

**Remaining minor issues:**
- Method 2 (Plugin Manifest) defers to "your Claude Code documentation" for
  actual installation steps. This is honest given that plugin manifest
  installation is platform-dependent, but a newcomer who tries this path gets
  no actionable instructions.
- No single "quick start" walkthrough showing input AND expected output together
  in one continuous example. The Input Formats and Output Format sections are
  separate; a newcomer must mentally stitch them together.

**Verdict:** All critical newcomer questions are answered. The remaining issues
are polish, not blockers.

---

### Scenario 2: Basic Daily Usage

- **Grade: FULLY SERVED** (unchanged from V1)

**Persona walkthrough (P2: Daily User):**

1. User knows the plugin exists. Goes to Usage section. Finds a concrete
   `/vibe-check` example with natural language input immediately.
2. Input Parameters table clearly marks 7 parameters as Required/Optional.
3. Three input formats documented with English examples (structured, natural
   language, simple shorthand).
4. Full output format template with all 5 sections shown.
5. Pattern Watch table connects patterns to signs and remedies.
6. "When to Use" section gives clear trigger points.

**Remaining minor issues:**
- Language Note ("The skill responds in the language you use for input") is
  placed far from the Usage section. A daily user scanning Usage might not
  scroll down to discover this.
- Output format template uses placeholders, not a filled-in example. A user
  who has never seen the output cannot fully predict what real feedback
  looks like. However, the template is clear enough to set expectations.

**Verdict:** A daily user can find usage examples, understand input formats,
know what output to expect, and locate parameter reference without difficulty.

---

### Scenario 3: API Provider and Model Configuration

- **Grade: FULLY SERVED** (unchanged from V1)

**Persona walkthrough (P3: Power User):**

1. User sees the dedicated "API Provider and Model Parameters" section with
   a clear heading.
2. The critical clarification is prominent: "These parameters do not trigger
   external API calls." Repeated in How It Works subsection and the "Important:
   No External API Calls" section.
3. Supported providers/models shown in a clean table with environment variables.
4. Validation rules documented: both params required together, model must match
   provider, API key must be configured.
5. Configuration example with `~/.claude/settings.json` JSON snippet provided.
6. Concrete usage example with `apiProvider: openai model: codex-5.2-high`.
7. "Limitations Compared to MCP Version" section explicitly states Claude
   simulates model awareness rather than making real calls.

**Remaining minor issues:**
- What happens when validation fails is still somewhat vague. The Troubleshooting
  section says to check provider/model pairing and API key, but does not describe
  the actual error message or behavior (does the skill refuse to run, warn, or
  fall back to defaults?). This is only partially resolvable without
  implementation testing.
- The relationship between `required_environment` in SKILL.md frontmatter
  (which declares keys as "required") and the README (which says they are
  "metadata") remains architecturally confusing for a power user inspecting
  both files. Documentation cannot fully resolve this without implementation
  changes.

**Verdict:** A power user can understand what apiProvider/model does, configure
it correctly, and is not misled about external API calls. The validation failure
behavior gap is minor.

---

### Scenario 4: MCP-to-Skills Migration

- **Grade: FULLY SERVED** (upgraded from PARTIALLY SERVED in V1)

**V1 issue resolution:**
The V1 review found migration steps only in ARCHITECTURE.md, with no README
coverage. Three fixes were applied:
1. README now has a "Migrating from MCP Version" section (line 29-31) with a
   cross-reference to ARCHITECTURE.md for step-by-step instructions.
2. A parameter mapping note states that parameter names are the same in both
   versions.
3. The "Phantom configuration" troubleshooting entry manages post-migration
   expectations.

**Persona walkthrough (P4: MCP Migrator):**

1. Migrator reads README. Comparison table clearly contrasts MCP Server vs
   Agent Skills across 5 dimensions including the new "Multi-model feedback"
   row.
2. "Limitations Compared to MCP Version" section is honest: real multi-model
   feedback is lost, Claude simulates model awareness.
3. "Migrating from MCP Version" section provides a clear entry point with
   cross-reference: "For step-by-step migration instructions, see
   ARCHITECTURE.md - Migration Path."
4. Key steps summarized in README: remove MCP config, copy skills directory,
   use `/vibe-check` instead of MCP tool invocation.
5. Parameter mapping confirmed: "Parameter names for goal, plan, apiProvider,
   model, progress, uncertainties, and taskContext are the same in both versions."
6. Following the ARCHITECTURE.md link, the migrator finds 3 clear steps and
   "key differences after migration" list.

**Remaining minor issues (acknowledged, not blocking):**
- The instruction "Remove MCP server configuration from your project" in
  ARCHITECTURE.md is somewhat vague -- it does not specify the exact file path
  or JSON block to remove. A migrator unfamiliar with MCP configuration
  locations might struggle. However, any user who previously configured an MCP
  server should know where their MCP config lives.
- No guidance on what happens if both MCP server and Skills plugin are installed
  simultaneously (potential tool naming conflict). This is an edge case that
  could be addressed in Troubleshooting.
- No explicit guidance to migrate API keys from MCP configuration to
  `~/.claude/settings.json`. The Configuration section documents the target
  location, but does not frame it as a migration step.

**Rationale for upgrade to FULLY SERVED:**
The V1 core issue was that a migrator reading only README found no migration
steps at all. Now README has a dedicated migration section with actionable
summary and cross-reference. The remaining issues are operational details
(exact config file paths, simultaneous installation) that affect edge cases,
not the primary migration journey. A migrator following README can understand
the trade-offs, find the steps, and complete the migration.

---

### Scenario 5: Troubleshooting

- **Grade: FULLY SERVED** (unchanged from V1)

**Persona walkthrough (all personas):**

1. Troubleshooting section in README covers 6 common issues:
   - Skill not appearing after installation
   - Claude asks for API keys / environment variables
   - Unexpected validation errors with apiProvider/model
   - Output not in expected language
   - Output looks the same with and without apiProvider/model (NEW in V1 fix)
   - npm test / npx jest fails
2. Each issue has clear resolution steps.
3. Language Note section addresses language behavior question.
4. Dead test file confusion is proactively addressed.

**V1 fix verification:**
The "Phantom configuration" entry (P4) is now in Troubleshooting (README line
255-256): "Output looks the same with and without apiProvider/model" with
explanation that this is expected behavior. This was the only Troubleshooting
gap identified in V1.

**Remaining minor issues:**
- Error recovery for validation failures is still vague (what specific error
  message does the user see?). The section tells users what to check but not
  what error to expect. This is resolvable only by testing actual behavior.
- No troubleshooting for simultaneous MCP + Skills installation (potential
  duplicate tool conflict).

**Verdict:** The troubleshooting section covers the most common failure modes
including the newly added phantom configuration case. Remaining gaps are
edge cases.

---

### Scenario 6: Contributing and Development

- **Grade: PARTIALLY SERVED** (unchanged from V1)

**Persona walkthrough (P5: Contributor):**

1. Contributor reads README Contributing section. Getting Started (4 steps),
   Guidelines (6 bullet points), "What Needs Help" (3 items) are all present.
2. ARCHITECTURE.md is now fully in English -- the critical Gap 6.1 is resolved.
3. CLAUDE.md has comprehensive development guidelines.
4. TEST-PLAN.md provides detailed test infrastructure roadmap.
5. Dead test file is prominently called out in README (bold "Dead code" in
   test table, addressed in Troubleshooting, mentioned in "What Needs Help").
6. Contributor runs `bash tests/validate_skill.sh` -- passes 28/28.

**Blocking friction points (require implementation changes):**

1. **Dead TypeScript test file (`tests/api_provider.test.ts`)**: Still present.
   A contributor sees a `.ts` test file, instinctively looks for `package.json`
   to run `npm install` / `npm test`, finds nothing, and wastes time. The
   documentation warns about this in three places (README Troubleshooting,
   README test table, CLAUDE.md), but the file itself remains a trap. Deletion
   is recommended (TEST-PLAN.md P0.2) but has not been executed.

2. **Korean test_scenarios.md**: A contributor wanting to run manual tests
   cannot follow the Korean test plan. README mentions this in "What Needs Help"
   but the file remains untranslated.

3. **No CI**: Contributors must manually run `bash tests/validate_skill.sh`.
   There is no automated safety net on PRs. TEST-PLAN.md P0.1 recommends
   adding a GitHub Actions workflow, but this has not been implemented.

4. **SKILL.md bilingual content**: A contributor modifying SKILL.md encounters
   Korean parameter descriptions and input format examples. The English
   documentation (ARCHITECTURE.md, README) explains these, but a contributor
   working directly in SKILL.md needs to understand both languages or rely
   entirely on the structural validator to catch regressions.

**Why this remains PARTIALLY SERVED:**
The documentation improvements are significant (English ARCHITECTURE.md, clear
Contributing section, honest "What Needs Help" list). But a "Fully Served"
contributor scenario requires the ability to clone, understand, test, and
contribute without hitting dead ends. The dead TypeScript test, Korean-only
manual test plan, and lack of CI are environmental friction points that
documentation alone cannot resolve. These require implementation changes
(file deletion, translation, CI setup) that were explicitly out of scope for
the documentation pass.

---

### Scenario 7: Security Audit

- **Grade: FULLY SERVED** (unchanged from V1)

**Persona walkthrough (P7: Security-Conscious Developer):**

1. Auditor reads README. Sees "Dependencies: None" in comparison table.
2. Follows footnote [^1] which explains `required_environment` is metadata.
3. Reaches "Important: No External API Calls" section: "contains no executable
   code, makes no network requests, and does not use your API keys at runtime."
4. Reads: "`required_environment` declaration in SKILL.md frontmatter exists as
   metadata for the apiProvider/model feature documentation."
5. Finds: "You do not need to configure any API keys for basic /vibe-check
   usage."
6. Can verify by inspecting SKILL.md directly: no code execution, only prompt
   instructions.

**Remaining minor issues:**
- No formal security posture statement (e.g., "This plugin has no file system
  access, no network access, no code execution" in a concise summary).
- The `required_environment` field name itself is inherently alarming -- the
  word "required" implies necessity. Documentation explains this away, but a
  quick scanner might still be concerned. This is a limitation of the SKILL.md
  metadata format.

**Verdict:** A security auditor reading README alone can understand why keys are
declared, verify no network calls occur, and trust the plugin enough to install.

---

### Scenario 8: Plugin Update

- **Grade: FULLY SERVED** (unchanged from V1)

**Persona walkthrough (P2: Daily User updating):**

1. User checks README for update instructions.
2. Finds dedicated "Updating" section (line 309-310).
3. Clear instruction: re-copy `.claude/skills/vibe-check/` directory.
4. Explicitly states: "The plugin has no local state or configuration to
   preserve."
5. Notes API key configuration lives in `~/.claude/settings.json` (separate
   from plugin).
6. Version shown at top of README (v0.1.0) and in plugin.json.

**Remaining minor issues:**
- No changelog. Users cannot see what changed between versions without reading
  git history. For v0.1.0 this is acceptable.
- No release tags or GitHub Releases.

**Verdict:** A user can find version information and update instructions without
difficulty.

---

## Cross-Scenario Issues

### 1. Validation failure behavior remains vague (affects Scenarios 3, 5)
What specific error the user sees when `apiProvider`/`model` validation fails
is not documented anywhere. SKILL.md defines validation rules in Korean, and
documentation describes what the rules are, but not the user-facing error
experience. This would require testing actual behavior or implementation changes.

### 2. Dead code and Korean test files remain (affects Scenario 6)
These are acknowledged as implementation-file issues that were out of scope for
the documentation pass. They are well-documented as known issues in three
places each.

### 3. No filled-in output example (affects Scenarios 1, 2)
The output format template uses placeholders. A single concrete example showing
real input mapped to real output would improve the newcomer and daily user
experience. This was deprioritized in V1 (P3 fix, labeled low priority).

### 4. Simultaneous MCP + Skills installation (affects Scenarios 4, 5)
No documentation addresses what happens if both the MCP server and Skills
plugin are installed at the same time. Potential tool naming conflict could
cause confusing behavior. Gemini external review flagged this as a risk.

### 5. MCP removal specificity (affects Scenario 4)
The "Remove MCP server configuration" instruction does not specify the exact
file path or JSON block to modify. Gemini external review noted this could
leave migrators with duplicate tool definitions.

---

## Remaining Issues Prioritized

| Priority | Issue | Affected Scenarios | Fix Type |
|----------|-------|-------------------|----------|
| Medium | Simultaneous MCP + Skills conflict not addressed | 4, 5 | Documentation (Troubleshooting entry) |
| Medium | MCP removal step lacks specificity (which file to edit) | 4 | Documentation (ARCHITECTURE.md migration step 1) |
| Low | No filled-in output example | 1, 2 | Documentation (README Usage section) |
| Low | Validation failure error messages undocumented | 3, 5 | Requires implementation testing |
| -- | Dead TypeScript test file | 6 | Implementation (delete file) |
| -- | Korean test_scenarios.md | 6 | Implementation (translate) |
| -- | No CI pipeline | 6 | Implementation (GitHub Actions) |

---

## Self-Critique

### What I might have over-rated

1. **Scenario 4 upgrade rationale.** I upgraded MCP Migration to FULLY SERVED
   because the primary blocker (no migration steps in README) was resolved. But
   Gemini's critique raises valid operational friction: the "remove MCP config"
   instruction is vague, and there is no guidance on duplicate tool conflicts.
   I judged these as edge cases rather than blockers because a user who
   previously configured an MCP server should know where their config lives.
   This judgment could be too generous -- a less experienced migrator might
   struggle.

2. **Scenario 1 and 2 readiness.** I rated these FULLY SERVED despite the
   absence of a filled-in output example. The template with placeholders is
   functional, but a newcomer who has never seen vibe-check output has no
   concrete expectations. This is a UX gap, not a documentation gap per se.

### What I might have under-explored

1. **README length and navigability.** The README is now comprehensive (~320
   lines). I did not evaluate whether the heading structure supports easy
   navigation via GitHub's auto-generated table of contents. For a document
   this long, cognitive load on casual browsers could be an issue.

2. **Cross-document link integrity.** I verified that README cross-references
   ARCHITECTURE.md for migration steps, but did not verify that the anchor
   link `ARCHITECTURE.md#migration-path` resolves correctly on GitHub (heading
   anchors depend on exact heading text and GitHub's slug generation).

3. **SKILL.md Korean content impact on real output.** The Language Note says
   "the skill responds in the language you use for input," but this is a claim
   about Claude's behavior, not a tested guarantee. A user providing English
   input might still receive Korean-inflected output due to the Korean
   instructions in SKILL.md. Testing this would require actual skill invocation.

### Assumptions

- I assumed the V1 fixes described in `temp/06-v1-fixes.md` are accurately
  reflected in the current README.md. I verified all three UX fixes (P1, P4,
  P5) by reading the current README and confirming the relevant sections exist.

- I assumed a migrator who previously configured an MCP server has sufficient
  familiarity with MCP configuration to know where to remove it, making the
  vague "remove MCP config" instruction acceptable. Gemini's critique
  challenges this assumption.

---

## External Validation

### Validator Confirmation
`bash tests/validate_skill.sh` passes 28/28 checks, confirming SKILL.md was
not modified during the documentation update process.

### Gemini (gemini-3-pro-preview) Assessment -- Scenario 4

Gemini assessed whether Scenario 4 should be upgraded to FULLY SERVED and
provided a nuanced "MOSTLY SERVED" verdict. Key feedback:

**Blind spots identified:**
1. **"How-to-Remove" blind spot**: The instruction "Remove MCP server
   configuration" is too vague. Users may not know which file to edit,
   and incomplete removal could cause duplicate tool definitions.
2. **API key migration gap**: No explicit instruction to move API keys from
   MCP configuration to `~/.claude/settings.json`.
3. **Korean argument-hint in SKILL.md frontmatter**: A migrator from the
   English MCP server might see Korean text and think the plugin is broken.

**Recommendations:**
- Expand ARCHITECTURE.md migration step 1 to specify the file path (e.g.,
  "Delete the vibe-check entry from your mcpServers configuration").
- Add a "Duplicate Tools" troubleshooting entry.

**My response to Gemini's critique:**
I acknowledge the operational friction points but maintain FULLY SERVED because:
(a) the primary V1 blocker (no migration steps in README at all) is resolved,
(b) the remaining issues are edge-case operational details that affect users
who cannot locate their own MCP configuration, and (c) the documentation now
provides a clear migration path with honest trade-off disclosure. However,
Gemini's recommended fixes (more specific removal instructions, duplicate tools
troubleshooting) are valid improvements that could be applied in a future pass.

### Gemini (gemini-3-pro-preview) Assessment -- Scenario 6

Gemini confirmed that Scenario 6 should remain PARTIALLY SERVED. Key feedback:

**Friction points confirmed:**
1. Dead TypeScript test is a "trap" that signals a messy or abandoned repo.
2. Korean SKILL.md content and test_scenarios.md lock English-speaking
   contributors out of half the plugin's logic.
3. No CI means the contributor workflow is fragile and relies on discipline.

**Recommendations:**
- Delete `tests/api_provider.test.ts` immediately.
- Translate `tests/test_scenarios.md` to English.
- Implement GitHub Actions CI (TEST-PLAN.md P0.1).

All three recommendations align with existing TEST-PLAN.md priorities and
require implementation changes outside the documentation scope.

### Assessment Summary

The V2 documentation is mature and comprehensive for a v0.1.0 prompt-only
plugin. Seven of eight user scenarios are fully served by the documentation
alone. The one remaining partially-served scenario (Contributing) has bounded,
well-documented friction points that require implementation changes rather than
further documentation work. The V1 fixes successfully addressed the migration
gap that was the most actionable documentation issue.
