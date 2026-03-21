# Batch Writing Supervisor Prompt (Lean)

Claude Code periodically checks a tmux session and automatically supervises another Claude Code instance's novel writing.

> **Why Claude Code instead of a script?**
> A bash script (file-existence/timeout-based) cannot judge the AI's actual state.
> Claude Code directly reads the tmux screen and understands context, enabling accurate decisions.

**Note: The supervised writer produces all novel output in Korean.**

## Execution Structure

```
/root/novel/                    <- Supervisor Claude Code runs here
├── no-title-XXX/               <- Writer works in this novel folder
│   ├── batch-supervisor.md     <- This file (supervision rules)
│   └── ...
```

- **Supervisor**: Open Claude Code at `/root/novel/` (parent folder) and input this prompt.
  - Reads the parent folder's CLAUDE.md (project guide), giving it full context for config.json management etc.
- **Writer**: Inside a tmux session, navigate to the novel folder (`no-title-XXX/`) and run `claude`.
  - Reads the novel folder's CLAUDE.md (writing constitution), so it follows that novel's specific rules.

---

## Configuration Variables

Modify these values for your novel before inputting the prompt.

| Variable | Description | Example |
|----------|-------------|---------|
| `NOVEL_ID` | Novel folder name | `no-title-015` |
| `SESSION` | tmux session name | `write-015` |
| `NOVEL_DIR` | Novel absolute path | `/root/novel/no-title-015` |
| `START_EP` | Starting episode | `1` |
| `END_EP` | Ending episode | `70` |
| `CHUNK_SIZE` | /clear interval (in episodes). **`-1` = never /clear** (use auto-compact instead) | `10` or `-1` |
| `WRITER_CMD` | Writer launch command | `claude` (default) |
| `ARC_MAP` | Arc-to-episode mapping | See below |

### WRITER_CMD Examples

