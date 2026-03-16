# {{NOVEL_TITLE}} - Writing Constitution

> This is the top-level ruleset for the novel "{{NOVEL_TITLE}}".
> All writing, editing, and review operations follow this document.

## Language Contract

- **Instructions** in this file and all settings/ files are in English for token efficiency.
- **All narrative output** (prose, dialogue, summaries, reviews, fixes) MUST be in **Korean**.
- **Korean examples** in this document are normative style targets, not optional references.
- Do NOT translate in-world terms, honorifics (존댓말/반말), or speech-level distinctions.
- When Korean examples conflict with abstract English instructions, **Korean examples win** for surface realization.

---

## 1. Project Overview

- **Title**: {{NOVEL_TITLE}}
- **Subtitle**: {{SUBTITLE}} (delete if none)
- **Genre**: {{GENRE}}
- **Tone & Mood**: {{TONE}}
- **Keywords**: {{KEYWORDS}}
- **Target Audience**: {{TARGET_AUDIENCE}}
- **One-line Summary**: {{ONE_LINE_SUMMARY}}
- **gemini_feedback**: true  <!-- set false to disable Gemini review -->
- **nim_feedback**: false  <!-- set true to enable NIM proofreading -->
- **nim_feedback_model**: "mistralai/mistral-large-3-675b-instruct-2512"
- **ollama_feedback**: false  <!-- set true to enable Ollama proofreading -->
- **ollama_feedback_model**: "gpt-oss:120b"
- **gpt_feedback**: true  <!-- set false to disable GPT review -->
- **illustration**: false  <!-- set true to generate episode illustrations. Cover is always generated -->

### 1.1 Core Promises

1. {{PROMISE_1}}
2. {{PROMISE_2}}
3. {{PROMISE_3}}

---

## 2. Folder Structure

```
{{NOVEL_ID}}/
├── CLAUDE.md              ← This file (Writing Constitution)
├── EDITOR_FEEDBACK_*.md   ← Editor reviews (gemini/gpt/nim/ollama)
├── settings/              ← Worldbuilding, characters, rules
│   ├── 01-style-guide.md
│   ├── 02-episode-structure.md
│   ├── 03-characters.md
│   ├── 04-worldbuilding.md
│   ├── 05-continuity.md
│   ├── 06-humor-guide.md       (optional)
│   ├── 07-periodic.md
│   └── 08-illustration.md
├── chapters/              ← Episode manuscripts
├── plot/                  ← Plot / foreshadowing
├── summaries/             ← Per-episode summaries
└── .claude/agents/        ← Agents (writer, unified-reviewer, etc.)
```

---

## 3. Writing Workflow

### 3.1 Preparation (Prep)

1. **Call `compile_brief` MCP tool**: Generates a compressed brief (~4-15KB) from project files (~300KB+). Do NOT read individual files directly.
   - Fallback if unavailable: `summaries/running-context.md` → relevant arc plot → `plot/foreshadowing.md` → `summaries/character-tracker.md`.
2. **Read last 2-3 paragraphs of previous episode**: Verify hook connection + prevent same ending hook type consecutively.
3. **Check editor feedback**: Reference `EDITOR_FEEDBACK_*.md` if unprocessed feedback exists.

### 3.2 Writing (Write)

1. Follow `settings/02-episode-structure.md`.
2. Follow `settings/01-style-guide.md`.
3. Target length: {{TARGET_LENGTH}}
4. **`novel-calc` MCP is for narrative verification only. Calculations must NOT drive the narrative.**
   - Write prose naturally first. Then verify numerical consistency with calc only if needed.
   - Calc results allowed in: (1) unified-reviewer evidence, (2) summaries/ updates, (3) in-world UI/popup numbers. NEVER insert calc results into narration, dialogue, or inner monologue.
   - **Use calc when**: dates are plot-critical, travel distance/time may cause contradiction, economy/supply is core conflict, checking word count.
   - **Skip calc when**: vague time expressions, atmospheric approximations, mundane travel/trade, combat distances/speeds.
   - Tools: dates(`date_calc`/`weekday`/`d_plus`/`date_diff`) | arithmetic(`calculate`) | travel(`speed_distance_time`/`travel_estimate`) | units(`unit_convert`/`convert_time`) | economy(`currency_calc`/`supply_calc`/`growth_calc`) | length(`char_count`)
5. **Always use `novel-hanja` MCP for Hanja naming.** Never assemble Hanja via LLM inference.
   - `hanja_lookup`, `hanja_search`, `hanja_meaning`, `hanja_verify`
