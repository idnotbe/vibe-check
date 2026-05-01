# Phase B+C — Empty `description` Guard + `echo`→`printf` Migration

Scope: follow-ups #2 (LOW) and #3 (LOW) from
`temp/61-validator-deferred-followups.md`. Bundled because they touch the
same lines (the three downstream `$FRONTMATTER` greps). Only
`tests/validate_skill.sh` was touched; SKILL.md is unchanged
(md5 `754c97a1ab352ffbca00ce2abef8afa2`, re-verified before and after).

## Diff (core lines only)

```diff
-if [ "$(echo "$FRONTMATTER" | grep '^name:')" = "name: vibe-check" ]; then
+if [ "$(printf "%s\n" "$FRONTMATTER" | grep '^name:')" = "name: vibe-check" ]; then
     pass "Skill name defined correctly"
 else
     fail "Skill name not defined, incorrect, or duplicated"
 fi

-if [ "$(echo "$FRONTMATTER" | grep -c '^description:')" -eq 1 ]; then
-    pass "Description defined"
-else
+if [ "$(printf "%s\n" "$FRONTMATTER" | grep -c '^description:')" -ne 1 ]; then
     fail "Description not defined or duplicated"
+elif ! printf "%s\n" "$FRONTMATTER" | grep -qE '^description:[[:space:]]+[^"'\''#[:space:]]'; then
+    fail "Description value is empty"
+else
+    pass "Description defined"
 fi
```

The non-empty regex narrows the "first non-whitespace char" class from
`[^[:space:]]` (any non-space) to `[^"'#[:space:]]` (any char that is
not a double-quote, single-quote, `#`, or whitespace). This rejects
three additional YAML-semantic-empty inputs that the wider class
would have let through:

| Input | First non-space char after `description:` | Result |
|-------|--------------------------------------------|--------|
| `description: ""` | `"` | reject (quoted-empty scalar) |
| `description: ''` | `'` | reject (quoted-empty scalar) |
| `description: # comment only` | `#` | reject (`#` starts a YAML comment, value is empty) |
| `description: foo # trailing comment` | `f` | PASS (first non-space char is `f`; trailing comment is not the value) |
| `description: x` | `x` | PASS |

A short comment block was added above each check explaining the
two-step structure, why `printf` replaced `echo`, and (above the
description check specifically) why the regex character class is
narrowed to `[^"'#[:space:]]` instead of plain `[^[:space:]]`.

## Option choice for B: **Option A (separate guard)**

Picked Option A — the duplicate-count check and the non-empty check are
separate `if`/`elif` arms, so the failure message distinguishes
"Description not defined or duplicated" (count != 1) from "Description
value is empty" (count == 1 but no non-whitespace after the colon).

Rationale:

- Phase 2 explicitly introduced duplicate-detection as a named property
  (per `temp/61` Resolved §1). Collapsing both into a single
  `grep -cE '…[[:space:]]+[^[:space:]]'` (Option B) would lose that
  signal: a duplicate key with one empty value and one non-empty value
  would report "empty" when the real defect is duplication, and a
  duplicate where both values are non-empty would report "not defined or
  duplicated" only by accident of the count being 2, with no way to
  surface "empty" failures distinctly.
- The branching is only one extra `elif`; complexity cost is negligible.
- Option B's only advantage (one fewer line) does not outweigh losing
  diagnostic precision in a no-CI repo where contributors read failure
  messages directly.
