# Implementation Plan: Korean→English + Dead Code Cleanup

## Tasks
1. **SKILL.md Korean→English** (HIGH RISK - core artifact, validator depends on it)
2. **test_scenarios.md Korean→English**
3. **Delete api_provider.test.ts**
4. **Update all documentation** to reflect changes

## SKILL.md Translation Scope

Lines with Korean content to translate:
- Line 4: argument-hint `[목표]` → `[goal]`, `[계획]` → `[plan]`, `[모델명]` → `[model]`, `(또는 자유 형식 텍스트)` → `(or free-form text)`
- Line 19: "사용자는 구조화된 형식..." → instruction about parsing input
- Line 21: "(필수)" → "(Required)"
- Lines 25-26: Korean parameter descriptions
- Line 28: "(선택)" → "(Optional)"
- Lines 32-36: Korean parameter descriptions
- Line 48: "구조화된 형식:" → "Structured format:"
- Lines 51-57: Korean example text → English equivalents
- Line 60: "자연어 형식:" → "Natural language format:"
- Line 62: Korean example → English equivalent
- Line 65: "간단한 형식:" → "Simple format:"
- Line 67: Korean example → English equivalent
- Line 70: "### API Provider 및 Model 처리" → "### API Provider and Model Handling"
- Line 72: "#### 기본 동작" → "#### Default Behavior"
- Lines 73-74: Korean default behavior text → English
- Line 76: "#### Provider별 특성" → "#### Provider Characteristics"
- Lines 78-87: Korean model descriptions → English
- Line 89: "#### 설정 방법" → "#### Configuration"
- Line 91: Korean instruction → English
- Line 102: "#### 유효성 검사" → "#### Validation Rules"
- Lines 103-105: Korean validation rules → English
- Line 115: "위 파라미터 형식에 따라..." → English parsing instruction

## Validator Safety Check

The validator greps for these patterns (ALL already English/code):
- `^---$` ✓ not affected
- `^name: vibe-check$` ✓ not affected
- `^description:` ✓ not affected
- `^required_environment:` ✓ not affected
- `  - OPENAI_API_KEY` etc. ✓ not affected
- `` `openai` `` etc. (case-insensitive) ✓ not affected
- Model names (plain text) ✓ not affected
- `` `apiProvider` `` etc. ✓ not affected
- `environment_variables` ✓ not affected
- `settings.json` ✓ not affected
- `| Provider | Models | Environment Variable |` ✓ not affected

**Conclusion**: All validator patterns match structural/code elements that are already English. Translation of surrounding Korean text will NOT break the validator.

## Documentation Updates Needed

After implementation changes:
- README.md: Remove all "bilingual" / "Korean" references, update Language Note
- ARCHITECTURE.md: Remove "Bilingual Content" section, update frontmatter reproduction
- CLAUDE.md: Remove Korean mentions, update key facts
- TEST-PLAN.md: Update test_scenarios.md status, remove api_provider.test.ts references

## Risk Assessment
- SKILL.md: HIGH - must preserve exact structure, parameter names, tables
- validate_skill.sh: NONE - not modified, but must still pass
- test_scenarios.md: LOW - straightforward translation
- api_provider.test.ts: NONE - just delete
- Docs: MEDIUM - many references to update consistently
