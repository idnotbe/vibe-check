#!/bin/bash

# Vibe Check Skill Validation Script
# Validates the SKILL.md structure and configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_FILE="$SCRIPT_DIR/../.claude/skills/vibe-check/SKILL.md"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Counters
PASS=0
FAIL=0

# Test functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAIL=$((FAIL + 1))
}

echo "========================================"
echo "Vibe Check Skill Validation"
echo "========================================"
echo ""

# Test 1: Check if SKILL.md exists
echo "1. Checking SKILL.md existence..."
if [ -f "$SKILL_FILE" ]; then
    pass "SKILL.md exists"
else
    fail "SKILL.md not found at $SKILL_FILE"
    exit 1
fi

# Test 2: Check frontmatter
echo ""
echo "2. Validating frontmatter..."
# Frontmatter must use this repo's flat key:value shape: line 1 is "---",
# every line until the closing "---" is blank or a "key: ..." line (no
# lists, multi-line values, or comments), and the closer appears before any
# other content. Awk used because line-count bounds can be fooled when body
# horizontal rules shift after frontmatter edits. The same awk extracts the
# frontmatter into $FRONTMATTER so the name/description checks below are
# bound to the frontmatter block instead of grepping the whole file (which
# could be satisfied by smuggled body markdown).
if FRONTMATTER=$(awk '
    NR == 1 && $0 != "---" { exit 1 }
    NR == 1 { in_fm=1; next }
    in_fm && /^---$/ { closed=1; exit 0 }
    in_fm && /^[a-zA-Z_-]+:/ { print; next }
    in_fm && /^[[:space:]]*$/ { print; next }
    in_fm { exit 1 }
    END { exit !closed }
' "$SKILL_FILE"); then
    pass "Frontmatter delimiters found"
else
    fail "Frontmatter delimiters not found"
    FRONTMATTER=""
fi

# Equality (not grep -q) catches duplicate `name:` keys: a second `name: foo`
# would yield a multi-line capture that doesn't equal the expected single line,
# preventing a YAML "last value wins" bypass where the loaded name differs
# from what the validator saw.
if [ "$(echo "$FRONTMATTER" | grep '^name:')" = "name: vibe-check" ]; then
    pass "Skill name defined correctly"
else
    fail "Skill name not defined, incorrect, or duplicated"
fi

if [ "$(echo "$FRONTMATTER" | grep -c '^description:')" -eq 1 ]; then
    pass "Description defined"
else
    fail "Description not defined or duplicated"
fi

# Test 3: Check parameter documentation
echo ""
echo "3. Checking parameter documentation..."
for param in "goal" "plan" "progress" "uncertainties" "taskContext"; do
    if grep -q "\`$param\`" "$SKILL_FILE"; then
        pass "Parameter '$param' documented"
    else
        fail "Parameter '$param' not documented"
    fi
done

# Test 4: Check for deprecated modelOverride
echo ""
echo "4. Checking for deprecated parameters..."
if grep -q "modelOverride" "$SKILL_FILE"; then
    fail "Deprecated 'modelOverride' parameter still present"
else
    pass "No deprecated 'modelOverride' parameter found"
fi

# Test 5: Legacy feature absence (negative checks)
# These guard against silent reintroduction of the removed apiProvider/model
# feature. They use positive `if grep -q ...; then fail; else pass; fi` style
# rather than `! grep -q` because under `set -e` the inversion can swallow
# failures. Anchors are deliberately specific:
#   - `^required_environment:` matches only the frontmatter field, not prose.
#   - `^\| \`apiProvider\`` and `^\| \`model\`` match only parameter-table rows;
#     the legacy compat blockquote (which legitimately backtick-wraps these
#     param names) is allowed to coexist because it never appears as a table row.
# Trade-off for the API-key-name checks: a future doc legitimately mentioning
# (e.g.) "OPENAI_API_KEY is not required" would trip them. That is intentional
# for this no-CI repo — the prevention value outweighs the friction, and any
# future legitimate mention can update this script in the same commit.
echo ""
echo "5. Checking legacy feature absence..."

if grep -q "^required_environment:" "$SKILL_FILE"; then
    fail "Legacy 'required_environment:' frontmatter field still present"
else
    pass "No 'required_environment:' frontmatter field"
fi

if grep -q "^| \`apiProvider\`" "$SKILL_FILE"; then
    fail "Legacy 'apiProvider' parameter table row still present"
else
    pass "No 'apiProvider' parameter table row"
fi

if grep -q "^| \`model\`" "$SKILL_FILE"; then
    fail "Legacy 'model' parameter table row still present"
else
    pass "No 'model' parameter table row"
fi

if grep -q "| Provider | Models | Environment Variable |" "$SKILL_FILE"; then
    fail "Legacy provider-model mapping table header still present"
else
    pass "No provider-model mapping table header"
fi

for key in "OPENAI_API_KEY" "GEMINI_API_KEY" "ANTHROPIC_API_KEY"; do
    if grep -q "$key" "$SKILL_FILE"; then
        fail "Legacy API key name '$key' still present"
    else
        pass "No legacy API key name '$key'"
    fi
done

# Summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo -e "${GREEN}Passed${NC}: $PASS"
echo -e "${RED}Failed${NC}: $FAIL"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validations failed. Please review the errors above.${NC}"
    exit 1
fi
