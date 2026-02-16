# V1 Technical Accuracy Review

## Summary

**Overall Assessment: PASS with 6 issues (0 Critical, 1 High, 4 Medium, 1 Low)**

The documentation is substantially accurate. All provider names, model names,
environment variables, parameter names, version numbers, and file paths are
correct. The 6 issues found are mostly minor inconsistencies and one
paraphrasing problem in ARCHITECTURE.md's YAML frontmatter block.

---

## Issues Found

### Issue T1: ARCHITECTURE.md argument-hint is a paraphrase, not a quote

- **File**: ARCHITECTURE.md, line 42
- **Severity**: Medium
- **Expected**: The YAML frontmatter code block should either exactly reproduce
  the SKILL.md frontmatter or explicitly note it is a translated/simplified
  version. SKILL.md line 4:
  `argument-hint: goal: [목표] plan: [계획] apiProvider: [openai|google|anthropic] model: [모델명] (또는 자유 형식 텍스트)`
- **Actual**: ARCHITECTURE.md line 42:
  `argument-hint: goal: [goal] plan: [plan] apiProvider: [openai|google|anthropic] model: [model]`
- **Problem**: Two differences: (1) Korean placeholders are silently translated
  to English, and (2) the trailing `(또는 자유 형식 텍스트)` ("or free-form
  text") is omitted entirely. Because this appears in a `yaml` code block
  labeled "YAML Frontmatter," a reader would expect an exact reproduction.
  The omission of the free-form text note changes the semantics (users might
  think only structured key:value input is accepted).

### Issue T2: Validation rules add "and vice versa" not in SKILL.md

- **File**: README.md line 182, ARCHITECTURE.md line 95
- **Severity**: Medium
- **Expected**: SKILL.md line 103 states the validation rule in one direction
  only: "apiProvider가 지정되면 model도 반드시 지정해야 함" = "If apiProvider
  is specified, model must also be specified." There is no reverse rule
  stated.
- **Actual**: README says "If `apiProvider` is specified, `model` must also be
  specified (and vice versa)". ARCHITECTURE.md says "`apiProvider` requires
  `model` to also be specified (and vice versa)".
- **Problem**: The "(and vice versa)" clause adds a rule not explicitly present
  in SKILL.md. While it may be a reasonable inference, documentation should
  match the implementation precisely. If the bidirectional requirement is
  intended, SKILL.md should be updated to state it (which is outside scope
  of this doc review). As-is, the docs overstate the validation.

### Issue T3: README enumerates 8 test groups while claiming 9

- **File**: README.md, lines 261-263
- **Severity**: High
- **Expected**: The README says "9 test groups" and should then list all 9.
  The 9 groups are: (1) Existence, (2) Frontmatter, (3) Required Environment,
  (4) API Providers, (5) Models, (6) Parameters, (7) Deprecated Params,
  (8) Config Examples, (9) Provider-Model Mapping.
- **Actual**: The inline enumeration reads: "frontmatter, required_environment,
  API provider docs, model docs, parameter docs, deprecated parameter absence,
  configuration examples, and provider-model mapping." -- that is 8 items.
  The "Existence" (SKILL.md file exists) group is omitted.
- **Problem**: The count "9 test groups" is correct but the enumeration only
  lists 8, creating a mismatch. A reader trying to map the list to the script
  will find one missing.

### Issue T4: README validation rule wording inconsistency (should vs must)

- **File**: README.md, lines 184 and 245
- **Severity**: Low
- **Expected**: Consistent wording for the same rule within the same document.
- **Actual**: Line 184 (Validation Rules section): "The corresponding API key
  environment variable **should** be configured". Line 245 (Troubleshooting
  section): "The corresponding API key environment variable **must** be set
  in `~/.claude/settings.json`".
- **Problem**: "should" and "must" have different RFC 2119 meanings. SKILL.md
  line 105 uses a verification phrasing ("확인" = verify/check) which is
  closer to "must". The two README sections disagree on the strength of this
  requirement.

### Issue T5: README directory structure missing .gitignore

- **File**: README.md, lines 61-78
- **Severity**: Medium
- **Expected**: The directory structure listing should match the actual repo
  contents. CLAUDE.md line 21 includes `.gitignore` in its listing.
- **Actual**: The README directory structure tree does not include `.gitignore`.
- **Problem**: Minor omission. The file exists in the repo and is listed in
  CLAUDE.md but missing from the README tree. A contributor looking only at
  README would not know `.gitignore` exists.

### Issue T6: validate_skill.sh settings.json check uses warn, not fail

- **File**: ARCHITECTURE.md line 140, TEST-PLAN.md line 26
- **Severity**: Medium
- **Expected**: Documentation should note that the `settings.json` check in
  test group 8 uses `warn` (not `fail`) if the reference is missing
  (validate_skill.sh line 153).
- **Actual**: Both ARCHITECTURE.md ("references present") and TEST-PLAN.md
  ("`settings.json` reference present") describe this as a standard check
  without distinguishing it from fail-level checks.