6. **Hanja notation**: Show reading + Hanja only on first appearance (`내공(內功)`). Korean-only thereafter. Ref: `summaries/hanja-glossary.md`. Exception: re-appearance after 30+ episodes, homophone disambiguation.
7. **Use era-appropriate units and terminology.**
   - Pre-modern settings: metric → traditional units, loanwords → Sino-Korean/native Korean. Use `unit_convert`.
   - Modern/SF: modern units OK. Refer to `settings/04-worldbuilding.md`.
   - **Pre-modern numeral rules (Korean output)**:
     - 아라비아 숫자 금지 in prose. Use 한글 수사.
     - No decimal notation: `1.5장` → `한 장 반`
     - `100명` → `백여 명`, `3일` → `사흘`, `7일` → `이레`, `10일` → `열흘`, `15일` → `보름`
     - Exception: EPISODE_META, plot/, summaries/ (meta areas)
8. **Footnotes**: Use `[^N]` format. `\[N\]` or `[N]` formats forbidden.

### 3.3 Unified Review

Per `.claude/agents/unified-reviewer.md`. Continuity + narrative quality + Korean proofreading + external feedback in a single pass.

**Modes** (periodic + change-based triggers):
- `continuity` (every episode): 13 continuity items + critical Korean errors(❌) + 반복표현/번역투/호응오류
- `standard` (every 5 eps **OR** new key character, relationship reversal, secret reveal, combat-heavy ep, etc.): continuity + 7 narrative items + full Korean proofing + external feedback
- `full` (arc boundary / setting change / long-term foreshadowing payoff): all items + detailed analysis + direct settings/ reference

**External feedback sources** (per CLAUDE.md flags):
1. **Gemini** (`gemini_feedback: true`): continuity/worldbuilding → `EDITOR_FEEDBACK_gemini.md`
2. **GPT** (`gpt_feedback: true`): prose/dialogue/emotion → `EDITOR_FEEDBACK_gpt.md`
3. **NIM** (`nim_feedback: true`): spelling/grammar → `EDITOR_FEEDBACK_nim.md`
4. **Ollama** (`ollama_feedback: true`): spelling/grammar → `EDITOR_FEEDBACK_ollama.md`

> All sources false → skip external review. Individual source failure → skip that source only, log it.

### 3.4 Post-Processing

1. **Inline summary update**: Writer updates directly in context after writing (no separate agent needed).
   - Required (every ep): `running-context.md`, `episode-log.md`, `character-tracker.md`
   - Conditional (only if relevant change): `promise-tracker.md`, `knowledge-map.md`, `relationship-log.md`, `foreshadowing.md`
2. **Insert EPISODE_META**: Append metadata block at episode end. Set `date` to today `"YYYY-MM-DD"`.
3. **Update feedback log**: Record 3.3 results in `editor-feedback-log.md`.
4. **Git commit**: After episode completion (manuscript + summaries). Batch 2-3 eps OK. Message: `{소설명} {N}~{M}화 집필`. Push only on user request.

### 3.5 Parallel Writing & Periodic Checks

→ See `settings/07-periodic.md`.

---

## 4. File Reference Priority

