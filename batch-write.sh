#!/bin/bash
# Novel Batch Writing Script (Lean Template)
#
# Place this file inside the novel folder and run it.
# Repeatedly calls Claude Code's `claude -p` to auto-write the novel.
# Each batch performs the full CLAUDE.md workflow (write -> unified-reviewer -> commit).
#
# NOTE: All novel output is written in Korean.
#
# === Lean Changes ===
# - 2 agents (writer, unified-reviewer) + review_episode MCP for external feedback
# - compile_brief MCP for prep (instead of reading individual files)
# - Inline summary updates (instead of summary-generator agent)
# - ~80% token savings
#
# === Installation Location ===
#   no-title-XXX/batch-write.sh   <- Place inside novel folder
#
# === Usage ===
#   cd no-title-XXX && bash batch-write.sh                  # full range
#   cd no-title-XXX && bash batch-write.sh 50 100           # eps 50~100 only
#   cd no-title-XXX && nohup bash batch-write.sh &          # background
#   cd no-title-XXX && nohup bash batch-write.sh 50 100 &   # background + range

set -euo pipefail

# Prevent nested session issues (needed when running inside a Claude Code session)
unset CLAUDECODE 2>/dev/null || true

# === Per-Novel Settings (modify as needed) ===
BATCH_SIZE=5                               # Episodes per batch (recommended: 3~5)
DEFAULT_START=1                            # Starting episode
DEFAULT_END=100                            # Ending episode
CHECKPOINT_INTERVAL=5                      # Periodic check interval (CLAUDE.md default: every 5 eps)

# Arc configuration (modify to match novel structure)
# get_arc function: episode number -> arc name mapping
get_arc() {
    local ep=$1
    if [ "$ep" -le 6 ]; then echo "prologue"
    elif [ "$ep" -le 100 ]; then echo "arc-01"
    elif [ "$ep" -le 200 ]; then echo "arc-02"
    elif [ "$ep" -le 300 ]; then echo "arc-03"
    elif [ "$ep" -le 400 ]; then echo "arc-04"
    fi
}

# Arc boundary episodes (triggers arc-end checks)
ARC_BOUNDARIES=(100 200 300 400)

# External AI feedback toggle
# true: run external AI (Gemini/GPT/NIM/Ollama) review via review_episode MCP
# false: run unified-reviewer only (skip external feedback)
USE_EXTERNAL_FEEDBACK=true
# ================================================

# Novel folder = script location = CWD
NOVEL_DIR="$(cd "$(dirname "$0")" && pwd)"
NOVEL_NAME="$(basename "$NOVEL_DIR")"
LOG_FILE="${NOVEL_DIR}/batch-write.log"
DETAIL_LOG="${NOVEL_DIR}/batch-write-detail.log"

START=${1:-$DEFAULT_START}
END=${2:-$DEFAULT_END}
LAST_CHECKPOINT=$((START - 1))

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" | tee -a "$LOG_FILE"
}

# Run from novel folder (.claude/agents/ auto-loaded)
cd "$NOVEL_DIR"

log "=== Batch writing start: ${NOVEL_NAME} eps ${START} ~ ${END} ==="
log "Detail log: tail -f ${DETAIL_LOG}"

for (( batch_start=START; batch_start<=END; batch_start+=BATCH_SIZE )); do
    batch_end=$((batch_start + BATCH_SIZE - 1))
    if [ "$batch_end" -gt "$END" ]; then
        batch_end=$END
    fi

    # Skip already-completed episodes (prevents duplicates on restart)
    actual_start=$batch_start
    for (( ep=batch_start; ep<=batch_end; ep++ )); do
        ep_arc=$(get_arc "$ep")
        ep_file="chapters/${ep_arc}/chapter-$(printf '%02d' "$ep").md"
        if [ -f "$ep_file" ]; then
            actual_start=$((ep + 1))
            log "Ep ${ep} already exists -> skipping ($(wc -c < "$ep_file")b)"
        else
            break
        fi
    done
    if [ "$actual_start" -gt "$batch_end" ]; then
        log "Batch eps ${batch_start}~${batch_end} all complete -> skipping"
        continue
    fi
    batch_start=$actual_start

    arc=$(get_arc "$batch_start")
    arc_file="plot/${arc}.md"

    log "--- Batch eps ${batch_start}~${batch_end} (${arc}) starting ---"

    # Auto-generate plot file if missing
    if [ ! -f "$arc_file" ]; then
        log "Generating ${arc}.md plot..."
        claude -p \
