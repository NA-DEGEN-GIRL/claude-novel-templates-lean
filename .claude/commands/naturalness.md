한국어 자연스러움만 전수 검사한다. full audit의 Phase 2.5만 독립 실행.

## 사용법

`/naturalness` 또는 `/naturalness N-M`

- 인자 없음: 전체 에피소드 검사
- 범위: 해당 화수만 검사

## 실행 방식 (핵심)

> **각 에피소드마다 별도의 Agent를 호출한다.**
> 하나의 Agent가 여러 화를 연속 처리하면 주의력이 떨어져서 어색한 표현을 놓친다. (테스트 완료: 연속 처리 시 0/51 감지, 개별 호출 시 3/3 감지)

절차:

1. 에피소드 파일 목록을 수집한다 (chapters/**/*.md, 번호순 정렬)
2. **각 에피소드마다** 아래를 반복:
   ```
   Agent(korean-naturalness: {N}화 검사)
   → .claude/agents/korean-naturalness.md를 읽고
   → chapters/{arc}/chapter-{N}.md 1개만 읽고
   → 어색한 표현을 찾아 보고
   ```
3. 각 Agent의 결과를 수집하여 `summaries/naturalness-report.md`에 통합 저장. **모든 에피소드의 상세 테이블(위치, 원문, 왜 어색한가, 수정안)을 빠짐없이 포함한다.** "N건" 요약만 적고 상세를 생략하거나 임시 파일을 참조하게 하지 않는다. `/naturalness-fix`가 이 보고서만 보고 수정하므로, 상세가 없으면 수정 불가.
4. 이미 `summaries/full-audit-report.md`가 있으면, 해당 보고서의 "자연스러움" 섹션도 갱신

## 주의

- **절대로 한 Agent가 여러 화를 처리하지 않는다.**
- Agent 호출 시 해당 화 파일 경로를 명시한다.
- 동시에 여러 Agent를 병렬 실행해도 된다 (각각 1화만 담당하므로).
- 각 Agent는 `.claude/agents/korean-naturalness.md`를 독립적으로 읽고 수행한다.
