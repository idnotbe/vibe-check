# V3 Adversarial Review

## Summary

**Issue count by severity: 0 Critical, 2 High, 3 Medium, 2 Low**

All V2 fixes verified as correctly applied. Seven new issues found, none
critical. The documentation is substantially accurate and consistent after
V2 fixes. The remaining issues are behavioral claims without implementation
backing, unverifiable external references, and minor description mismatches.

---

## V2 Fix Verification

All V2 issues from temp/08-v2-accuracy.md and temp/10-v2-consistency.md checked
against the current working tree:

| V2 Issue | Fixed? | Verification |
|----------|--------|-------------|
| N1: README Troubleshooting bidirectional wording | YES | README.md line 248 now reads "If `apiProvider` is specified, `model` must also be specified" |
| N2: CLAUDE.md "Both must be specified together" | YES | CLAUDE.md line 48 now reads "If `apiProvider` is specified, `model` must also be specified; model must match provider" |
| N3: ARCHITECTURE.md test group 8 warn/fail | YES | ARCHITECTURE.md line 146 now has "(pass/fail)" and "(pass/warn)" notation |
| C1: CLAUDE.md omits "Existence" test group | YES | CLAUDE.md line 60 now includes "file existence" and line 63 says "28 checks across 9 test groups" |
| C2: ARCHITECTURE.md directory listing incomplete | YES | ARCHITECTURE.md lines 14-32 now list all 11 files matching README |
| C3: Validation rule direction | YES | Fixed via N1 and N2 |
| C5: ARCHITECTURE.md warn/fail | YES | Fixed via N3 |
| C6: README plugin.json fields incomplete | YES | README.md line 59 now lists "Author, homepage, repository, license, and keywords" |
| C4: Description singular/plural | NOT FIXED (by design) | plugin.json says "checks" (plural), SKILL.md says "check" (singular). Documented as acceptable in temp/11-v2-fixes.md |
| C7: argument-hint lists only 4 of 7 params | NOT FIXED (by design) | Implementation file, out of scope per temp/11-v2-fixes.md |

---

## New Issues Found

### Issue A1: README language claim has no implementation backing

- **File**: README.md, lines 235 and 253
- **Severity**: High
- **What it says**:
  - Line 235: "The skill will respond in the language you use for input."
  - Line 253: "The skill responds in the language you use for input. If you
    write in English, feedback will be in English."
- **What SKILL.md actually says**: Nothing. There is no language-related
  instruction anywhere in SKILL.md. No "respond in the user's language"
  directive exists.
- **Problem**: This is a behavioral claim presented as a feature guarantee,
  but it has zero backing in the implementation (SKILL.md). Claude may
  happen to do this by default, but the documentation presents it as a
  designed behavior. Worse, SKILL.md contains substantial Korean text
  (parameter descriptions, input format examples, configuration instructions)
  which could bias Claude toward Korean responses. The claim is stated twice
  in README -- once in the Language Note section and once in Troubleshooting --
  reinforcing a guarantee the implementation does not make.
- **V2 status**: V1 and V2 reviews noted this as a concern (V1 UX review
  self-critique point 4, V2 scenario review) but never classified it as a
  documentation accuracy issue. It was treated as a "testing gap" rather
  than a "doc-claims-something-SKILL.md-doesn't-support" issue.

### Issue A2: Research statistics (+27%, -41%) are unverifiable

- **File**: README.md, line 35
- **Severity**: High
- **What it says**: "Based on research showing **+27% improvement in success
  rates** and **-41% reduction in harmful actions**"
- **Problem**: These statistics are attributed to "Chain-Pattern Interrupts
  (CPI)" in the Credits section (line 315), but:
  1. No citation, paper title, URL, or DOI is provided
  2. "Chain-Pattern Interrupts" returns no well-known peer-reviewed results
     with these exact numbers
  3. The Gemini external reviewer said these stats "match external research
     findings on agent oversight" but did not provide a specific source either
  4. These appear to originate from the upstream MCP server
     (PV-Bhat/vibe-check-mcp-server) README, which also does not cite a
     specific paper
  - A user or contributor performing due diligence cannot verify these claims.
    Presenting unverifiable statistics in a README lends false authority to the
    tool. At minimum, a citation should be added; if no primary source exists,
    the claim should be softened or attributed to the upstream project.

### Issue A3: Description text disagrees between SKILL.md and plugin.json