"${arc} 상세 플롯을 작성해줘.

사전 읽기:
- CLAUDE.md (작품 개요, 구성)
- plot/ 폴더의 기존 아크 파일 (형식 참조)
- plot/master-outline.md (해당 아크 개요)
- compile_brief MCP로 현재 상태 확인 (실패 시 summaries/running-context.md 폴백)

작성 규칙:
1. 기존 아크 플롯 파일과 동일한 형식으로 작성
2. master-outline.md의 해당 아크 개요를 따름
3. 10화 블록 상세 포함
4. 캐릭터 아크, 복선 계획, 주요 전투/이벤트 목록 포함
5. 결과를 plot/${arc}.md에 저장" >> "$LOG_FILE" 2>&1

        if [ ! -f "$arc_file" ]; then
            log "ERROR: ${arc}.md generation failed. Script halted."
            exit 1
        fi
        log "${arc}.md generation complete"
    fi

    # External feedback instruction
    if [ "$USE_EXTERNAL_FEEDBACK" = true ]; then
        FEEDBACK_INSTRUCTION="- mcp__novel_editor__review_episode를 호출하여 외부 AI 편집 리뷰도 수행한다."
    else
        FEEDBACK_INSTRUCTION="- 외부 AI 편집 리뷰는 건너뛴다. unified-reviewer만 실행한다."
    fi

    # Batch writing prompt — delegates to Lean workflow
    # NOTE: Prompt content is in Korean as the writer AI operates in Korean
    PROMPT="${batch_start}~${batch_end}화를 순차 집필해줘.

[배치 파라미터]
- 범위: ${batch_start}화 ~ ${batch_end}화
- 플롯: 각 화의 아크에 해당하는 plot/{arc}.md 참조 (배치가 아크를 걸칠 수 있으므로 화마다 확인).
- 1화를 완전히 완료(집필 + unified-reviewer + 요약 갱신 + 커밋)한 후 다음 화로 넘어간다.
- 각 화 집필 전 compile_brief MCP 도구를 호출하여 현재 맥락을 확인한다. 개별 summaries/settings 파일을 직접 읽지 않는다. compile_brief 실패 시만 writer.md의 폴백 순서(running-context -> 아크 플롯 -> character-tracker) 적용.

[워크플로]
CLAUDE.md의 전체 워크플로(사전 준비 -> 집필 -> 통합 리뷰 -> 후처리 -> 커밋)를 매 화마다 빠짐없이 따른다.
- 사전 준비: compile_brief MCP 호출로 압축 브리프 수신. 이전 화와의 연결성을 확보한다.
- 통합 리뷰: unified-reviewer 에이전트 1회 호출 (모드는 주기+변화량 기반 자동 결정).
${FEEDBACK_INSTRUCTION}
- 요약 갱신: writer가 집필 직후 인라인으로 갱신 (별도 에이전트 불필요).

[에러 처리]
에러 발생 시 에러 내용을 stdout에 출력하고, 해당 화에서 작업을 중단한다."

    # Periodic check: triggered when CHECKPOINT_INTERVAL+ eps since last check
    episodes_since_checkpoint=$((batch_end - LAST_CHECKPOINT))
    if [ "$episodes_since_checkpoint" -ge "$CHECKPOINT_INTERVAL" ]; then
        PROMPT="${PROMPT}

