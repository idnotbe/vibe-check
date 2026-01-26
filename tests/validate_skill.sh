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
WARN=0

# Test functions
pass() {
    echo -e "${GREEN}✓ PASS${NC}: $1"
    PASS=$((PASS + 1))
}

fail() {
    echo -e "${RED}✗ FAIL${NC}: $1"
    FAIL=$((FAIL + 1))
}

warn() {
    echo -e "${YELLOW}⚠ WARN${NC}: $1"
    WARN=$((WARN + 1))
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
if grep -q "^---$" "$SKILL_FILE"; then
    pass "Frontmatter delimiters found"
else
    fail "Frontmatter delimiters not found"
fi

if grep -q "^name: vibe-check$" "$SKILL_FILE"; then
    pass "Skill name defined correctly"
else
    fail "Skill name not defined or incorrect"
fi

if grep -q "^description:" "$SKILL_FILE"; then
    pass "Description defined"
else
    fail "Description not defined"
fi

# Test 3: Check required_environment
echo ""
echo "3. Checking required_environment..."
if grep -q "^required_environment:" "$SKILL_FILE"; then
    pass "required_environment section exists"
else
    fail "required_environment section not found"
fi

for key in "OPENAI_API_KEY" "GEMINI_API_KEY" "ANTHROPIC_API_KEY"; do
    if grep -q "  - $key" "$SKILL_FILE"; then
        pass "$key listed in required_environment"
    else
        fail "$key not listed in required_environment"
    fi
done

# Test 4: Check API providers documentation
echo ""
echo "4. Checking API provider documentation..."
for provider in "openai" "google" "anthropic"; do
    if grep -qi "\`$provider\`" "$SKILL_FILE"; then
        pass "Provider '$provider' documented"
    else
        fail "Provider '$provider' not documented"
    fi
done

# Test 5: Check model documentation
echo ""
echo "5. Checking model documentation..."
MODELS=(
    "gpt-5.2-high"
    "codex-5.2-high"
    "gemini-3.0-pro-preview"
    "gemini-3.0-flash-preview"
    "claude-sonnet-4.5"
    "claude-opus-4.5"
)

for model in "${MODELS[@]}"; do
    if grep -q "$model" "$SKILL_FILE"; then
        pass "Model '$model' documented"
    else
        fail "Model '$model' not documented"
    fi
done

# Test 6: Check parameter documentation
echo ""
echo "6. Checking parameter documentation..."
for param in "apiProvider" "model" "goal" "plan" "progress" "uncertainties" "taskContext"; do
    if grep -q "\`$param\`" "$SKILL_FILE"; then
        pass "Parameter '$param' documented"
    else
        fail "Parameter '$param' not documented"
    fi
done

# Test 7: Check for deprecated modelOverride
echo ""
echo "7. Checking for deprecated parameters..."
if grep -q "modelOverride" "$SKILL_FILE"; then
    fail "Deprecated 'modelOverride' parameter still present"
else
    pass "No deprecated 'modelOverride' parameter found"
fi

# Test 8: Check environment variable configuration example
echo ""
echo "8. Checking configuration examples..."
if grep -q "environment_variables" "$SKILL_FILE"; then
    pass "Environment variables configuration example present"
else
    fail "Environment variables configuration example missing"
fi

if grep -q "settings.json" "$SKILL_FILE"; then
    pass "settings.json reference present"
else
    warn "settings.json reference not found"
fi

# Test 9: Check provider-model mapping table
echo ""
echo "9. Checking provider-model mapping..."
if grep -q "| Provider | Models | Environment Variable |" "$SKILL_FILE"; then
    pass "Provider-model mapping table exists"
else
    fail "Provider-model mapping table not found"
fi

# Summary
echo ""
echo "========================================"
echo "Validation Summary"
echo "========================================"
echo -e "${GREEN}Passed${NC}: $PASS"
echo -e "${RED}Failed${NC}: $FAIL"
echo -e "${YELLOW}Warnings${NC}: $WARN"
echo ""

if [ $FAIL -eq 0 ]; then
    echo -e "${GREEN}All validations passed!${NC}"
    exit 0
else
    echo -e "${RED}Some validations failed. Please review the errors above.${NC}"
    exit 1
fi
