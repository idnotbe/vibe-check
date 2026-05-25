# Canonical Autonomy text — insert verbatim into target CLAUDE.md files

This text was reviewed twice (codex via pal-mcp-clink + vibe-check skill) and finalized in `/home/idnotbe/projects/vibe-check/CLAUDE.md`. Insert it **verbatim** into target CLAUDE.md files.

---

## Block A: `## Autonomy` section (insert as a standalone H2 section)

```markdown
## Autonomy

Default = autonomous execution. Report results in 1-2 sentences. Request confirmation only for items under "Confirmation required" below.

**Decision rule** — both must hold to execute autonomously:
1. **Reversible from local state** with a short, well-known sequence (`git revert`, `git restore`, `git mv` back, etc.) — not requiring conflict resolution or reflog archaeology.
2. **No external side effects already in flight** — nothing that has notified humans, triggered CI someone watches, or could already have been pulled/consumed.

If either fails, confirm.

**Pre-authorized (execute without confirmation)** — within this repo, when the decision rule holds:
- File edit/create/delete (tracked), `git add/commit/push` (including `origin/main`)
- Local branch/tag operations, `git revert`, `git restore`
- Running tests, validators, builds; moving action-plans and updating status
- Delegating to subagents; calling `pal mcp clink`, `vibe-check`

**Confirmation required** — irreversible, history-rewriting, destructive, or external blast radius:
- `git push --force` / `--force-with-lease` (especially on shared branches)
- History rewrites on already-pushed commits: `git commit --amend`, `git rebase -i`, `git reset --hard` on shared history
- Workspace destruction outside git's safety net: `git clean -fd`, `rm -rf` on untracked files/directories, direct edits inside `.git/`
- Remote-ref deletion: `git push --delete`, deleting unmerged branches
- Creating/commenting on GitHub PRs/issues, sending external messages or email
- Release tags, `npm publish`, deploys, cost-incurring operations
- Bypassing hooks (`--no-verify` etc.), modifying `git config`
- Anything the user explicitly reserved decision authority over **in this conversation** (plan text alone does not count)

**Default for unlisted operations**: if it touches only local tracked state and is reversible per the decision rule, treat as Pre-authorized. If it rewrites history, deletes untracked work, or has external reach, treat as Confirmation required. When genuinely ambiguous, confirm once and remember the answer for the rest of the session.
```

---

## Block B: `**Plan authoring — autonomy principles:**` block (insert under existing Action Plans / plan-related section if present, otherwise as a subsection of Autonomy)

```markdown
**Plan authoring — autonomy principles:**
- Default is **end-to-end autonomous execution**. Do not insert any pause / checkpoint / review / sign-off / approval / surface-to-user step — regardless of wording — unless it cites the exact "Confirmation required" bullet it maps to.
- commit/push are reversible — never gate them.
- Each gated step must include a citation comment naming the matching bullet, e.g. `# Gate: Confirmation required → "git push --force on shared branches"`. No citation = remove the gate.
- When auditing existing plans, apply the same citation test: any gate without a valid citation is removed before execution proceeds.
```

---

## Placement guidance

- Block A is the canonical `## Autonomy` section. Place it as a top-level H2.
  - Sensible placement: after general repo overview and before specific workflow/testing sections, OR right before any pre-existing "Action Plans" / "Workflow" section. Avoid burying it at the bottom.
  - If the file has a section about approvals/permissions/operations, replace or supersede with Block A and note removed/deprecated lines in the report.

- Block B goes under whichever section governs plans/action-items/runbooks in that repo.
  - If the repo has an "Action Plans" section, insert Block B there.
  - If no such section exists, insert Block B as a subsection at the end of Block A.
  - If the repo has its own pre-existing "approval gate" wording in plans/runbooks, keep Block B and additionally call out the conflict in the report.

## Anti-patterns to avoid during insertion

- Do **not** paraphrase or "improve" the text — the wording was reviewed twice. Insert verbatim.
- Do **not** translate to Korean. The wider rule is "All committed content should be in English" if such a rule exists in the file; otherwise still keep English for consistency with the canonical text.
- Do **not** delete unrelated existing content. Limit edits to placement of the new blocks plus removal of pre-existing rules that directly conflict (and only with explicit note in the report).
- Do **not** introduce additional approval gates or weaken the rules.
