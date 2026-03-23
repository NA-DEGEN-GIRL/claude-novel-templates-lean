# Parallel Writing & Periodic Checks

> Claude lean의 정기 점검 규약. 매 화 unified-review가 잡지 못하는 누적 드리프트를 제어한다.

**Language Contract: All narrative output, summaries, and review text MUST be in Korean.**

---

## 1. Post-Parallel-Writing Consistency Check

동시 집필 또는 summary 지연이 있었으면, 병렬 작성 종료 후 아래 절차를 강제한다.

### Parallel Writing Criteria

- 여러 agent/session이 다른 화를 동시에 집필
- 연속 화가 존재하지만 summary가 뒤늦게 갱신됨
- 사용자가 병렬 집필 중이라고 명시

### Per-Agent Rules

- 각 작성자는 자신의 할당 범위 안에서 초안과 1차 self-review를 끝낸다.
- 병렬 작성 중에는 summary 충돌을 막기 위해 필수 summary 갱신을 마지막 reconciliation까지 미뤄도 된다.
- `EPISODE_META`는 각 화에 정상 삽입한다.

### Reconciliation

1. 낮은 화수부터 높은 화수 순으로 본문 연결 확인
2. higher episode를 lower episode에 맞춰 조정
3. `running-context.md`, `episode-log.md`, `character-tracker.md`를 화수 순으로 일괄 갱신
4. `review-log.md`와 `action-log.md`에 병렬 정리 결과 기록

---

## 2. Periodic Checks

### Trigger

- 기본 5화 단위
- 최대 8화 초과 금지
- 아크 전환에서는 무조건 실행
- 드리프트 징후가 있으면 조기 실행

### Review Floors

- 1화 또는 새 아크 첫 화: `full`
- 5화 배수: `standard`
- 아크 마지막 화: `standard + arc transition package`

### Check Items

Core 항목은 매번 실행한다. Optional은 관련이 있을 때만 수행한다.

| # | Item | Type | Method |
|---|---|---|---|
| P1 | Summary consistency | Core | 최근 점검 이후 화수의 본문과 `running-context`, `episode-log`, `character-tracker` 불일치 탐지 |
| P2 | Foreshadowing deadlines | Optional | `plot/foreshadowing.md`에서 회수 시점 경과 여부 확인 |
| P3 | Character state freshness | Core | `character-tracker.md`가 최신 화 종료 상태를 반영하는지 확인 |
| P4 | Unfulfilled promises | Optional | `promise-tracker.md`에서 과잉 유예 또는 방치 약속 탐지 |
| P5 | running-context hygiene | Optional | `running-context.md`가 과팽창하지 않았는지, 다음 화 런웨이가 선명한지 확인 |
| P6 | Personality drift vs growth | Core | 성격 변화가 사건 기반인지 확인. 일시적 퇴행도 사건 근거가 있으면 허용 |
| P7 | WHY/HOW + motivation-action gap | Core | 최근 5화 재독으로 설명 갭, 동기/행동 갭, OAG 의심 탐지 |
| P8 | External AI batch review | Optional | `mcp__novel_editor__batch_review` 또는 `review_episode`로 일괄 리뷰. CLAUDE.md 플래그에서 켠 소스만 대상 |
| P9 | POV / era / scene logic | Optional | 시점 지식 위반, 시대 부적합 표현, 장면 물리 논리 점검 |
| P10 | Cross-episode repetition | Core | 어구/감정 처리/정보 재노출/엔딩 훅 반복 패턴 탐지 |
| P11 | Korean naturalness | Core | 번역투, 호응, 템포 저하, 장면별 어색한 문장 정리 |
| P12 | Meta-reference prohibition | Core | 본문 속 `몇 화에서`, `프롤로그에서`, `1부에서` 금지 표현 탐지 |
| P13 | Thematic progress | Core | 최근 5화의 `thematic_function`이 주제 진행을 만들고 있는지 확인 |

### Mandatory Order

정기 점검 수정은 아래 순서로 한다.

1. summary consistency
2. fact / continuity
3. WHY/HOW + motivation-action
4. POV / era / scene logic
5. repetition
6. Korean naturalness
7. external AI review reconciliation
8. summary re-sync

### Post-Check Actions

1. patch-feasible 항목은 즉시 수정
2. 구조 수정이 필요한 항목은 `review-log.md`에 HOLD 기록
3. `running-context.md`를 현재 상태로 갱신
4. 반복 패턴이 발견되면 `repetition-watchlist.md` 갱신
5. `action-log.md`에 점검 결과 append
6. commit 메시지 예시: `{소설명} {N}~{M}화 정기 점검 완료`

---
