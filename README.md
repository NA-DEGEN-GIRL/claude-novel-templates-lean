# Claude Novel Templates -- Lean Edition

Claude Code 중심으로 한국어 웹소설 프로젝트를 운영하기 위한 경량 템플릿.

이 템플릿은 `Claude 단일 런타임`을 기본 전제로 둔다. 집필, 리뷰, 배치 감독, 감사까지 Claude Code 안에서 닫힌 루프로 돌리고, MCP와 외부 AI는 필요한 만큼만 붙인다.

---

## 시작 전

이 템플릿의 기본 역할 분리는 단순하다.

- Claude Code: writer / reviewer / supervisor / auditor
- MCP: `compile_brief`, 계산, 한자 검증, 표기 통일, 삽화 생성 같은 보조 도구
- 외부 AI: 선택적 편집자. 켜지 않아도 기본 파이프라인은 동작

사용 방식은 두 가지다.

- 구독형/정액형 환경: Claude Code와 외부 서비스의 각 플랜 한도 안에서 사용
- API 과금형 환경: 사용하는 서비스별 정책에 따라 사용량 기반 과금

핵심은 "무슨 모델을 몇 개 붙이느냐"보다 **Claude Code를 어떤 문서와 규칙으로 운용하느냐**다.

## Shared Settings Layer

이 템플릿의 `settings/`는 [claude-codex-novel-templates-hybrid](/root/novel/claude-codex-novel-templates-hybrid/settings), [codex-novel-templates-lean](/root/novel/codex-novel-templates-lean/settings)와 **동일한 공통 집필 레이어**다.

- `settings/`는 일반 소설과 웹소설 모두에 적용되는 문체, 캐릭터, 연속성, 정기 점검 규약을 담는다.
- `CLAUDE.md`와 `batch-supervisor.md`는 Claude lean의 실행 방식만 정의한다.
- 문학 규칙을 개선할 때는 보통 `settings/`를 먼저 고치고, Claude 전용 운용 차이는 상위 문서에서 처리한다.

---

## 먼저 볼 문서

- [CLAUDE.md](./CLAUDE.md): 소설 최상위 운영 규약
- [INIT-PROMPT.md](./INIT-PROMPT.md): 새 프로젝트 시작 프롬프트
- [batch-supervisor.md](./batch-supervisor.md): 연속 집필 감독 규칙
- [batch-supervisor-audit.md](./batch-supervisor-audit.md): 배치 감사 규칙
- [settings/01-style-guide.md](./settings/01-style-guide.md): 문체 가이드
- [settings/03-characters.md](./settings/03-characters.md): 캐릭터 앵커
- [settings/05-continuity.md](./settings/05-continuity.md): 연속성 기준
- [settings/07-periodic.md](./settings/07-periodic.md): 정기 점검 기준

초보자 기준 권장 읽기 순서:

1. 이 README
2. [INIT-PROMPT.md](./INIT-PROMPT.md)
3. [CLAUDE.md](./CLAUDE.md)
4. [batch-supervisor.md](./batch-supervisor.md)

---

## What This Is

- 한국어 웹소설용 프로젝트 스캐폴드
- Claude Code 기준 운영 문서 세트
- `settings / plot / summaries / chapters` 구조가 잡힌 템플릿
- Claude writer + unified-reviewer + audit + supervisor workflow
- 외부 AI 없이도 굴릴 수 있는 lean 분기

## What This Is Not

- Codex 전용 템플릿
- Hybrid처럼 `Claude supervisor + Codex writer` 구조를 기본 전제로 둔 파이프라인
- 외부 AI 리뷰가 반드시 있어야만 돌아가는 템플릿
- 복잡한 멀티모델 오케스트레이션을 먼저 깔아두는 무거운 분기

---

## Design Principles

1. `settings/`는 세 템플릿이 공유하는 집필 규약이고, `CLAUDE.md`와 `batch-supervisor.md`는 Claude 런타임 레이어다.
2. 매 화 집필, 정기 점검, 아크 경계 감사를 문서와 체크리스트로 강제한다.
3. `compile_brief`를 우선 쓰되, 불가하면 fallback으로 읽기 순서를 정한다.
4. 대표 대사와 보이스 규칙은 복붙용 문장 사전이 아니라 운용 앵커로 쓴다.
5. 아크 경계에서 `patch-feasible`과 `HOLD`를 구분하고, `forward-fix`는 문서 3곳에 동시에 기록한다.

---

## Repository Layout

- [CLAUDE.md](./CLAUDE.md)
  - 소설 최상위 운영 규약
- [INIT-PROMPT.md](./INIT-PROMPT.md)
  - 새 소설 초기 세팅 프롬프트