1. **This file (CLAUDE.md)** — highest priority
2. **settings/ folder** — detailed rules
3. **Previous episode text** — established facts
4. **summaries/** — reference only, episode text takes precedence

---

## 5. Prohibitions

> The following rules are NEVER violated under any circumstances.

1. **No sudden character personality changes**: Only gradual change allowed. Abrupt shifts require a convincing preceding event.
2. **No deus ex machina**: Crisis resolution only via previously established abilities/resources/characters.
3. **No setting contradictions**: Established worldbuilding rules cannot be changed. Modify settings files first if needed.
4. **No length violations**: Stay within ±20% of target length.
5. **No meta expressions**: 금지 표현 예시: "소설에서처럼", "독자 여러분" — no 4th wall breaking.
6. **No renaming proper nouns**: Names defined in settings files cannot be arbitrarily changed.
7. **No episode structure meta-references in prose**: 금지: "3화에서", "프롤로그에서", "1부에서" in narration/dialogue. Reference past events by date/place/event name. Meta areas (EPISODE_META, plot/, summaries/) are exempt.
8. **No POV switch spoilers**: 금지: `[시점 전환: 세르반]` meta tags in prose. Use `***` scene break then shift naturally via tone/setting/senses.
9. **No unearned emotional escalation**: 감정적 클라이맥스(죽음, 고백, 배신, 재회)는 해당 관계나 갈등이 최소 2화 이상 사전 전개된 후에만 허용한다.
10. **No costless victories**: 주요 성과를 "무상 보상"처럼 처리하지 말 것. 희생·트레이드오프·후속 부담은 같은 화에 드러날 수도 있고, 복선으로 유예되었다가 이후 큰 대가로 회수될 수도 있다. 어떤 경우에도 성과가 장기적으로 긴장과 균형을 깨는 순이익으로만 남아서는 안 된다.
11. **No finale overload**: 마지막 아크에서 설명, 감정 결산, 클라이맥스 액션을 한 화에 과밀하게 압축하지 않는다. 독자가 전개를 따라가고 감정과 사건을 각각 소화할 여백을 확보한다. 적정 분량은 전체 길이·장르·리듬에 맞게 조정. 스릴러 등 압축이 미덕인 장르에서는 의도된 고밀도 전개를 허용한다.

### 5.1 Intentional Mysteries (의도적 비밀)

> `/why-check` 실행 시 아래 항목은 "설명 누락"이 아니라 **의도적 미스터리**로 간주한다.
> 독자에게 숨기는 것이 서사적 목적이 있는 경우에만 기록한다.

| 비밀 | 공개 예정 시점 | 왜 숨기는가 |
|------|-------------|-----------|
| {{MYSTERY_1}} | {{아크/화수}} | {{서사적 이유}} |

> 이 목록에 없는 설명 누락은 실수로 간주한다.

---

## 6. Episode Metadata (EPISODE_META)

Append this format at the end of each episode file. (Auto-removed by reader)

```markdown
---

### EPISODE_META
```yaml
episode: {{NUMBER}}
title: "{{TITLE}}"
summary: "{{SUMMARY}}"
date: "{{DATE}}"
pov: "{{POV_CHARACTER}}"
location: "{{LOCATION}}"
timeline: "{{TIMELINE_POSITION}}"
characters_appeared:
  - {{CHARACTER_1}}
  - {{CHARACTER_2}}
new_elements:
  - "{{NEW_ELEMENT}}"
unresolved:
  - "{{UNRESOLVED_THREAD}}"
next_episode_hook: "{{HOOK}}"
```
```

---

## 7. Cover Image & Illustrations

→ See `settings/08-illustration.md`.

- **Cover**: Auto-generate via `generate_image` if `cover.png` doesn't exist at first episode. Save prompt to `cover-prompt.txt`.
- **Episode illustrations**: Only when `illustration: true`. Use `generate_illustration` tool, insert as blockquote.
- **`character-prompts.md`**: Manage per-character image prompts. Maintained for cover use even when `illustration: false`.

---

## 8. 대화 관계 규칙 (Dialogue Relationship Rules)

> This section stays in Korean as it defines Korean-specific honorific/speech-level rules.

### 8.1 호칭/어투 매트릭스

"행 캐릭터가 열 캐릭터에게 말할 때"의 존댓말/반말/호칭 규칙. 자주 대화하는 쌍만 기록.

| 화자 → 청자 | {{CHAR_A}} | {{CHAR_B}} | {{CHAR_C}} |
|-------------|-----------|-----------|-----------|
| **{{CHAR_A}}** | — | {{존/반+호칭}} | {{존/반+호칭}} |
| **{{CHAR_B}}** | {{존/반+호칭}} | — | {{존/반+호칭}} |
| **{{CHAR_C}}** | {{존/반+호칭}} | {{존/반+호칭}} | — |

> 미등록 조합 기본값: {{DEFAULT_RULE}}

### 8.2 상황별 어투 전환

| 캐릭터 | 상황 A | 상황 B |
|--------|--------|--------|
| {{CHAR}} | {{공적 석상: ~합니다}} | {{사적 대화: 반말}} |

### 8.3 어투 변화 이력

| 화수 | 화자 → 청자 | 변화 내용 | 사유 |
|------|------------|----------|------|
| {{N}}화 | {{A}} → {{B}} | 존댓말 → 반말 | {{사건 설명}} |

### 8.4 어투 원칙

1. **어투 변화는 사건에 의해서만 발생**: 설명 없는 갑작스러운 전환 금지.
2. **감정 극단 시 일시적 이탈 허용**: 장면 종료 후 원래로 복귀.
3. **공적/사적 구분**: 같은 쌍이라도 상황에 따라 다를 수 있다.
4. **어투 역행 금지**: 반말→존댓말 전환은 특수 사건(배신, 관계 단절 등) 필요.
5. **대화는 정보 전달만을 위해 존재하지 않는다**: 모든 대화 교환은 정보 전달 외에 최소 하나의 기능(캐릭터 성격 노출, 관계 변화, 서브텍스트, 유머)을 수행해야 한다.

---

## 9. Customization Guide

After copying this template, fill in `{{PLACEHOLDER}}` values and:

1. `settings/01-style-guide.md` — prose style rules
2. `settings/02-episode-structure.md` — episode structure
3. `settings/03-characters.md` — character sheets
4. `settings/04-worldbuilding.md` — worldbuilding
5. `cover-prompt.txt` — cover image prompt
6. Optional: `settings/06-humor-guide.md` etc.
7. Section 8 — fill in the honorific/speech-level matrix

---