- Quoted-empty (`""`/`''`) and comment-only (`# …`) handling fits the
  same Option A arm: the narrowed character class flips them from PASS
  to FAIL with the "Description value is empty" message — the most
  accurate diagnostic for an input whose loaded YAML value is an empty
  string. This is consistent with the schema enforcer policy (follow-up
  #4) that already rejects quoted scalars; quoted-*empty* is the
  natural extension of that policy and an explicit, not accidental,
  rejection.

## C migration

All three downstream `$FRONTMATTER` greps now pipe via `printf "%s\n"`.
Verified: `grep -n 'FRONTMATTER' tests/validate_skill.sh` shows zero
`echo "$FRONTMATTER"` occurrences (only awk-side
`FRONTMATTER=$(awk …)` capture, the `FRONTMATTER=""` reset, and the
three `printf "%s\n" "$FRONTMATTER" | grep …` invocations).

A 3-line comment above the `name:` check documents *why* `printf` is
used (latent decoupling from echo's `-e`/`-n`/`-E` interpretation —
currently safe because the awk `^[a-zA-Z_-]+:` filter forbids leading
dashes, but the coupling is removed).

## Scenario results (11/11 as expected)

| # | Variant | Expected | Got |
|---|---------|----------|-----|
| 1 | Original SKILL.md | 17/17 PASS | 17/17 PASS, exit 0 |
| 2 | `description:` (no value) | empty FAIL | "Description value is empty" FAIL, 16/17, exit 1 |
| 3 | `description: ` (single space) | empty FAIL | "Description value is empty" FAIL, 16/17, exit 1 |
| 4 | `description: ""` | empty FAIL (NEW) | "Description value is empty" FAIL, 16/17, exit 1 |
| 5 | `description: ''` | empty FAIL (NEW) | "Description value is empty" FAIL, 16/17, exit 1 |
| 6 | `description: # comment only` | empty FAIL (NEW) | "Description value is empty" FAIL, 16/17, exit 1 |
| 7 | `description: foo # trailing comment` | PASS | 17/17 PASS, exit 0 |
| 8 | `description: x` | PASS | 17/17 PASS, exit 0 |
| 9 | Two non-empty `description:` lines | duplicate FAIL | "Description not defined or duplicated" FAIL, 16/17, exit 1 |
| 10 | BOM + CRLF whole file (Phase A s7) | 17/17 PASS | 17/17 PASS, exit 0 |
| 11 | mid-FM list-form line (Phase A s9) | Test 2 FAIL + name FAIL + desc FAIL | 3 FAILs, 14/17, exit 1 |

### Scenario 9 detail (Option A win)

Input frontmatter:

```yaml
---
name: vibe-check
description: Metacognitive sanity check…
description: another value
argument-hint: goal: …
---
```

Output: `✗ FAIL: Description not defined or duplicated` (the
"duplicated" path), **not** the "empty" path. This is the diagnostic
distinction Option A preserves and Option B would have collapsed.

### Scenario 6 detail (new comment-only rejection)

Input frontmatter line: `description: # comment only`

Without the narrowed class, `[[:space:]]+[^[:space:]]` matched `: #`
(non-space char after the colon-space is `#`) and the line PASSED —
even though the YAML-loaded value is the empty string because `#`
opens a comment. With `[^"'#[:space:]]`, `#` is excluded from the
"first real char" class and the regex falls through to the "empty"
arm.

### Scenario 11 detail (Phase A s9 regression)

s11 is the most informative regression spot: when awk exits non-zero
from `in_fm { exit 1 }`, the bash command-substitution propagates the
failure, the `if` branches to the failure arm, and `FRONTMATTER` is
explicitly reset to `""`. The downstream description check still hits
the "count != 1" arm (count is 0), reporting
"Description not defined or duplicated" — the same message and same
3-FAIL fingerprint as Phase A. The new "empty" arm is unreachable on
an empty `$FRONTMATTER` because the count check fires first; the
narrowed character class therefore has no effect on this path.

### Scenario 10 detail (Phase A s7 regression)

BOM stripped on line 1 + CRLF tolerance on `---` delimiters and on
captured key:value lines: 17/17 PASS, identical to Phase A. The
description value `Metacognitive sanity check…` survives the `\r`
strip in the awk capture, and the narrowed regex's first non-space
char is `M` (alphanumeric) — passes both pre- and post-fix.

## Known limitations

### Now blocked (was previously a bypass)

- **Quoted-empty scalars** (`description: ""`, `description: ''`).
  YAML-semantic empty; previously matched `[[:space:]]+[^[:space:]]`
  via the `"` or `'` char and PASSED. Now rejected by the narrowed
  `[^"'#[:space:]]` class.
- **Comment-only values** (`description: # …`). YAML-semantic empty
  because `#` opens a comment. Previously PASSED; now rejected.

### Still in scope but intentional

- **Whitespace-only value detection is regex-based, not "trim and
  compare"**. `description: \t` (tab after colon-space) FAILS
  ("empty") because `[[:space:]]+[^"'#[:space:]]` requires a real
  non-whitespace, non-quote, non-`#` char. `description: x ` (trailing
  whitespace after a real value) PASSES because the first non-space
  char is `x`. Correct.
- **No length / content quality check**. `description: a` passes (s8
  variant). The validator only enforces "at least one
  qualifying-non-whitespace char"; semantic quality (length, sentence
  structure) is out of scope.
- **Quoted YAML scalars with content** (`description: "foo"`) still
  string-equality-fail / regex-fail (deferred #4, intentional schema
  enforcer). Quoted-empty is now a natural sub-case of the same policy.
- **`printf` portability**: `printf "%s\n"` is POSIX-mandated and
  identical across bash builtin, dash, busybox, and `/usr/bin/printf`.
  No portability concern.
- The new `printf "%s\n" "$FRONTMATTER"` produces an extra trailing
  newline vs `echo` (which also adds one). Net effect on `grep` is
  identical because `grep` is line-oriented and ignores trailing empty
  lines for match purposes.

### Edge cases the narrowed class still does not catch

- `description: |` or `description: >` (block scalar indicators).
  First non-space char is `|` / `>`, both alphanumeric-adjacent and
  not in the exclusion list — would PASS the regex but the YAML value
  is whatever follows on indented continuation lines. The frontmatter
  awk filter (`^[a-zA-Z_-]+:` for key lines, blank-line for the rest)
  rejects the indented continuation as not-a-kv-line, so block scalars
  fail Test 2 ("Frontmatter delimiters not found") before reaching the
  description check. Defense-in-depth holds, just at a different layer.
- `description: !!str` (YAML tag with no value). First non-space char
  is `!`, not in the exclusion list — would PASS. Acceptable: the
  schema enforcer policy (follow-up #4) covers explicit-tag rejection
  if it becomes a real concern; not a known bypass today.

## File path

- /home/idnotbe/projects/vibe-check/tests/validate_skill.sh
