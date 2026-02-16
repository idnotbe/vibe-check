# V1 UX and Scenario Review

## Summary

**Overall grade: 6 FULLY SERVED / 2 PARTIALLY SERVED / 0 NOT SERVED**

The documentation rewrite made substantial progress. The README went from a
minimal overview to a comprehensive user-facing document. ARCHITECTURE.md was
fully translated from Korean to English. CLAUDE.md and TEST-PLAN.md were
enhanced with accurate context. All 19 addressable gaps from the gap analysis
were addressed. The validator passes 28/28 checks, confirming SKILL.md is intact.

Two scenarios remain PARTIALLY SERVED due to issues that are either inherent
limitations (plugin.json installation mechanics are Claude Code platform-dependent)
or require implementation-file changes (Korean test files, dead TypeScript test).

---

## Per-Scenario Results

### Scenario 1: First Discovery and Installation

- **Grade: FULLY SERVED**

**What works well:**
- README opens with a clear one-sentence explanation: "Metacognitive sanity checks for agent plans."
- The Overview section immediately explains what the plugin is, what it is not (no external process, no API calls), and how it relates to the MCP version.
- Two installation methods are documented: Method 1 (copy skills directory) and Method 2 (plugin manifest).
- Full directory structure is shown so newcomers understand the repo layout.
- The "Important: No External API Calls" section proactively addresses the trust question before a newcomer even gets to the API provider section.
- Footnote [^1] on the comparison table directly addresses the "Dependencies: None" vs `required_environment` contradiction.
- Version, license, and author are shown prominently at the top.

**Remaining issues:**
- Method 2 (Plugin Manifest) is vague: "Refer to your Claude Code documentation for plugin manifest installation steps." This is honest (the mechanics are platform-dependent), but a newcomer who tries this path gets no actionable steps. This is acceptable given that Claude Code plugin installation via manifest is not a stable/public API, but it could frustrate a user who assumes it should work.
- No "quick start" example showing input AND expected output together as a single walkthrough. The Input Formats and Output Format sections are separate -- a newcomer must mentally stitch them together.

**Verdict:** All four sub-questions from the verification method are answered:
1. Understand what it does from README alone? **Yes** -- Overview is clear.
2. Install it following instructions? **Yes** -- Method 1 is copy-paste.
3. Know about both installation methods? **Yes** -- both documented.
4. Not confused by API key requirements? **Yes** -- footnote + dedicated section.

---

### Scenario 2: Basic Daily Usage

- **Grade: FULLY SERVED**

**What works well:**
- Usage section starts with a concrete `/vibe-check` example showing natural language input.
- All 7 parameters documented in an Input Parameters table with Required/Optional clearly marked.
- Three input formats shown with English examples (structured, natural language, simple shorthand).
- Full output format template with all 5 sections (Quick Assessment, Key Questions, Pattern Watch, Recommendation, If Adjusting).
- Pattern Watch table connects patterns to signs and remedies.
- "When to Use" section gives three clear trigger points.
- The output format section references the Pattern Watch table, bridging the gap identified in Gap 2.4.

**Remaining issues:**
- The phrase "The skill responds in the language you use for input" in the Language Note section is an important detail for daily users but is placed far from the Usage section. A daily user scanning the Usage section might not scroll down to find this.
- No example of what a complete output actually looks like with real content (the template shows placeholders). A daily user who has never seen the output cannot fully predict what they will receive. However, the template is clear enough to set expectations.

**Verdict:** All four sub-questions answered:
1. Find usage examples easily? **Yes** -- prominent Usage section.
2. Understand all input formats? **Yes** -- three formats with examples.
3. Know what output to expect? **Yes** -- full template shown.
4. Find parameter reference when needed? **Yes** -- Input Parameters table.

---

### Scenario 3: API Provider and Model Configuration

- **Grade: FULLY SERVED**

**What works well:**
- Dedicated "API Provider and Model Parameters" section with clear heading.
- The critical clarification is stated prominently: "These parameters do not trigger external API calls." This is repeated in the How It Works subsection and the "Important: No External API Calls" section.
- Supported providers and models shown in a clean table with environment variables.
- Validation rules are documented (both params required together, model must match provider, API key must be configured).
- Configuration example with `~/.claude/settings.json` JSON snippet.
- A concrete usage example with `apiProvider: openai` and `model: codex-5.2-high`.
- The "Limitations Compared to MCP Version" section explicitly states Claude simulates model awareness rather than making real calls.

