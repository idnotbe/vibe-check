# User Scenarios for Vibe Check Plugin

## Persona Definitions

### P1: The Newcomer (Discovery + First Install)
A developer who encounters the vibe-check plugin for the first time -- through
GitHub search, a recommendation, or browsing Claude Code plugins. They have
Claude Code installed but have never used a third-party skill plugin. Their
primary question: "What does this do and how do I get it working?"

### P2: The Daily User (Routine /vibe-check Invocations)
A developer who has the plugin installed and uses `/vibe-check` as part of their
regular workflow. They invoke it before complex decisions, deployments, or when
they feel uncertain. They use mostly natural-language input and rarely think
about configuration.

### P3: The Power User (API Provider/Model Configuration)
A developer who wants to use the `apiProvider` and `model` parameters to
customize vibe-check behavior. They may expect the plugin to actually call
external models (OpenAI, Google, Anthropic) or they may understand that these
parameters influence Claude's feedback style. This distinction is the core
documentation challenge for this persona.

### P4: The MCP Migrator (Coming from vibe-check-mcp-server)
A developer who previously used PV-Bhat's vibe-check-mcp-server (which makes
real external LLM API calls) and wants to switch to this lighter Skills-based
version. Their key concern: understanding what they gain (simplicity, no
external dependencies) and what they lose (actual multi-model feedback).

### P5: The Contributor (Modifying, Testing, Adding CI)
A developer who wants to fork or contribute to the vibe-check plugin. They need
to understand the repo structure, run tests, modify SKILL.md, and potentially
set up CI. This persona also covers the DevOps perspective (setting up GitHub
Actions).

### P6: The Non-Korean Speaker (International Developer)
A developer who does not read Korean. They encounter Korean text in SKILL.md
(parameter descriptions, argument-hint, input format examples, configuration
instructions), ARCHITECTURE.md (entirely Korean), and test_scenarios.md
(entirely Korean). Their experience is degraded and their ability to contribute
is limited.

### P7: The Security-Conscious Developer
A developer who audits plugins before installing them. They see
`required_environment` listing 3 API keys in a plugin that claims to have "no
runtime dependencies" and "no external API calls." This creates a trust barrier
that must be addressed by documentation.

---

## Scenario 1: First Discovery and Installation

### Persona: P1 (Newcomer), also affects P6 and P7

### Steps
1. Developer finds the plugin on GitHub (search, link, recommendation)
2. Reads README.md for overview
3. Sees the comparison table: "Dependencies: None" vs MCP version
4. Reads Installation section: `cp -r .claude/skills/ /path/to/your/project/.claude/skills/`
5. Copies the skills directory into their project
6. Opens Claude Code and tries `/vibe-check` for the first time
7. Provides a goal and plan, receives structured feedback

### Expected Documentation Needs
- Clear one-sentence explanation of what the plugin does
- Unambiguous installation steps (what to copy, where to put it)
- Clarification of the two installation paths:
  - Manual copy (documented in README)
  - Plugin manifest via plugin.json (undocumented)
- First-use example showing what input looks like and what output to expect
- Explicit statement that no API keys are needed for basic usage

### Current Documentation Gaps

**Gap 1.1: plugin.json installation path is undocumented.**
README only documents `cp -r`. The existence of `.claude-plugin/plugin.json`
implies a plugin-registry installation method, but no documentation explains
how to use it. A newcomer who sees plugin.json may try a `claude plugin install`
workflow that does not exist or behaves unexpectedly.
- Affected file: README.md (Installation section)

**Gap 1.2: "Dependencies: None" is misleading.**
The comparison table says "Dependencies: None" but SKILL.md frontmatter declares
`required_environment` with 3 API keys. Even if these are metadata-only, a user
reading both files will be confused.
- Affected files: README.md (comparison table), needs clarifying footnote
- Known issue: TEST-PLAN.md P1.1 already identifies this

**Gap 1.3: No "what to expect" example.**
README shows input format but does not show example output. A newcomer does not
know what "Vibe Check Results" look like until they try it.
- Affected file: README.md (Usage section)

