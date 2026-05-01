# Phase A — Validator CRLF / BOM / Trailing-Whitespace Tolerance

Scope: follow-up #1 from `temp/61-validator-deferred-followups.md`. Only
`tests/validate_skill.sh` was touched; `SKILL.md` is unchanged
(md5 `754c97a1ab352ffbca00ce2abef8afa2`).

## Diff (core lines only)

```diff
-SKILL_FILE="$SCRIPT_DIR/../.claude/skills/vibe-check/SKILL.md"
+# SKILL_FILE is overridable via environment so test fixtures (e.g. CRLF/BOM
+# variants) can be validated without touching the canonical file in-tree.
+SKILL_FILE="${SKILL_FILE:-$SCRIPT_DIR/../.claude/skills/vibe-check/SKILL.md}"
```

```diff
 if FRONTMATTER=$(awk '
-    NR == 1 && $0 != "---" { exit 1 }
+    # POSIX octal byte escapes (\357\273\277 = EF BB BF). See portability note.
+    NR == 1 { sub(/^\357\273\277/, "") }
+    NR == 1 && !match($0, /^---[[:space:]]*$/) { exit 1 }
     NR == 1 { in_fm=1; next }
-    in_fm && /^---$/ { closed=1; exit 0 }
-    in_fm && /^[a-zA-Z_-]+:/ { print; next }
-    in_fm && /^[[:space:]]*$/ { print; next }
+    in_fm && /^---[[:space:]]*$/ { closed=1; exit 0 }
+    in_fm && /^[a-zA-Z_-]+:/ { sub(/\r$/, ""); print; next }
+    in_fm && /^[[:space:]]*$/ { sub(/\r$/, ""); print; next }
     in_fm { exit 1 }
     END { exit !closed }
 ' "$SKILL_FILE"); then
```

(A short comment block was also added above the awk explaining the
tolerance contract — see file for full text.)

## Why each change

1. **`SKILL_FILE` env override** — lets `SKILL_FILE=/tmp/fixture.md bash
   tests/validate_skill.sh` exercise variant inputs without mutating the
   canonical artifact. Default value is identical to the old hard-coded
   path, so existing call sites keep working.
2. **`sub(/^\357\273\277/, "")` on NR==1** — strips a UTF-8 BOM (EF BB BF)
   if present so the line-1 `---` match isn't blocked by 3 phantom bytes.
   Editors on Windows and some macOS workflows occasionally insert this.
   Octal byte escapes are used (not hex `\xEF…`) because POSIX awk mandates
   octal byte escapes inside ERE while hex byte escapes are
   implementation-defined.
3. **`/^---[[:space:]]*$/` for both opener and closer** — a CRLF checkout
   appends `\r` to every line (which `[[:space:]]` covers) and editors
   that don't auto-trim leave a trailing space. The looser regex absorbs
   both without admitting any non-whitespace content.
4. **`sub(/\r$/, "")` before `print`** — the captured frontmatter is
   piped to downstream string-equality checks (`= "name: vibe-check"`).
   Without this, a CRLF file would print `name: vibe-check\r`, which is
   not equal to the expected literal and would FAIL Test 3 even after
   Test 2 passed. Stripping `\r` here keeps the binding intact.

## Scenario results (11/11 as expected)

| # | Variant | Expected | Got |
|---|---------|----------|-----|
| 1 | Original SKILL.md | 17/17 PASS | 17/17 PASS, exit 0 |
| 2 | LF→CRLF whole file | Test 2 PASS (frontmatter recognized) | 17/17 PASS, exit 0 |
| 3 | UTF-8 BOM prepended | Test 2 PASS | 17/17 PASS, exit 0 |
| 4 | First `---` has trailing space | Test 2 PASS | 17/17 PASS, exit 0 |
| 5 | Closing `---` removed | Test 2 FAIL | FAIL (Test 2 + name + desc), exit 1 |
| 6 | First line `--` (broken opener) | Test 2 FAIL | FAIL (Test 2 + name + desc), exit 1 |
| 7 | BOM + CRLF (whole-file CRLF + BOM on line 1) | Test 2 PASS | 17/17 PASS, exit 0 |
| 8 | First line `--- \r` (no BOM, trailing space + CRLF) | Test 2 PASS | 17/17 PASS, exit 0 |
| 9 | Partial-print reset guard: list-form line mid-frontmatter (after a valid `name:`/`description:`/`argument-hint:`) so awk hits `in_fm { exit 1 }` *after* having already printed earlier lines | Test 2 FAIL **and** name/desc FAIL (FRONTMATTER reset to "") | FAIL (Test 2 + name + desc), exit 1 |
| 10 | Opener with **leading** whitespace (`   ---`) — leading space is *not* covered by `^---[[:space:]]*$` since `^` anchors before any whitespace | Test 2 FAIL | FAIL (Test 2 + name + desc), exit 1 |
| 11 | Frontmatter line with inline comment (`name: vibe-check # main`) — the `^[a-zA-Z_-]+:` line predicate matches (anchor only checks the prefix), so Test 2 still passes; the inline-comment text is captured and the name *string-equality* check rejects it | Test 2 PASS, **Test 3 name FAIL** (16/17) | Test 2 PASS, name FAIL, desc PASS, exit 1 |

