# V4 Consistency Audit

Audited on: 2026-02-16
Auditor: Cross-document consistency check across all 6 primary documents

Files reviewed:
- `/home/idnotbe/projects/vibe-check/.claude/skills/vibe-check/SKILL.md`
- `/home/idnotbe/projects/vibe-check/README.md`
- `/home/idnotbe/projects/vibe-check/ARCHITECTURE.md`
- `/home/idnotbe/projects/vibe-check/CLAUDE.md`
- `/home/idnotbe/projects/vibe-check/TEST-PLAN.md`
- `/home/idnotbe/projects/vibe-check/tests/test_scenarios.md`

---

## Cross-Document Checks

### (a) Parameter Lists -- FAIL

SKILL.md defines 7 parameters:
- Required: `goal`, `plan`
- Optional: `progress`, `uncertainties`, `taskContext`, `apiProvider`, `model`

| Document | Parameters Listed | Match? |
|----------|-------------------|--------|
| SKILL.md | goal, plan, progress, uncertainties, taskContext, apiProvider, model (7) | Source of truth |
| README.md | goal, plan, progress, uncertainties, taskContext, apiProvider, model (7) | PASS |
| ARCHITECTURE.md | goal, plan, progress, uncertainties, taskContext, apiProvider, model (7) | PASS |
| test_scenarios.md | goal, plan, apiProvider, model, uncertainties (5 used explicitly) | PARTIAL -- see note |
| CLAUDE.md | apiProvider, model mentioned; full list not enumerated | N/A (not expected) |

**Note on test_scenarios.md**: The file uses `progress` in section 2.3 (absent), and `taskContext` is never used in any test case. This is acceptable for a test plan (not all parameters need to appear in every test), but `taskContext` has zero test coverage.

**Verdict**: PASS for documentation consistency. Minor gap in test_scenarios.md test coverage for `taskContext` (no test scenario exercises it).

Adjusting to: **PASS** (parameter lists in documentation are consistent; test scenario coverage gap is a quality note, not a consistency issue).

---

### (b) Provider/Model Tables -- PASS

Source of truth (SKILL.md line 40-44):

| Provider | Models | Env Var |
|----------|--------|---------|
| openai | gpt-5.2-high, codex-5.2-high | OPENAI_API_KEY |
| google | gemini-3.0-pro-preview, gemini-3.0-flash-preview | GEMINI_API_KEY |
| anthropic | claude-sonnet-4.5, claude-opus-4.5 | ANTHROPIC_API_KEY |

| Document | Providers | Models | Env Vars | Match? |
|----------|-----------|--------|----------|--------|
| README.md (line 178-182) | 3/3 | 6/6 | 3/3 | PASS |
| ARCHITECTURE.md (line 93-97) | 3/3 | 6/6 | 3/3 | PASS |
| test_scenarios.md | 3/3 | 6/6 | 3/3 | PASS |
| validate_skill.sh | 3/3 | 6/6 | 3/3 | PASS |
| CLAUDE.md | 3/3 (mentioned) | 6 (mentioned) | 3 (mentioned) | PASS |

**Verdict**: PASS -- all documents use identical provider/model/env-var data.

---

### (c) Test File Inventory -- FAIL

After deleting `tests/api_provider.test.ts`, every document that lists test files should list exactly:
- `tests/validate_skill.sh`
- `tests/test_scenarios.md`

| Document | Files Listed | Includes api_provider.test.ts? | Match? |
|----------|-------------|-------------------------------|--------|
| README.md | validate_skill.sh, test_scenarios.md | No | PASS |
| ARCHITECTURE.md | validate_skill.sh, test_scenarios.md | No | PASS |
| TEST-PLAN.md | validate_skill.sh, test_scenarios.md | No | PASS |
| CLAUDE.md Repo Structure | validate_skill.sh, **api_provider.test.ts**, test_scenarios.md | **YES** | **FAIL** |
| CLAUDE.md Test File Status table | validate_skill.sh, test_scenarios.md, **api_provider.test.ts** | **YES** | **FAIL** |

**Details**: CLAUDE.md still contains three references to the deleted file:
1. Repo Structure section (line 14): `tests/api_provider.test.ts  # DEAD CODE -- see Testing notes`
2. Test File Status table (line 63): `| tests/api_provider.test.ts | Dead code | No package.json/tsconfig/node_modules |`
3. Paragraph after table (line 65): "The TypeScript test cannot run. There is no Node.js scaffolding in this repo. It should be deleted or properly scaffolded (see TEST-PLAN.md P0)."

**Verdict**: **FAIL** -- CLAUDE.md has 3 stale references to a deleted file.

---

### (d) Test Count -- PASS

Claim: validate_skill.sh has 28 checks across 9 groups.