- [MIGRATION-PROMPT.md](./MIGRATION-PROMPT.md)
  - 기존 프로젝트를 lean 구조로 옮길 때 참고
- [REBUILD-PROMPT.md](./REBUILD-PROMPT.md)
  - 소설 재구축용 프롬프트
- [batch-supervisor.md](./batch-supervisor.md)
  - tmux writer 감독 문서
- [batch-supervisor-audit.md](./batch-supervisor-audit.md)
  - tmux auditor 감독 문서
- `settings/`
  - 문체, 구조, 캐릭터, 세계관, 연속성, 정기 점검, 삽화 규칙
  - hybrid / codex lean과 동일한 공통 authoring layer
- `plot/`
  - master outline, arc plots, foreshadowing
- `summaries/`
  - running context, episode log, character tracker, review/action logs
- `chapters/`
  - 실제 원고 파일
- `reference/`
  - 이름표 등 참고 자료
- `.claude/`
  - Claude Code용 agents / commands / local settings

---

## 필수 환경

### 1. Claude Code

이 템플릿의 기본 실행 엔진이다.

```bash
npm install -g @anthropic-ai/claude-code
```

권장:

- 긴 컨텍스트 모델
- 장편을 다루는 경우 auto-compact를 안정적으로 쓰는 환경
- 배치 집필을 돌릴 경우 `tmux`

### 2. MCP 서버

필수는 아니지만, 생산성과 검증 품질이 크게 올라간다.

| MCP | 용도 | 권장도 |
|---|---|---|
| `novel-editor` | `compile_brief`, `review_episode` | 강력 권장 |
| `novel-calc` | 날짜, 거리, 이동, 경제, 분량 검증 | 선택 |
| `novel-hanja` | 한자 검색/검증 | 한자 병기 작품이면 사실상 필수 |
| `novel-naming` | 표기 변이, 별호/문파/인명 통일 | 권장 |
| `novelai-image` | 표지/삽화 생성 | 선택 |

핵심 규칙:

- `compile_brief`가 가능하면 먼저 사용
- `novel-calc`는 검증용이지 서사를 대신하는 도구가 아님
- 한자 표기는 추정 조합 금지, `novel-hanja` 검증 우선
- 고유명사가 많아지면 `novel-naming`으로 표기 드리프트를 잡는다

### 3. 외부 AI

선택 사항이다. [CLAUDE.md](./CLAUDE.md)의 플래그로 켜고 끈다.

- Gemini: 연속성 / 세계관
- GPT: 산문 / 대화 / 감정 표현
- NIM: 맞춤법 / 문법
- Ollama: 로컬 교정

모두 꺼도 lean 파이프라인은 정상 동작한다.

---

## 최소 경로

가장 빨리 시작하는 방법은 아래 순서다.

```bash
git clone https://github.com/NA-DEGEN-GIRL/claude-novel-templates-lean.git
cp -r claude-novel-templates-lean my-novel
cd my-novel
claude
```

그다음:

1. [INIT-PROMPT.md](./INIT-PROMPT.md) 사용
2. [CLAUDE.md](./CLAUDE.md)의 placeholder 채우기
3. `settings/`와 `plot/` 초기화
4. `"1화 작성해줘"` 또는 supervisor 경로로 시작

---

## 빠른 시작

### 1. 새 소설 폴더 만들기

```bash
cp -r /root/novel/claude-novel-templates-lean /root/novel/my-novel
cd /root/novel/my-novel
```

### 2. 초기 세팅

[INIT-PROMPT.md](./INIT-PROMPT.md)에서 상황에 맞는 프롬프트를 쓴다.

- 시나리오 제안부터 받고 싶으면 `프롬프트 1`
- 이미 컨셉이 정해져 있으면 `프롬프트 2`
- 거의 자동으로 만들고 싶으면 `프롬프트 3`
- 기존 소설 구조를 복제하고 싶으면 `프롬프트 4`

### 3. 직접 집필

```bash
cd /root/novel/my-novel
claude
```

대화창에서 예:

```text
1화 작성해줘.
```

### 4. 배치 감독 집필

```bash
cd /root/novel
claude
```

대화창에서 예:

```text
my-novel/batch-supervisor.md 규칙에 따라 1화부터 20화까지 감독해줘.
```

---

## 매 화 집필 워크플로

기본 흐름은 [CLAUDE.md](./CLAUDE.md) Section 3을 따른다.

1. `compile_brief`로 맥락 로드
2. 직전 화 마지막 2~3문단 확인
3. `settings/03-characters.md`에서 핵심 인물 앵커 확인
4. planning gate 정리
5. 초안 작성
6. unified-reviewer 실행
7. summary / feedback-log / EPISODE_META / action-log 갱신
8. git commit

