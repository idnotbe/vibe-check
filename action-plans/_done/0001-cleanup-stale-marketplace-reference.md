---
status: done
progress: "Closed"
---

# Plan 0001: Cleanup Stale Marketplace Reference in overview.md

## Classification: Lightweight

This plan qualifies as Lightweight per `action-plans/README.md` §103: it is a
single-doc edit to one untracked file (`docs/requirements/overview.md`), it
does not touch `SKILL.md`, it does not modify the validator
(`tests/validate_skill.sh`), and it adds no new requirement IDs. An abbreviated
Phase 0 alignment block plus a single execution phase suffice; the verification
surface collapses to two `rg` invocations.

## Background & Motivation

Hub repository `idnotbe/claude-plugins` closed its plan 0006 ("deprecate
standalone marketplaces") and recorded ADR-007, which makes the hub the single
install path for every `idnotbe` plugin. As part of plan 0006 phase 3, the
vibe-check repo's standalone `.claude-plugin/marketplace.json` was deleted in
commit `3b6f32c` and the README, CLAUDE.md, ARCHITECTURE.md, and SKILL.md were
rewritten to cite the hub instead.

During plan 0006 phase 3 review, both round 1 (codex) and round 2 (claude)
flagged a single residual stale reference at
`docs/requirements/overview.md:28` that the §11 enumeration in the drafts had
missed. Both reviewers explicitly classified the line as out-of-scope for plan
0006 (because it lives inside vibe-check's untracked `docs/` WIP) and
recommended a future cleanup plan in this repository. This is that plan.

The line is factually wrong on two counts: it claims a file
(`.claude-plugin/marketplace.json`) that no longer exists, and it advertises
dual distribution (standalone marketplace + hub) that ADR-007 explicitly
closed.

## Scope

### In scope

- One bullet rewrite at `docs/requirements/overview.md:28` (the line inside
  the `### In Scope` section that names the deleted standalone marketplace
  manifest as a distribution mechanism).

### Out of scope (explicitly)

- `docs/architecture/decisions.md` ADR-004. Already superseded with an
  explicit callout; its historical body is preserved by design (parallels how
  hub plan 0006 preserved historical ADR bodies). A future governance plan may
  move it to `_ref/`; not this plan.
- `docs/requirements/non-functional-and-constraints.md`. Already correctly
  cites hub-only install plus ADR-007. No edit needed.
- `README.md`, `CLAUDE.md`, `ARCHITECTURE.md`, `SKILL.md`. Already cleaned by
  hub plan 0006 phase 3 (commit `3b6f32c`).
- The git-tracking status of `docs/`. The directory remains untracked WIP by
  inheritance from plan 0006 phase 3. This plan does not revisit that
  decision.
- `tests/validate_skill.sh`. Untouched; SKILL.md is not modified, so the
  validator surface is unchanged.

## Phase F.0: Open Commit (BEFORE Phase 0)

This subphase runs FIRST, before Phase 0 begins. It publishes the plan file
on `main` in the `not-started` state so the plan is visible but execution has
not yet begun; Phase 0 then opens against an already-committed plan file.

### User approval gate

Before the push, surface the commit to the user and wait for explicit
approval. Push is irreversible and externally visible.

### Suggested commit message

```
plan: open 0001-cleanup-stale-marketplace-reference (not-started)
```

### Phase F.0 execution steps

- [ ] Create the action-plan file at
      `action-plans/0001-cleanup-stale-marketplace-reference.md` with
      frontmatter `status: not-started` and `progress: "Not started"`.
- [ ] Stage and create commit 1 with the message
      `plan: open 0001-cleanup-stale-marketplace-reference (not-started)`.
- [ ] Surface commit 1 to the user and wait for explicit approval before
      pushing. Push is irreversible and externally visible.
- [ ] Push commit 1 to `main`.

## Phase 0: Alignment Gate (abbreviated per Lightweight)

The four alignment decisions are recorded explicitly here so that they are
not silently inherited. Each decision is restated as an explicit acknowledgement
step the executor must check off before opening Phase 1.

The decisions:

1. **`docs/` is untracked WIP.** This state is inherited from plan 0006
   phase 3 and is not a decision this plan revisits. The entire `docs/` tree
   (overview.md, functional.md, non-functional-and-constraints.md,
   architecture/components.md, architecture/decisions.md) remains outside
   the git index.
2. **Working-tree-only edits.** No `git add docs/...` will be issued. This
   mirrors plan 0006 phase 3's pattern. The constraint holds until a future
   plan formally tracks `docs/` under version control.
3. **ADR-004 governance and non-functional-and-constraints.md hub-citation
   block are out of scope.** Both surfaces are intentionally preserved as
   they stand: ADR-004 because its historical body is documented as
   superseded-but-preserved, non-functional-and-constraints.md because it is
   already correct. This plan is narrow on purpose.
4. **The sole git artifact this plan produces is the action-plan file
   itself.** It is created in the `not-started` state and committed to `main`
   (open commit). When execution begins, the frontmatter flips to `active` in
   the working tree only — no per-step commits. On completion, the frontmatter
   flips to `done` and the file is `git mv`'d to `action-plans/_done/` in a
   second commit. No `docs/*` file enters the index at any point during this
   plan.

Phase 0 acknowledgement steps:

- [ ] Acknowledge decision 1: confirm that `docs/` is untracked WIP inherited
      from hub plan 0006 phase 3 and that this plan does not revisit that
      state.
- [ ] Acknowledge decision 2: confirm that no `git add docs/...` will be
      issued at any point during execution.
- [ ] Acknowledge decision 3: confirm that ADR-004 governance and
      `non-functional-and-constraints.md` are out of scope for this plan.
- [ ] Acknowledge decision 4: confirm the three-state lifecycle for the
      action-plan file itself (open commit at `not-started` →
      working-tree-only `active` mutation during execution → close commit
      at `done` with `git mv` to `_done/`).
- [ ] Flip to active: edit the action-plan frontmatter in the working tree
      to `status: active`, `progress: "Execution in progress"`. **Working-tree
      only — do NOT commit or stage this change** (it is part of in-flight
      working-tree mutation per Phase 0 alignment decision #4 / Pattern A
      semantics).

## Phase 1: Execution

### Verbatim before/after for `docs/requirements/overview.md`

Pre-edit, lines 23-33 (5 lines context above the target, the target at line
28, and 5 lines below):

```
### In Scope

- A single Claude Code skill (`vibe-check`) implemented as a behavioral-mandate prompt in `SKILL.md`.
- Producing a fixed-shape output block (Quick Assessment, Key Questions, Pattern Watch, Recommendation, If Adjusting, Next Action).
- A continuation mandate that requires the agent to keep working after the output block — the block is feedback, not a stopping point.
- A structural validator (`tests/validate_skill.sh`) that protects the skill's documented surface.
- Distribution as a Claude Code plugin via `.claude-plugin/plugin.json` and a marketplace manifest at `.claude-plugin/marketplace.json`.

### Out of Scope

- Any runtime code, compiled assets, or executable artifacts inside the plugin.
- Outbound API calls, network requests, environment variable reads, or API-key configuration.
```

Post-edit, same window with the target rewrite applied:

```
### In Scope

- A single Claude Code skill (`vibe-check`) implemented as a behavioral-mandate prompt in `SKILL.md`.
- Producing a fixed-shape output block (Quick Assessment, Key Questions, Pattern Watch, Recommendation, If Adjusting, Next Action).
- A continuation mandate that requires the agent to keep working after the output block — the block is feedback, not a stopping point.
- A structural validator (`tests/validate_skill.sh`) that protects the skill's documented surface.
- Distribution as a Claude Code plugin via `.claude-plugin/plugin.json`, installable through the `idnotbe/claude-plugins` hub.

### Out of Scope

- Any runtime code, compiled assets, or executable artifacts inside the plugin.
- Outbound API calls, network requests, environment variable reads, or API-key configuration.
```

### Edit semantics

The edit is a single-line replacement. The pre-edit bullet enumerates two
distribution artifacts (`plugin.json` plus `marketplace.json`); the post-edit
bullet enumerates one (`plugin.json`) and names the `idnotbe/claude-plugins`
hub as the install path. ADR/date provenance is intentionally NOT cited here
— that lives in `non-functional-and-constraints.md` where it already
correctly does; duplicating it in `overview.md` would conflate "what is
required" with "why it changed". The edit is working-tree-only — no
`git add` of any `docs/*` file.

### Phase 1 execution steps

- [ ] Read `/home/idnotbe/projects/vibe-check/docs/requirements/overview.md`
      lines 23-33 and confirm the pre-edit block above still matches the live
      file byte-for-byte. If the live file has drifted, stop and re-align
      before editing.
- [ ] Apply the single-line replacement at line 28: replace the pre-edit
      bullet with the post-edit bullet shown above (no ADR citation in this
      bullet — provenance lives in `non-functional-and-constraints.md`).
- [ ] Run `git status` in the vibe-check repo and confirm
      `docs/requirements/overview.md` (and the rest of `docs/`) still shows
      as untracked, with no `git add docs/...` issued.

## Phase F-1: Docs Sync Gate

The validator `bash tests/validate_skill.sh` is **not applicable** to this
plan: SKILL.md is untouched, so the skill's documented surface is unchanged
and the validator's checks are vacuously satisfied (or rather, they continue
to pass on whatever HEAD state they passed on before this plan started). This
gate is replaced by two `rg` sweeps.

### Anchor 1: target-file scoped sweep

```
rg "marketplace\.json" docs/requirements/overview.md
```

Expected: zero hits.

### Anchor 2: full-tree sibling sweep, asserting two FILES (not lines)

```
rg -l "marketplace\.json|marketplace add idnotbe/vibe-check|single-plugin install|standalone marketplace|per-plugin marketplace" docs/ --type-add 'md:*.md' -t md
```

Expected output (exactly two file paths, in any order):

```
docs/architecture/decisions.md
docs/requirements/non-functional-and-constraints.md
```

Rationale: the `-l` flag returns one line per matching file, so the gate is
"two known-allowed files, no third file." Both surfaces literally contain
`.claude-plugin/marketplace.json` strings — `decisions.md` in preserved
ADR-004 historical body (lines 127, 129, 134, 139, 146, 150, 156), and
`non-functional-and-constraints.md` at line 14 in the hub-citation block that
documents the removal. Both are intentional and out-of-scope per Phase 0
alignment.

Any third file in the output, or a missing expected file, fails Phase F-1 and
blocks Phase F.close.

Note on the regex: the alternation token `@vibe-check` was dropped. It has
zero current matches in `docs/` and was the most future-fragile token in the
regex (could collide with bare skill-invocation references). It is recorded
here as an explicit non-token; if a future cleanup wants to add it back as a
forward-looking guard, document explicitly that it is a future-only check.

### Phase F-1 execution steps

- [ ] Run Anchor 1 (`rg "marketplace\.json" docs/requirements/overview.md`)
      and confirm zero hits. If any hit appears, Phase 1 was incomplete —
      stop and re-edit before proceeding.
- [ ] Run Anchor 2 (the `rg -l` invocation above) and confirm the output is
      exactly the two file paths listed (`docs/architecture/decisions.md`
      and `docs/requirements/non-functional-and-constraints.md`), in any
      order. Any third file, or any missing expected file, blocks Phase F.close.

## Phase F.close: Close Commit (AFTER Phase F-1)

This subphase runs LAST, after Phase F-1 has passed. It flips the action-plan
file's frontmatter to `done`, fills the Notes & Deviations section if any,
moves the file to `_done/`, and pushes the close commit.

### User approval gate

Before the push, surface the commit to the user and wait for explicit
approval. Push is irreversible and externally visible.

### Suggested commit message

```
plan: close 0001-cleanup-stale-marketplace-reference

Rewrites docs/requirements/overview.md:28 to drop the stale
.claude-plugin/marketplace.json reference and cite the idnotbe/claude-plugins
hub. Working-tree-only edit; docs/ remains untracked WIP by inheritance from
hub plan 0006 phase 3.
```

### Phase F.close execution steps

- [ ] Edit the action-plan file's frontmatter in the working tree to
      `status: done` and `progress: "Closed"`. This is the first staged
      change for commit 2.
- [ ] If any deviation from the plan as drafted occurred during execution,
      fill the Notes & Deviations section now. If no deviation occurred,
      leave the placeholder note in place.
- [ ] `git mv` the file from
      `action-plans/0001-cleanup-stale-marketplace-reference.md` to
      `action-plans/_done/0001-cleanup-stale-marketplace-reference.md`.
      Note that this is a working-tree-only edit to `docs/`-adjacent state:
      the docs/ tree itself is NOT staged at any point during this plan.
- [ ] Stage and create commit 2 with the close-plan message shown above.
- [ ] Surface commit 2 to the user and wait for explicit approval before
      pushing.
- [ ] Push commit 2 to `main`.

## Plan-execution governance

This draft was reviewed in two independent rounds (codex round 1 + claude round 2)
before the final plan file was written, in keeping with the meta-thread protocol used
to draft this plan. The repo's Lightweight 1-round allowance (`action-plans/README.md`
§103) applies to plan EXECUTION (Phase 0 → Phase 1 → Phase F-1 → Phase F.close); the
2-round override applied only to plan-drafting and is now historical.

## Notes & Deviations

- **Close-commit message wording rephrased.** The plan's *Suggested commit
  message* (Phase F.close) opens with `Rewrites docs/requirements/overview.md:28
  ...`, which two independent reviewers (codex codereviewer round 1; gemini
  codereviewer round 2) flagged as ambiguous: a `git log` reader could infer
  the close commit itself modifies `docs/`, when in fact the close commit
  stages only the action-plan file's frontmatter flip plus the `git mv` to
  `_done/`. The body was rephrased to lead with `Closes plan 0001` and to
  explicitly state `This commit only moves the plan file to _done/ and flips
  its frontmatter to done.` The semantic content is unchanged; only the
  attribution-of-action wording is tightened. The plan's other sections were
  followed verbatim.
