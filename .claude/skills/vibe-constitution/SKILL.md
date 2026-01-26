---
name: vibe-constitution
description: Manage session-specific behavioral rules and guidelines. Use to set constraints, check active rules, or reset guidelines for the current session.
argument-hint: <update|reset|check> [rules...]
disable-model-invocation: true
---

# Vibe Constitution - Session Rules Manager

Manage behavioral rules and constraints for the current session.

## Command Syntax

```
/vibe-constitution update "new rule to add"
/vibe-constitution reset "rule1" "rule2" "rule3"
/vibe-constitution check
```

**Arguments received**: $ARGUMENTS

## Commands

### `update` - Add a Rule
Adds a new rule to the current session's constitution.
- Maximum 50 rules per session
- Duplicate rules are ignored

### `reset` - Replace All Rules
Replaces all existing rules with the provided list.
- Clears previous rules
- Sets new rules from arguments
- Maximum 50 rules

### `check` - View Current Rules
Displays all active rules for the current session.

## Your Task

Based on the command in arguments:

### For `update`:
1. Read current rules from `data/constitution.json`
2. Add the new rule if not duplicate
3. Enforce 50-rule limit (remove oldest if exceeded)
4. Save updated rules
5. Confirm the addition

### For `reset`:
1. Parse all rules from arguments
2. Validate (max 50, non-empty)
3. Replace entire rule set
4. Save to `data/constitution.json`
5. Confirm the reset

### For `check`:
1. Read current rules
2. Display formatted list
3. Show rule count

## Output Format

### For `update`:
```
## Constitution Updated

**Added Rule**: [the new rule]

### Active Rules ([count]/50)
1. [rule 1]
2. [rule 2]
...
```

### For `reset`:
```
## Constitution Reset

**New Rules Set**: [count] rules

### Active Rules
1. [rule 1]
2. [rule 2]
...
```

### For `check`:
```
## Current Constitution

**Active Rules**: [count]/50

1. [rule 1]
2. [rule 2]
...

[If no rules: "No rules set for this session."]
```

## Data File Format

Store rules in `data/constitution.json`:

```json
{
  "rules": [
    "Always explain before implementing",
    "Prefer simple solutions",
    "Ask for confirmation before file changes"
  ],
  "updated": "2026-01-26T10:00:00Z"
}
```

## Rule Guidelines

Good rules are:
- Specific and actionable
- Focused on behavior, not outcomes
- Clear and unambiguous

Example good rules:
- "Always run tests before committing"
- "Explain approach before writing code"
- "Use TypeScript strict mode"
- "Limit functions to 50 lines"

Example poor rules:
- "Be better" (too vague)
- "Don't make mistakes" (not actionable)
- "Write good code" (subjective)

## Integration with Vibe Check

When `/vibe-check` is used, it should reference active constitution rules.

The rules provide context for evaluating whether a plan follows session guidelines.

## If No Arguments or Invalid Command

Show help:
```
## Vibe Constitution - Help

Manage session rules and guidelines.

**Commands:**
- `/vibe-constitution update "rule"` - Add a new rule
- `/vibe-constitution reset "r1" "r2"` - Replace all rules
- `/vibe-constitution check` - View current rules

**Current Status:**
[Show rule count or "No rules set"]
```

## Reading Current State

```
Current constitution:
!`cat data/constitution.json 2>/dev/null || echo '{"rules":[],"updated":null}'`
```
