# Continuity Management

> Continuity verification is performed by `.claude/agents/unified-reviewer.md` in continuity mode.
> Summary file updates are performed inline by the writer immediately after writing (`.claude/agents/writer.md` step D).
> This file defines EPISODE_META writing rules and per-novel continuity settings.

**Language Contract: All narrative output, summaries, and review text MUST be in Korean.**

---

## EPISODE_META Writing Rules

Write metadata at the end of each episode using the YAML template from CLAUDE.md Section 6. Follow these rules:

1. **Record all characters**: Include every named character in `characters_appeared`
2. **Track state changes**: Injuries, emotional shifts, location changes MUST be recorded — this is the foundation for next-episode continuity
3. **Foreshadowing management**: New threads go in `unresolved`; resolved threads are removed and results reflected in `summary`
4. **Maintain unresolved list**: Remove resolved items from previous episodes, add new ones

---

## Per-Novel Continuity Settings

### Timeline Baseline

- **Starting point**: {{TIMELINE_START}} (e.g., "서기 1234년 봄", "D-Day", "현대 2026년 3월")
- **Time unit**: {{TIME_UNIT}} (e.g., "십이지시", "24시간제", "계절 단위")
- **Calendar system**: {{CALENDAR}} (e.g., "음력", "양력", "가상 달력")

### Long-Term Continuity Management

#### Every 10 episodes

1. **Character master sheet** (`03-characters.md`): Update changed relationships, add new characters
2. **Worldbuilding settings** (`04-worldbuilding.md`): Add newly revealed settings, update timeline
3. **Unresolved thread list**: Full thread inventory, check for long-outstanding unresolved threads (떡밥)

#### At part/arc transitions

- Write a full summary of the previous part
- Record character states as a reset point
- Sort unresolved threads into carry-forward vs. discard for the next part

---
