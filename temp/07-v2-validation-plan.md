# V2 Validation Plan (Resuming Interrupted Work)

## Context
- Phases 1-6 complete: gap analysis, user scenarios, doc changes, V1 review, V1 fixes
- V2 validation was interrupted - resuming now
- Need TWO independent validation rounds, each with multiple perspective teammates

## Validation Round 1 (V2)
Three teammates with different perspectives:
1. **v2-accuracy-checker** - Technical accuracy: verify every factual claim in docs against implementation
2. **v2-scenario-tester** - UX/scenario walkthrough: walk through all 8 user scenarios against updated docs
3. **v2-consistency-auditor** - Cross-document consistency: check all 4 docs agree with each other

Each teammate:
- Uses vibe-check skill for metacognitive check on their own approach
- Uses pal clink to get external model perspectives
- Uses subagents for parallel work
- Writes findings to temp/ files
- Communicates via file links

## Validation Round 2 (V3) - After V2 fixes applied
Three different-perspective teammates:
1. **v3-newcomer-sim** - Simulates a newcomer reading docs for first time
2. **v3-adversarial** - Adversarial reviewer: tries to find contradictions, misleading claims, gaps
3. **v3-korean-bridge** - Bilingual reviewer: checks Korean↔English accuracy in translations

Each teammate same requirements as V2.

## Files
- temp/08-v2-accuracy.md - accuracy checker findings
- temp/09-v2-scenarios.md - scenario tester findings
- temp/10-v2-consistency.md - consistency auditor findings
- temp/11-v2-fixes.md - fixes applied from V2
- temp/12-v3-newcomer.md - newcomer sim findings
- temp/13-v3-adversarial.md - adversarial findings
- temp/14-v3-korean.md - bilingual review findings
- temp/15-v3-fixes.md - final fixes from V3
