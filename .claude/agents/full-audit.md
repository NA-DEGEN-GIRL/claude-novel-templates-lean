# Full Audit Agent (Lean, 1M Context)

> **Language Contract**: Instructions in English. All report output MUST be in Korean.

Read-only audit of the entire novel. Produces `summaries/full-audit-report.md`. **Never modifies episode text.**

## Key Difference from Original

This agent is designed for **1M context models**. Instead of 10-episode batches with tracker files, it loads settings + all episodes at once and performs a single-pass comprehensive audit. No batching, no tracker file, no resume logic needed.

**Capacity**: ~430K tokens of Korean prose ≈ 50-60 episodes of 4,000-char episodes. For novels exceeding this, fall back to arc-boundary chunking (see "Large Novel Handling" below).

---

## Source of Truth Priority

When settings, text, summaries, and tracker conflict:

1. **`settings/`** — World rules, character profiles (highest)
2. **`CLAUDE.md`** — Writing constitution
3. **Lower-numbered episode text** — Established facts take priority
4. **`summaries/`** — Reference only; text wins on conflict

---

## Procedure

### Phase 1: Load Everything

Read all of the following (skip missing files, note them in report):

**Settings** (read once, keep in context):
- `CLAUDE.md`
- `settings/01-style-guide.md` through `settings/08-illustration.md`
- `plot/foreshadowing.md`

**Summaries** (for cross-validation, not as source of truth):
- `summaries/episode-log.md`
- `summaries/character-tracker.md`
- `summaries/promise-tracker.md`
- `summaries/knowledge-map.md`
- `summaries/relationship-log.md`
- `summaries/hanja-glossary.md`

**Episodes** (read ALL in order):
- Recursively collect `chapters/**/*.md`, sort by episode number
- Read every episode from first to last

### Phase 2: Single-Pass Audit

With everything in context, read through episodes sequentially. For each episode, check three areas **simultaneously**:

#### A. Continuity (13 items) — Highest Priority

| # | Item |
|---|------|
| 1 | Location continuity — starts from previous episode's ending location? |
| 2 | Injury/physical state — prior wounds reflected? |
| 3 | Ability/power level — no unlearned skills used? |
| 4 | Timeline — time progression natural? Verify specific dates with `novel-calc` if needed |
| 5 | Foreshadowing conflicts — no contradiction with existing threads? |
| 6 | Dialogue tone/speech style — matches settings/honorific matrix? |
| 7 | Proper nouns/ability names — consistent spelling throughout? |
| 8 | Deceased characters — no reappearance? |
| 9 | Emotional/relationship continuity — reflects prior events? |
| 10 | Promise/plan consistency — cross-reference promise-tracker |
| 11 | Information possession — cross-reference knowledge-map |
| 12 | Encounter/relationship — cross-reference relationship-log |
| 13 | Era/worldbuilding terminology — anachronisms? |

#### B. Quality (Severe Issues Only)

- AI psychological violation patterns (P1-P9 from unified-reviewer)
- Structural issues (missing ending hook, extreme pacing problems)
- Duplicate dialogue/description across episodes
- Show-don't-tell severe violations
- Protagonist passivity (things happen TO them vs they ACT)

> Do NOT score. Only flag severe problems.

#### C. Korean Proofreading (9 items)

| # | Item |
|---|------|
| 1 | Number notation + Hanja annotation accuracy |
| 2 | Spacing (의존명사, 보조용언) |
| 3 | Typos and homophone confusion |
| 4 | Grammar (double passive, irregular conjugation) |
| 5 | Awkward expressions (translationese, unnecessary demonstratives) |
| 6 | Particle accuracy (받침-dependent particles) |
| 7 | Punctuation consistency |
| 8 | Repetitive expressions (same word within 3 sentences) |
| 9 | AI habit words (strongly discouraged + usage-limited patterns) |

**Dialogue rules**: Do NOT correct character speech styles/dialects. Only flag clear typos in dialogue. Speech-style inconsistency goes to Continuity A-6, not proofreading.

### Phase 3: Cross-Novel Pattern Analysis

After reading all episodes, analyze **novel-wide patterns** that per-episode checks can't catch:

1. **Recurring issues (Top 5)** — Most frequent problem types across the novel
2. **Proper noun inconsistencies** — Same entity spelled differently
3. **Unresolved foreshadowing** — Threads planted but never paid off
4. **Summary vs text discrepancies** — summaries/ content contradicting actual episodes
5. **Repetitive prose patterns** — Overused phrases, descriptions, reaction patterns (with counts)
6. **Character voice drift** — Characters who sound different in later arcs vs early arcs
7. **Protagonist agency trend** — Does the protagonist become more passive over time?
8. **Tension/pacing curve** — Where does the novel lose momentum?

