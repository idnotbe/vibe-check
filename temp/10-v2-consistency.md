# V2 Cross-Document Consistency Audit

## Summary

**Overall Assessment: MOSTLY CONSISTENT with 7 issues (0 Critical, 2 High, 3 Medium, 2 Low)**

The four documentation files (README.md, ARCHITECTURE.md, CLAUDE.md, TEST-PLAN.md)
are broadly consistent on the major facts: plugin name, version, provider/model
data, parameter names, output format, and the core "no API calls" messaging. The
V1 tech review fixes resolved several inconsistencies (argument-hint paraphrase,
missing .gitignore, "and vice versa" removal, test group enumeration in README).
The remaining 7 issues are mostly omissions in one doc that other docs cover
correctly, plus one internal inconsistency within README.

---

## Consistency Matrix

The matrix below shows agreement (+) or disagreement (-) for each dimension
across all document pairs. "N/A" means the dimension is not covered in that doc.

| # | Dimension | README | ARCH | CLAUDE | TEST-PLAN | Notes |
|---|-----------|--------|------|--------|-----------|-------|
| 1 | Plugin version (0.1.0) | + | + | + | N/A | All match plugin.json |
| 2 | Plugin name ("vibe-check") | + | + | + | + | Consistent everywhere |
| 3 | Parameter list (7 params) | + | + | + | + | Same 7 names, same required/optional |
| 4 | Provider/model table (3/6/3) | + | + | + | + | All tables match SKILL.md exactly |
| 5 | Test count (28 checks) | + | + | + | + | All say 28 |
| 6 | Test groups (9 groups) | + | + | **-** | + | CLAUDE.md enumerates only 8 (Issue C1) |
| 7 | Output format (5 sections) | + | N/A | N/A | N/A | README matches SKILL.md exactly |
| 8 | Installation methods (2) | + | + | N/A | N/A | Both mention copy + manifest |
| 9 | Directory/file structure | + | **-** | + | N/A | ARCH lists only 5 of 11 files (Issue C2) |
| 10 | "No API calls" messaging | + | + | + | N/A | Consistent strength and wording |
| 11 | Dead code status (api_provider.test.ts) | + | + | + | + | All say "dead code" / "no Node.js" |
| 12 | Korean content acknowledgment | + | + | + | N/A | All acknowledge bilingual SKILL.md |
| 13 | "Prompt-only" / "no runtime" claims | + | + | + | + | Consistent across all docs |
| 14 | Test command | + | N/A | + | + | All say `bash tests/validate_skill.sh` |
| 15 | Plugin manifest fields | **-** | + | N/A | + | README incomplete (Issue C6) |

**Legend**: + = consistent with ground truth and other docs, - = inconsistency found, N/A = not covered

---

## Issues Found

### Issue C1: CLAUDE.md omits "Existence" test group from inline enumeration

- **Severity**: High
- **File**: CLAUDE.md, lines 60-62
- **Ground truth**: validate_skill.sh has 9 test groups. Group 1 is "Existence"
  (SKILL.md file exists).
- **What CLAUDE.md says**: "It validates SKILL.md structure: frontmatter,
  required_environment, API provider docs, model docs, parameter docs, deprecated
  parameter absence, config examples, and provider-model mapping table." -- 8 items.
- **What other docs say**:
  - README (line 270): "file existence, frontmatter, ..." -- lists all 9
  - ARCHITECTURE.md (lines 133-141): numbered list of all 9 groups
  - TEST-PLAN.md (lines 17-28): table with all 9 groups
- **Impact**: A developer reading CLAUDE.md and trying to match the enumeration
  to the script will find one missing group. CLAUDE.md does not claim "9 groups"
  (it only says "28 checks"), so there is no numeric contradiction, but the
  enumeration is incomplete compared to the other three docs.
- **V1 status**: V1 issue T3 caught the same problem in README (which listed 8
  groups while claiming 9). README was fixed but CLAUDE.md was not updated.

### Issue C2: ARCHITECTURE.md directory structure lists only 5 of 11 files

