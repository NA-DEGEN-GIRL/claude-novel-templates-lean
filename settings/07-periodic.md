# Parallel Writing & Periodic Checks

> Defines consistency checks after parallel writing and periodic checks every 5 episodes.

**Language Contract: All narrative output, summaries, and review text MUST be in Korean.**

---

## 1. Post-Parallel-Writing Consistency Check

When episodes are written in parallel, the following procedure MUST be performed **after writing is complete**.

### Parallel Writing Criteria

Any of the following qualifies as "parallel writing":
- Multiple agents writing different episodes simultaneously
- Consecutive episodes exist where summary files were not updated
- User explicitly states parallel writing is in progress

### Per-Agent Rules

- Steps 3.1-3.3 proceed as normal (context loading, writing, self-review)
- Step 3.4 continuity verification: perform only within own assigned range
- Step 3.5 post-processing: **defer summary updates** (to prevent conflicts)
- EPISODE_META insertion: perform as normal

### Post-Completion Reconciliation

1. **Cross-continuity verification**: Run `unified-reviewer` in `continuity` mode to check inter-episode connections
2. **Conflict resolution**: Adjust higher-numbered episodes to match lower-numbered ones
3. **Batch summary update**: Update all summary files in episode-number order

---

## 2. Periodic Checks (Every 5 Episodes)

> Prevents **cumulative drift** that per-episode pipelines cannot catch.

### Trigger

- 5 or more episodes written since the last periodic check
- Arc transition points (perform even if fewer than 5 episodes)

### Check Items

| # | Item | Method |
|---|------|--------|
| P1 | Summary consistency | `summary-validator` **batch audit (mode B)** — targets episodes written since last check |
| P2 | Foreshadowing deadlines | Check `plot/foreshadowing.md` for threads past their expected resolution point |
| P3 | Character state freshness | Verify `summaries/character-tracker.md` current state matches **latest episode end state** |
| P4 | Unfulfilled promises | Check `summaries/promise-tracker.md` for overdue or neglected promises |
| P5 | running-context | Verify `summaries/running-context.md` is under 200 lines and accurately reflects current state |
| P6 | Personality drift | Check main character dialogue/actions for consistency with `settings/03-characters.md` |
| P7 | External AI batch review | Call `mcp__novel_editor__batch_review` for episodes since last check. Only target active sources per CLAUDE.md feedback flags (gemini/gpt/nim/ollama). Prioritize episodes with `❌ 실패` records in `editor-feedback-log.md` |
| P8 | Korean quality check | Only for episodes where P7 produced text modifications — re-check via `unified-reviewer` continuity mode (includes Korean proofreading) |
| P9 | Meta-reference prohibition | Full scan for in-prose references like "X화에서", "프롤로그에서", "1부에서" (episode number/structure name references) |

### Post-Check Actions

1. Fix all discovered issues.
2. Update `running-context.md` to current state.
3. Include check results in commit: `{소설명} {N}~{M}화 정기 점검 완료`

---
