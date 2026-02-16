# V1 Review Fixes Applied

## Issues Fixed from Tech Review (temp/04-v1-tech-review.md)

| Issue | Severity | Fix Applied |
|-------|----------|-------------|
| T1: ARCHITECTURE.md argument-hint paraphrase | Medium | Restored verbatim Korean text from SKILL.md and added translation note |
| T2: "and vice versa" not in SKILL.md | Medium | Removed "and vice versa" from both README.md and ARCHITECTURE.md |
| T3: README enumerates 8 test groups but claims 9 | High | Added "file existence" to the enumeration |
| T4: "should" vs "must" inconsistency | Low | Standardized to "must" everywhere |
| T5: README directory structure missing .gitignore | Medium | Added .gitignore to directory tree |
| T6: settings.json check uses warn not fail | Medium | Added "(pass/warn)" notation in TEST-PLAN.md check table |

## Issues Fixed from UX Review (temp/05-v1-ux-review.md)

| Priority | Issue | Fix Applied |
|----------|-------|-------------|
| P1 | Migration steps only in ARCHITECTURE.md | Added "Migrating from MCP Version" section to README with cross-reference to ARCHITECTURE.md |
| P2 | "should" vs "must" | Combined with T4 above |
| P4 | "Phantom configuration" frustration | Added troubleshooting entry "Output looks the same with and without apiProvider/model" |
| P5 | No parameter mapping for MCP migrators | Added note in migration section: "Parameter names are the same in both versions" |

## Issues Not Fixed (by design)

| Issue | Reason |
|-------|--------|
| P3: Filled-in output example | Low priority; template with placeholders is sufficient |
| P6: Changelog | Requires future release process, not a current doc gap |

## Verification
- `bash tests/validate_skill.sh`: 28/28 pass (SKILL.md untouched)
- No implementation files modified