**Gap 1.4: Environment variable behavior on first run is unclear.**
If `required_environment` causes Claude Code to prompt for or block on missing
API keys, the newcomer's first experience is broken. Documentation should
explicitly state whether the plugin loads without these keys.
- Affected file: README.md (Installation section)

---

## Scenario 2: Basic Daily Usage (/vibe-check)

### Persona: P2 (Daily User)

### Steps
1. Developer is mid-task and feeling uncertain about their approach
2. Types `/vibe-check` followed by natural language description
3. Receives structured feedback (Quick Assessment, Key Questions, Pattern Watch,
   Recommendation, If Adjusting)
4. Adjusts plan based on feedback or proceeds with confidence
5. Optionally re-runs `/vibe-check` after adjustments

### Expected Documentation Needs
- All three input formats documented with clear examples:
  - Structured (key: value pairs)
  - Natural language (free-form text)
  - Simple (goal / plan shorthand)
- Description of each output section and what it means
- Guidance on when to use vibe-check (the "When to Use" section)
- Description of optional parameters (progress, uncertainties, taskContext)

### Current Documentation Gaps

**Gap 2.1: Output format is undocumented in README.**
README says "Claude will analyze your plan and provide: Quick assessment, Key
questions, Pattern warnings, Clear recommendations" but does not show the actual
output template. The full output format (with markdown structure) only exists in
SKILL.md lines 162-182.
- Affected file: README.md (Usage section)

**Gap 2.2: Optional parameters are not explained in README.**
README shows one usage example with goal+plan only. The optional parameters
(`progress`, `uncertainties`, `taskContext`) are documented only in SKILL.md
(lines 29-36, in Korean). README does not mention them at all.
- Affected file: README.md (Usage section)

**Gap 2.3: Input format examples in SKILL.md are in Korean.**
All three input format examples in SKILL.md (lines 48-68) use Korean text.
Non-Korean users reading SKILL.md directly would not be able to follow these.
The README has one English example but it is minimal.
- Affected file: README.md needs English examples; SKILL.md is Korean by design
  (constraint: we cannot modify SKILL.md)

**Gap 2.4: No guidance on interpreting feedback.**
A user who receives "Pattern Watch: Complex Solution Bias" may not understand
what to do about it. The Pattern Watch table in README (lines 69-79) lists
patterns and remedies, which is good, but there is no bridge between the output
format and this reference table.
- Affected file: README.md could link output sections to the Pattern Watch table

---

## Scenario 3: API Provider and Model Configuration

### Persona: P3 (Power User), also affects P7 (Security-Conscious)

### Steps
1. User reads about `apiProvider` and `model` parameters
2. Sees the provider/model table (openai, google, anthropic with specific models)
3. Sees `required_environment` listing 3 API keys
4. Configures API keys in `~/.claude/settings.json`
5. Invokes `/vibe-check` with `apiProvider: openai model: gpt-5.2-high`
6. Expects feedback informed by (or generated by) the specified model
7. Receives Claude's feedback styled/informed by the specified model's characteristics

### Expected Documentation Needs
- Clear explanation of what `apiProvider` and `model` actually do
- **Critical**: Whether these parameters trigger external API calls or just
  influence Claude's feedback style
- Which models are supported per provider
- How to configure API keys and where
- What happens if API keys are missing
- Validation rules (provider requires model, model must match provider)

### Current Documentation Gaps

**Gap 3.1: The fundamental nature of apiProvider/model is undocumented.**
This is the single most confusing aspect of the plugin. SKILL.md says these
parameters make Claude "consider the specified model's characteristics" when
giving feedback (line 74). But the required_environment keys, the validation
rules about checking if "the API key environment variable is set" (line 105),
and the provider-specific descriptions all strongly imply external API calls.

A power user will reasonably expect that setting `apiProvider: openai` causes
the plugin to call GPT-5.2. When they discover it does not, they may feel
misled or file a bug.

README does not explain this at all. The comparison table says "LLM Calls:
Claude itself acts as meta-mentor" which hints at it, but this is easily missed.
- Affected file: README.md needs a dedicated section explaining this
- This is the highest-priority documentation gap for the power user persona

