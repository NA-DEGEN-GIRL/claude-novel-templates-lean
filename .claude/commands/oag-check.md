캐릭터가 정보를 알면서도 당연한 행동을 하지 않는 의무 행동 갭(OAG)을 탐지한다.

## 사용법

```
/oag-check                  # 전체 소설
/oag-check arc-01           # 특정 아크만
/oag-check 1-5              # 범위 지정
```

## 실행

1. `.claude/agents/oag-checker.md`를 읽고 지시에 따른다.
2. `settings/03-characters.md`에서 캐릭터 성격을 읽는다.
3. 에피소드 본문을 순서대로 읽으며 결정 노드를 추출한다.
4. **Generate-Then-Check**: 기대 행동을 먼저 생성하고, 그 다음 텍스트에서 확인한다.
5. 산출물: `summaries/oag-report.md`