중요한 운영 원칙:

- 대표 대사는 복붙하지 않는다
- `novel-calc`는 검증용이다
- 한자 표기는 `novel-hanja`로 검증한다
- 표기 변이는 `novel-naming`으로 정리한다

---

## 정기 점검과 아크 경계

정기 점검은 [settings/07-periodic.md](./settings/07-periodic.md)를 따른다.

현재 기본값:

- 기본 5화 단위
- 최대 8화 초과 금지
- 아크 전환에서는 무조건 실행

핵심 점검 축:

- summary consistency
- character state freshness
- WHY/HOW + motivation-action gap
- repetition
- Korean naturalness
- thematic progress

아크 경계에서는 추가로 아래가 중요하다.

1. `patch-feasible`은 즉시 repair batch로 수정
2. 구조 수정이 필요한 항목은 `HOLD`로 분류
3. `forward-fix`는 `review-log.md`, `running-context.md`, 다음 아크 plot에 동시에 기록
4. `scope: current-arc` open HOLD가 있으면 아크 마감 불가

---

## batch-supervisor.md 사용법

[batch-supervisor.md](./batch-supervisor.md)는 tmux writer를 감독하는 문서다.

실행 전에 최소 아래 변수를 채운다.

| 변수 | 설명 |
|---|---|
| `NOVEL_ID` | 소설 폴더명 |
| `SESSION` | tmux 세션명 |
| `NOVEL_DIR` | 소설 절대 경로 |
| `START_EP` | 시작 화 |
| `END_EP` | 종료 화 |
| `CHUNK_SIZE` | `/clear` 간격. `-1`이면 auto-compact 위주 |
| `WRITER_CMD` | 기본 `claude` |
| `ARC_MAP` | 아크-화수 매핑 |

supervisor가 하는 일:

- review floor 결정
- writer 세션 상태 확인
- 다음 화 프롬프트 전송
- 에러 복구
- 아크 경계 A~F 절차 강제
- patch-feasible / HOLD 분류 확인
- batch-progress.log와 config 정합성 확인

초보자용 권장 순서:

1. [CLAUDE.md](./CLAUDE.md) 작성
2. `settings/`와 `plot/` 최소 채우기
3. [batch-supervisor.md](./batch-supervisor.md) 변수 채우기
4. `/root/novel`에서 Claude 실행
5. supervisor에게 해당 문서 기준 집필 감독 요청

---

## settings 가이드

가장 중요한 설정 파일은 아래 네 개다.

- [settings/01-style-guide.md](./settings/01-style-guide.md)
  - Voice Profile은 문장 버릇 사전이 아니라 문체 계약
- [settings/03-characters.md](./settings/03-characters.md)
  - 대표 대사는 운용 앵커이며, 실제 본문에서는 변주해서 사용
- [settings/05-continuity.md](./settings/05-continuity.md)
  - 불변 조건, 타임라인, arc transition 정합성 기준
- [settings/07-periodic.md](./settings/07-periodic.md)
  - 정기 점검과 병렬 집필 정리 규칙

좋은 초기 상태의 기준:

- `01-style-guide`에 서술 온도와 대표 문단이 들어 있다
- `03-characters`에 주인공과 핵심 동료의 동기, 약점, 대표 대사가 들어 있다
- `04-worldbuilding`에 규칙과 대가가 들어 있다
- `05-continuity`에 timeline baseline과 invariants가 들어 있다
- `plot/master-outline.md`와 `plot/arc-01.md`가 존재한다

---

## Lean과 Hybrid 차이

`claude-novel-templates-lean`은 `Claude 단일 런타임`이다.

| 항목 | lean | hybrid |
|---|---|---|
| 집필 | Claude Code | Codex |
| 리뷰 | Claude Code | Claude가 Codex 글 검증 |
| supervisor | Claude Code | Claude Code |
| 복잡도 | 낮음 | 높음 |
| 교차 모델 검증 | 약함 | 강함 |
| 시작 난이도 | 낮음 | 중간 |

권장 기준:

- 단순하게 시작하고 싶으면 lean
- 교차 모델 검증이 중요하면 hybrid

---

## Notes

- `settings/03-characters.md`의 대표 대사는 그대로 재사용하지 않는다.
- `settings/01-style-guide.md`의 Section 0은 "잘 읽히는 문장"을 위한 기준이지, 말버릇 모음집이 아니다.
- `summaries/action-log.md`는 운영 로그다. 집필 완료나 감사 완료 때 한 줄씩 append한다.
- `summaries/review-log.md`는 arc boundary와 HOLD 관리의 원장이다.

이 템플릿은 Claude Code를 기준으로 바로 쓰는 lean 분기다.
