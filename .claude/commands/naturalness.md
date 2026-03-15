한국어 자연스러움만 전수 검사한다. full audit의 Phase 2.5만 독립 실행.

## 사용법

`/naturalness` 또는 `/naturalness N-M`

- 인자 없음: 전체 에피소드 검사
- 범위: 해당 화수만 검사

## 실행

1. `.claude/agents/korean-naturalness.md`를 읽고 지시에 따른다.
2. **반드시 1화씩 순차 실행한다. 배치/병렬 처리 금지.** 한 에피소드를 읽고, 검사하고, 결과를 기록한 후 다음 에피소드로 넘어간다. 여러 화를 한번에 묶어서 검사하면 주의가 분산되어 어색한 표현을 놓친다.
3. 결과를 `summaries/naturalness-report.md`에 저장한다.
4. 이미 `summaries/full-audit-report.md`가 있으면, 해당 보고서의 "자연스러움" 섹션을 갱신한다.