**Remaining issues:**
- The phrase "The corresponding API key environment variable should be configured" in validation rules uses "should" (soft requirement) while SKILL.md line 105 states it as a hard validation check. A power user might interpret "should" as optional and be surprised by validation failure. Consider "must" for consistency.
- What happens when validation fails is still somewhat vague. The Troubleshooting section says to check provider/model pairing and API key, but does not describe the actual error message or behavior (does the skill refuse to run? give a warning? fall back to default?). This was Gap 5.3 and is only partially resolved.
- The relationship between `required_environment` in SKILL.md frontmatter and the actual API key validation in the prompt body is architecturally confusing. The frontmatter declares them as "required" but the README says they are "metadata." A power user inspecting both files may still be confused about whether Claude Code itself enforces these at plugin load time. The documentation notes this ambiguity but cannot fully resolve it without implementation changes.

**Verdict:** All four sub-questions answered:
1. Understand what apiProvider/model does? **Yes** -- clearly explained as non-API-calling.
2. Find configuration instructions? **Yes** -- settings.json example provided.
3. Know which models are supported? **Yes** -- provider/model table.
4. Not misled into thinking external APIs are called? **Yes** -- stated multiple times.

---

### Scenario 4: MCP-to-Skills Migration

- **Grade: PARTIALLY SERVED**

**What works well:**
- Comparison table in README clearly contrasts MCP Server vs Agent Skills across 5 dimensions.
- "Limitations Compared to MCP Version" section is honest about the trade-off: real multi-model feedback is lost.
- ARCHITECTURE.md has a Migration Path section with 3 clear steps and "key differences after migration" list.
- The comparison table now includes "Multi-model feedback" row distinguishing real external calls from Claude simulation.

**Remaining issues:**
- Migration steps are in ARCHITECTURE.md but NOT in README. A migrator who only reads README (the natural starting point) does not find step-by-step migration instructions. README has the comparison table and limitations note, but the actual "here is how to migrate" steps are only in ARCHITECTURE.md. The README should either include migration steps or have a visible cross-reference like "For migration steps, see ARCHITECTURE.md > Migration Path."
- No parameter mapping between MCP server and Skills version (Gap 4.3 remains open). A migrator does not know how their existing MCP invocation parameters map to Skills parameters. Even a simple note like "parameter names are identical" or "these parameters were renamed/removed" would help.
- The comparison table says "Copy skills directory or use plugin manifest" for installation but does not mention the migration-specific step of removing MCP server configuration first. ARCHITECTURE.md covers this; README does not.
- No mention of what happens to existing MCP configuration if both the MCP server and the Skills plugin are installed simultaneously. Can they coexist? Will there be a naming conflict?

**Verdict:** A migrator can understand the trade-offs from README, but completing the actual migration requires finding ARCHITECTURE.md. The scenario is partially served because the primary user-facing document (README) is missing the actionable migration steps.

---

### Scenario 5: Troubleshooting

- **Grade: FULLY SERVED**

**What works well:**
- Dedicated Troubleshooting section in README with 5 common issues:
  1. Skill not appearing after installation
  2. Claude asks for API keys
  3. Validation errors with apiProvider/model
  4. Output not in expected language
  5. npm test / npx jest fails
- Each issue has clear resolution steps.
- Language Note section addresses the language behavior question.
- The `npm test` failure is proactively addressed, preventing confusion.
- Dead test file is prominently marked in the test file table.

**Remaining issues:**
- Error recovery for validation failures is still vague (what specific error does the user see?). The Troubleshooting section tells users what to check but not what error message they would see. This is a minor issue since users can match their error to the troubleshooting item by symptom.
- No troubleshooting for "I configured API keys but the model parameter does not seem to change anything." This is the "phantom configuration" frustration (Gap 3.4) -- the user expects different output and gets the same Claude feedback. The Troubleshooting section does not address this disappointment scenario explicitly. The "API Provider and Model Parameters" section explains the behavior, but a disappointed user looking at Troubleshooting would not find "my output looks the same with and without apiProvider."

**Verdict:** The troubleshooting section covers the most common failure modes. The remaining gaps are edge cases.

---

### Scenario 6: Contributing and Development

- **Grade: PARTIALLY SERVED**

