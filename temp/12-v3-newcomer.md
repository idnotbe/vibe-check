# V3 Newcomer Simulation Review

**Reviewer**: Agent (simulating first-time developer)
**Date**: 2026-02-16
**Persona**: Developer who uses Claude Code but has never seen vibe-check

---

## First Impressions (README only)

**Time to understand purpose**: ~15 seconds. The opening line ("Metacognitive
sanity checks for agent plans") is clear and compelling. The blockquote with
version/license/author is clean.

**Overall feel**: Professional but overloaded. The README tries to serve too many
audiences at once -- newcomers, MCP migrators, contributors, and users curious
about the apiProvider feature. The result is that the simple core message ("copy
a folder, type `/vibe-check`") gets buried under disclaimers, footnotes, and
caveats.

**What I understood quickly**:
- This is a prompt-only plugin -- no code executes
- It provides metacognitive feedback on plans
- It is based on the vibe-check-mcp-server
- Installation is `cp -r`

**What confused me immediately**:
- Why does a prompt-only plugin need API keys?
- The `required_environment` vs "no dependencies" contradiction
- Why Korean is mentioned at all if the README is in English
- Why dead test code is listed in the directory structure

---

## Installation Walkthrough

**Could I install it?** YES, with mild friction.

**Method 1 (cp -r)**: Clear and simple. One command. Works.

**Method 2 (Plugin Manifest)**: Vague. "If your Claude Code environment supports
plugin installation via manifest" -- does it or doesn't it? "Refer to your Claude
Code documentation" is a dead-end for most users. This method is either real or
not; hedging language makes it look like an aspirational feature.

**Verification gap**: After copying, how do I confirm it worked? There is no
"run this to check" step. The README goes straight from "copy" to "usage" with
no verification. A newcomer might type `/vibe-check` and get nothing, with no
way to diagnose why.

**Missing**: No mention of what Claude Code version is required, or a link to
Claude Code itself for context.

---

## Usage Walkthrough

**Could I use it?** YES. The usage examples are the strongest part of the README.

**Clarity wins**:
- Three input format examples (structured, natural language, simple) -- excellent
- Parameter table is clean and easy to scan
- Output format section shows exactly what to expect
- "When to Use" section gives practical triggers

**Minor gaps**:
- The first usage example (line 98-101) does not use key:value format, yet the
  parameter table implies structured input is the norm. Slightly inconsistent.
- No example of what happens with bad input (missing goal/plan)

---

## Trust Evaluation (API Keys)

**Was I alarmed?** YES. This is the single biggest newcomer problem.

The README creates a trust paradox:
1. "No dependencies" --> good, I trust this
2. `required_environment` declares 3 API keys --> wait, what?
3. "These are metadata" --> that's a strange concept
4. "Your API keys are never read or transmitted" --> why do you need them then?
5. "The corresponding API key environment variable must be configured" (Validation
   Rules, line 189) --> now I'm asked to SET keys that aren't used?

The footnote [^1] and "Important: No External API Calls" section work hard to
explain this, but the explanation itself is suspicious. A newcomer reading
"we need your API keys but we promise we don't use them" will either:
- Skip the feature entirely (best case)
- Distrust the entire plugin (likely case)
- Configure keys and hope nothing bad happens (worst case)

**Gemini's external assessment agrees**: "This looks like a social engineering
trap or incredibly bad design." That is harsh but captures the newcomer sentiment
accurately.

**Root cause**: The `required_environment` field in SKILL.md's YAML frontmatter
is a Claude Code convention. Claude Code may flag missing env vars based on this
declaration. The README acknowledges this in the Troubleshooting section ("Claude
asks for API keys / environment variables") but the explanation feels defensive
rather than reassuring.

---

## Confusion Points

### Critical (blocks understanding or trust)

1. **API key requirement contradiction**: "No dependencies" + "required_environment"
   + "must be configured" + "never used" is an irreconcilable messaging problem
   for newcomers. The footnote/disclaimer approach works for people who already
   trust the project -- it does not build trust for newcomers.

2. **No post-install verification step**: After copying files, there is no way
   to confirm the skill is loaded. This will cause silent failures.

3. **Plugin manifest hedging**: Method 2 installation says "if your environment
   supports" which implies the author isn't sure. This undermines confidence.

### Moderate (causes friction but doesn't block)

4. **Dead code in directory listing**: Listing `api_provider.test.ts` as "Dead
   code" in the official directory structure is unusual. Most projects either
   fix or remove dead code; advertising it suggests incomplete cleanup.

5. **Korean language note**: Mentioning bilingual content in SKILL.md raises
   questions about quality and completeness. A newcomer who opens SKILL.md
   and sees Korean text they cannot read may feel they're using an unfinished
   product.

6. **MCP comparison that self-sabotages**: The "Limitations Compared to MCP
   Version" section (line 25-27) effectively tells newcomers "the other version
   is better." This is honest, but poor marketing. A newcomer who hasn't used
   either version may choose the MCP version instead.

7. **"Agent Skills" link goes to agentskills.io**: The Credits link to
   agentskills.io -- this may or may not be a real, useful resource. No
   context is given about what this standard is.

### Minor (nitpicks)

8. **`.gitignore` is a Python template**: The gitignore contains extensive Python
   boilerplate (Django, Flask, Jupyter, etc.) for a project with no Python code.
   Not visible in README, but a contributor would notice.

9. **`on_notification.wav` and `on_stop.wav`**: Sound files exist in the repo
   root but aren't mentioned anywhere. Likely local development artifacts that
   leaked into the repo.

10. **`.claude/` directory has extra files**: `ccyolo.md`, `plugin-dirs`,
    `settings.json`, `statusline.sh`, `guardian/guardian.log` -- these are
    local Claude Code configuration files that shouldn't be in the repo.
    They aren't in the documented directory structure.

---

## What's Missing (from newcomer perspective)

1. **Prerequisites section**: What is Claude Code? Link to it. What version do
   I need? What OS/platform is supported?

2. **Post-install verification**: "Run `/vibe-check help` to verify installation"
   or equivalent.

3. **Quick start section**: A 3-line "copy, verify, use" flow at the very top,
   before the comparison tables and architecture discussion.

4. **A real-world before/after example**: Show a plan that was checked and how the
   feedback improved it. The usage examples show input but the output example is
   a template with placeholders.

5. **FAQ for the API key concern**: The current Troubleshooting section partially
   addresses this, but a direct FAQ entry like "Q: Will this steal my API keys?
   A: No, here's why..." would build trust faster.

6. **Badges/shields**: No CI badge, no version badge, no license badge. These
   are standard trust signals on GitHub READMEs.

---

## Cross-doc Evaluation

### ARCHITECTURE.md
- Well-structured and clear
- Adds valuable context about the design philosophy
- The migration path section is useful
- Correctly documents the bilingual situation
- A newcomer would not read this unless directed to by README (which it is, for
  migration). Not a problem -- it serves its purpose as a reference.

### CLAUDE.md
- Excellent as a contributor guide
- Clearly explains the repo structure, testing, and conventions
- The "Key Facts" and "apiProvider/model Feature" sections are more concise than
  the README equivalents -- a newcomer might actually understand the API key
  situation better from CLAUDE.md than from README
- Correctly flags api_provider.test.ts as dead code with recommendation to delete

### TEST-PLAN.md
- Well-prioritized roadmap
- P0 items (CI, dead test cleanup, docs) are the right priorities
- P1.1 (README vs SKILL.md contract mismatch) directly acknowledges the API key
  confusion issue this review identified
- A newcomer would never read this, but a contributor would find it valuable

### Cross-doc consistency
- All four documents agree on: 28 checks, dead test file, bilingual status,
  no-API-calls claim, and the directory structure
- The "no external API calls" message is consistent across all docs
- No contradictions found between documents

---

## Self-Critique

**Potential biases in this review**:
- I may be over-weighting the API key concern because external validation
  (Gemini) also flagged it, creating confirmation bias
- The "Korean language" concern may reflect English-centric bias -- bilingual
  projects are normal in international development
- I simulated a developer who already uses Claude Code; a developer who does
  NOT use Claude Code would have an even harder time (no context for what
  `.claude/skills/` means or how `/vibe-check` invocations work)
- I did not actually test the installation path end-to-end (just read about it)

**What this review might miss**:
- The README may read better on GitHub with rendered footnotes and anchor links
- Some confusion points may be resolved by Claude Code itself (e.g., it might
  auto-discover skills and provide built-in verification)
- The API key concern might be moot if Claude Code handles `required_environment`
  gracefully (not prompting users aggressively)

---

## External Validation

### Vibe Check Results (self-applied)

The vibe-check skill provided feedback on this review's own plan:
- **Assessment**: Plan is on track
- **Key insight**: Define which newcomer persona (Claude Code user vs. complete
  newcomer) -- this review chose "Claude Code user, plugin newcomer"
- **Pattern watch**: No major pitfalls, minor risk of Complex Solution Bias
- **Recommendation**: Proceed with minor adjustments

### Gemini (pal clink) Findings

Gemini was asked "As a developer seeing this README for the first time, what
would confuse you?" Key findings:

1. **API key situation**: "Alarming" -- "looks like a social engineering trap
   or incredibly bad design"
2. **Simulated model feedback**: "sounds like snake oil" -- value proposition
   of apiProvider/model is unconvincing
3. **Dead code and Korean references**: "makes it look unmaintained or amateurish"
4. **Trust verdict**: "No" -- would not install
5. **Missing**: No explanation of what Claude Code is
6. **Installability**: Passes the 2-minute test for basic `cp -r`
7. **MCP comparison**: "effectively sells the user away from this project"

**Convergence with this review**: Gemini independently identified the same top-3
issues (API keys, dead code, Korean references) and the same missing element
(Claude Code context/link). High confidence these are real newcomer problems.

---

## Directory Structure Verification

Files listed in README directory tree vs actual files:

| README Lists | Actually Exists? | Notes |
|---|---|---|
| .claude/skills/vibe-check/SKILL.md | YES | |
| .claude-plugin/plugin.json | YES | |
| tests/validate_skill.sh | YES | |
| tests/api_provider.test.ts | YES | Dead code |
| tests/test_scenarios.md | YES | |
| ARCHITECTURE.md | YES | |
| CLAUDE.md | YES | |
| TEST-PLAN.md | YES | |
| README.md | YES | |
| LICENSE | YES | |
| .gitignore | YES | |

Files that exist but are NOT in README directory tree:
- `.claude/ccyolo.md` -- local config
- `.claude/plugin-dirs` -- local config
- `.claude/settings.json` -- local config
- `.claude/statusline.sh` -- local config
- `.claude/guardian/guardian.log` -- local log
- `.mcp.json` -- local MCP config (gitignored)
- `on_notification.wav` -- sound file
- `on_stop.wav` -- sound file
- `temp/` -- working directory (11 files)

**Verdict**: The documented structure matches reality for tracked files. However,
several local development artifacts exist that are not gitignored and could
confuse contributors who clone the repo.

---

## Overall Grade

### NEEDS WORK

The README is comprehensive and well-written, but it fails the newcomer trust
test. The API key situation is the single largest barrier -- it creates genuine
suspicion in first-time readers. Secondary issues (dead code, Korean references,
missing prerequisites) compound the trust problem.

**What works well**:
- Clear purpose statement (first 15 seconds)
- Good usage examples with multiple input formats
- Thorough troubleshooting section
- Honest documentation of limitations
- Consistent cross-document information

**What needs fixing (prioritized)**:
1. **P0**: Resolve the API key paradox -- either remove `required_environment`
   from SKILL.md or make the "metadata-only" explanation dramatically clearer
   (consider removing the validation rule that requires keys to be configured)
2. **P0**: Add post-install verification step
3. **P1**: Add prerequisites / "What is Claude Code" context
4. **P1**: Remove or properly scaffold the dead test file
5. **P1**: Add a quick-start section at the top (3 steps: copy, verify, use)
6. **P2**: Reconsider whether the MCP comparison / limitations section belongs
   in the README (move to ARCHITECTURE.md?) -- it currently undermines confidence
7. **P2**: Clean up repo artifacts (sound files, extra .claude/ files)
8. **P2**: Add GitHub badges for trust signals