- Actual run output: "Passed: 28, Failed: 0, Warnings: 0"
- Counting checks in script source:
  - Group 1 (Existence): 1
  - Group 2 (Frontmatter): 3
  - Group 3 (Required Environment): 4
  - Group 4 (API Providers): 3
  - Group 5 (Models): 6
  - Group 6 (Parameters): 7
  - Group 7 (Deprecated Params): 1
  - Group 8 (Config Examples): 2
  - Group 9 (Provider-Model Mapping): 1
  - Total: 28, Groups: 9

| Document | Count Stated | Match? |
|----------|-------------|--------|
| README.md | "9 test groups (28 checks total)" | PASS |
| ARCHITECTURE.md | "28 automated checks across 9 test groups" | PASS |
| CLAUDE.md | "28 checks across 9 test groups" (line 57) | PASS |
| TEST-PLAN.md | "28 checks across 9 test groups" with detailed breakdown table | PASS |

**Verdict**: PASS -- all documents consistently state 28 checks / 9 groups, matching the actual script.

---

### (e) Input Format Examples -- PASS

SKILL.md defines three input formats (lines 46-68):
1. **Structured**: key: value pairs with goal, plan, progress, uncertainties, taskContext, apiProvider, model
2. **Natural Language**: free-form sentence
3. **Simple**: "goal / plan" shorthand

README.md (lines 118-137) shows:
1. **Structured**: Same key: value format (omits apiProvider/model from the basic example, shows them in a separate provider example -- section "Example with Provider")
2. **Natural Language**: Same free-form format
3. **Simple**: Same "goal / plan" format

Both documents use the same authentication example ("Add user authentication" / "OAuth2 + JWT tokens, Redis for session storage").

**Minor difference**: SKILL.md's structured example includes `apiProvider: anthropic (optional)` and `model: claude-opus-4.5 (optional)` inline. README's basic structured example omits these (shows them separately under "Example with Provider" -- different provider/model: openai / codex-5.2-high). This is acceptable editorial choice, not inconsistency.

**Verdict**: PASS -- input format examples are consistent in structure and semantics.

---

### (f) Output Format -- PASS

SKILL.md output format (lines 162-182):
```
## Vibe Check Results
### Quick Assessment
### Key Questions to Consider (1-4)
### Pattern Watch
### Recommendation
### If Adjusting
```

README.md output format (lines 143-163): Identical structure, identical placeholder text.

**Verdict**: PASS -- output formats are character-for-character identical.

---

### (g) Validation Rules -- PASS

SKILL.md validation rules (lines 103-105):
1. If `apiProvider` is specified, `model` must also be specified.
2. Verify if the specified `model` is supported by the `apiProvider`.
3. Verify if the API key environment variable for the provider is set.

| Document | Rule 1 (pair required) | Rule 2 (model matches provider) | Rule 3 (env var set) |
|----------|----------------------|-------------------------------|---------------------|
| README.md (line 186-188) | Yes | Yes | Yes |
| ARCHITECTURE.md (line 100-102) | Yes | Yes | Yes |
| CLAUDE.md (line 42) | Yes ("must also be specified; model must match provider") | Yes | Implied (metadata) |
| test_scenarios.md (1.2) | Tested (rows 8-9) | Tested (row 7) | Tested (section 1.3) |

**Verdict**: PASS -- validation rules are consistently stated across all documents.

---

### (h) "What Needs Help" -- PASS

README.md "What Needs Help" section (line 292) lists:
- Adding a GitHub Actions CI workflow (see TEST-PLAN.md P0.1)

TEST-PLAN.md P0.1 status: No "Done" marker. The item is still open (no .github/workflows directory exists on disk).

Completed items NOT listed in "What Needs Help":
- P0.2 (Delete api_provider.test.ts) -- marked "Done" in TEST-PLAN.md, not in "What Needs Help" -- correct
- P0.3 (Add testing documentation) -- marked "Done" in TEST-PLAN.md, not in "What Needs Help" -- correct
- P2.1 (Add testing to ARCHITECTURE.md) -- marked "Done" in TEST-PLAN.md, not in "What Needs Help" -- correct

**Verdict**: PASS -- "What Needs Help" lists only genuinely incomplete items.

---

### (i) Directory Structures -- FAIL

Actual files on disk (committed, excluding temp/ and .git/):
```
.claude/skills/vibe-check/SKILL.md
.claude-plugin/plugin.json
.gitignore
.mcp.json
ARCHITECTURE.md
CLAUDE.md
LICENSE
README.md
TEST-PLAN.md
on_notification.wav
on_stop.wav
tests/test_scenarios.md
tests/validate_skill.sh
```

