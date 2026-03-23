# 소설 초기 셋업 프롬프트

> `/root/novel/`에서 Claude Code를 열고 아래 프롬프트를 붙여넣는다.
> 목표는 "새 소설 프로젝트 생성 + 초기 검증 + lean 운영 레이어 정렬"까지다. 에피소드 집필은 하지 않는다.

---

## 사용법

```bash
cd /root/novel && claude
```

아래 프롬프트 중 하나를 골라 그대로 붙여넣고, `[대괄호]` 안의 값만 바꿔 쓴다.

---

## 프롬프트 1: 시나리오 선택형 (추천)

장르와 키워드만 주면 Claude가 시나리오를 제안하고, 선택 후 전체 프로젝트를 셋업한다.

```text
claude-novel-templates-lean/ 를 참고해서 새 소설 프로젝트를 만들어줘.

## 조건

- 장르: [장르]
- 톤: [톤앤무드]
- 분량: [에피소드 목표 분량]
- 총 화수: [목표 화수]
- 특이사항: [있으면 적기]

## 작업 원칙

- 에피소드 본문은 쓰지 마라. 프로젝트 셋업과 검증만 한다.
- `CLAUDE.md`를 최상위 운영 문서로 삼아라.
- `settings/`, `plot/`, `summaries/`, `chapters/` 구조를 유지하라.
- `settings/01-style-guide.md` Section 0은 문장 버릇 목록이 아니라 문체 계약으로 채워라.
- `settings/03-characters.md`의 대표 대사는 복붙용 문장이 아니라 운용 앵커가 되게 설계하라.
- `settings/05-continuity.md`에는 timeline baseline, invariants, arc transition 기준을 채워라.
- `settings/07-periodic.md`는 최신 periodic check 규칙(P1~P13)과 `patch-feasible / HOLD` 흐름에 맞춰라.
- `batch-supervisor.md`가 새 `CLAUDE.md`와 `settings/`를 실제로 참조하도록 맞춰라.
- `compile_brief` 사용을 전제로 하되, fallback 읽기 순서도 살아 있게 유지하라.
- MCP가 있으면 `novel-editor`, `novel-calc`, `novel-hanja`, `novel-naming`을 쓰는 방향으로 정리하라.

## 진행 순서

1. 컨셉 3개 제안
   - 제목
   - 한줄 소개
   - 주인공
   - 핵심 갈등
   - 예상 아크
   - 차별점

2. story-consultant 평가
   - `.claude/agents/story-consultant.md` 기준으로 7개 관점 평가
   - 각 컨셉에 GO / REVISE / NO-GO 판정
   - 강점, 리스크, "3화까지 보여줘야 할 것" 정리

3. 선택한 컨셉 확장
   - 주요 캐릭터 3~5명
   - 핵심 약속 3개
   - 아크 구성
   - 세계관 핵심 규칙

4. 확장 컨셉 재평가
   - story-consultant로 한 번 더 평가
   - GO가 나오면 다음 단계로

5. 프로젝트 생성
   - 새 폴더 생성 (no-title-XXX, 다음 번호 자동 결정)
   - `claude-novel-templates-lean/`의 `CLAUDE.md`, `INIT-PROMPT.md`, `MIGRATION-PROMPT.md`, `REBUILD-PROMPT.md`, `batch-supervisor.md`, `batch-supervisor-audit.md`, `settings/`, `summaries/`, `chapters/`, `plot/`, `reference/`, `.claude/`, `compile_brief.py`를 복사
   - `.claude/settings.local.example.json`을 `.claude/settings.local.json`으로 복사
   - `CLAUDE.md`의 placeholder를 실제 내용으로 채운다
   - `settings/01-style-guide.md`, `02-episode-structure.md`, `03-characters.md`, `04-worldbuilding.md`, `05-continuity.md`, `07-periodic.md`, `08-illustration.md`를 실제 내용으로 작성한다
   - 필요하면 `06-humor-guide.md`를 추가한다
   - `plot/master-outline.md`, `plot/foreshadowing.md`, `plot/arc-01.md`를 작성한다
   - `summaries/` 초기 파일을 점검한다:
     - `running-context.md`
     - `episode-log.md`
     - `character-tracker.md`
     - `promise-tracker.md`
     - `knowledge-map.md`
     - `relationship-log.md`
     - `decision-log.md`
     - `review-log.md`
     - `repetition-watchlist.md`
     - `hanja-glossary.md`
     - `illustration-log.md`
     - `editor-feedback-log.md`
     - `action-log.md`
     - `style-lexicon.md`
   - `batch-supervisor.md`의 변수와 절차가 새 프로젝트 구조와 맞는지 정리한다
   - 필요하면 상위 `config.json`에 새 소설을 등록한다

6. settings 정밀 점검
   - `settings/01-style-guide.md`를 다시 읽고 평균체/패턴 문체로 미끄러지지 않는지 점검
   - `settings/03-characters.md`를 다시 읽고 핵심 인물 대사가 서로 교체 가능하게 쓰이지 않았는지 점검
   - `settings/05-continuity.md`에 불변 조건이 실제 플롯과 맞는지 점검
   - `settings/07-periodic.md`와 `batch-supervisor.md`의 periodic / hold 규칙이 맞물리는지 점검
   - 필요하면 이 단계에서 바로 수정한다

7. 플롯 사전 검증
   - `/oag-check plan`으로 동기 갭과 planning gap을 먼저 점검
   - `/why-check plan`으로 설명 갭을 점검
   - 구멍이 발견되면 즉시 plot을 수정한다

8. 교차 검증
   - 사실 관계: `03-characters ↔ 04-worldbuilding ↔ plot`
   - 서사 실현성: `CLAUDE.md 1.1/1.2 ↔ plot/master-outline.md`
   - 운영 정합성: `CLAUDE.md ↔ settings/07-periodic.md ↔ batch-supervisor.md`
   - 표기/시대감: `01-style-guide ↔ 04-worldbuilding`
   - 모순이 있으면 즉시 수정하고, plot이 수정되면 `/oag-check plan` + `/why-check plan`을 1회 재실행한다

9. git 정리
   - 소설 폴더를 독립 git 레포로 초기화하고 첫 커밋
   - 필요하면 상위 레포에서 `config.json` 등 등록 변경만 별도 커밋

10. 최종 보고
   - 생성된 파일 목록
   - 남은 리스크
   - 바로 집필 가능한지 여부
   - 첫 집필 전 추천 순서
   - 첫 아크 종료 후 반드시 돌릴 감사 절차

에피소드 집필은 하지 마라.
```

