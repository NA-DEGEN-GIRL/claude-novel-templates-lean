# Claude Novel Templates — Lean Edition

AI(Claude Code)로 웹소설을 쓰기 위한 **경량화 템플릿**.

[원본 템플릿](https://github.com/NA-DEGEN-GIRL/claude-novel-templates)에서 에이전트 12종 → 2종으로 통합하고, MCP 기반 맥락 압축(`compile_brief`)과 인라인 요약 갱신으로 **토큰 사용량을 ~70-80% 절감**한다.

---

## 원본 대비 변경점

| 항목 | 원본 (12-agent) | Lean (2-agent) |
|------|----------------|----------------|
| 에이전트 | writer, reviewer, continuity-checker, korean-proofreader, gemini-feedback, summary-generator, summary-validator, plot-planner, illustration-manager + 감사 3종 | **writer** + **unified-reviewer** |
| 맥락 로딩 | 개별 summaries 파일 직접 읽기 | `compile_brief` MCP 1회 호출 (압축 브리프) |
| 요약 갱신 | summary-generator 에이전트 호출 | writer가 인라인 갱신 (별도 에이전트 불필요) |
| 리뷰 파이프라인 | reviewer → gemini-feedback → continuity-checker → korean-proofreader (4단계) | review_episode MCP → unified-reviewer (2단계) |
| 지시문 언어 | 한국어 | **영어** (토큰 ~40% 추가 절감). 소설 출력은 한국어 |
| 토큰 절감 | 기준 | **~70-80% 절감** |

### Language Contract

- **지시문** (CLAUDE.md, agents/, settings/): 영어로 작성 → 토큰 절감
- **소설 출력** (본문, 대사, 요약, 리뷰): 반드시 **한국어**
- **한국어 예시** (문체, 호칭, 교정 규칙): 원문 그대로 보존 — 스타일 타깃으로 기능

---

## 필수 환경

| 도구 | 용도 | 설치 |
|------|------|------|
| [Claude Code](https://docs.anthropic.com/en/docs/claude-code) | 집필 에이전트 실행 | `npm install -g @anthropic-ai/claude-code` |
| [Gemini CLI](https://github.com/google-gemini/gemini-cli) | 외부 AI 편집자 (선택) | `npm install -g @google/gemini-cli` |

### MCP 서버

| MCP 서버 | 용도 | 레포 |
|----------|------|------|
| **novel-editor** | 외부 AI 리뷰 + `compile_brief` 맥락 압축 | [mcp-novel-editor](https://github.com/NA-DEGEN-GIRL/mcp-novel-editor) |
| **novel-calc** | 날짜/단위/이동시간 계산 | [mcp-novel-calc](https://github.com/NA-DEGEN-GIRL/mcp-novel-calc) |
| **novel-hanja** | 한자어 검색/검증 | [mcp-novel-hanja](https://github.com/NA-DEGEN-GIRL/mcp-novel-hanja) |
| **novelai-image** | 캐릭터/삽화/표지 생성 | [mcp-novelai-image](https://github.com/NA-DEGEN-GIRL/mcp-novelai-image) |

> `novel-editor`의 `compile_brief`가 lean 워크플로의 핵심이다. 없으면 개별 summaries 파일 직접 읽기로 폴백한다.

---

## 빠른 시작

### 1. 템플릿 복사

```bash
git clone https://github.com/NA-DEGEN-GIRL/claude-novel-templates-lean.git

NEW_ID="my-novel"
mkdir -p $NEW_ID
cp -r claude-novel-templates-lean/{CLAUDE.md,INIT-PROMPT.md,settings,summaries,chapters,plot} $NEW_ID/
mkdir -p $NEW_ID/.claude/agents
cp -r claude-novel-templates-lean/.claude/* $NEW_ID/.claude/
```

### 2. 초기 셋업

[INIT-PROMPT.md](./INIT-PROMPT.md)에 4가지 셋업 프롬프트가 준비되어 있다.

```bash
cd my-novel && claude
# INIT-PROMPT.md에서 원하는 프롬프트를 복사하여 붙여넣기
```

### 3. 집필 시작

```bash
# 방법 A: 감독자 배치 (권장 — 자동 연속 집필)
cd /root/novel && claude
# → "my-novel/batch-supervisor.md 대로 수행"

# 방법 B: 직접 집필 (한 화씩)
cd my-novel && claude
# → "1화 작성해줘"
```

---

## 프로젝트 구조

```
my-novel/
├── CLAUDE.md                  ← Writing Constitution (English + Korean examples)
├── INIT-PROMPT.md             ← AI 셋업 프롬프트 (4종)
├── compile_brief.py           ← 맥락 압축 스크립트 (MCP 서버에서 호출)
├── batch-write.sh             ← 배치 자동 집필 스크립트
├── batch-supervisor.md        ← 배치 집필 감독 프롬프트
├── batch-supervisor-audit.md  ← 배치 감사 감독 프롬프트
├── settings/
│   ├── ...
├── chapters/
├── plot/
├── summaries/
└── .claude/
    ├── commands/
    │   ├── audit.md              ← /audit — 전수 감사
    │   ├── audit-fix.md          ← /audit-fix — 감사 수정
    │   ├── narrative-review.md   ← /narrative-review — 서사 리뷰
    │   └── narrative-fix.md      ← /narrative-fix — 서사 수정
    └── agents/
        ├── writer.md             ← Writer (A-F pipeline)
        ├── unified-reviewer.md   ← Unified reviewer (continuity + quality + Korean)
        ├── full-audit.md         ← Full audit (1M context, single-pass or chunked)
        └── narrative-reviewer.md ← Narrative reviewer (서사 품질 진단)
```

### 에이전트 4종

| 에이전트 | 역할 | 실행 시점 |
|----------|------|----------|
| **writer** | 집필 파이프라인: compile_brief → 장면 구성 → 집필 → 요약 갱신 → 커밋 | 매화 |
| **unified-reviewer** | 연속성 + 품질 + 한글 교정 (3모드: continuity/standard/full) | 매화 (writer가 호출) |
| **full-audit** | 전수 팩트 체크. 1M 컨텍스트로 싱글 패스 또는 동적 청킹 | 아크/소설 완결 시 |
| **narrative-reviewer** | 서사 품질 전체 리뷰 (장르 이탈, 주인공 수동화, 스케일 인플레이션 등) | 아크/소설 완결 시 |

### 커맨드 4종

| 커맨드 | 역할 | 산출물 |
|--------|------|--------|
| `/audit` | 전수 감사 실행 (읽기 전용) | `full-audit-report.md` |
| `/audit-fix` | 감사 보고서 기반 오류 수정 (연속성→품질→한글 순) | `full-audit-fix-log.md` |
| `/narrative-review` | 서사 품질 리뷰 (읽기 전용) | `narrative-review-report.md` |
| `/narrative-fix` | 서사 리뷰 기반 품질 수정 (사용자 승인 후 실행) | `narrative-fix-log.md` |

원본의 12개 에이전트 + 3개 커맨드가 **4개 에이전트 + 4개 커맨드**로 통합되었다. 수정 커맨드(`/audit-fix`, `/narrative-fix`)는 별도 에이전트 없이 SOP 기반으로 직접 실행한다.

---

## 워크플로 (1화 기준)

```
A. Prep — compile_brief MCP 호출 (압축 브리프 수신)
     ↓
B. Plan — 비트시트 (3-5 장면)
     ↓
C. Write — 본문 집필 (문체 가이드 + 세계관 준수)
     ↓
D. Inline Summary — writer가 직접 요약 7종 갱신
     ↓
E. Review
   ├─ review_episode MCP (외부 AI) → EDITOR_FEEDBACK_*.md
   └─ unified-reviewer (모드 자동 결정)
     ↓
F. Commit — 본문 + 요약 함께 커밋
```

---

## 배치 자동 집필

### 감독자 방식 (권장): `batch-supervisor.md`

Claude Code가 tmux 세션의 집필 AI를 모니터링. 에러 복구, 질문 응답, 다음 화 전송을 자동 처리한다.

```bash
cd /root/novel && claude
# → "my-novel/batch-supervisor.md 대로 수행"
```

### 스크립트 방식: `batch-write.sh`

`claude -p`를 5화 단위로 반복 호출. 백그라운드 무인 실행 가능.

```bash
cd my-novel

bash batch-write.sh            # 전체 범위
bash batch-write.sh 50 100     # 특정 범위
nohup bash batch-write.sh &    # 백그라운드
```

### 감사 감독: `batch-supervisor-audit.md`

전수 감사(`/audit`)를 N화 배치로 자동 감독한다.

---

## 정기 점검 (5화마다)

| # | 항목 | 방법 |
|---|------|------|
| P1 | 요약 정합성 | unified-reviewer standard 모드 (S1-S6 검증) |
| P2 | 복선 회수 시한 | foreshadowing.md 체크 |
| P3 | 캐릭터 상태 최신성 | character-tracker ↔ 최신 에피소드 |
| P4 | 미이행 약속 | promise-tracker 체크 |
| P5 | running-context | 200줄 이내 + 최신 반영 |
| P6 | 성격 드리프트 | 최근 대사/행동 ↔ 캐릭터 시트 |
| P7 | 외부 AI 일괄 리뷰 | `batch_review` MCP |
| P8 | 한글 품질 | unified-reviewer continuity 모드 |
| P9 | 메타 참조 금지 | "X화에서" 전수 검사 |

---

## 관련 레포

- [claude-novel-templates](https://github.com/NA-DEGEN-GIRL/claude-novel-templates) — 원본 (12-agent)
- [mcp-novel-editor](https://github.com/NA-DEGEN-GIRL/mcp-novel-editor) — 외부 AI 리뷰 + compile_brief
- [mcp-novel-calc](https://github.com/NA-DEGEN-GIRL/mcp-novel-calc) — 수치 계산
- [mcp-novel-hanja](https://github.com/NA-DEGEN-GIRL/mcp-novel-hanja) — 한자어 검증
- [mcp-novelai-image](https://github.com/NA-DEGEN-GIRL/mcp-novelai-image) — 이미지 생성

---

## 라이선스

MIT License