- **File**: SKILL.md line 3, plugin.json line 4
- **Severity**: Medium
- **Details**: Two differences between the two source-of-truth files:
  1. **Singular vs plural**: SKILL.md says "sanity check" (singular),
     plugin.json says "sanity checks" (plural)
  2. **Suffix presence**: SKILL.md has the suffix "Helps prevent tunnel
     vision, over-engineering, and goal misalignment." plugin.json truncates
     before this suffix.
- **How docs align**:
  - README line 3: Uses plural + full suffix (hybrid of both)
  - ARCHITECTURE.md line 47: Uses singular + full suffix (matches SKILL.md)
- **Impact**: This was flagged as V2 C4 and marked "not fixed by design."
  However, the inconsistency between the two implementation files is a fact.
  A contributor editing the description has no single source of truth.
- **V2 status**: Known issue, intentionally not fixed.

### Issue A4: ARCHITECTURE.md "Agent Skills standard" claim is vague

- **File**: ARCHITECTURE.md, line 177
- **Severity**: Medium
- **What it says**: "Specification: Agent Skills standard with Claude Code
  extensions"
- **Problem**: This implies vibe-check conforms to a formal specification
  called "Agent Skills standard." While agentskills.io exists (per Gemini
  verification), ARCHITECTURE.md does not link to it, and the phrase "with
  Claude Code extensions" is undefined. A reader cannot determine:
  - What the "Agent Skills standard" requires
  - What "Claude Code extensions" means
  - Whether vibe-check actually conforms to the standard
  - README credits agentskills.io in the Credits section, but ARCHITECTURE.md
    does not cross-reference it
- **Recommendation**: Either link to the standard or remove the conformance
  claim.

### Issue A5: ARCHITECTURE.md MCP server version reference may be stale

- **File**: ARCHITECTURE.md, line 176
- **Severity**: Medium
- **What it says**: "Original MCP server reference: latest (2026-01)"
- **Problem**: This is a point-in-time reference that will become stale. More
  importantly, it claims the reference is "latest" as of January 2026, but
  there is no mechanism to verify this or keep it updated. If the upstream
  MCP server has released a newer version since January 2026, this claim is
  already incorrect. The documentation should either remove the date or link
  to the upstream repo's releases page.

### Issue A6: .gitignore is Python-focused, misleading for a prompt-only repo

- **File**: .gitignore
- **Severity**: Low
- **What it is**: The .gitignore file is a comprehensive Python .gitignore
  template (Django, Flask, Scrapy, Jupyter, pytest, pyenv, etc.) with no
  relevance to this prompt-only repo.
- **Problem**: This is not a documentation issue per se, but it contradicts
  the documentation's repeated emphasis that "this is a prompt-only plugin
  with no runtime code." A contributor cloning the repo would see a .gitignore
  full of Python tooling and wonder if the project has Python components.
  The .gitignore also does not ignore `temp/` (which is untracked per git
  status) or `node_modules/` (relevant given the dead TypeScript test file).

### Issue A7: SKILL.md missing validation rule for model-without-apiProvider

- **File**: SKILL.md, line 103
- **Severity**: Low
- **What SKILL.md says** (translated): "If apiProvider is specified, model must
  also be specified" (one direction only)
- **What the dead TypeScript test says**: api_provider.test.ts line 65-66
  tests the reverse: `if (model && !apiProvider)` produces an error.
- **What the docs now say**: All docs now use one-directional wording
  (matching SKILL.md) after V2 fixes.
- **Problem**: The documentation is now internally consistent, but the
  *intended behavior* appears to be bidirectional based on the TypeScript
  test. SKILL.md only states one direction. If someone contributes a
  bidirectional rule to SKILL.md (which the TS test suggests was intended),
  the docs would need updating again. This is a latent design ambiguity
  rather than a documentation error.
- **V2 status**: V2 self-critique point 2 acknowledged this. The docs were
  standardized on SKILL.md's unidirectional wording, which is correct for
  documentation accuracy even if the intended behavior differs.

---

## Near-Misses (things that look like issues but aren't)

1. **argument-hint free-form text clause**: The `(또는 자유 형식 텍스트)`
   parenthetical in SKILL.md line 4 looks like it might mean the `model`
   parameter accepts free-form text. But it actually describes the overall
   input format flexibility (structured vs. natural language), as confirmed
   by the input format examples in SKILL.md lines 46-68. V2 already analyzed
   this and correctly dismissed it.