---

## 프롬프트 2: 컨셉 확정형

이미 쓰고 싶은 소설이 정해져 있을 때.

```text
claude-novel-templates-lean/ 를 참고해서 새 소설 프로젝트를 만들어줘.

## 소설 정보

- 제목: [제목]
- 부제: [부제 또는 없음]
- 장르: [장르]
- 톤: [톤앤무드]
- 한줄 소개: [한줄 소개]
- 배경: [시대/세계관 간단 설명]
- 분량: [에피소드 목표 분량]
- 총 화수: [목표 화수]

## 주인공

- 이름: [이름]
- 설명: [성격, 외형, 배경 등]

## 핵심 컨셉

[2~3줄로 이 소설의 핵심을 설명]

## 진행

1. 주요 캐릭터 3~5명 제안
2. 핵심 약속 3개와 아크 구성 제안
3. story-consultant 평가 수행. GO가 나오면 다음으로
4. `claude-novel-templates-lean/` 구조대로 프로젝트 생성
5. `settings/01-style-guide.md`, `03-characters.md`, `05-continuity.md`, `07-periodic.md` 정밀 점검
6. `/oag-check plan` + `/why-check plan` 실행
7. 교차 검증 수행
8. git 초기화 및 첫 커밋
9. 에피소드 집필은 하지 않는다
```

---

## 프롬프트 3: 풀 자동

빠르게 테스트하고 싶을 때.

```text
claude-novel-templates-lean/ 를 참고해서 새 [장르] 소설 프로젝트를 자동으로 셋업해줘.

조건:
- 장르: [장르]
- 톤: [자유 또는 지정]
- 총 화수: [목표 화수]
- 분량: [목표 분량 또는 기본값]

나에게 중간 질문을 최소화하고 네 판단으로 진행해라.
다만 에피소드 본문은 쓰지 마라.

아래를 전부 수행해라:
- 컨셉 제안
- story-consultant 평가
- 프로젝트 생성
- settings 정밀 점검
- `/oag-check plan` + `/why-check plan`
- 교차 검증
- git 초기화

마지막에는:
- 어떤 소설을 만들었는지
- 남은 리스크가 무엇인지
- 바로 집필 가능한지

를 요약해라.
```

---

## 프롬프트 4: 기존 소설 복제

설정은 유지하고 새 프로젝트만 따로 만들고 싶을 때.

```text
no-title-[원본 번호]/ 소설의 설정을 복제해서 새 프로젝트를 만들어줘.

## 복제 대상

- 원본: no-title-[번호]
- 복제할 것:
  - `CLAUDE.md`
  - `settings/`
  - `.claude/agents/`
  - `.claude/commands/`
  - `plot/master-outline.md`
  - `plot/foreshadowing.md`
- 복제하지 않을 것:
  - `chapters/` 본문
  - `EDITOR_FEEDBACK*`
  - 진행 중인 summary 상태

## 변경 사항

- 새 폴더명: no-title-[새 번호] (자동 결정)
- 새 프로젝트 경로에 맞게 문서 내부 경로와 변수 갱신
- `batch-supervisor.md` 변수 재작성
- 필요하면 `CLAUDE.md`의 제목/작성자/분량 정보 갱신

## 완료 후

- settings 정밀 점검
- 운영 정합성 검증 (`CLAUDE.md ↔ settings/07-periodic.md ↔ batch-supervisor.md`)
- git 초기화
- 최종 상태 요약

에피소드 집필은 하지 마라.
```

---

## 셋업 후 집필 시작

프로젝트 생성이 끝나면 두 가지 경로가 있다.

### 방법 A: 직접 집필

```bash
cd /root/novel/no-title-XXX
claude
```

대화창에서:

```text
1화 작성해줘.
```

### 방법 B: 감독자 배치 집필

```bash
cd /root/novel
claude
```

대화창에서:

```text
no-title-XXX/batch-supervisor.md 규칙에 따라 감독해줘.
```

---

## 참고

- 시나리오가 마음에 들지 않으면 "다시", "이 시나리오와 저 시나리오를 섞어"처럼 수정 요청하면 된다.
- settings는 생성 직후 한 번 더 읽고 다듬는 것이 좋다. 특히 `01-style-guide`, `03-characters`, `05-continuity`, `07-periodic`.
- `settings/`의 세부 규칙이 `CLAUDE.md`의 일반 원칙보다 더 구체적이면 settings가 우선한다.
- 셋업 단계에서 구멍을 막는 비용이 집필 후 수정 비용보다 훨씬 낮다. `/oag-check plan`과 `/why-check plan`은 생략하지 않는 편이 좋다.
