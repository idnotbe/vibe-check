# Verification Round 1: Structure and Completeness Review

**Reviewer**: reviewer-1
**Date**: 2026-02-23
**Requirement Change**: All 7 repos will use the English version only. Korean draft dropped.
**Files Reviewed**:
- `/home/idnotbe/projects/vibe-check/temp/draft-readme-en.md` (English -- sole version for all 7 repos)
- `/home/idnotbe/projects/vibe-check/temp/readme-update-analysis.md` (Requirements)
- `/home/idnotbe/projects/vibe-check/action-plans/README.md` (Current original, Korean)

---

## 1. Single Version for All Repos

**Requirement change**: Korean draft dropped. English draft (`draft-readme-en.md`) will be applied to all 7 repos.

**Additional consideration**: 5 of the 7 repos currently have Korean READMEs. Applying the English version will change the language of those files. This is intentional per the team lead's directive.

| Repo | Current Language | New Language |
|------|-----------------|--------------|
| vibe-check | Korean | English |
| claude-memory | Korean | English |
| claude-code-guardian | Korean | English |
| deepscan | Korean | English |
| prd-creator | Korean | English |
| ops | English | English (no change) |
| daemon | English | English (no change) |

---

## 2. Requirements Completeness

### Requirement 1: New "Action Plan File Structure" section
**PASS** -- Draft adds this section (lines 26-45) with:
- Ordered phase/step mandate
- Checkmark convention: `[v]`/`[ ]`/`[/]`
- Example with Phase 1 and Phase 2
- Completion rule ("all steps [v] = done")

### Requirement 2: Status Values "done" -- mandatory _done/ move
**PASS** -- Draft updated:
- `done: Completed → **must** move to _done/` (line 24)
- Changed from original: optional to mandatory

### Requirement 3: Lifecycle step 3 -- mandatory _done/ move
**PASS** -- Draft updated:
- `Complete work -> status: done, move to _done/ (required)` (line 50)
- Changed from original: "(optional)" to "(required)"

---

## 3. Contradictions Check

**No internal contradictions found.** Status Values and Lifecycle are now consistent -- both say _done/ move is mandatory.

**Minor note**: The frontmatter YAML code block in the draft uses ` ```yaml ` (with language hint). The current originals (Korean repos) use bare ` ``` `. This is an improvement, not a contradiction.

---

## 4. Edge Cases

### 4a. Single-step plans
**ISSUE (Low Severity)** -- The new section states plans "must contain ordered actions (phase1, phase2... or step1, step2...)". A single-step fix (e.g., "bump version number") would feel over-structured with a full "Phase 1" heading.

**Suggestion**: Soften to "should" for simple plans, or note that a flat checklist without phase headings is acceptable for single-task plans.

### 4b. Obsolete/abandoned plans
**ISSUE (Medium Severity)** -- The lifecycle assumes all plans reach "done" status. There is no defined path for plans that are cancelled, superseded, or abandoned before completion. The status enum has no `cancelled`/`obsolete` value.

**Current state**: Such plans presumably go to `_ref/` but:
- The frontmatter status enum has no matching value
- Lifecycle step 4 ("Archive as reference -> move to _ref/") implies sequential flow after done, not a direct path from active/blocked

**Suggestion**: Either (a) add a `cancelled`/`obsolete` status with direct `_ref/` path, or (b) clarify that `_ref/` accepts non-completed plans directly from root.

### 4c. Gap between _done/ and _ref/
**ISSUE (Medium Severity)** -- Lifecycle step 4 is ambiguous. It reads as a sequential next step after step 3 (done -> _done/), implying the flow is: root -> _done/ -> _ref/. But this may not be the intent.

**Suggestion**: Clarify whether step 4 means:
- (A) Moving files from `_done/` to `_ref/` for long-term archival, OR
- (B) Moving files directly from root to `_ref/` (for abandoned plans), OR
- (C) Both paths are valid

---

## 5. Checkmark Convention Clarity

### `[v]`/`[ ]`/`[/]` Assessment
**ISSUE (High Severity -- from Gemini CLI)** -- The `[v]` convention is non-standard. GitHub, VSCode, Obsidian, and most Markdown renderers natively support `[x]` for checked items and `[ ]` for unchecked items, rendering them as interactive checkboxes. Using `[v]` will:
- Not render as native checkboxes on GitHub
- Break integrations that parse markdown task lists
- Confuse contributors familiar with standard `[x]` convention

**The `[/]` for "in progress" is also non-standard** but there is no standard equivalent, so it is an acceptable custom extension. However, it should be noted that it will render as literal text, not a checkbox.

**Counterargument**: The `[v]` choice may be intentional -- to distinguish "vibe-check style" progress tracking from standard GitHub checkboxes, and to visually pair with `[/]` as a coherent custom system. If intentional, document the reason.

**Suggestion**: Either:
1. Switch to `[x]` for done (standard) and keep `[/]` for in-progress (custom, with note), OR
2. Keep `[v]` but explicitly document why the non-standard convention was chosen

---

## 6. Operational Impact of Mandatory _done/

**Assessment**: Low-to-medium friction.

**Pros**:
- Root directory stays clean -- only active plans visible
- Clear signal that a plan is fully complete
- Easy to see project health at a glance

**Cons**:
- Extra `git mv` step every time a plan completes
- If forgotten, root accumulates "done" files that violate the rule
- No enforcement mechanism -- relies on developer discipline or CI check

**Suggestion**: This is a reasonable convention. The operational cost is one `git mv` command per completed plan, which is minor. Could note in README that `git mv` is the expected mechanism.

---

## 7. External Review: Gemini CLI (gemini-3.1-pro-preview)

Gemini CLI provided a thorough review. Key findings aligned with this review:

1. **HIGH**: `[v]` breaks standard markdown checkbox rendering -- recommends `[x]`
2. **MEDIUM**: Missing "abandoned/cancelled" lifecycle path -- recommends adding `obsolete`/`cancelled` status
3. **MEDIUM**: Ambiguous `_ref/` archival flow -- recommends decoupling from linear lifecycle
4. **LOW**: Overly rigid phase/step mandate -- recommends softening for simple plans

**Note**: Codex CLI (codex-5.2-high) was unavailable due to usage limits.

---

## Summary of Findings

| # | Finding | Severity | Category |
|---|---------|----------|----------|
| 1 | `[v]` breaks standard markdown checkboxes | High | Checkmark convention |
| 2 | No lifecycle path for abandoned/cancelled plans | Medium | Edge case |
| 3 | Ambiguous _ref/ archival flow (step 4) | Medium | Edge case |
| 4 | Rigid phase/step mandate for simple plans | Low | Edge case |
| 5 | All 3 requirements correctly applied | -- | Completeness (PASS) |
| 6 | No internal contradictions | -- | Consistency (PASS) |
| 7 | 5 Korean repos will switch to English | Info | Language change |

### Verdict
The English draft correctly implements all 3 required changes. There are 4 issues to address before finalizing -- 1 high severity (checkmark convention) and 3 medium/low (edge cases). None are blockers that require rewriting the draft; they can be resolved with targeted edits. Note that 5 repos will undergo a language change from Korean to English.
