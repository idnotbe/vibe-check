# Marketplace.json design review for idnotbe/vibe-check

## Goal
Make `idnotbe/vibe-check` repo installable via:
```
/plugin marketplace add idnotbe/vibe-check
/plugin install vibe-check@vibe-check
```

The repo currently has the plugin AT THE REPO ROOT:
- `.claude-plugin/plugin.json` (plugin manifest, v0.2.0)
- `.claude/skills/vibe-check/SKILL.md` (the skill)

It has NO `marketplace.json`. We need to add one so the same repo serves as both marketplace and (its only) plugin.

## Verified docs facts (from code.claude.com/docs/en/plugin-marketplaces and plugins-reference)

- `marketplace.json` requires: `name` (kebab-case, becomes the `@<name>` in install), `owner` (object, name required), `plugins` (array)
- Each plugin entry requires: `name`, `source`
- `source` as relative-path string: "Local directory within the marketplace repo. Must start with `./`. Resolved relative to the marketplace root, not the `.claude-plugin/` directory."
- Docs show `"./my-plugin"` (subdirectory) examples but **do NOT explicitly show `"./"` (just root)** — neither confirmed nor denied.

## Three options for `source`

### Option A: `"source": "./"` (proposed)
```json
{
  "name": "vibe-check",
  "owner": { "name": "idnotbe", "url": "https://github.com/idnotbe" },
  "plugins": [{ "name": "vibe-check", "source": "./", "description": "..." }]
}
```
- Pro: zero file moves, preserves manual-copy install
- Pro: matches "Must start with ./" rule literally
- Con: not in any official example — risk that the resolver rejects bare `./`

### Option B: Restructure plugin into `./plugins/vibe-check/` subdirectory
- Move `.claude-plugin/plugin.json` → `plugins/vibe-check/.claude-plugin/plugin.json`
- Move `.claude/skills/vibe-check/` → `plugins/vibe-check/.claude/skills/vibe-check/`
- Marketplace.json source: `"./plugins/vibe-check"`
- Pro: matches docs example exactly, lowest risk
- Con: BIG breaking change. Breaks the existing manual-copy install (`cp -r .claude/skills/...`). Users with existing copies break. tests/validate_skill.sh paths break.
- Con: every README install instruction needs rewriting beyond the plugin-install section

### Option C: GitHub object source (self-referential)
```json
"source": {"source": "github", "repo": "idnotbe/vibe-check"}
```
- Pro: unambiguous, in docs as a valid source type
- Pro: zero file moves
- Con: when user runs `/plugin marketplace add idnotbe/vibe-check`, Claude Code clones the repo locally; then this plugin source says "go fetch idnotbe/vibe-check from github again" — likely re-clones or maybe deduplicates, behavior unclear
- Con: feels weird — the marketplace IS this repo, and we're saying "go elsewhere to find the plugin"

## Proposed marketplace.json (Option A)

```json
{
  "name": "vibe-check",
  "owner": {
    "name": "idnotbe",
    "url": "https://github.com/idnotbe"
  },
  "metadata": {
    "description": "Metacognitive sanity checks for agent plans.",
    "homepage": "https://github.com/idnotbe/vibe-check"
  },
  "plugins": [
    {
      "name": "vibe-check",
      "source": "./",
      "description": "Metacognitive sanity checks for agent plans. Use before irreversible actions, when uncertainty is high, or when complexity is escalating."
    }
  ]
}
```

## Proposed README install section

````markdown
## Installation

### Method 1: Install via Claude Code plugin marketplace (recommended)

```
/plugin marketplace add idnotbe/vibe-check
/plugin install vibe-check@vibe-check
```

### Method 2: Manual copy (fallback)

```bash
cp -r .claude/skills/ /path/to/your/project/.claude/skills/
```
````

## Question for reviewer

Read/analyze only, do not modify files.

1. Is Option A (`"source": "./"`) the right call, or is the docs ambiguity serious enough that I should do Option B (restructure into subdirectory)?
2. Are there any failure modes in Option A I'm not seeing — e.g., does Claude Code's resolver have a special meaning for bare `./` that conflicts (like "use the marketplace itself as the plugin")?
3. Is the marketplace.json structure (top-level `metadata` block) correct? Or should `description`/`homepage` go elsewhere?
4. Anything else about this design that smells wrong?