2. **CLAUDE.md line 42 "lines 38-106" reference**: The apiProvider/model
   system is described as "SKILL.md (lines 38-106)." Line 38 is the
   "Supported API Providers and Models" heading; line 106 is the end of the
   validation rules section. The parameters are defined slightly earlier
   (lines 35-36) but the claim is reasonable for the core specification block.

3. **README Migration Path anchor link**: README links to
   `ARCHITECTURE.md#migration-path`. The heading "## Migration Path" exists
   at ARCHITECTURE.md line 158. GitHub auto-generates anchors from headings
   as lowercase-hyphenated, so `#migration-path` resolves correctly.

4. **TEST-PLAN.md P1.2 duplication count**: Claims provider/model data is
   hardcoded in "four places." Verified: SKILL.md, validate_skill.sh,
   api_provider.test.ts, test_scenarios.md -- correct.

5. **validate_skill.sh exit behavior**: CLAUDE.md says "exit code 0 on
   success, 1 on failure." Script lines 175-181 confirm: `if [ $FAIL -eq 0 ];
   then exit 0; else exit 1; fi`. The WARN counter does not affect exit code.
   This is consistent with calling the settings.json check a "warn" -- it
   does not cause the script to exit 1.

---

## Self-Critique

1. **Issue A1 (language claim)**: This was flagged by V1 and V2 as a concern
   but never promoted to a documentation issue. I am promoting it because
   the adversarial framing reveals it more clearly: the README makes a
   behavioral guarantee ("will respond in the language you use for input")
   that has zero implementation backing in SKILL.md. Whether Claude happens
   to do this naturally is irrelevant to documentation accuracy.

2. **Issue A2 (research stats)**: The Gemini external reviewer said these are
   "verified" and "match external research findings." However, matching
   general research themes is not the same as verifying specific numbers.
   I could not find a specific paper or source with exactly "+27%" and "-41%"
   for CPI. I am flagging this as unverifiable rather than incorrect.

3. **Issue A6 (.gitignore)**: This is arguably out of scope for a
   documentation review. I include it because it creates a misleading signal
   about the project's technology stack, which contradicts the documentation's
   "prompt-only" narrative.

4. **Gemini's verification reliability**: The external reviewer (Gemini via
   pal clink) verified several claims including the research stats, the
   agentskills.io URL, and the upstream repo. However, LLMs can confabulate
   verification. I treated Gemini's responses as additional data points
   rather than authoritative confirmation.

5. **Description mismatch (A3)**: I re-raised V2 C4 because the adversarial
   framing asks "which source of truth wins?" This remains unresolved and
   could confuse contributors, even though it was intentionally not fixed.

---

## External Validation

### Gemini 3.0 Pro (via pal clink)

Key findings from external review:

1. **Research stats (+27%, -41%)**: Gemini said "verified" and "consistent
   with research on agent oversight" but did not cite a specific paper. This
   supports my A2 classification as "unverifiable."

2. **agentskills.io**: Gemini said this is "a real open standard." This
   reduces concern about a broken or fake link, though the URL was not
   directly tested.

3. **PV-Bhat/vibe-check-mcp-server**: Gemini confirmed this is a real
   GitHub repository.

4. **Model names**: Gemini confirmed all 6 model names as plausible for the
   2026 timeframe.

5. **required_environment friction**: Gemini flagged that Claude Code may
   prompt for API keys even though they are not used, creating user friction.
   This aligns with README's existing Troubleshooting section (line 244) but
   validates that the concern is real.

6. **Korean language leakage risk**: Gemini flagged that Korean text in
   SKILL.md's argument-hint increases the risk of language leakage. This
   supports my Issue A1 finding.

---

## Overall Verdict

**MINOR ISSUES**

The documentation is in good shape after V2 fixes. All V2 issues that were
marked as fixed are genuinely fixed. The remaining issues fall into two
categories:

1. **Behavioral claims without implementation backing** (A1): The language
   guarantee is the most significant remaining issue. It should either be
   softened to a description of expected behavior or backed by an instruction
   in SKILL.md.

2. **Unverifiable claims** (A2): The research statistics lack citation. This
   is not necessarily wrong, but it cannot be verified.

3. **Minor inconsistencies** (A3, A4, A5, A6, A7): These are cosmetic,
   architectural, or latent design issues that do not mislead users in
   practice.

No contradictions remain between the four documentation files after V2 fixes.
The cross-document consistency is strong.