- **Severity**: High
- **File**: ARCHITECTURE.md, lines 14-26
- **Ground truth**: The repo contains 11 tracked documentation/implementation files.
- **What ARCHITECTURE.md shows**: Only 5 files: SKILL.md, plugin.json,
  validate_skill.sh, api_provider.test.ts, test_scenarios.md
- **What other docs show**:
  - README (lines 66-82): All 11 files
  - CLAUDE.md (lines 11-21): All 11 files
- **Missing from ARCHITECTURE.md**: README.md, ARCHITECTURE.md, CLAUDE.md,
  TEST-PLAN.md, LICENSE, .gitignore
- **Impact**: A reader consulting ARCHITECTURE.md as the design document would
  get an incomplete picture of the repository contents. The scope of the ARCH
  listing appears intentionally focused on "plugin structure" (implementation +
  tests), but this is not stated. Without an explanation, it reads as an
  incomplete listing compared to README and CLAUDE.md.
- **V1 status**: V1 issue T5 caught .gitignore missing from README. README was
  fixed but ARCHITECTURE.md's listing was not expanded.

### Issue C3: Validation rule directionality inconsistency (internal + cross-doc)

- **Severity**: Medium
- **Files**: README.md lines 187 vs 248, CLAUDE.md line 48, ARCHITECTURE.md line 95
- **Ground truth**: SKILL.md line 103 says (translated): "If apiProvider is
  specified, model must also be specified." This is ONE-DIRECTIONAL (apiProvider
  implies model, but not necessarily the reverse).
- **One-directional wording** (matches SKILL.md):
  - README line 187: "If `apiProvider` is specified, `model` must also be specified"
  - ARCHITECTURE.md line 95: "If `apiProvider` is specified, `model` must also be
    specified"
- **Bidirectional wording** (goes beyond SKILL.md):
  - README line 248: "`apiProvider` and `model` must be specified together -- you
    cannot use one without the other"
  - CLAUDE.md line 48: "Both must be specified together; model must match provider"
- **Impact**: README contradicts itself (line 187 vs line 248). CLAUDE.md and
  README Troubleshooting imply a bidirectional requirement not explicitly stated
  in SKILL.md. A user specifying only `model` would get different guidance
  depending on which section they read.
- **V1 status**: V1 issue T2 caught "and vice versa" in README line 182 and
  ARCHITECTURE.md line 95. The "and vice versa" was removed from the Validation
  Rules sections, but the Troubleshooting section (README line 248) and CLAUDE.md
  (line 48) still use bidirectional wording.

### Issue C4: Description text differs between SKILL.md and plugin.json

- **Severity**: Medium
- **Files**: SKILL.md line 3, plugin.json line 4, README.md line 3,
  ARCHITECTURE.md line 41
- **Ground truth**: Two "source" files disagree:
  - SKILL.md: "Metacognitive sanity **check**" (singular) + "Helps prevent tunnel
    vision, over-engineering, and goal misalignment." (full suffix)
  - plugin.json: "Metacognitive sanity **checks**" (plural) + no "Helps prevent..."
    suffix
- **How docs align**:
  - README line 3: Uses plural ("checks") + full suffix -- hybrid of both sources
  - ARCHITECTURE.md line 41: Verbatim from SKILL.md (singular, full suffix)
- **Impact**: Minor wording difference. The plural/singular distinction does not
  change meaning, but the difference between implementation files (SKILL.md vs
  plugin.json) propagates into documentation that cites them. A contributor
  editing the description may not know which source to trust.

### Issue C5: ARCHITECTURE.md does not distinguish warn vs fail in test group 8

- **Severity**: Medium
- **File**: ARCHITECTURE.md line 140
- **Ground truth**: validate_skill.sh line 153 uses `warn` (not `fail`) for the
  settings.json reference check. The `warn` function increments WARN counter but
  does not affect exit code.
- **What ARCHITECTURE.md says** (line 140): "`environment_variables` and
  `settings.json` references present" -- no severity distinction
