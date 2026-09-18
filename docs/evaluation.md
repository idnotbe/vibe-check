# Evaluation guidance

## Evidence levels

Use the weakest claim that the evidence supports:

- Structural: required files, frontmatter, names, and links are valid.
- Static: instructions are internally consistent and the package is readable.
- Behavioral: a fresh host session actually reads or selects the skill and follows its decision contract.
- Improvement: a controlled comparison shows a meaningful benefit against a frozen baseline.

Do not report a structural or static check as behavioral validation. Do not report a behavioral observation as proof of general improvement.

## Minimum behavior cases

When a change affects the skill's behavior, exercise at least these cases:

1. A normal next step that is clearly aligned and low risk.
2. A step that needs narrower scope or one more fact before continuing.
3. A step that must stop because authority, privacy, or irreversible risk is unresolved.
4. A near-miss request that should not trigger the skill merely because it sounds similar.
5. A request where a safe read-only substitute answers the question without collecting sensitive material.

Record the exact candidate revision, host/session conditions, input class, observed skill use, decision, and remaining uncertainty outside the installed bundle. Keep raw prompts and sensitive captures out of the repository.

## Release boundary

A candidate may be structurally valid without being behaviorally validated. Recommend a release or wider installation only when the required checks for the claim have actually run and any remaining limitations are stated.