**Gap 3.2: API key configuration is only documented in SKILL.md (in Korean).**
The `~/.claude/settings.json` configuration example (SKILL.md lines 92-99) is
preceded by Korean text. README has no API key configuration instructions.
- Affected file: README.md (needs configuration section)

**Gap 3.3: Validation behavior is undocumented.**
SKILL.md (lines 103-105) describes validation rules in Korean:
- apiProvider requires model to also be specified
- model must be supported by the chosen provider
- API key env var must be set for the chosen provider

But what happens when validation fails? Does the skill error out, warn, or
fall back to defaults? This is not documented anywhere.
- Affected file: README.md (needs troubleshooting/configuration section)

**Gap 3.4: "Phantom configuration" confusion.**
Users setting `apiProvider: openai` will expect a real OpenAI response. They
will get a Claude response that "considers GPT-5.2-high characteristics." This
is a role-play/simulation, not an actual model switch. Without documentation,
users may file bug reports claiming the model parameter is broken.
- Affected file: README.md needs explicit clarification

---

## Scenario 4: MCP-to-Skills Migration

### Persona: P4 (MCP Migrator)

### Steps
1. User has been using PV-Bhat/vibe-check-mcp-server
2. Discovers this Skills-based alternative
3. Reads README comparison table (MCP Server vs Agent Skills)
4. Evaluates trade-offs:
   - Gain: No external process, no npm dependencies, native Claude integration
   - Lose: Actual external model calls (Gemini, OpenAI, etc.)
5. Decides to migrate
6. Removes MCP server configuration
7. Copies skills directory into project
8. Adjusts workflow from MCP tool invocation to `/vibe-check` slash command

### Expected Documentation Needs
- Side-by-side comparison of MCP vs Skills (already partially in README)
- Explicit list of what changes in the migration
- **Critical**: Clear statement that external LLM calls are replaced by Claude's
  own meta-analysis. The migrator loses multi-model perspective.
- Migration steps (uninstall MCP, install Skills)
- Mapping of MCP parameters to Skills parameters

### Current Documentation Gaps

**Gap 4.1: Migration steps are not documented.**
README has a comparison table but no migration guide. ARCHITECTURE.md (line 78-79)
mentions migration in Korean: "1. Install Skills (.claude/skills/ copy), 2. Use
/vibe-check" but this is only 2 lines in Korean.
- Affected file: README.md (needs Migration section) or ARCHITECTURE.md
  (needs English translation)

**Gap 4.2: Feature parity is not honestly documented.**
The comparison table frames Skills as equivalent to MCP with simpler installation.
But the MCP server makes *actual* external API calls to Gemini, OpenAI, etc.
The Skills version has Claude role-play as those models. This is a significant
functional difference that is not disclosed.
- Affected file: README.md (comparison table needs a "Limitations" note)

**Gap 4.3: Parameter mapping is absent.**
MCP server may have different parameter names or additional parameters. No
documentation maps old parameters to new ones.
- Affected file: README.md (Migration section)

---

## Scenario 5: Troubleshooting

### Persona: All personas, but especially P1, P3, P6

### Steps (various failure modes)
1. **Missing API keys**: User runs `/vibe-check` without setting API keys.
   Plugin may fail to load or warn.
2. **Invalid provider/model combo**: User specifies `apiProvider: openai
   model: claude-opus-4.5`. Validation should catch this but behavior is unclear.
3. **No goal or plan provided**: User types just `/vibe-check` with no arguments.
   SKILL.md has a special case for this (lines 210-214).
4. **Korean output when English expected**: User provides English input but
   receives Korean-inflected output because SKILL.md instructions are Korean.
5. **Dead test file confusion**: Contributor runs `npx jest` or `npm test` and
   gets errors because there is no Node.js scaffolding.
6. **Plugin does not appear in Claude Code**: Skills directory copied to wrong
   location or plugin.json not recognized.

### Expected Documentation Needs
- FAQ or Troubleshooting section covering common failure modes
- Clear error messages for validation failures
- Guidance on language behavior (input/output language expectations)
- Explanation of why there is no package.json (this is a prompt-only plugin)

### Current Documentation Gaps

**Gap 5.1: No troubleshooting documentation exists.**
Neither README nor any other doc has a troubleshooting section. Users hitting
any of the above failure modes have no guidance.
- Affected file: README.md (needs Troubleshooting section)

