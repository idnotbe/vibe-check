# Validator Deferred Follow-ups

## Resolved
- ~~Test 3 metadata greps not bound to frontmatter~~ — **resolved** in Phase 2.
  Body markdown smuggle and duplicate keys now both rejected.
- ~~CRLF / trailing-whitespace / BOM tolerance on `---` lines~~ — **resolved** in
  Phase A (this branch). awk strips a UTF-8 BOM via POSIX octal escape
  (`\357\273\277`) and matches delimiters with `^---[[:space:]]*$`; captured
  key:value lines also strip a trailing `\r` so downstream string-equality
  checks remain CRLF-agnostic. See `temp/63-phaseA-draft.md` for the 11-case
  scenario matrix and gawk/mawk portability verification.
- ~~Empty `description:` value bypass~~ — **resolved** in Phase B (this branch).
  Two-step check: (1) exactly one `^description:` line, (2) first non-space
  char after the colon-space matches `[^"'#[:space:]]`. This rejects bare
  `description:`, whitespace-only values, quoted-empty `""`/`''`, and
  comment-only `# comment` while preserving `description: foo # trailing` and
  similar legitimate values. See `temp/64-phaseBC-draft.md`.
- ~~`echo` vs `printf` for multi-line variable expansion~~ — **resolved** in
  Phase C (this branch). All three downstream `echo "$FRONTMATTER" | grep`
  sites migrated to `printf "%s\n" "$FRONTMATTER" | grep`. Pure
  defense-in-depth: the awk filter (`^[a-zA-Z_-]+:`) already forbids leading
  dashes, but the migration removes the latent coupling.

## Still deferred

### (LOW) False-fails on Claude Code skill features this repo doesn't use

**Symptom**: Test 2 awk regex / name string-equality reject:
- YAML lists, frontmatter comments, multi-line block scalars, numeric/special-char keys
- **Quoted YAML scalars** (`name: "vibe-check"` — semantically identical to unquoted, valid YAML, but string equality fails). R2 finding.

Official Claude Code skills schema permits all of these; Claude Code itself loads such files.

**Why intentional**: this repo's SKILL.md is fixed-shape (3 keys: name, description, argument-hint). Restrictive regex acts as a schema enforcer. If a future contributor tries to adopt list-shaped or quoted frontmatter, validator fails fast and forces an explicit decision.

**Defer**: only revisit if the project decides to widen schema. If a YAML auto-formatter (e.g., IDE plugin) starts touching SKILL.md and inserts quotes, revisit immediately.
