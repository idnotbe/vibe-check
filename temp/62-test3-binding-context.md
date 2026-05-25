# Phase 2 Context — Test 3 Binding to Frontmatter (R1 fixes applied)

## What changed
File: `tests/validate_skill.sh` — Test 2 block (lines 47-83).

### Three changes
1. **Validate-and-extract awk** (single source of truth): same awk validates frontmatter structure AND outputs the frontmatter lines. Wrapped as `if FRONTMATTER=$(awk ...); then pass; else fail; FRONTMATTER=""; fi`. The reset on else wipes any partial-print stdout that leaked from a failed awk.
2. **Bind name check to frontmatter**: was `grep -q "^name: vibe-check$" "$SKILL_FILE"` (whole file). Now `[ "$(echo "$FRONTMATTER" | grep '^name:')" = "name: vibe-check" ]`. The string equality also catches duplicate keys (multi-line capture won't equal the single-line expected value).
3. **Bind description check to frontmatter + duplicate detection**: was `grep -q "^description:" "$SKILL_FILE"`. Now `[ "$(echo "$FRONTMATTER" | grep -c '^description:')" -eq 1 ]`. Requires exactly one description key.

### Why
- **Body smuggle** (R2 finding from previous phase): `name: vibe-check` in body markdown satisfied whole-file grep even with broken frontmatter. Closed by binding to extracted frontmatter.
- **Duplicate key** (R1 finding this phase): `name: vibe-check\nname: evil-override` would still pass a `grep -q` because the first line matches; YAML parsers take the LAST value, so the loaded skill name would be "evil-override" while validator passed. Closed by string-equality check (multi-line capture fails comparison).

## Sanity-test results (12/12 correct across both phase iterations)

Previous (pre-duplicate-key fix): 7/7 scenarios.

After R1 duplicate-key fix:
| # | Scenario | Expected | Got |
|---|----------|----------|-----|
| A1 | Real SKILL.md | DELIM_PASS NAME_PASS DESC_PASS | ✓ |
| A2 | Duplicate `name:` with vibe-check first then evil | DELIM_PASS NAME_FAIL DESC_PASS | ✓ |
| A3 | Duplicate `description:` | DELIM_PASS NAME_PASS DESC_FAIL | ✓ |
| A4 | Duplicate `name:` both vibe-check | DELIM_PASS NAME_FAIL DESC_PASS | ✓ |
| A5 | R2 body smuggle | DELIM_PASS NAME_FAIL DESC_FAIL | ✓ |
| A6 | Wrong skill name | DELIM_PASS NAME_FAIL DESC_PASS | ✓ |

A4 reasoning: even when both duplicate names happen to equal `vibe-check`, treating as malformed is safer than silently accepting (no need for two name keys).

## Validator full run
17/17 PASS, exit 0.

## Design decisions / R1 deferrals

R1 (gemini) found 4 items:
- HIGH: duplicate keys → **fixed** (this commit).
- MEDIUM: CRLF line endings → deferred to follow-up #1.
- LOW: empty description value → deferred to follow-up #2.
- LOW: echo→printf style → deferred to follow-up #3 (R1 acknowledges not a real bug given the awk filter).

R0 (codex) had verified set -e safety, POSIX awk portability (gawk + mawk), single-source-of-truth invariant, and rejected simpler `head -n N` alternatives.