**Gap 5.2: Language behavior is completely undocumented.**
SKILL.md contains Korean throughout its instructions. Whether the output will
be in Korean, English, or the user's input language is not documented. This is
a critical usability issue for the P6 persona.
- Affected file: README.md (needs Language section or note)

**Gap 5.3: Error recovery paths are undocumented.**
SKILL.md defines validation rules (lines 103-105) but does not specify error
messages or recovery guidance. If a user provides `apiProvider` without `model`,
what happens? The test_scenarios.md (line 28) expects "Error: Provider required"
but this is a manual test plan that has never been executed.
- Affected file: README.md (Troubleshooting section)

---

## Scenario 6: Contributing and Development

### Persona: P5 (Contributor), also P6 (Non-Korean Speaker)

### Steps
1. Forks the repository
2. Reads CLAUDE.md for development guidelines
3. Reads ARCHITECTURE.md for design understanding (blocked if non-Korean)
4. Explores test infrastructure:
   - Finds validate_skill.sh (runnable, 28 checks)
   - Finds api_provider.test.ts (tries to run, fails -- dead code)
   - Finds test_scenarios.md (manual, Korean)
5. Makes changes to SKILL.md
6. Runs `bash tests/validate_skill.sh` to verify
7. Wants to add CI -- reads TEST-PLAN.md for guidance
8. Submits PR

### Expected Documentation Needs
- Contributing guidelines (what to change, what not to change)
- Clear test instructions (which tests work, which do not)
- Architecture overview in English
- SKILL.md stability contract (it is the "API" -- treat it carefully)
- CI setup guidance

### Current Documentation Gaps

**Gap 6.1: ARCHITECTURE.md is entirely in Korean.**
CLAUDE.md states "All committed content should be in English" (line 60), but
ARCHITECTURE.md is entirely in Korean. A non-Korean contributor cannot understand
the design philosophy, skill specification, or implementation notes.
- Affected file: ARCHITECTURE.md (needs English translation)

**Gap 6.2: No CONTRIBUTING.md or contributing section in README.**
There are no contributing guidelines. CLAUDE.md has development guidelines but
is focused on Claude Code agent behavior, not human contributors. A contributor
does not know:
- How to submit PRs
- What coding standards to follow
- How to add new providers/models (and update tests to match)
- The review process
- Affected file: README.md (needs Contributing section) or new CONTRIBUTING.md

**Gap 6.3: Dead test file is a contributor trap.**
api_provider.test.ts looks like a real test. A contributor will try to run it,
waste time debugging, and conclude the repo is broken. CLAUDE.md and TEST-PLAN.md
document this, but a new contributor reads README first.
- Affected file: README.md (Testing section should be more prominent about this)

**Gap 6.4: test_scenarios.md is in Korean and never executed.**
A contributor wanting to run manual tests cannot follow the Korean test plan.
Even if translated, the checklist (line 217-223) has never been executed, so
there is no baseline of known-good results.
- Affected file: tests/test_scenarios.md (needs English translation, outside
  current doc-only constraint)

---

## Scenario 7: Security Audit and Trust Evaluation

### Persona: P7 (Security-Conscious Developer)

### Steps
1. Reads README: "Dependencies: None", "prompt-only", "no runtime code"
2. Inspects plugin.json: sees `required_environment` is not listed here
3. Inspects SKILL.md frontmatter: sees 3 API keys in `required_environment`
4. Alarm: "Why does a prompt-only plugin need my OpenAI, Google, and Anthropic
   API keys?"
5. Reads through SKILL.md to verify no code execution occurs
6. Checks for any network calls, process spawning, or data exfiltration
7. Finds none -- concludes keys are metadata -- but the documentation did not
   explain this, requiring manual audit

### Expected Documentation Needs
- Explicit statement: "This plugin makes no network calls and does not use
  your API keys. The required_environment declaration is metadata for
  provider/model documentation."
- Security posture summary (what the plugin can and cannot do)
- Explanation of why required_environment exists despite no runtime

### Current Documentation Gaps