**What works well:**
- ARCHITECTURE.md is now fully in English -- the critical Gap 6.1 is resolved.
- README has a Contributing section with Getting Started (4 steps), Guidelines (6 bullet points), and "What Needs Help" (3 items).
- CLAUDE.md has comprehensive development guidelines covering SKILL.md stability, testing, and repo structure.
- TEST-PLAN.md provides a detailed test infrastructure roadmap.
- Dead test file is prominently called out in README (bold "Dead code" in test table, addressed in Troubleshooting, mentioned in What Needs Help).
- The validator check enumeration in TEST-PLAN.md is thorough (all 28 checks in a table).

**Remaining issues:**
- `tests/test_scenarios.md` is still in Korean (acknowledged as "not addressable" since it is an implementation file). A contributor wanting to run manual tests is blocked. The README mentions it under "What Needs Help" which is good, but the contributor cannot contribute to manual testing without translation.
- `tests/api_provider.test.ts` is still present as dead code. README and CLAUDE.md document it clearly, but it remains a contributor trap until actually deleted or scaffolded. TEST-PLAN.md P0.2 recommends deletion but this has not been executed.
- No formal PR process or code review guidelines documented. Contributing section says what to do but not the review/merge process. For a small project this may be acceptable.
- ARCHITECTURE.md "Bilingual Content in SKILL.md" section notes the Korean/English inconsistency with CLAUDE.md's English-only guideline but does not resolve the tension. A contributor might wonder: should new SKILL.md content be in English or Korean?

**Verdict:** The contributor experience is significantly improved (English ARCHITECTURE.md alone is a major improvement), but the Korean test files and dead TypeScript test remain friction points that require implementation changes to fully resolve.

---

### Scenario 7: Security Audit

- **Grade: FULLY SERVED**

**What works well:**
- "Important: No External API Calls" section directly addresses the trust concern with explicit statements: "contains no executable code, makes no network requests, and does not use your API keys at runtime."
- The `required_environment` purpose is explained: "exists as metadata for the apiProvider/model feature documentation."
- Footnote [^1] on the comparison table proactively addresses the apparent contradiction.
- "You do not need to configure any API keys for basic /vibe-check usage" is an explicit trust statement.
- CLAUDE.md also states "this repo makes no outbound API calls" for agent-level awareness.
- A security auditor reading README alone can understand why the keys are declared and verify that no code executes.

**Remaining issues:**
- No formal security posture statement (e.g., "This plugin has no file system access, no network access, no code execution"). The existing statements are sufficient for understanding, but a security-conscious developer might appreciate a concise security summary.
- The `required_environment` field name itself is still potentially alarming -- the word "required" implies the plugin needs these keys. The documentation explains this away, but a quick scanner (looking at SKILL.md frontmatter without reading README) could still be concerned. This is an inherent limitation of the SKILL.md metadata format that cannot be resolved in documentation alone.

**Verdict:** All three sub-questions answered:
1. Find explanation of API key requirements? **Yes** -- multiple explicit explanations.
2. Verify no network calls? **Yes** -- stated clearly, verifiable by code inspection.
3. Trust the plugin enough to install? **Yes** -- the prompt-only nature is well-documented.

---

### Scenario 8: Plugin Update

- **Grade: FULLY SERVED**

**What works well:**
- Dedicated "Updating" section in README with clear instructions: re-copy the `.claude/skills/vibe-check/` directory.
- Explicitly states "The plugin has no local state or configuration to preserve" which answers the "will my customizations be overwritten?" question.
- Notes that API key configuration lives in `~/.claude/settings.json` (separate from the plugin).
- Version is shown at top of README (v0.1.0) and in plugin.json.

**Remaining issues:**
- No changelog. Users cannot see what changed between versions without reading git history. For v0.1.0 this is acceptable but will become a problem as the plugin evolves.
- No release tags or GitHub Releases. The "latest release" instruction assumes the user knows to pull from main or find a tag. This is a process issue, not a documentation issue.

**Verdict:** Both sub-questions answered:
1. Find version information? **Yes** -- shown at top of README and in plugin.json.
2. Know how to update? **Yes** -- Updating section with clear steps.

---

## Cross-Scenario Issues

### 1. Migration steps only in ARCHITECTURE.md (affects Scenarios 1, 4)
The migration path is documented in ARCHITECTURE.md but not in README. README is the natural entry point for all users. A cross-reference or summary in README would help.