- **What TEST-PLAN.md says** (line 26): "`environment_variables` reference present
  (pass/fail), `settings.json` reference present (pass/warn)" -- correctly notes
  the warn level
- **What README says** (line 271): "configuration examples" -- summary level, no
  severity detail (acceptable for user-facing doc)
- **Impact**: A contributor reading ARCHITECTURE.md's testing section would assume
  all 28 checks are pass/fail, when one is actually pass/warn. TEST-PLAN.md is
  the only doc that documents this correctly.
- **V1 status**: V1 issue T6 flagged this. It remains unfixed in ARCHITECTURE.md.

### Issue C6: README describes plugin.json fields incompletely

- **Severity**: Low
- **File**: README.md lines 57-59
- **Ground truth**: plugin.json contains 8 top-level fields: name, version,
  description, author (with name+url), skills, homepage, repository, license,
  keywords
- **What README says**: "Plugin name, version, and description / Skills path
  reference / Author and repository metadata" -- omits homepage, license, keywords
- **What ARCHITECTURE.md says** (line 28): "name: `vibe-check`, version: `0.1.0`,
  skills path, author, homepage, repository, license, keywords" -- complete list
- **Impact**: A user reading README's Method 2 installation section gets an
  incomplete picture of what plugin.json contains. Not a contradiction, but an
  omission that makes the two docs inconsistent in depth.

### Issue C7: SKILL.md argument-hint lists only 4 of 7 parameters

- **Severity**: Low (implementation observation, not a doc-only issue)
- **File**: SKILL.md line 4
- **Ground truth**: SKILL.md body documents 7 parameters (goal, plan, progress,
  uncertainties, taskContext, apiProvider, model).
- **What argument-hint shows**: Only 4 parameters (goal, plan, apiProvider, model)
  plus a note "(or free-form text)".
