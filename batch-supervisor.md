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
- **If session doesn't exist**: Create with `tmux new-session -d -s {{SESSION}} -x 220 -y 50`, then run `tmux send-keys -t {{SESSION}} 'cd {{NOVEL_DIR}} && unset CLAUDECODE && {{WRITER_CMD}}' Enter`
- **If session exists**: Capture the screen to assess current state and continue
- **Session size**: Must be 220x50 or larger to prevent capture-pane truncation

### 2. Episode-to-Arc Mapping

```
{{Describe ARC_MAP here}}
```

Given episode number N, determine the arc and zero-padded filename from this mapping:
- Arc: the key whose range contains N
- File: `chapters/{arc}/chapter-{NN}.md` (NN = zero-padded 2 digits, or 3 digits if 100+ episodes)

### 3. Writing Prompts

#### 3a. Chunk Start Prompt (first episode or after /clear every CHUNK_SIZE)

```
{N}화를 집필해줘.
[지침]
- .claude/agents/writer.md의 자율 집필 마스터 체크리스트(A~F)를 빠짐없이 수행한다.
- 플롯: plot/{arc}.md 참조
- 집필 전 compile_brief(novel_dir="{{NOVEL_DIR}}", episode_number={N}) MCP 도구를 호출하여 현재 맥락을 확인한다. 개별 summaries/settings 파일을 직접 읽지 않는다. compile_brief 실패 시만 폴백(running-context -> 아크 플롯 -> character-tracker).
- 파일명: chapters/{arc}/chapter-{NN}.md
[리뷰]
1. mcp__novel_editor__review_episode(episode_file="{{NOVEL_DIR}}/chapters/{arc}/chapter-{NN}.md", novel_dir="{{NOVEL_DIR}}", sources="auto") 호출하여 외부 AI 편집 리뷰를 먼저 수행한다 (EDITOR_FEEDBACK_*.md 생성).
2. unified-reviewer 에이전트를 실행한다 (모드: 주기+변화량 기반 자동 결정). EDITOR_FEEDBACK 파일을 참조하여 통합 리뷰.
3. 리뷰 결과 반영 후 수정사항이 있으면 요약 파일도 재갱신한다.
[후처리]
- 요약 파일 인라인 갱신 (writer.md D단계)
- config.json은 건드리지 않는다 (감독자가 처리).
- git commit은 현재 소설 폴더 파일만. push 안 함.
[자율 실행]
- 무인 배치이다. 질문하지 말고 모든 단계를 자율 완료한다.
- 정기 점검 조건 충족 시 바로 수행한다.
```

#### 3b. Continuation Prompt Within Chunk (previous episode context still loaded)

```
이어서 {N}화를 집필해줘. writer.md 체크리스트(A~F) 동일 수행.
- 파일명: chapters/{arc}/chapter-{NN}.md
- 편집 리뷰: mcp__novel_editor__review_episode(episode_file="{{NOVEL_DIR}}/chapters/{arc}/chapter-{NN}.md", novel_dir="{{NOVEL_DIR}}", sources="auto")
- compile_brief를 호출하여 현재 상태를 확인한다. 개별 파일 직접 읽기 금지.
```

#### 3c. Plot Generation Prompt (when the arc's plot file doesn't exist)

```
{arc}의 플롯 파일이 없다. plot/{arc}.md를 먼저 작성해줘.
- plot/master-outline.md와 plot/foreshadowing.md를 참조한다.
- 이전 아크의 plot 파일 형식을 따른다.
- 완료 후 {N}화 집필을 이어서 진행한다.
```

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
| **Stuck asking question** | Line ending with `?` followed by `> ` prompt. Or `(y/n)`, `[Y/n]` etc. input wait | Send appropriate answer: `tmux send-keys -t {{SESSION}} 'answer' Enter` |
| **Permission request** | `Allow`, `Deny`, `permission` etc. with input wait | `tmux send-keys -t {{SESSION}} 'y' Enter` |
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

#### 4e. Supervision Intervals

| Situation | Check Interval |
|-----------|----------------|
| Immediately after sending first prompt | 30 seconds later to confirm start |
| Work in progress | Every 2 minutes |
| After error recovery | Every 1 minute for 3 checks, then normal interval |
| After chunk boundary (/clear) | 1 minute later to confirm start |

### 5. Special Situation Handling

#### 5a. Chunk Boundary (/clear)

**If `CHUNK_SIZE = -1`**: Skip this step entirely. The writer uses auto-compact, which preserves context better than /clear. This is the recommended setting for 1M context models (Claude Opus).

**If `CHUNK_SIZE > 0`**: Reset context every CHUNK_SIZE episodes:

```bash
tmux send-keys -t {{SESSION}} '/clear' Enter
```

Wait 3 seconds, then send full prompt (3a).

> **When to use CHUNK_SIZE = -1 (recommended)**: Claude Opus or any model with auto-compact. Auto-compact preserves important context while managing window size.
> **When to use CHUNK_SIZE > 0**: Models without auto-compact (NIM proxy models, open-source models), or when context window is small (< 200K).

#### 5b. Arc Transition

When the episode number enters a new arc range:

1. Confirm completion of the last episode of the previous arc
2. **Run `/why-check` on the completed arc**: Send the following prompt to the writer session:
   ```
   방금 완료한 {prev_arc}({start}~{end}화)에 대해 /why-check을 실행해줘.
   - .claude/agents/why-checker.md의 절차를 따른다.
   - 대상: {start}화 ~ {end}화
   - 산출물: summaries/why-check-report.md
   - 완료 후 대기.
   ```
   Wait for completion. If MISSING items with priority 6+ are found, log them but do NOT block arc transition — they will be addressed in the next narrative-review cycle.
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

#### 5c. Periodic Check (Every 5 Episodes)

When a multiple-of-5 episode completes, add to the next episode prompt:

```
※ 5화 단위 정기 점검 시점이다. settings/07-periodic.md의 P1~P9를 수행한 후 집필을 시작한다.
※ P7(외부 AI 일괄 리뷰)은 CLAUDE.md의 피드백 플래그(gemini_feedback, gpt_feedback 등)가 true인 소스만 대상으로 mcp__novel_editor__batch_review를 호출한다.
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
[HH:MM] Periodic check instructed (every 5 eps)
[HH:MM] Plot generation instructed: plot/{arc}.md
```

### 7. Termination Conditions

- Supervision ends when all episodes through `END_EP` are completed
- **On final completion** (last episode of the novel): Run `/why-check full` on the entire novel. This catches long-range accumulated gaps that arc-level checks miss. Log results for the narrative-review cycle.
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