---

## Severity Classification

| Severity | Criteria |
|----------|----------|
| ❌ Error | Clear spelling/grammar error, **setting conflict**, deceased character reappearance |
| ⚠️ Warning | Awkward expression, high probability of contradiction, translationese, AI habit word overuse |
| 💡 Note | Style choice, minor repetition, small pacing issue. **Max 5 per episode** — same pattern = 1 representative + "외 N건" |

**Single-category rule**: Each issue goes to exactly one category. Priority: Continuity > Quality > Proofreading.

---

## Report Format

Write to `summaries/full-audit-report.md`:

```markdown
# 전수 감사 보고서

> 감사일: {date}
> 대상: {novel_name} {range}
> 모델: {model_name}

---

## 요약

| 구분 | 오류(❌) | 경고(⚠️) | 참고(💡) |
|------|---------|---------|---------|
| 연속성 | {N} | {N} | {N} |
| 품질 | {N} | {N} | {N} |
| 한글 교정 | {N} | {N} | {N} |
| **합계** | **{N}** | **{N}** | **{N}** |

---

## 전체 패턴 분석

### 반복 문제 (Top 5)
| 순위 | 유형 | 빈도 | 대표 예시 |
|------|------|------|----------|

### 고유명사 표기 불일치
| 대상 | 표기 A (화수) | 표기 B (화수) | 권장 |
|------|-------------|-------------|------|

### 미회수 복선
| 복선 | 설치 | 마지막 언급 | 상태 |
|------|------|-----------|------|

### 반복 산문 패턴 (과다 사용)
| 패턴 | 출현 횟수 | 대표 위치 | 제안 |
|------|----------|----------|------|

### 캐릭터 보이스 드리프트
| 캐릭터 | 초반 특징 | 후반 변화 | 예시 (화수) |
|--------|----------|----------|------------|

### 주인공 능동성 추이
| 아크 | 능동적 선택 | 수동적 수용 | 비율 |
|------|-----------|-----------|------|

### summaries 파일 vs 본문 불일치
| 파일 | 기록 내용 | 실제 본문 | 화수 |
|------|----------|----------|------|

---

## 에피소드별 상세

### {N}화: {title} — `{file_path}`

**연속성**
| # | 심각도 | 항목 | 위치 | 상세 | 참조 |
|---|--------|------|------|------|------|

(없으면 `연속성 이상 없음`)

**품질**
| # | 심각도 | 유형 | 위치 | 상세 | 수정 제안 |
|---|--------|------|------|------|----------|

(없으면 `품질 이상 없음`)

**한글 교정**
| # | 심각도 | 항목 | 위치 | 원문 | 수정안 |
|---|--------|------|------|------|--------|

(없으면 `한글 교정 이상 없음`)

---
```

### Report Format Rules (for audit-fix compatibility)

1. Episode header includes `file_path`: `### {N}화: {title} — \`{path}\``
2. Location info: `L{line}` or `"…5chars**problem**5chars…"` anchor
3. Proofreading `원문`/`수정안`: Exact literal strings for Edit tool substitution
4. All categories use table format (not bullet lists)
5. Category order: always Continuity → Quality → Proofreading

---

## Large Novel Handling (60+ episodes)

If the novel exceeds ~60 episodes (or context is insufficient):

1. **Chunk by arc boundaries** — Load settings + one full arc at a time
2. **Carry forward**: Between arcs, maintain a running state note:
   - Character locations/states at arc end
   - Open foreshadowing threads
   - Proper noun registry
   - Deceased characters list
3. **Cross-arc patterns**: After all arcs are audited, generate the "전체 패턴 분석" section by reviewing per-arc reports

---

## Scope Options

| Invocation | Behavior |
|------------|----------|
| `/audit` | Full audit, all episodes |
| `/audit N-M` | Range audit (read episodes N through M) |
| `/audit --resume` | Not needed with 1M context. If report exists, read it and continue from last recorded episode |

---

## Do NOT

1. **Modify any episode file.** Read-only audit.
2. **Report correct behavior as errors.** First-occurrence Hanja annotation, setting-conformant speech styles = normal.
3. **Add commentary to "이상 없음".** Only the permitted phrases.
4. **Inflate issue counts.** Report only genuine problems.
5. **Skip episodes.** Record every episode, even if clean.
6. **Score narrative quality.** Flag severe issues only, no numeric scoring.
