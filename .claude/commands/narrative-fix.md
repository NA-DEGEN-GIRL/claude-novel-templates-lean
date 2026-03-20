서사 리뷰 또는 WHY-CHECK 보고서를 기반으로 수정한다.

## 사용법

```
/narrative-fix                    # narrative-review 보고서 기반 (기본)
/narrative-fix C1,H1,H2          # 특정 항목만 수정
/narrative-fix --source why-check # why-check 보고서 기반 (경량 모드)
/narrative-fix --source why-check --scope priority-6+  # 고우선도만
/narrative-fix --source why-check --items MISS-01,MISS-03  # 특정 항목만
/narrative-fix --source why-check --promote --items INF-02  # INFERABLE 항목 승격 수정
```

## 두 가지 모드

### 기본 모드 (narrative-review 기반)
- 입력: `summaries/narrative-review-report.md`
- 전략: S1~S6 (구조적 서사 수정)
- 범위: 제한 없음 (다화 수정, 장면 재구성 가능)

### WHY-CHECK 모드 (`--source why-check`)
- 입력: `summaries/why-check-report.md` (또는 `why-check-report-final.md`)
- 전략: E1~E4 (경량 설명 보강 — 아래 참조)
- 범위: **항목당 1~3문장, 단일 화수, 기존 장면 내부 삽입만**
- MISSING만 기본 대상. INFERABLE은 `--promote` 시만.
- CLAUDE.md §5.1 (의도적 비밀) 해당 항목은 자동 스킵.
- 한도 초과 시 `HOLD` → 다음 `/narrative-review` 이관.

## 실행

1. 해당 보고서 파일이 없으면 `/narrative-review` 또는 `/why-check`를 먼저 실행하라고 안내.
2. `.claude/agents/narrative-fixer.md`를 읽고 지시에 따른다.
3. 수정 전 계획을 사용자에게 보여주고 승인을 받는다.
4. **본문을 절대 과도하게 수정하지 않는다** — 최소한의 변경으로 진단된 문제를 해결한다.
5. 산출물: 수정된 에피소드 + `summaries/narrative-fix-log.md` (기본) 또는 `summaries/why-fix-log.md` (WHY-CHECK 모드)
