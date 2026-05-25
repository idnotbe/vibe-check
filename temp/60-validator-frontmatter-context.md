# Phase 1 Context — Validator Frontmatter Fix

## What changed
File: `tests/validate_skill.sh`, lines 46-65 (Test 2 frontmatter delimiter check).

### Before
```bash
if grep -q "^---$" "$SKILL_FILE"; then
    pass "Frontmatter delimiters found"
else
    fail "Frontmatter delimiters not found"
fi
```

### After
```bash
# Frontmatter must be a well-formed YAML block: line 1 is "---", every line
# until the closing "---" is blank or "key: ..." shape, and the closer must
# appear before any other content. Awk used because line-count bounds can be
# fooled when body horizontal rules shift after frontmatter edits.
if awk '
    NR == 1 { if ($0 != "---") { bad=1; exit } ; next }
    /^---$/ { closed=1; exit }
    /^[a-zA-Z_-]+:/ { next }
    /^[[:space:]]*$/ { next }
    { bad=1; exit }
    END { if (bad || !closed) exit 1 }
' "$SKILL_FILE"; then
    pass "Frontmatter delimiters found"
else
    fail "Frontmatter delimiters not found"
fi
```

## Why
The original `grep -q "^---$"` matched ANY `---` line in the file, including markdown body horizontal rules (SKILL.md has them at lines 11 and 56). This meant the check would pass even with frontmatter entirely deleted, as long as a body horizontal rule existed.

A first-iteration fix using `head -n 20 + grep -c >= 2` was rejected because line 11 body rule still satisfies it. A second-iteration fix using `sed -n '2,10p' + grep -c >= 1` was rejected because deleting the line-5 closer shifts line 11 body rule to line 10, still inside the bound.

Awk-based structural check escapes this entire class of fragility: it walks the file from line 1, requires `---`, then keeps going through YAML key:value lines or blanks until it hits the next `---` (the closer). Anything else between aborts. If file ends before closer found, fail.

## Local sanity-test results (6/6 correct)
- Real file → PASS ✓
- Closer (line 5) deleted → FAIL ✓
- Opener (line 1) deleted → FAIL ✓
- Lines 1-5 deleted → FAIL ✓
- Empty file → FAIL ✓
- Only opener, no closer ever → FAIL ✓

## Validator full run
17/17 PASS, exit 0.

## Out of scope (deferred)
- CRLF / BOM / trailing whitespace tolerance on delimiter lines (real but uncommon for this Linux-edited repo).
- Multi-line YAML continuation values (SKILL.md doesn't use them).
- Quoted YAML values containing `---` (extremely unlikely in this codebase).
