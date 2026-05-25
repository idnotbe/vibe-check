#!/usr/bin/env python3
"""One-shot inserter for canonical Autonomy blocks into target CLAUDE.md."""
import sys

TARGET = "/home/idnotbe/projects/deepscan/CLAUDE.md"

BLOCK_A = """## Autonomy

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

"""

BLOCK_B = """
**Plan authoring — autonomy principles:**
- Default is **end-to-end autonomous execution**. Do not insert any pause / checkpoint / review / sign-off / approval / surface-to-user step — regardless of wording — unless it cites the exact "Confirmation required" bullet it maps to.
- commit/push are reversible — never gate them.
- Each gated step must include a citation comment naming the matching bullet, e.g. `# Gate: Confirmation required → "git push --force on shared branches"`. No citation = remove the gate.
- When auditing existing plans, apply the same citation test: any gate without a valid citation is removed before execution proceeds.
"""


def main() -> int:
    with open(TARGET, "r", encoding="utf-8") as f:
        content = f.read()

    marker_a = "## Action Plans"
    n = content.count(marker_a)
    if n != 1:
        print(f"ERROR: marker_a count={n}", file=sys.stderr)
        return 2

    content = content.replace(marker_a, BLOCK_A + marker_a)

    if not content.endswith("\n"):
        content += "\n"
    content = content + BLOCK_B
    if not content.endswith("\n"):
        content += "\n"

    with open(TARGET, "w", encoding="utf-8") as f:
        f.write(content)

    print(f"OK new_length={len(content)}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