| Document | Lists api_provider.test.ts? | Lists .mcp.json? | Lists .wav files? | Accurate? |
|----------|---------------------------|-------------------|-------------------|-----------|
| README.md | No | No | No | Mostly (omits .mcp.json, .wav) |
| ARCHITECTURE.md | No | No | No | Mostly (omits .mcp.json, .wav) |
| CLAUDE.md | **YES** | No | No | **FAIL** (lists deleted file; omits .mcp.json, .wav) |

**Notes on omitted files**: `.mcp.json` and `on_notification.wav`/`on_stop.wav` were added in commit `127284a` ("chore: add local config and sound files"). These are local configuration and auxiliary files. Their omission from README.md and ARCHITECTURE.md directory trees is a minor documentation gap but arguably intentional (they are not core to the plugin). However, CLAUDE.md as the "project instructions" file should be the most accurate inventory.

**Verdict**: **FAIL** -- CLAUDE.md lists `tests/api_provider.test.ts` which no longer exists. All three directory listings omit `.mcp.json` and `.wav` files added in a recent commit, though this is a minor issue.

---

## Issues Found

### Issue 1 (High): CLAUDE.md contains 3 stale references to deleted api_provider.test.ts

**Location**: `/home/idnotbe/projects/vibe-check/CLAUDE.md`

1. **Line 14** (Repo Structure): `tests/api_provider.test.ts            # DEAD CODE -- see Testing notes`
2. **Line 63** (Test File Status table): `| tests/api_provider.test.ts | Dead code | No package.json/tsconfig/node_modules |`
3. **Line 65** (paragraph): "The TypeScript test cannot run. There is no Node.js scaffolding in this repo. It should be deleted or properly scaffolded (see TEST-PLAN.md P0)."

**Fix**: Remove the Repo Structure line, the table row, and the follow-up paragraph. These describe a file that has been deleted (TEST-PLAN.md P0.2 is marked "Done").

### Issue 2 (Medium): CLAUDE.md claims SKILL.md is bilingual and test_scenarios.md is Korean

**Location**: `/home/idnotbe/projects/vibe-check/CLAUDE.md`

1. **Lines 33-37** (Key Facts, 3rd bullet): "SKILL.md is bilingual (English and Korean). Structural elements ... are in English. Parameter descriptions, input format examples, and configuration instructions are in Korean. This is a known inconsistency with the English-only guideline below."
2. **Line 38**: "tests/test_scenarios.md is written in Korean."
3. **Line 14**: `tests/test_scenarios.md               # Manual test plan (Korean)`

Both SKILL.md and test_scenarios.md have been fully translated to English. These statements are now incorrect.

**Fix**: Remove the bilingual bullet, change "(Korean)" to just "Manual test plan" in the Repo Structure, and remove the Korean note about test_scenarios.md.

### Issue 3 (Low): All directory listings omit .mcp.json and .wav files

**Location**: README.md (line 66-82), ARCHITECTURE.md (line 14-31), CLAUDE.md (line 10-20)

The files `.mcp.json`, `on_notification.wav`, and `on_stop.wav` exist in the repo root (committed in `127284a`) but are not listed in any directory structure. These are local config/auxiliary files and may be intentionally omitted, but CLAUDE.md as the authoritative project-instructions file should ideally account for all committed files or explicitly note the omission.

### Issue 4 (Low): test_scenarios.md has no test case for `taskContext` parameter

**Location**: `/home/idnotbe/projects/vibe-check/tests/test_scenarios.md`

While `taskContext` is listed as a parameter in SKILL.md, README.md, and ARCHITECTURE.md (all 7 parameters consistent), no test scenario in test_scenarios.md actually exercises `taskContext`. This is a test coverage gap, not a consistency issue.

---

## Summary

**FAIL -- 2 checks failed, 7 passed**

| Check | Result |
|-------|--------|
| (a) Parameter lists | PASS |
| (b) Provider/model tables | PASS |
| (c) Test file inventory | **FAIL** -- CLAUDE.md still lists deleted api_provider.test.ts |
| (d) Test count (28 / 9 groups) | PASS |
| (e) Input format examples | PASS |
| (f) Output format | PASS |
| (g) Validation rules | PASS |
| (h) "What Needs Help" | PASS |
| (i) Directory structures | **FAIL** -- CLAUDE.md lists deleted file; all docs omit .mcp.json/.wav |

**Root cause**: CLAUDE.md was not fully updated after the V4 changes (SKILL.md English translation, test_scenarios.md English translation, api_provider.test.ts deletion). It retains 3 stale file references and 2 stale language claims from the pre-V4 state.

**Recommended action**: Update CLAUDE.md to:
1. Remove all 3 references to `tests/api_provider.test.ts`
2. Remove the "bilingual" bullet and Korean-language claims
3. Optionally add `.mcp.json` and `.wav` files to the Repo Structure (or add a note explaining their omission)