### 2. Validation failure behavior remains vague (affects Scenarios 3, 5)
What specific error the user sees when `apiProvider`/`model` validation fails is not documented anywhere. SKILL.md defines validation rules in Korean, and the documentation describes what the rules are, but not the user-facing error experience. This would require either testing the actual behavior or making implementation changes.

### 3. "should" vs "must" language inconsistency (affects Scenarios 3, 5, 7)
README uses "should be configured" for API key requirement while SKILL.md uses a hard validation check. This creates ambiguity about whether the key is truly required for the apiProvider/model feature to work.

### 4. Dead code and Korean test files remain (affects Scenario 6)
These are acknowledged as implementation-file issues that were out of scope for the documentation pass. They are well-documented as known issues, but contributors still encounter them.

### 5. No filled-in output example (affects Scenarios 1, 2)
The output format template uses placeholders. A single concrete example showing real input mapped to real output would significantly help newcomers and daily users visualize the experience.

---

## Prioritized Fix List

| Priority | Issue | Affected Scenarios | Fix Location |
|----------|-------|-------------------|--------------|
| 1 (Medium) | Add migration steps to README or add cross-reference to ARCHITECTURE.md | 4 | README.md |
| 2 (Medium) | Change "should be configured" to "must be configured" for API key in validation rules | 3, 5 | README.md |
| 3 (Low) | Add a concrete filled-in output example (not just template) | 1, 2 | README.md |
| 4 (Low) | Add "phantom configuration" note to Troubleshooting ("output looks the same with/without apiProvider") | 3, 5 | README.md |
| 5 (Low) | Add brief parameter mapping note for MCP migrators (even "parameter names are the same" or "these MCP params have no equivalent") | 4 | README.md |
| 6 (Low) | Add changelog or CHANGES.md when releasing future versions | 8 | New file |

Items NOT in this list (acknowledged but out of scope for doc-only fixes):
- Delete or scaffold `tests/api_provider.test.ts` (requires implementation change)
- Translate `tests/test_scenarios.md` to English (requires implementation change)
- Add GitHub Actions CI (requires implementation change)

---

## Self-Critique

### What I might have missed

1. **Accessibility of the README itself.** The README is now quite long. I did not evaluate whether the table of contents / heading structure makes it easy to navigate with GitHub's built-in TOC. The README does not have an explicit table of contents -- it relies on GitHub's auto-generated one from headings. For a document this comprehensive, an explicit TOC at the top might improve navigation.

2. **Link verification.** I did not verify that the external links in the README (agentskills.io, PV-Bhat/vibe-check-mcp-server GitHub repo) are actually reachable. These were flagged in the gap analysis as R9 (external URL verification) and left as-is.

3. **plugin.json completeness.** I reviewed plugin.json but did not deeply evaluate whether its fields match the README/ARCHITECTURE.md descriptions exactly. The `skills` array points to `./.claude/skills/vibe-check` which appears correct.

4. **SKILL.md Korean content impact on output.** I noted the Language Note section but did not actually test whether providing English input produces English output. The documentation says "the skill responds in the language you use for input" but this is a claim about Claude's behavior, not a guarantee. Testing this would require actually invoking the skill.

5. **Newcomer cognitive load.** The README is now comprehensive but long (~310 lines). A complete newcomer might feel overwhelmed. The gap analysis favored comprehensiveness over brevity, which is the right trade-off for serving all 8 scenarios, but it introduces a "wall of text" risk for casual browsers.

---

## External Validation

### Validator Confirmation
`bash tests/validate_skill.sh` passes all 28/28 checks, confirming SKILL.md was not modified during the documentation update process.

### Cross-Document Consistency Check
- README, ARCHITECTURE.md, CLAUDE.md, and TEST-PLAN.md all consistently state that no external API calls are made.
- Provider/model tables are consistent across README (line 174-178), ARCHITECTURE.md (line 88-92), and SKILL.md (lines 40-44).
- Version is consistently 0.1.0 in README header, plugin.json, and ARCHITECTURE.md.
- The "28 checks across 9 test groups" claim is consistent across README, CLAUDE.md, TEST-PLAN.md, and ARCHITECTURE.md.

### Assessment Summary
The documentation update is thorough and well-executed. The 6 FULLY SERVED scenarios cover the highest-priority user journeys (newcomer installation, daily usage, power user configuration, troubleshooting, security audit, and updates). The 2 PARTIALLY SERVED scenarios (migration and contributing) have clear, bounded remaining issues that are either documentation cross-referencing fixes or implementation-file changes that were out of scope.