[정기 점검]
${batch_end}화 완료 후, CLAUDE.md/settings/07-periodic.md의 정기 점검(P1~P9)을 수행한다."
        if [ "$USE_EXTERNAL_FEEDBACK" = true ]; then
            PROMPT="${PROMPT}
P7은 mcp__novel_editor__batch_review로 직전 점검 이후 에피소드를 대상으로 일괄 리뷰한다."
        fi
        LAST_CHECKPOINT=$batch_end
    fi

    # Arc transition check
    for boundary in "${ARC_BOUNDARIES[@]}"; do
        if [ "$batch_start" -le "$boundary" ] && [ "$batch_end" -ge "$boundary" ]; then
            PROMPT="${PROMPT}

[아크 종료 점검]
${boundary}화(아크 종료) 완료 후:
1. 정기 점검(P1~P9)을 수행한다 (위에서 미수행 시).
2. 아크 전체 요약을 summaries/arc-summaries/에 작성한다.
3. 아크 목표 달성도를 검토한다.
4. running-context.md를 대정리한다 (해당 아크 내용을 아크 요약으로 이관)."
            LAST_CHECKPOINT=$boundary
        fi
    done

    log "Running claude (eps ${batch_start}~${batch_end})..."
    echo "===== [$(date '+%H:%M:%S')] Batch eps ${batch_start}~${batch_end} starting =====" >> "$DETAIL_LOG"

    if stdbuf -oL claude -p --verbose --output-format stream-json "$PROMPT" | \
        jq --unbuffered -r '
        if .type == "assistant" then
          (.message.content[]? |
            if .type == "text" then "[" + (now | strftime("%H:%M:%S")) + "] " + .text
            elif .type == "tool_use" then "[" + (now | strftime("%H:%M:%S")) + "] tool: " + .name + " -> " + (.input | tostring | .[0:120])
            else empty end)
        elif .type == "tool_result" then
          "  > " + (.content | tostring | .[0:200])
        elif .type == "result" then
          "[" + (now | strftime("%H:%M:%S")) + "] done (" + ((.duration_ms // 0) / 1000 | tostring) + "s, " + ((.total_cost_usd // 0) * 100 | round | tostring) + "c)"
        else empty end
        ' >> "$DETAIL_LOG" 2>/dev/null; then
        # Verify actual file creation (claude -p may exit 0 despite internal errors)
        missing=()
        created=()
        for (( ep=batch_start; ep<=batch_end; ep++ )); do
            ep_arc=$(get_arc "$ep")
            ep_file="chapters/${ep_arc}/chapter-$(printf '%02d' "$ep").md"
            if [ ! -f "$ep_file" ]; then
                missing+=("ep${ep}")
            else
                size=$(wc -c < "$ep_file")
                created+=("ep${ep}(${size}b)")
            fi
        done
        if [ ${#missing[@]} -gt 0 ]; then
            first_missing=$(echo "${missing[0]}" | grep -o '[0-9]*')
            log "ERROR: claude returned success but files not created: ${missing[*]}"
            log "Restart: cd ${NOVEL_DIR} && bash batch-write.sh ${first_missing} ${END}"
            exit 1
        fi
        log "Batch eps ${batch_start}~${batch_end} complete: ${created[*]}"
    else
        EXIT_CODE=$?
        log "ERROR: Batch eps ${batch_start}~${batch_end} failed (exit code: ${EXIT_CODE})"
        log "Restart: cd ${NOVEL_DIR} && bash batch-write.sh ${batch_start} ${END}"
        exit 1
    fi

    # Progress
    completed=$((batch_end - START + 1))
    total=$((END - START + 1))
    pct=$((completed * 100 / total))
    log "Progress: ${completed}/${total} eps (${pct}%)"

    # Inter-batch delay (API rate limit prevention)
    if [ "$batch_end" -lt "$END" ]; then
        sleep 10
    fi
done

log "=== Full writing complete: ${NOVEL_NAME} eps ${START} ~ ${END} ==="