For #2/#3/#4/#7/#8 the spec only required the delimiter check to pass; in
practice the full 17/17 also passes because the awk-side `\r` strip and
BOM strip keep the extracted `$FRONTMATTER` byte-for-byte equal to the LF
reference.

For #9: the awk script `print`s the early valid frontmatter lines to its
internal buffer, then exits 1 when it hits the `- not_a_kv_line`. Because
awk's exit code is non-zero, the surrounding `FRONTMATTER=$(...)`
command-substitution propagates a non-zero status — the `if` branches to
the failure arm, which both reports the FAIL and explicitly resets
`FRONTMATTER=""`. The downstream `name:` and `description:` checks then
operate on an empty string and FAIL as designed. This confirms the
`set -e` regression guard from the previous patch (PR #20 series): even
with partial awk output, the binding stays bound to "frontmatter
recognized" rather than leaking previously-printed lines.

The canonical SKILL.md still produces 17/17 PASS, exit 0 (md5
`754c97a1ab352ffbca00ce2abef8afa2` re-verified before and after the
octal change).

## Awk portability note

The script uses three constructs worth flagging:

- **`sub(/^\357\273\277/, "")`** — POSIX awk **octal byte escape** for the
  UTF-8 BOM (EF BB BF). POSIX explicitly mandates octal byte escapes
  inside ERE, so behavior is identical across gawk, mawk, and BusyBox
  awk *by spec* — no implementation-specific verification needed. The
  earlier draft used hex (`\xEF\xBB\xBF`), which is implementation-defined
  per POSIX (gawk and mawk happen to support it, BusyBox awk's support is
  documented but was unverified on this host); switching to octal removes
  that concern. Verified locally with **gawk 5.2.1** and **mawk 1.3.4**
  against scenarios s3 (BOM-only) and s7 (BOM + CRLF) — both produce
  identical, BOM-stripped output.
- **`match($0, /^---[[:space:]]*$/)`** — `match()` and POSIX bracket
  classes are POSIX-mandated; both gawk and mawk handle them.
- **`sub(/\r$/, "")`** — bare `\r` in a regex is universally supported.

Direct verification: ran the production awk block under `gawk` and
`mawk` against the s2 (CRLF), s3 (BOM), s4 (trailing-space), s7
(BOM + CRLF), and s8 (`--- \r`) fixtures — all five produced identical,
correct stripped output and exit code 0 under both implementations.

## Known limitations

- **Quoted YAML scalars** (`name: "vibe-check"`) still fail Test 3
  binding by string equality. This is the intentional schema-enforcer
  carve-out documented as deferred #4 in `temp/61-…` — out of scope here.
- **Empty `description:` value** still passes (deferred #2). Untouched.
- **`echo "$FRONTMATTER" | grep …` style** still in use for downstream
  binding (deferred #3). Phase B+C will migrate to `printf "%s\n"`.
- **Mid-frontmatter BOM or stray UTF-8 BOM further into the file** is
  not handled — only line 1, and only via the POSIX octal byte-escape
  `sub(/^\357\273\277/, "")` (so the strip itself is portability-safe by
  spec). Line 1 is the realistic insertion point; deeper BOMs would
  require per-line handling that isn't worth the complexity here.
- **Tab-only delimiter line** (`---\t`) passes because `[[:space:]]`
  covers tabs. That's almost certainly the right call (it's still
  whitespace per YAML), but listed for completeness.

## File path

- /home/idnotbe/projects/vibe-check/tests/validate_skill.sh