| Value | Description |
|-------|-------------|
| `claude` | Default Claude Code (auto-loads novel folder's CLAUDE.md) |
| `claude --model claude-sonnet-4-6` | Specify a particular model |

### ARC_MAP Example

```json
{
  "arc-01": [1, 10],
  "arc-02": [11, 20],
  "arc-03": [21, 30]
}
```

---

## Usage

```bash
# Supervisor runs from the parent folder
cd /root/novel
claude
```

Input the following prompt into Claude Code:

---

## Prompt

Supervise batch writing for the {{NOVEL_ID}} novel. Follow these rules.

### 1. Session Management

- tmux session name: `{{SESSION}}`
- **If session doesn't exist**: Create with `tmux new-session -d -s {{SESSION}} -x 220 -y 50`, then launch the writer using the command send protocol in 3d
- **If session exists**: Capture the screen to assess current state and continue
- **Session size**: Must be 220x50 or larger to prevent capture-pane truncation

### 2. Episode-to-Arc Mapping

```
{{Describe ARC_MAP here}}
```

Given episode number N, determine the arc and zero-padded filename from this mapping:
- Arc: the key whose range contains N
- File: `chapters/{arc}/chapter-{NN}.md` (NN = zero-padded 2 digits, or 3 digits if 100+ episodes)

### 2.5 Review Floor Determination (Supervisor Responsibility)

Before sending any writing prompt, the supervisor determines the `review_floor` for that episode:

```
if N is first episode of a new arc   → review_floor = full
elif N is last episode of current arc → review_floor = standard + arc transition package
elif N % 5 == 0                       → review_floor = standard
else                                  → review_floor = continuity
```

**Arc transition package** (마지막 화 완료 후 자동 실행):
1. `/oag-check` on completed arc (행동 갭 탐지 — 별도 에이전트)
2. `/narrative-fix --source oag` — 행동 갭 수정 (CRITICAL→HIGH 순)
3. `/why-check text` on completed arc (수정된 본문에서 설명 누락 탐지)
4. `/narrative-fix --source why-check --scope priority-6+` — 설명 보강
5. Arc summary + character state reset (settings/05-continuity.md)
6. Unresolved thread triage (carry-forward vs discard)

Insert the determined `review_floor` into the writing prompt's [리뷰] section. The writer can escalate above the floor (e.g., continuity → standard if a new character appears), but CANNOT go below it.

**Arc boundary detection**: Check ARC_MAP:
- **First episode** of any arc → `full` (보이스/설정/톤 진입 제어)
- **Last episode** of any arc → `standard` + arc transition package (why-check + 요약 리셋)
- Both checks apply to prologue, all arcs, and epilogue.

**Periodic check alignment**: When `review_floor = standard` (5화 배수), also add periodic check instruction to the prompt.

### 3. Writing Prompts

#### 3a. Chunk Start Prompt (first episode or after /clear every CHUNK_SIZE)

```
{N}화를 집필해줘.
[지침]
- .claude/agents/writer.md의 steps 1-12를 순서대로 수행한다.
- 집필 시작 시 compile_brief(novel_dir="{{NOVEL_DIR}}", episode_number={N}) MCP 도구를 먼저 호출하여 현재 맥락을 확인한다.
- compile_brief 실패 시에만 writer.md step 1의 폴백 순서를 따른다.
- plot/{arc}.md를 확인하여 이번 화의 아크 역할과 다음 2~3화 런웨이를 맞춘다.
- 직전 화 마지막 2~3문단을 확인하여 오프닝 연결과 엔딩 훅 중복을 방지한다.
- planning flags(flashback_present, new_danger, new_setting_claim, calc_used)를 step 4에서 먼저 결정하고, step 7 자가 리뷰는 해당 플래그에 따라 조건부 항목까지 수행한다.
- 파일명: chapters/{arc}/chapter-{NN}.md
[리뷰]
- 외부 AI 리뷰: 매 화 반드시 호출. mcp__novel_editor__review_episode(episode_file="{{NOVEL_DIR}}/chapters/{arc}/chapter-{NN}.md", novel_dir="{{NOVEL_DIR}}", sources="auto"). 실패 시 로그만 남기고 계속.
- 이번 화의 리뷰 최소 모드(review_floor): {supervisor가 §2.5 규칙으로 결정하여 삽입}
- review_floor 이하로 강등하지 마라. 올릴 수만 있다.
1. unified-reviewer를 최종 결정 모드로 실행한다. EDITOR_FEEDBACK 파일이 있으면 전체 항목을 참조하여 처리한다.
2. 수정 발생 시 summary 파일을 재갱신하고 검증한다.
[후처리]
- writer.md steps 8-9에 따라 요약 파일 인라인 갱신 및 summary fact-check를 수행한다.
- step 11에서 EPISODE_META를 삽입하고, 리뷰를 처리한 경우 editor-feedback-log까지 갱신한다.
- config.json은 건드리지 않는다 (감독자가 처리).
- git commit은 현재 소설 폴더 파일만. push 안 함.
[자율 실행]
- 무인 배치이다. 질문하지 말고 모든 단계를 자율 완료한다.
- 정기 점검/리스크 승격 조건을 만나면 해당 모드와 후속 단계를 즉시 수행한다.
```

#### 3b. Continuation Prompt Within Chunk (previous episode context still loaded)

```
이어서 {N}화를 집필해줘.
- .claude/agents/writer.md의 steps 1-12를 동일하게 수행한다.
- compile_brief(novel_dir="{{NOVEL_DIR}}", episode_number={N})로 현재 상태를 먼저 확인한다.
- compile_brief를 우선 사용하되, writer.md step 2-3에 필요한 범위의 plot/{arc}.md와 직전 화 마지막 2~3문단은 직접 확인한다.
- step 4에서 planning flags를 먼저 결정하고, step 7 자가 리뷰는 해당 플래그 기반 조건부 항목까지 수행한다.
- 외부 AI 리뷰: 매 화 반드시 review_episode MCP 호출 (실패 시 로그만 남기고 계속).
- 리뷰 최소 모드(review_floor): {supervisor가 삽입}. 이 모드 이하로 강등 불가. 올릴 수만 있다.
- 파일명: chapters/{arc}/chapter-{NN}.md
```

#### 3c. Plot Generation Prompt (when the arc's plot file doesn't exist)

```
{arc}의 플롯 파일이 없다. plot/{arc}.md를 먼저 작성해줘.
- plot/master-outline.md와 plot/foreshadowing.md를 참조한다.
- 이전 아크의 plot 파일 형식을 따른다.
- 완료 후 {N}화 집필을 이어서 진행한다.
```

#### 3d. Command Send Protocol (Important)

Do not rely on a single `tmux send-keys ... Enter` call for prompts or recovery commands. `Enter` may occasionally fail to register, leaving the command text pasted but not executed.

Always send commands in this order:

```bash
tmux send-keys -t {{SESSION}} -l 'command text'
sleep 0.3
tmux send-keys -t {{SESSION}} Enter
```

Then verify shortly after sending:

```bash
sleep 2
tmux capture-pane -t {{SESSION}} -p -S -20
```

Interpretation:

- **Started correctly**: New output appears, or the trailing `> ` prompt disappeared
- **Enter likely failed**: The command text is visible but the session is still waiting at `> `

If Enter likely failed, resend only Enter once:

```bash
tmux send-keys -t {{SESSION}} Enter
sleep 2
tmux capture-pane -t {{SESSION}} -p -S -20
```

Rules:

- Use `-l` for command text so tmux sends the string literally
- Send `Enter` separately; do not use double-Enter by default
- Retry only one extra `Enter` before treating it as a state/error investigation case
- Apply this protocol to all prompt sends, `/clear`, `/why-check`, permission answers, and recovery commands

### 4. Supervision Loop

#### 4a. Screen Capture

```bash
tmux capture-pane -t {{SESSION}} -p -S -50
```

- `-S -50`: Capture only the last 50 lines (token savings)
- If output is long, check only the final portion needed for state assessment

#### 4b. State Assessment Criteria

| State | Detection Pattern | Action |
|-------|-------------------|--------|
| **Working** | No `> ` prompt visible, text being output. Or last line shows `Working`, `Thinking`, `Simmering` etc. | Re-check after 2 minutes |
| **Auto-compact triggered** | `Auto-compact` or `Compacting conversation` message | Normal operation. Re-check after 2 minutes |
| **Stuck asking question** | Line ending with `?` followed by `> ` prompt. Or `(y/n)`, `[Y/n]` etc. input wait | Send appropriate answer using the command send protocol in 3d |
| **Permission request** | `Allow`, `Deny`, `permission` etc. with input wait | Send `y` using the command send protocol in 3d |
| **Error occurred** | `Error`, `error`, `FATAL`, `Traceback`, `Permission denied`, `No such file` etc. | Analyze error cause, send recovery command |
| **MCP connection failure** | `MCP`, `connection`, `timeout`, `ECONNREFUSED` etc. | Try reconnecting with `/mcp`. If repeated failure, restart session |
| **Infinite loop** | Same operation repeated 3+ times, or no progress on same episode for 10+ minutes | `/clear` then restart with full prompt |
| **Completed** | `> ` prompt appears, preceding output contains completion-related messages (commit done, batch-progress.log recorded, etc.) | Send next episode prompt |
| **Abnormal exit** | No `claude` process, only bash prompt (`$`) visible | Restart with `unset CLAUDECODE && {{WRITER_CMD}}` |

#### 4c. Completion Verification

To accurately determine "completed" state, verify all of the following:

1. **Prompt waiting**: `> ` or `>` prompt on the last line of the screen
2. **Work artifact exists**: Chapter file exists (`ls {{NOVEL_DIR}}/chapters/{arc}/chapter-{NN}.md`)
3. **Progress log check**: `tail -1 {{NOVEL_DIR}}/summaries/batch-progress.log` contains the episode number
   <!-- batch-progress.log is created and maintained by the supervisor. Format: one line per episode, 'EP {N} DONE {timestamp}'. Used for completion tracking and resume. -->

All three conditions must be met for "completed" status. If only the prompt is visible but the file doesn't exist, the episode may have failed silently.

#### 4d. config.json Update (Supervisor Responsibility)

After completion verification, the supervisor directly registers the episode in `/root/novel/config.json`. The writer does NOT touch config.json.

1. Read `title` and `date` from EPISODE_META in the chapter file
2. Add to the novel's appropriate part > `episodes` array:
   ```json
   { "number": N, "title": "제목", "file": "{{NOVEL_ID}}/chapters/{arc}/chapter-{NN}.md" }
   ```
3. Match `totalEpisodes` to the actual registered count
4. If earlier episodes are missing, register them together
5. If the chapter's EPISODE_META contains `intentional_deviations`, note them in the supervision log.

#### 4e. Supervision Intervals

| Situation | Check Interval |
|-----------|----------------|
| Immediately after sending any prompt/command | 2 seconds later to verify execution (3d), then normal interval |
| Immediately after sending first prompt | 30 seconds later to confirm start |
| Work in progress | Every 2 minutes |
| After error recovery | Every 1 minute for 3 checks, then normal interval |
| After chunk boundary (/clear) | 2 seconds later to verify execution, then 1 minute later to confirm start |

### 5. Special Situation Handling

#### 5a. Chunk Boundary (/clear)

**If `CHUNK_SIZE = -1`**: Skip this step entirely. The writer uses auto-compact, which preserves context better than /clear. This is the recommended setting for 1M context models (Claude Opus).

**If `CHUNK_SIZE > 0`**: Reset context every CHUNK_SIZE episodes:

```bash
tmux send-keys -t {{SESSION}} -l '/clear'
sleep 0.3
tmux send-keys -t {{SESSION}} Enter
```

Wait 3 seconds, then send full prompt (3a).

> **When to use CHUNK_SIZE = -1 (recommended)**: Claude Opus or any model with auto-compact. Auto-compact preserves important context while managing window size.
> **When to use CHUNK_SIZE > 0**: Models without auto-compact (NIM proxy models, open-source models), or when context window is small (< 200K).

#### 5b. Arc Transition

When the episode number enters a new arc range:

1. Confirm completion of the last episode of the previous arc
2. **Run `/why-check` on the completed arc**: Send the following prompt to the writer session:
   ```
   방금 완료한 {prev_arc}({start}~{end}화)에 대해 /why-check text를 실행해줘.
   - .claude/agents/why-checker.md의 Text Mode 절차를 따른다.
   - 대상: {start}화 ~ {end}화
   - 산출물: summaries/why-check-report.md
   - 완료 후 대기.
   ```
   Wait for completion. If MISSING items with priority 6+ are found:
   - Items fixable in 1-3 sentences → send `/narrative-fix --source why-check --scope priority-6+` to apply quick patches before proceeding
   - Items requiring structural changes → log as HOLD in `summaries/why-check-report.md` (add `[HOLD]` tag to the item), defer to next `/narrative-review` cycle. HOLD is released when narrative-review Phase 4 re-diagnoses the item as `confirmed` (integrated into fix guide) or `unconfirmed` (dismissed with reasoning).
3. Check if `plot/{arc}.md` exists for the new arc
   - If missing, send plot generation prompt (3c) first
4. **Run `/why-check plan` on the new arc's plot file**: After plot/{arc}.md is created (or confirmed to exist), send:
   ```
   plot/{arc}.md에 대해 /why-check plan을 실행해줘.
   - .claude/agents/why-checker.md의 Planning Mode 절차를 따른다.
   - 이전 아크까지의 본문도 참조하여, 이 플롯이 만들 WHY/HOW 질문에 답이 있는지 확인한다.
   - PLANNING GAP이 발견되면 plot/{arc}.md를 즉시 수정한다.
   - 산출물: summaries/why-check-plan-{arc}.md
   - 완료 후 대기.
   ```
   Wait for completion. This is the highest-value application of why-checker — fixing a gap in the outline costs one sentence, fixing it in finished prose costs a scene rewrite.
5. Arc transitions are periodic check triggers, so add to the first episode prompt after transition:

```
※ 아크 전환 시점이므로 settings/07-periodic.md의 정기 점검(P1~P9)을 먼저 수행한 후 집필을 시작한다.
```

#### 5c. Periodic Check

Trigger: 5화 단위를 기본으로 하되, settings/07-periodic.md에 따라 앞당기거나 늦출 수 있다 (최대 8화). When triggered, add to the next episode prompt:

```
※ 정기 점검 시점이다. settings/07-periodic.md의 P1~P9를 수행한 후 집필을 시작한다.
※ P7(외부 AI 일괄 리뷰)은 CLAUDE.md의 피드백 플래그(gemini_feedback, gpt_feedback 등)가 true인 소스만 대상으로 mcp__novel_editor__batch_review를 호출한다.
※ 정기 점검과 별도로, why-checker의 Rolling Mini-Check(Phase 1.5 OAG)는 batch-supervisor가 아닌 /why-check 명령으로 수동 실행한다. 자동 집필 중에는 아크 전환 시점의 why-check만 수행.
```

#### 5d. Session Crash Recovery

If the session has completely disappeared:

1. Check session existence with `tmux ls`
2. If missing, recreate session (Section 1 session management procedure)
3. Check last completed episode in `batch-progress.log`
4. Resume from next episode with full prompt

#### 5e. Skipping Already-Completed Episodes

Before starting, read `summaries/batch-progress.log` and build a list of completed episodes.
Skip already-completed episodes. For episodes where the chapter file exists but is not in the log, verify before deciding.

### 6. Log Management

The supervisor outputs progress in this format:

```
[HH:MM] Ep {N} prompt sent (chunk start)
[HH:MM] Ep {N} working (2m)
[HH:MM] Ep {N} working (4m)
[HH:MM] Ep {N} completed -> proceeding to next
[HH:MM] Ep {N} error detected: {error summary} -> attempting recovery
[HH:MM] /clear performed (chunk boundary)
[HH:MM] Arc transition: {prev arc} -> {new arc}
[HH:MM] Periodic check instructed (per 07-periodic.md trigger)
[HH:MM] Plot generation instructed: plot/{arc}.md
```

### 7. Termination Conditions

- Supervision ends when all episodes through `END_EP` are completed
- **On final completion** (last episode of the novel), run the full verification pipeline:

  **Phase A: 독립 분석 (병렬 가능)**
  1. `/why-check full` — entire novel, long-range gap detection
  2. `/book-review` + `/book-review-gpt` — independent reader evaluations (parallel)

  **Phase B: 통합 진단**
  3. `/narrative-review` — full narrative quality analysis. Phase 4 automatically references why-check-report, book-review, and book-review-gpt if they exist.

  **Phase C: 서사 수정**
  4. `/narrative-fix` — apply fix guide items from narrative-review (S1~S6)

  **Phase D: 수정 후 재검증**
  5. `/why-check` delta-check — ④에서 수정된 화수 + 인접 1화만 재검증 (전체 재실행 불필요). 해결된 항목은 resolved, 새로 생긴 문제는 new, 여전한 문제는 still-missing으로 분류.
  6. `/narrative-fix --source why-check` — still-missing 항목만 경량 패치 (E1~E4). **④ 이전의 구 보고서를 쓰지 않는다.**

  **Phase E: 사실 검증**
  7. `/audit` — factual continuity, proper nouns, timeline, worldbuilding rules. Includes Korean naturalness check (Phase 2.5 내장).
  8. `/audit-fix` — audit 결과 기반 오류 수정 (필요 시)

  **Conflict priority** (when reports disagree): factual consistency > explicit contradiction > explanation gap > narrative quality > reader preference.
- Halt and report to user if 3 consecutive unrecoverable errors occur
- If the supervisor's own context is running low, summarize current progress and output a handoff prompt for continuation, then terminate

### 8. Range

Episodes {{START_EP}} through {{END_EP}}.

---

## Supervisor Self-Replacement Prompt

When the supervisor's context is running low, output a handoff prompt in this format:

```
Continue batch supervision.
- Novel: {{NOVEL_ID}}
- Session: {{SESSION}}
- Current progress: ep {N} {state}
- Last completed: ep {M}
- Remaining range: {M+1}~{{END_EP}}
- Notes: {describe if any}
- Follow batch-supervisor.md rules.
```
