# V5 Adversarial Review

Adversarial documentation review conducted after V4 changes (SKILL.md English
translation, test_scenarios.md English translation, api_provider.test.ts deletion,
all docs updated).

## Attack Vectors Tested

### 1. Stale Korean/bilingual references in active docs
- **Target**: CLAUDE.md, README.md, ARCHITECTURE.md, TEST-PLAN.md
- **Result**: PASS. Grepped all non-temp files for Korean characters (U+AC00-U+D7AF,
  U+3130-U+318F, U+FFA0-U+FFDC). Zero matches outside `temp/`. Grepped for
  "Korean", "bilingual" in active doc files -- zero matches. The old CLAUDE.md
  bullets about "SKILL.md is bilingual" and "test_scenarios.md is written in
  Korean" are gone.

### 2. Stale references to deleted api_provider.test.ts
- **Target**: All non-temp files
- **Result**: PASS. `ls tests/` confirms only `test_scenarios.md` and
  `validate_skill.sh` exist. Grepped for "api_provider.test.ts" in active docs:
  only TEST-PLAN.md P0.2 mentions it, and correctly says "Done. `tests/api_provider.test.ts`
  has been deleted." This is a historical completion note, not a stale reference.
  CLAUDE.md, README.md, and ARCHITECTURE.md no longer list it.

### 3. Stale "dead code" references
- **Target**: All active docs
- **Result**: PASS. No active doc refers to "dead code" outside the TEST-PLAN.md
  historical note about the deletion.

### 4. Version consistency
- **Target**: plugin.json, README.md, ARCHITECTURE.md, CLAUDE.md
- **Result**: PASS. All references say 0.1.0:
  - plugin.json line 3: `"version": "0.1.0"`
  - README.md line 5: `0.1.0`
  - README.md line 72: `v0.1.0`
  - ARCHITECTURE.md line 33: `0.1.0`
  - ARCHITECTURE.md line 169: `0.1.0`
  - CLAUDE.md line 12: `v0.1.0`

### 5. CLAUDE.md "lines 38-106" reference accuracy
- **Target**: CLAUDE.md line 36 claims SKILL.md lines 38-106 define the
  apiProvider/model system.
- **Result**: PASS. SKILL.md line 38 is "### Supported API Providers and Models"
  (start of provider/model content). Line 106 is the last line of the Validation
  section (end of the apiProvider/model block). Line 107 is `---` (section
  separator). The reference is accurate.

### 6. Provider/model table consistency across files
- **Target**: SKILL.md, README.md, ARCHITECTURE.md
- **Result**: PASS. All three files have identical provider-model mapping tables:
  - openai: gpt-5.2-high, codex-5.2-high / OPENAI_API_KEY
  - google: gemini-3.0-pro-preview, gemini-3.0-flash-preview / GEMINI_API_KEY
  - anthropic: claude-sonnet-4.5, claude-opus-4.5 / ANTHROPIC_API_KEY

### 7. Parameter list consistency
- **Target**: SKILL.md, README.md, ARCHITECTURE.md
- **Result**: PASS. All list 7 parameters (goal, plan, progress, uncertainties,
  taskContext, apiProvider, model) with consistent required/optional designation.

### 8. Validation rule consistency (unidirectional vs bidirectional)
- **Target**: All docs describing the apiProvider/model validation rules
- **Result**: PASS. All active documents consistently state the unidirectional
  rule: "If `apiProvider` is specified, `model` must also be specified." None
  claim the reverse. This was a known issue in earlier rounds (V2 N1/N2) and
  has been corrected.

### 9. Test count consistency
- **Target**: All docs mentioning validate_skill.sh
- **Result**: PASS. All say "28 checks" and "9 test groups." Running the
  validator confirms: 28 passed, 0 failed, 0 warnings.

### 10. Directory structure listings consistency
- **Target**: CLAUDE.md, README.md, ARCHITECTURE.md
- **Result**: PASS. All three directory listings are consistent and match the
  actual repo contents. None list api_provider.test.ts. All include the same
  set of files.

### 11. validate_skill.sh actually passes
- **Target**: tests/validate_skill.sh
- **Result**: PASS. Ran `bash tests/validate_skill.sh` -- 28 passed, 0 failed,
  0 warnings.

### 12. Remaining Korean in SKILL.md or test_scenarios.md
- **Target**: The two files that were recently translated
- **Result**: PASS. Zero Korean characters found in either file. SKILL.md is
  entirely English. test_scenarios.md is entirely English.

### 13. Misleading "required_environment" claims
- **Target**: SKILL.md frontmatter vs README "no dependencies" claim
- **Result**: INFO (known tension, documented). SKILL.md uses
  `required_environment` (implying required). README footnote [^1] and the
  "Important: No External API Calls" section explain this is metadata. The
  tension is inherent in the SKILL.md frontmatter field name and cannot be
  fully resolved in documentation. TEST-PLAN.md P1.1 discusses this explicitly
  and offers the nuclear option (removing `required_environment` entirely).
  No new issue -- this is a known, documented tension.