- **Doc impact**: ARCHITECTURE.md (line 42) and CLAUDE.md (within "The
  apiProvider/model Feature" context) reproduce or reference this hint. Since
  the hint is in SKILL.md frontmatter (an implementation file), the docs
  faithfully reflect it. But the hint itself is incomplete relative to the
  parameter table in the same file.
- **Note**: This is an implementation-file issue, not a documentation issue.
  Listed here because the external reviewer flagged it and it affects how docs
  represent the frontmatter.

---

## Internal Consistency (per-document self-contradictions)

### README.md
- **Self-contradiction on validation rule direction**: Line 187 states
  one-directional rule; line 248 states bidirectional rule. These are in
  different sections (Validation Rules vs Troubleshooting) and give users
  conflicting guidance. (See Issue C3.)
- No other internal contradictions found. "should" vs "must" inconsistency
  from V1 (issue T4) has been fixed -- both instances now use "must."

### ARCHITECTURE.md
- No internal contradictions found. The document is internally consistent.

### CLAUDE.md
- No internal contradictions found. The document is internally consistent.

### TEST-PLAN.md
- No internal contradictions found. The document is internally consistent.
  TEST-PLAN.md is the most precise of the four docs regarding test details.

---

## V1 Issue Status

| V1 Issue | Status in V2 | Notes |
|----------|-------------|-------|
| T1: ARCH argument-hint paraphrase | **Fixed** | Now verbatim with translation note |
| T2: "and vice versa" not in SKILL.md | **Partially fixed** | Removed from Validation Rules sections, but bidirectional wording remains in README Troubleshooting (line 248) and CLAUDE.md (line 48). See Issue C3. |
| T3: README lists 8 test groups not 9 | **Fixed in README, new in CLAUDE.md** | README now lists 9. CLAUDE.md still lists 8. See Issue C1. |
| T4: README should vs must | **Fixed** | Both README instances now use "must" |
| T5: README missing .gitignore | **Fixed in README, persists in ARCH** | README now includes .gitignore. ARCHITECTURE.md listing still omits it (and 5 other files). See Issue C2. |
| T6: warn vs fail not distinguished | **Unfixed** | ARCHITECTURE.md still does not note the warn level. See Issue C5. |

---

## Self-Critique

1. **Scope of ARCHITECTURE.md directory listing**: I flagged ARCHITECTURE.md's
   5-file listing as an inconsistency (Issue C2). However, it could be argued
   that ARCHITECTURE.md intentionally shows only the "plugin structure" (core
   implementation + tests) and not the full repo. The document's heading is
   "Plugin Structure," which might justify a narrower scope. But without an
   explicit note like "documentation files omitted for brevity," a reader
   comparing it to README's listing will see a gap.

2. **Bidirectional validation rule**: Issue C3 flags the bidirectional wording
   as inconsistent with SKILL.md. However, the bidirectional interpretation
   may actually be the *intended* behavior -- it is arguably a reasonable
   inference that specifying `model` without `apiProvider` should also be
   invalid. The dead TypeScript test file (api_provider.test.ts line 66)
   actually tests the reverse direction ("apiProvider must be specified when
   model is set"), suggesting the bidirectional rule was intended. The
   inconsistency is still real in the documentation, but the "correct" fix
   might be to make SKILL.md bidirectional rather than making the docs
   unidirectional.

3. **Description singular/plural**: Issue C4 may be overly pedantic. The
   difference between "check" and "checks" is cosmetic and does not affect
   user understanding. I included it for completeness but acknowledge it is
   very low severity.

4. **Exclusion of temp/ files**: I did not audit temp/ files for consistency
   since they are working documents, not deliverables. The master-context.md
   has a different English translation of the argument-hint than the actual
   SKILL.md text, but this is acceptable for a planning document.

5. **Korean translation confidence**: For Issue C3, I relied on my translation
   of SKILL.md line 103. The Korean text "apiProvider가 지정되면 model도 반드시
   지정해야 함" does clearly state one direction, but a native Korean speaker
   should confirm there is no implied bidirectionality in the phrasing.

---

## External Validation

### Gemini 3.0 Pro (via pal clink)

External review confirmed all 6 originally reported issues as valid
discrepancies. The reviewer added two findings:

1. **argument-hint lists only 4 of 7 parameters** (incorporated as Issue C7).
   The hint in SKILL.md frontmatter omits `progress`, `uncertainties`, and
   `taskContext`. This is an implementation-file observation.

2. **Validation script maintainability risk**: validate_skill.sh hardcodes
   expected values rather than parsing them from SKILL.md. This is already
   documented in TEST-PLAN.md P1.2 and P2.2, so it is a known issue rather
   than a new finding.

The external reviewer rated Issue C3 (validation rule direction) as the most
critical finding and recommended standardizing on bidirectional wording. This
aligns with my self-critique point #2 above.

### Methodology Assessment (from external reviewer)

The reviewer validated the methodology as "rigorous" and identified one blind
spot: I initially did not check the SKILL.md frontmatter argument-hint against
the parameter documentation in the same file. This was corrected and incorporated
as Issue C7.

---

## Prioritized Fix Recommendations

| Priority | Issue | Fix Location | Effort |
|----------|-------|-------------|--------|
| 1 | C1: Add "Existence" test group to CLAUDE.md enumeration | CLAUDE.md line 60 | Trivial |
| 2 | C2: Expand ARCHITECTURE.md directory listing to match README | ARCHITECTURE.md lines 14-26 | Small |
| 3 | C3: Standardize validation rule direction across all docs | README.md line 248, CLAUDE.md line 48 | Small |
| 4 | C5: Add warn/fail distinction to ARCHITECTURE.md test group 8 | ARCHITECTURE.md line 140 | Trivial |
| 5 | C6: Complete plugin.json field list in README | README.md lines 57-59 | Trivial |
| 6 | C4: Align description text (singular/plural) | README.md line 3 or plugin.json line 4 | Trivial (but plugin.json is implementation) |
| 7 | C7: argument-hint incomplete | SKILL.md line 4 | Trivial (but SKILL.md is implementation) |