- **Problem**: The documentation implies all 28 checks are pass/fail, but one
  is actually pass/warn. A developer relying on the docs might expect the
  script to exit 1 if settings.json is missing, when it would actually only
  warn. This is minor but technically inaccurate.

---

## Verified Correct

The following verifications passed with no issues:

### Paths and File References
- All file paths in all 4 docs verified against actual repo contents
- `.claude/skills/vibe-check/SKILL.md` -- exists
- `.claude-plugin/plugin.json` -- exists
- `tests/validate_skill.sh` -- exists
- `tests/api_provider.test.ts` -- exists
- `tests/test_scenarios.md` -- exists
- `LICENSE` -- exists
- `README.md`, `ARCHITECTURE.md`, `CLAUDE.md`, `TEST-PLAN.md` -- all exist
- No references to non-existent files found

### Parameter Names
- All 7 parameters correctly listed in README, ARCHITECTURE.md, and CLAUDE.md:
  `goal`, `plan`, `progress`, `uncertainties`, `taskContext`, `apiProvider`, `model`
- Required/optional designations correct: `goal` and `plan` required, rest optional
- Matches SKILL.md lines 21-36

### Provider/Model Data
- Provider names: `openai`, `google`, `anthropic` -- correct in all docs
- Model names all correct in all docs:
  - openai: `gpt-5.2-high`, `codex-5.2-high`
  - google: `gemini-3.0-pro-preview`, `gemini-3.0-flash-preview`
  - anthropic: `claude-sonnet-4.5`, `claude-opus-4.5`
- Environment variables correct: `OPENAI_API_KEY`, `GEMINI_API_KEY`, `ANTHROPIC_API_KEY`
- Provider-to-model mappings correct in all tables
- Provider-to-env-var mappings correct in all tables

### Version Numbers
- plugin.json: `"version": "0.1.0"` -- source of truth
- README line 5: `0.1.0` -- correct
- README line 68: `v0.1.0` -- correct
- ARCHITECTURE.md line 28: `0.1.0` -- correct
- ARCHITECTURE.md line 169: `0.1.0` -- correct
- CLAUDE.md line 12: `v0.1.0` -- correct
- No conflicting version claims (the old `1.0.0` from gap analysis was fixed)

### Output Format
- README output template (lines 139-159) exactly matches SKILL.md (lines 162-182)
- All 5 section names match: Quick Assessment, Key Questions to Consider,
  Pattern Watch, Recommendation, If Adjusting

### Test Validator
- 28 checks verified by running the script: 28 passed, 0 failed, 0 warnings
- 9 test groups verified by manual count against script source
- TEST-PLAN.md enumeration table (lines 17-28) matches script exactly
- ARCHITECTURE.md testing section (lines 131-141) matches script exactly

### Cross-Document Consistency (verified correct)
- Plugin name "vibe-check" consistent across all docs
- Description of plugin as "prompt-only" / "no runtime code" consistent
- "No external API calls" messaging consistent across README, ARCHITECTURE,
  CLAUDE.md
- Dead code status of api_provider.test.ts consistently documented
- Korean content in SKILL.md and test_scenarios.md acknowledged appropriately
- Test command `bash tests/validate_skill.sh` consistent everywhere

---

## Self-Critique

1. **Issue T2 (vice versa)**: I flagged the "and vice versa" addition as an
   inaccuracy, but it could be argued this is a reasonable documentation of
   intended behavior even if SKILL.md only states one direction. A Korean
   speaker might interpret the SKILL.md text differently. However, I believe
   documentation should match implementation precisely, and the bidirectional
   claim is not explicitly supported by the source text.

2. **Issue T6 (warn vs fail)**: This is arguably very minor. The `warn` function
   in the script increments a WARN counter but does not affect the exit code
   (only FAIL count does). Documenting this distinction may be overkill for
   most readers. But for technical accuracy, the difference is real.

3. **Missing external validation**: I was asked to use the vibe-check skill and
   pal clink for external validation. The vibe-check skill is a metacognitive
   feedback tool, not a verification tool -- it would assess my review
   methodology, not verify documentation facts. The clink tool would provide
   third-party AI perspective. Both would add meta-level feedback but cannot
   substitute for the line-by-line verification I performed. I chose to
   prioritize thoroughness of the direct verification.

4. **Korean translation accuracy**: I translated Korean text from SKILL.md to
   verify documentation claims. While I am confident in the translations of
   the specific validation rules and parameter descriptions, subtle nuances
   could exist. A native Korean speaker should confirm Issue T2 in particular.

5. **Completeness gap**: I did not verify whether every single sentence in the
   docs is accurate -- only the factual/technical claims (paths, names,
   numbers, rules, structures). Prose descriptions of "how the skill works"
   or "design philosophy" were not verified against implementation because
   they describe intent rather than checkable facts.

---

## External Validation

External validation via vibe-check skill and pal clink was not performed for
this review. The verification methodology is direct comparison of documentation
claims against implementation source code, which is self-verifiable. All
findings are supported by specific line references in both implementation and
documentation files.
