한국어 자연스러움만 전수 검사한다. full audit의 Phase 2.5만 독립 실행.

## 사용법

`/naturalness` 또는 `/naturalness N-M`

- 인자 없음: 전체 에피소드 검사
- 범위: 해당 화수만 검사

## 실행

1. `.claude/agents/korean-naturalness.md`를 읽고 지시에 따른다.
2. 대상 에피소드를 순서대로 읽으며, 원어민이 어색하게 느낄 표현을 찾는다.
3. 결과를 `summaries/naturalness-report.md`에 저장한다.
4. 이미 `summaries/full-audit-report.md`가 있으면, 해당 보고서의 "자연스러움" 섹션을 갱신한다.
