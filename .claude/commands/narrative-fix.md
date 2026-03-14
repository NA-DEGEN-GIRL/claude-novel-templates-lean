서사 리뷰 보고서를 기반으로 서사 품질을 수정한다.

## 사용법

`/narrative-fix` 또는 `/narrative-fix C1` 또는 `/narrative-fix C1,H1,H2`

- 인자 없음: 보고서의 전체 수정 항목을 우선순위순 처리
- 항목 지정: 특정 항목만 수정 (예: C1 = CRITICAL 1번)

## 실행

1. `summaries/narrative-review-report.md`가 없으면 `/narrative-review`를 먼저 실행하라고 안내.
2. `.claude/agents/narrative-fixer.md`를 읽고 지시에 따른다.
3. 수정 전 계획을 사용자에게 보여주고 승인을 받는다.
4. **본문을 절대 과도하게 수정하지 않는다** — 최소한의 변경으로 진단된 문제를 해결한다.
5. 산출물: 수정된 에피소드 + `summaries/narrative-fix-log.md`