**Gap 7.1: No security or trust documentation.**
There is no explanation of why API keys are listed in required_environment.
CLAUDE.md mentions it as a "known contract mismatch" (line 23-24) but this is
internal developer documentation, not user-facing.
- Affected file: README.md (needs a Security/Trust note)

**Gap 7.2: The trust barrier is the first thing a careful user encounters.**
A security-conscious developer may not install the plugin at all if they see
unexplained API key requirements. This is a higher barrier than a missing
feature -- it is a trust failure.
- Affected file: README.md (Installation section should proactively address this)

---

## Scenario 8: Plugin Update and Version Management

### Persona: P2 (Daily User), P1 (Newcomer)

### Steps
1. A new version of vibe-check is released
2. User wants to update their local copy
3. Looks for update instructions
4. Finds none -- must manually re-copy the skills directory
5. Wonders if their local customizations (if any) will be overwritten

### Expected Documentation Needs
- Version information and changelog
- Update procedure
- Whether local modifications are safe across updates

### Current Documentation Gaps

**Gap 8.1: No versioning or update documentation.**
plugin.json has `"version": "0.1.0"` but there is no changelog, no update
instructions, and no guidance on version compatibility.
- Affected file: README.md (needs Version/Update section)

---

## Documentation Requirements Matrix

This matrix maps each scenario to the documentation files that should serve it,
and identifies the primary gaps.

| Scenario | Primary Doc | Supporting Docs | Critical Gaps |
|----------|-------------|-----------------|---------------|
| 1. Discovery + Install | README.md | plugin.json | 1.1 (plugin.json path), 1.2 (deps mismatch), 1.4 (env var behavior) |
| 2. Daily Usage | README.md | SKILL.md | 2.1 (output format), 2.2 (optional params), 2.3 (Korean examples) |
| 3. Provider Config | README.md | SKILL.md | 3.1 (what apiProvider does), 3.2 (config in Korean), 3.4 (phantom config) |
| 4. MCP Migration | README.md | ARCHITECTURE.md | 4.1 (no migration guide), 4.2 (feature parity honesty) |
| 5. Troubleshooting | README.md | -- | 5.1 (no troubleshooting section), 5.2 (language behavior) |
| 6. Contributing | CLAUDE.md, README.md | ARCHITECTURE.md, TEST-PLAN.md | 6.1 (ARCHITECTURE in Korean), 6.2 (no contributing guide), 6.3 (dead test) |
| 7. Security Audit | README.md | CLAUDE.md | 7.1 (no security note), 7.2 (trust barrier) |
| 8. Update/Version | README.md | plugin.json | 8.1 (no update docs) |

### Gap Priority Ranking

| Priority | Gap ID | Description | Impact |
|----------|--------|-------------|--------|
| Critical | 3.1 | apiProvider/model behavior unexplained | Users expect external API calls, get role-play |
| Critical | 7.1 | No explanation of required_environment keys | Trust barrier blocks installation |
| Critical | 6.1 | ARCHITECTURE.md in Korean | Non-Korean contributors cannot understand design |
| High | 1.2 | "Dependencies: None" vs required_environment | Contradictory messaging |
| High | 2.1 | Output format not in README | Users cannot preview what they will get |
| High | 2.2 | Optional parameters not in README | Users miss useful features |
| High | 4.2 | Feature parity not honestly documented | Migrators discover downgrade after switching |
| High | 5.1 | No troubleshooting section | Users stuck on common failures |
| Medium | 1.1 | plugin.json installation undocumented | Confusion about installation method |
| Medium | 3.2 | API key config only in Korean | Power users cannot configure |
| Medium | 5.2 | Language behavior undocumented | International users confused by Korean output |
| Medium | 6.2 | No contributing guidelines | Contributors guess at process |
| Medium | 6.3 | Dead test file traps contributors | Wasted time, impression of broken repo |
| Low | 4.3 | No MCP parameter mapping | Migrators must figure out mapping themselves |
| Low | 8.1 | No update documentation | Users manually re-copy on updates |

---

## Self-Critique

### Scenarios I may have under-explored

