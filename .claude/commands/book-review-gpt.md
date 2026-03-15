GPT 5.4로 소설을 독자 관점에서 리뷰한다. Claude가 오케스트레이션하고, GPT가 읽고 평가한다.

## 사용법

`/book-review-gpt`

## 왜 GPT로?

Claude book-review와 다른 관점을 제공한다. 두 리뷰를 비교하면 균형 잡힌 평가가 된다.

## 실행 절차

### Step 1: 아크 구조 파악

chapters/ 폴더에서 아크별 에피소드 파일을 수집하고, 각 아크의 문자 수를 확인한다.

### Step 2: 순차 아크 리뷰 (GPT 5.4)

**반드시 순차 실행한다. 병렬 금지.** 이전 아크 요약이 다음 아크의 맥락이 되므로.

각 아크에 대해:

```bash
CONTENT=$(cat chapters/{arc}/*.md)
PREV_SUMMARY="{이전 아크까지의 누적 요약}"

codex exec -m gpt-5.4 "
You are reviewing a Korean novel arc by arc. This is ARC {N}.

Previous arcs summary:
${PREV_SUMMARY}

Read the text below as a READER. After reading, provide:
1. 아크 요약 (3-4문장)
2. 읽다가 걸린 순간 (어색하거나 뜬금없었던 것)
3. 읽다가 빨라진 순간 (몰입된 곳)
4. 아크 점수 (/10)
5. 가장 인상적인 대사 1개 인용

Write in Korean. Be honest and specific.

---
${CONTENT}
"
```

- 첫 번째 아크: PREV_SUMMARY 없이 실행
- 두 번째 아크부터: 이전 아크의 "아크 요약"을 PREV_SUMMARY에 누적
- 마지막 아크: 추가로 "6. 끝나고 남은 감정"도 요청

### Step 3: 통합 리뷰 (GPT 5.4)

모든 아크 리뷰를 모아서 GPT 5.4에 최종 통합 리뷰를 요청한다:

```bash
codex exec -m gpt-5.4 "
You reviewed the Korean novel '{title}' arc by arc. Here are your arc reviews.
Now write a UNIFIED book review in Korean.

{아크별 리뷰 전부}

Write the unified review with:
1. 📖 한줄 소개
2. ⭐ 종합 점수
3. 🎯 추천 대상 / ⛔ 비추 대상
4. 💬 한마디 (감정적 독후감 1문장)
5. 총평 (3문장)
6. 아크별 점수 테이블
7. 강점 (top 3, 구체적 인용 포함)
8. 약점 (top 3)
9. 읽다가 걸린 순간 vs 빨라진 순간 (전체 통합)
10. 비교 작품
11. 가장 크게 거슬린 문제 1개

Write entirely in Korean. Be honest, specific, quote memorable lines.
"
```

### Step 4: 저장

결과를 `summaries/book-review-gpt.md`에 저장한다. 아크별 상세 리뷰도 하단에 포함.

## 주의

- settings/, plot/, summaries/는 GPT에 보내지 않는다. 본문만.
- 이전 아크 요약은 GPT가 직접 쓴 것만 사용 (Claude가 요약하지 않음)
- codex exec 호출이 실패하면 재시도 1회. 2회 실패 시 해당 아크 스킵하고 다음으로.
