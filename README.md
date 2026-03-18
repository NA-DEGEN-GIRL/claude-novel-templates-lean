# Claude Novel Templates — Lean Edition

AI(Claude Code)로 웹소설을 쓰기 위한 **경량화 템플릿**.

[원본 템플릿](https://github.com/NA-DEGEN-GIRL/claude-novel-templates)에서 에이전트 12종 → 2종으로 통합하고, MCP 기반 맥락 압축(`compile_brief`)과 인라인 요약 갱신으로 **토큰 사용량을 ~70-80% 절감**한다.

---

## 원본 대비 변경점

| 항목 | 원본 (12-agent) | Lean (9-agent) |
|------|----------------|----------------|
| 집필 에이전트 | writer + reviewer + continuity-checker + korean-proofreader + gemini-feedback + summary-generator (6종) | **writer** + **unified-reviewer** (2종) |
| 감사/리뷰 에이전트 | full-audit + audit-verifier + audit-fixer (3종) | **full-audit** + **narrative-reviewer** + **narrative-fixer** + **book-reviewer** + **why-checker** (5종) |
| 셋업/검증 에이전트 | — | **story-consultant** + **korean-naturalness** (2종) |
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

# 권한 설정 (claude -p 배치 실행에 필수)
cp $NEW_ID/.claude/settings.local.example.json $NEW_ID/.claude/settings.local.json
```

> **`settings.local.json` 없이 `claude -p`를 실행하면 도구 사용이 차단됩니다.** 배치 집필/감사 시 반드시 복사해야 합니다. 대화형(`claude`) 실행 시에는 수동 승인이 가능하므로 선택사항입니다.

### 2. 초기 셋업

[INIT-PROMPT.md](./INIT-PROMPT.md)에 4가지 셋업 프롬프트가 준비되어 있다.

```bash
cd my-novel && claude
# INIT-PROMPT.md에서 원하는 프롬프트를 복사하여 붙여넣기
```

셋업 흐름 요약 (프롬프트 1 기준):

1. **시나리오 제안** — 장르/키워드로 3개 시나리오 생성
2. **전문가 컨셉 평가** — story-consultant 에이전트가 6개 관점에서 GO/REVISE/NO-GO 판정
3. **선택 & 확장** — 캐릭터, 아크 설계, 핵심 약속, 세계관 규칙
4. **확장 컨셉 재평가** — story-consultant 재실행, GO 후 진행
5. **프로젝트 생성** — 템플릿 기반 전체 파일 자동 생성
6. **플롯 사전 검증** (`/why-check plan`) — master-outline, arc-01에 대해 WHY/HOW/WHEN/SO-WHAT 질문. PLANNING GAP 발견 시 즉시 수정
7. **교차 검증** — 3팀(사실 관계/서사 실현성/표기 일관성) 병렬 검증. 4단계에서 plot 수정 시 why-check plan 재실행
8. **git commit** — 소설 폴더 독립 레포 + 상위 레포 등록

### 3. 집필 시작

```bash
# 감독자 배치 (자동 연속 집필)
cd /root/novel && claude
# → "my-novel/batch-supervisor.md 대로 수행"

# 또는 직접 집필 (한 화씩)
cd my-novel && claude
# → "1화 작성해줘"
```

---

## 프로젝트 구조

```
my-novel/
├── CLAUDE.md                  ← Writing Constitution (English + Korean examples)
├── INIT-PROMPT.md             ← AI 셋업 프롬프트 (4종)
├── batch-supervisor.md        ← 배치 집필 감독 프롬프트
├── batch-supervisor-audit.md  ← 배치 감사 감독 프롬프트
├── settings/
│   ├── ...
├── chapters/
├── plot/
├── summaries/
├── reference/
│   └── name-table.md         ← 이름 레퍼런스 (~590항목, 12개 문화권)
└── .claude/
    ├── commands/              ← 9종 (아래 표 참조)
    └── agents/                ← 9종 (아래 표 참조)
```

### 에이전트 9종

| 에이전트 | 역할 | 실행 시점 |
|----------|------|----------|
| **writer** | 집필 파이프라인: compile_brief → 장면 구성 → 집필 → 요약 갱신 → 커밋 | 매화 |
| **unified-reviewer** | 연속성 + 품질 + 한글 교정 (3모드: continuity/standard/full) | 매화 (writer가 호출) |
| **story-consultant** | 컨셉 사전 평가: 6개 관점(연재 편집자, 장르 전문가, 캐릭터/감정, 구조, AI 실행 리스크 등)에서 GO/REVISE/NO-GO 판정 | 초기 셋업 시 (INIT-PROMPT 1~2.5단계) |
| **full-audit** | 전수 팩트 체크. 1M 컨텍스트로 싱글 패스 또는 동적 청킹 | 아크/소설 완결 시 |
| **narrative-reviewer** | 서사 품질 전체 리뷰 (장르 이탈, 주인공 수동화, 스케일 인플레이션 등). Phase 4에서 교차 검증 통합 | 아크/소설 완결 시 |
| **narrative-fixer** | 서사 리뷰 기반 수술적 수정 (S1~S6) 또는 WHY-CHECK 경량 패치 (E1~E4) | narrative-review 또는 why-check 이후 |
| **book-reviewer** | 독자/비평가 관점 작품 평가. settings/plot/summaries 읽지 않음 — 본문만으로 판단 | 아크/소설 완결 시 |
| **why-checker** | "왜?" "어떻게?" 질문 생성 → 본문에서 답 검색. 설정 구멍/플롯 홀 탐지. Planning Mode로 플롯 사전 검증도 수행 | 아크 전환 시, 소설 완결 시, 초기 셋업 시 |
| **korean-naturalness** | 한국어 자연스러움 전수 검사. 문법이 맞더라도 원어민 감각에 어색하면 지적 | 완결 후 또는 품질 점검 시 |

### 커맨드 9종

| 커맨드 | 역할 | 산출물 |
|--------|------|--------|
| `/audit` | 전수 감사 실행 (읽기 전용) | `full-audit-report.md` |
| `/audit-fix` | 감사 보고서 기반 오류 수정 (연속성→품질→한글 순) | `full-audit-fix-log.md` |
| `/narrative-review` | 서사 품질 리뷰 (읽기 전용). Phase 4에서 book-review/why-check 교차 검증 | `narrative-review-report.md` |
| `/narrative-fix` | 서사 리뷰 기반 품질 수정. 기본 모드(S1~S6) 또는 WHY-CHECK 모드(E1~E4) | `narrative-fix-log.md` 또는 `why-fix-log.md` |
| `/book-review` | 독자/비평가 관점 작품 평가 (Claude). 본문만 읽고 판단 | `book-review.md` |
| `/book-review-gpt` | GPT로 독자 관점 리뷰. Claude와 다른 시각 제공. 두 리뷰 비교로 균형 잡힌 평가 | `book-review-gpt.md` |
| `/naturalness` | 한국어 자연스러움 전수 검사. 에피소드별 개별 Agent 호출 (주의력 유지) | 인라인 보고서 |
| `/naturalness-fix` | naturalness 보고서의 지적 사항을 맥락 기반 선별 수정. 의도적 문체/말투 오탐 필터링 | 수정된 에피소드 |
| `/why-check` | WHY/HOW 질문 생성 + 본문 답 검색. 아크/범위/full/plan 모드 지원 | `why-check-report.md` |

---

## 검증/리뷰 파이프라인

소설의 품질 검증은 시점에 따라 다른 도구 조합으로 수행한다.

### 집필 시 (매화)

```
writer → unified-reviewer (continuity/standard/full 모드 자동 결정)
```

### 아크 전환 시

```
/why-check (완료 아크 사후 검증)
    ↓
/why-check plan (다음 아크 플롯 사전 검증)
    ↓  PLANNING GAP 발견 시 즉시 수정
/narrative-fix --source why-check (우선도 6+ 경량 패치, 1~3문장)
```

> 플롯 단계에서 구멍 1개를 막는 비용은 문장 1개다. 같은 구멍이 집필 후 발견되면 장면 재작성이 필요하다.

### 완결 시 (전체 검증)

```
/why-check full (전체 소설 WHY/HOW 검증)
    ↓
/book-review + /book-review-gpt (독립적 작품 평가 2건)
    ↓
/narrative-review (Phase 1~3 독립 분석 + Phase 4 교차 검증)
    ↓
/narrative-fix (통합 fix guide 실행)
```

### 교차 검증 시스템

`/narrative-review`의 **Phase 4**가 교차 검증의 핵심이다.

1. Phase 1~3에서 narrative-reviewer가 **독립적으로** 서사 품질을 분석하고 fix guide를 생성한다
2. Phase 4에서 `book-review.md`, `book-review-gpt.md`, `why-check-report.md`가 존재하면 읽는다
3. 각 외부 보고서의 이슈를 **텍스트에서 재진단**한다 (외부 판단을 그대로 수용하지 않음)
4. 확인된 이슈는 기존 fix guide 항목의 우선도를 올리거나 신규 항목으로 추가한다
5. Phase 1~3의 점수와 판단은 변경하지 않는다 — fix guide만 보강된다

> 원칙: **판단은 reviewer, 실행은 fixer.** narrative-fixer는 단일 fix guide만 받아서 실행한다.

### `/narrative-fix` 이중 모드

| 모드 | 입력 | 전략 | 범위 |
|------|------|------|------|
| **기본** (narrative-review 기반) | `narrative-review-report.md` | S1~S6 (구조적 서사 수정) | 다화 수정, 장면 재구성 가능 |
| **WHY-CHECK** (`--source why-check`) | `why-check-report.md` | E1~E4 (경량 설명 보강) | 항목당 1~3문장, 단일 화수, 기존 장면 내부 삽입만 |

WHY-CHECK 모드는 아크 전환 시 빠른 패치용이다. 한도 초과 항목은 HOLD 처리되어 다음 `/narrative-review` 사이클로 이관된다.

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

### 집필 감독: `batch-supervisor.md`

Claude Code가 tmux 세션의 집필 AI를 모니터링. 에러 복구, 질문 응답, 다음 화 전송을 자동 처리한다.

```bash
cd /root/novel && claude
# → "my-novel/batch-supervisor.md 대로 수행"
```

아크 전환 시 감독자가 자동으로 수행하는 추가 작업:

1. 완료 아크에 `/why-check` 실행
2. 우선도 6+ 항목에 `/narrative-fix --source why-check` 경량 패치
3. 다음 아크 플롯 파일에 `/why-check plan` 실행 (PLANNING GAP 즉시 수정)
4. 정기 점검(P1~P9) 지시

### 감사 감독: `batch-supervisor-audit.md`

전수 감사(`/audit`)를 N화 배치로 자동 감독한다.

---

## `reference/` 디렉토리

| 파일 | 내용 |
|------|------|
| `reference/name-table.md` | 이름 레퍼런스 (~590항목, 12개 문화권). 셋업 시 캐릭터 이름 선택에 활용 |

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