### 14. Broken cross-document links
- **Target**: README.md internal anchors and cross-file links
- **Result**: PASS. Checked key links:
  - `ARCHITECTURE.md#migration-path` -- heading exists at line 152
  - `TEST-PLAN.md` -- file exists
  - `CLAUDE.md` -- file exists
  - Internal anchors (#api-provider-and-model-parameters,
    #important-no-external-api-calls) match actual headings in README.md

### 15. External URL validity
- **Target**: agentskills.io, PV-Bhat/vibe-check-mcp-server, github.com/idnotbe
- **Result**: NOT VERIFIED (out of scope for static review). These URLs appear
  in README.md Credits and ARCHITECTURE.md. Previous rounds flagged this as
  unverifiable without network access. No new finding.

### 16. .gitignore mismatch with project nature
- **Target**: .gitignore contents vs project type
- **Result**: INFO (minor). The .gitignore is a Python template (pyenv, Django,
  Flask, Scrapy, etc.) for a project that has no Python code. It also lacks
  `node_modules/` and `temp/` entries. The `temp/` directory is currently
  untracked (shown in `git status`) and not gitignored, meaning it could be
  accidentally committed. This is a minor hygiene issue, not a documentation
  contradiction.

### 17. test_scenarios.md content accuracy post-translation
- **Target**: tests/test_scenarios.md model names, provider names, parameter names
- **Result**: PASS. All model names (gpt-5.2-high, codex-5.2-high,
  gemini-3.0-pro-preview, gemini-3.0-flash-preview, claude-sonnet-4.5,
  claude-opus-4.5) match SKILL.md. Provider names and parameter names are
  consistent. The test scenario structure is coherent.

### 18. SKILL.md YAML frontmatter validity
- **Target**: The YAML block at top of SKILL.md
- **Result**: PASS. Well-formed: has `---` delimiters, `name`, `description`,
  `argument-hint`, and `required_environment` with 3 list items. The
  `argument-hint` uses `(or free-form text)` in English (previously Korean).

### 19. README test table vs actual test files
- **Target**: README.md Testing section file table
- **Result**: PASS. Table lists exactly 2 files:
  - tests/validate_skill.sh (Automated, bash) -- exists
  - tests/test_scenarios.md (Manual plan) -- exists
  No phantom files listed. No real files omitted.

### 20. Contradictions between SKILL.md behavior descriptions and README
- **Target**: How the apiProvider/model feature is described
- **Result**: PASS. Both consistently say:
  - Claude generates all feedback (no external API calls)
  - apiProvider/model influence feedback style, not the model used
  - Default behavior uses current Claude Code session model
  - README Limitations section is honest about the trade-off

## Issues Found

### Issue 1 -- Severity: Low -- temp/ directory not gitignored
- **Location**: .gitignore
- **Problem**: The `temp/` directory containing 22 working documents is untracked
  but not listed in `.gitignore`. A careless `git add -A` or `git add .` could
  commit all temp files. The .gitignore is also a Python-heavy template despite
  the project having zero Python files.
- **Impact**: Accidental commit of working notes. No documentation contradiction.
- **Fix**: Add `temp/` to `.gitignore`.

### Issue 2 -- Severity: Informational -- SKILL.md validation rule gap
- **Location**: SKILL.md lines 102-105
- **Problem**: SKILL.md says "If `apiProvider` is specified, `model` must also be
  specified" but does not state the reverse: what happens if `model` is specified
  without `apiProvider`. The test_scenarios.md (line 29) does test this case
  ("Model without provider -> Error: Provider required") but SKILL.md's
  validation rules do not explicitly state this. This means Claude's behavior
  for this edge case is undefined in the skill prompt.
- **Impact**: Claude might handle `model`-without-`apiProvider` inconsistently.
  Low practical impact since users are unlikely to specify model without provider.
- **Fix**: Add "If `model` is specified, `apiProvider` must also be specified"
  to SKILL.md validation rules, or document that model-without-provider is
  inferred from the model name.

### Issue 3 -- Severity: Informational -- validate_skill.sh pass/warn semantics
- **Location**: validate_skill.sh line 150-153, TEST-PLAN.md line 25,
  ARCHITECTURE.md line 141
- **Problem**: The `settings.json` check (test 8.2) uses `warn` instead of
  `fail`. The WARN counter does not affect the exit code (`if [ $FAIL -eq 0 ];
  then exit 0`). This means the script can report warnings but still exit 0.
  TEST-PLAN.md and ARCHITECTURE.md correctly document "(pass/warn)" for this
  check. However, README.md line 258 says "9 test groups (28 checks total)"
  without noting that one check is warn-only. A contributor might expect all
  28 checks to be hard failures.
- **Impact**: Minimal -- the behavior is correct and documented in TEST-PLAN.md.
  README simplification is reasonable.

## Summary

**PASS**

The documentation is internally consistent after the V4 changes. The three major
changes (SKILL.md English translation, test_scenarios.md English translation,
api_provider.test.ts deletion) have been properly reflected across all active
documentation files. No stale Korean references, no phantom file references, no
version mismatches, no contradictions in provider/model tables, and the validator
passes all 28 checks.

The only actionable finding is the missing `temp/` entry in `.gitignore` (Issue 1,
Low severity). Issues 2 and 3 are informational observations about edge cases,
not documentation defects.
