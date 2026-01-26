---
name: vibe-learn
description: Record mistakes, preferences, and successes for future reflection. Use after making errors, discovering better approaches, or when the user expresses preferences.
argument-hint: <mistake|preference|success> <description> [solution]
disable-model-invocation: true
---

# Vibe Learn - Learning Record System

Record and track learning entries to improve future performance.

## Command Syntax

```
/vibe-learn mistake "description of what went wrong" "how it was fixed"
/vibe-learn preference "user preference to remember"
/vibe-learn success "what worked well"
```

**Arguments received**: $ARGUMENTS

## Categories

When recording mistakes, classify them into one of these categories:

| Category | Description | Example |
|----------|-------------|---------|
| `complex-solution-bias` | Chose unnecessarily complex approach | Used custom implementation instead of built-in |
| `feature-creep` | Added unrequested functionality | Added pagination when only list was needed |
| `premature-implementation` | Started coding before understanding | Wrote code before reading requirements |
| `misalignment` | Drifted from user's actual intent | Built feature A when user wanted feature B |
| `overtooling` | Used too many tools/dependencies | Added 5 libraries for simple task |
| `other` | Doesn't fit above categories | Misc errors |

## Your Task

Based on the arguments provided:

1. **Parse the input** to identify:
   - Type: `mistake`, `preference`, or `success`
   - Description: What happened (enforce single sentence)
   - Solution: How it was resolved (for mistakes)

2. **Categorize** (for mistakes):
   - Determine which category best fits
   - If unclear, use `other`

3. **Check for duplicates**:
   - If a very similar entry exists, note it's already known

4. **Record the entry**:
   - Add to the project's learning log
   - File location: `data/learnings.json`

5. **Provide feedback**:
   - Confirm what was recorded
   - Show category statistics if relevant

## Output Format

```
## Learning Recorded

**Type**: [mistake/preference/success]
**Category**: [category name] (for mistakes)
**Description**: [one-sentence description]
**Solution**: [solution if provided]

### Statistics
- This category: [X] entries
- Top patterns: [list top 3 categories with counts]

### Insight
[Optional: Pattern observation if this category is recurring]
```

## Data File Format

The learning data should be stored in `data/learnings.json`:

```json
{
  "entries": [
    {
      "type": "mistake",
      "category": "complex-solution-bias",
      "description": "Used custom date parser instead of built-in Date",
      "solution": "Replaced with native Date.parse()",
      "timestamp": "2026-01-26T10:00:00Z"
    }
  ],
  "stats": {
    "complex-solution-bias": 3,
    "feature-creep": 1,
    "premature-implementation": 2,
    "misalignment": 0,
    "overtooling": 1,
    "other": 0
  }
}
```

## Duplicate Detection

Consider entries duplicates if:
- Same type AND
- Description has >60% word overlap

If duplicate detected:
- Don't add new entry
- Inform user it's already recorded
- Show the existing entry

## Enforcement Rules

1. **Single Sentence**: Truncate descriptions to first sentence
2. **Solution Required**: For mistakes, prompt for solution if missing
3. **Category Assignment**: Auto-categorize based on keywords if not specified

## If No Arguments Provided

Show current learning statistics:
- Total entries by type
- Top 3 mistake categories
- Recent entries (last 5)

Read existing data with:
```
Current learnings:
!`cat data/learnings.json 2>/dev/null || echo '{"entries":[],"stats":{}}'`
```