1. **Team adoption scenario**: What happens when one developer on a team installs
   the plugin and recommends it to others? Is there a per-project vs per-user
   installation distinction? The skills directory is project-local, but
   `~/.claude/settings.json` is user-global. This mismatch could cause confusion
   in team settings.

2. **Automated/CI usage**: Could `/vibe-check` be invoked programmatically as
   part of a CI pipeline or pre-commit hook? This is probably not a supported
   use case for a Claude Code skill, but some users may ask about it.

3. **Skill conflict scenario**: What happens if a user already has a skill named
   "vibe-check" from another source? Plugin naming conflicts are not addressed
   in any documentation.

4. **Offline usage**: Since the plugin is prompt-only and runs within Claude Code,
   it requires an active Claude session. But users might wonder if it works
   offline or with local models. This edge case is unaddressed.

5. **Korean-speaking user scenario**: I focused on the non-Korean speaker as a
   gap, but Korean-speaking users are likely the primary audience given the
   SKILL.md language. Documentation should ideally serve both audiences, but
   the CLAUDE.md mandate ("all committed content should be in English") creates
   tension with the Korean SKILL.md content.

### Assumptions I made

- I assumed `required_environment` in SKILL.md frontmatter may cause Claude Code
  to prompt for or validate these environment variables at plugin load time. I
  could not verify this assumption without testing, but the documentation should
  address it regardless.

- I assumed the `apiProvider`/`model` parameters do NOT trigger external API
  calls, based on: (a) README says "Claude itself acts as meta-mentor", (b)
  CLAUDE.md says "this repo makes no outbound API calls", (c) the plugin is
  prompt-only with no runtime code. If this assumption is wrong, nearly all of
  Scenario 3 and 7 need revision.

- I assumed plugin.json enables some form of registry-based installation, but
  Claude Code plugin installation mechanics are not well-documented publicly,
  so I could not verify the exact workflow.

---

## External Validation

### Vibe-Check Self-Assessment

Running `/vibe-check` on this scenario design plan produced the following
feedback:

**Quick Assessment**: Plan is on track with minor adjustments needed.

**Key feedback incorporated**:
1. Consolidation advice: Merged the original "DevOps" persona into the
   Contributor persona (P5) rather than keeping 6+ thin personas.
2. Elevated the `required_environment` confusion into its own dedicated
   scenario (Scenario 7: Security Audit) rather than burying it.
3. Each scenario now cites specific files and line numbers where gaps exist.
4. Added a caution against over-engineering: kept scenario depth proportional
   to actual plugin complexity.

**Pattern Watch flag**: Mild Feature Creep risk -- designing too many scenarios
for a single-skill plugin. Addressed by keeping scenarios focused and
maintaining a clear priority ranking in the Documentation Requirements Matrix.

### Gemini CLI (gemini-3-pro-preview) Assessment

Gemini reviewed the scenario plan against all project files and identified
several critical additions:

**Missing personas surfaced**:
1. The Non-Korean Speaker -- added as P6. Gemini correctly noted that SKILL.md's
   Korean instructions may force Korean-inflected or mixed-language output, even
   for English-speaking users.
2. The Security Auditor -- added as P7. Gemini highlighted the high trust
   barrier created by requiring 3 API keys for a tool that uses none.

**Key edge cases Gemini identified**:
1. "Phantom Configuration" trap: Users setting apiProvider expect real model
   calls. Incorporated as Gap 3.4.
2. Environment Variable Hard-Stop: required_environment may block plugin loading.
   Incorporated as Gap 1.4.
3. Dead Code Confusion: Contributors trying `npm test` on a repo with no
   package.json. Already identified as Gap 6.3 but Gemini reinforced its severity.
4. Feature downgrade for MCP migrators: The Skills version replaces actual
   external model calls with simulated ones. Incorporated as Gap 4.2.

**Gemini's recommended next steps** (all incorporated):
- Added "Missing Env Var" scenario to Scenario 5 (Troubleshooting)
- Added language behavior as Gap 5.2
- Clarified that `tests/api_provider.test.ts` is a known stumbling block

### Codex CLI Assessment

Codex CLI was unavailable due to rate limiting. The analysis proceeds without
this data point. The vibe-check self-assessment and Gemini feedback provide
sufficient external validation from two independent perspectives.
