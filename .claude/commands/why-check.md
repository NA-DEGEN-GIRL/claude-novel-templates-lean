"왜?", "어떻게?" 질문을 생성하고, 본문에 답이 있는지 검사한다. 설정 구멍/플롯 홀 탐지.

## 사용법

`/why-check` 또는 `/why-check arc-03` 또는 `/why-check 41-51`

- 인자 없음: 전체 소설 검사
- 아크/범위 지정: 해당 구간만 검사

## 실행

1. `.claude/agents/why-checker.md`를 읽고 지시에 따른다.
2. **settings/, plot/, summaries/는 읽지 않는다.** 독자가 아는 것만으로 판단.
3. 산출물: `summaries/why-check-report.md`
