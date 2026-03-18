# 기존 템플릿 → Lean 마이그레이션 프롬프트

> 기존 12-agent 템플릿으로 만든 소설 프로젝트를 lean 9-agent 템플릿으로 전환한다.
> `/root/novel/`(상위 폴더)에서 Claude Code를 열고 아래 프롬프트를 붙여넣는다.

---

## 사용법

```bash
cd /root/novel && claude
```

아래 프롬프트를 붙여넣는다.

---

## 프롬프트

```
claude-novel-templates-lean/ 을 참고해서 no-title-{XXX}/ 소설 프로젝트를 lean 템플릿으로 마이그레이션해줘.

## 절대 금지

- `chapters/` 본문은 **어떤 경우에도 수정하지 마라.**
- 기존 소설의 설정, 캐릭터, 고유 규칙, 세계관 의미를 바꾸지 마라.
- `summaries/` 기존 내용을 삭제하거나 재서술하지 마라. 필요한 새 필드만 추가하라.
- old 템플릿의 placeholder 방식으로 덮어쓰지 마라. 이미 채워진 값을 lean 구조에 재배치하라.

## 마이그레이션 목표

- `CLAUDE.md`를 lean 구조(§1~§10)로 재편한다.
- `settings/`는 규칙을 유지한 채 영어 지시문으로 전환한다. 한국어 예시/호칭/고유 용어는 유지.
- 에이전트/커맨드 참조를 lean 체계(9 에이전트 + 9 커맨드)로 업데이트한다.
- lean의 신규 파일과 섹션을 추가한다.
- `batch-supervisor.md`를 lean 운영 절차(why-check 통합, 아크 전환)에 맞게 갱신한다.
- 결과물이 **기존 소설 프로젝트로서 계속 운영 가능**해야 한다.

## 진행 방식 (12단계)

### 1단계: 사전 백업 + 인벤토리
먼저 아래를 표로 정리해라 (파일 수정 금지):
- 현재 프로젝트 파일 구조
- old 에이전트/커맨드 목록
- 소설 고유 설정 목록 (캐릭터, 세계관, 저주 체계 등 특수 규칙)
- lean에서 새로 생기는 파일/섹션 목록
- old → lean 매핑표

git에서 마이그레이션 전 커밋을 확인하거나, 필요 시 백업 브랜치를 생성한다.

### 2단계: 마이그레이션 계획 수립
수정/생성/삭제할 파일을 체크리스트로 만들어 보여준다.
위험 요소와 롤백 기준도 명시한다.
**사용자 승인 후 진행.**

### 3단계: lean 골격 반영
lean 템플릿에서 아래를 복사/적용:
- `.claude/agents/` (9종)
- `.claude/commands/` (9종)
- `settings/08-illustration.md` (없으면 생성)
- `settings/07-periodic.md` (lean 기준으로 교체)
- `batch-supervisor.md`

**기존 소설 고유 파일은 건드리지 않는다.**

### 4단계: CLAUDE.md 재구성
기존 `CLAUDE.md`의 채워진 정보를 lean 구조로 옮긴다:
- Language Contract (신규 추가)
- §1 Project Overview + §1.1 Core Promises
- §2 Folder Structure
- §3 Writing Workflow (compile_brief 기반)
- §4 File Reference Priority
- §5 Prohibitions + §5.1 Intentional Mysteries (신규: 의도적 비밀 테이블)
- §6 AI Execution Guardrails (신규: 과정 제약 3개)
- §7 Episode Metadata
- §8 Cover & Illustrations
- §9 대화 관계 규칙 (호칭 매트릭스)
- §10 Customization Notes

**기존 금지 사항, 핵심 약속, 캐릭터 호칭을 누락 없이 보존한다.**

### 5단계: settings 영어 전환
각 `settings/*.md`를 다음 원칙으로 변환:
- 지시문/헤더 → 영어
- 한국어 예시, 호칭 규칙, 고유 용어 → 유지
- 규칙 추가/삭제 없이 의미 보존
- 외래어 관련: lean style-guide 헤더 규칙 추가 ("예시가 CLAUDE.md 금지사항 위반하면 버그")

### 6단계: 에이전트/커맨드 참조 교체
프로젝트 전체에서 구 에이전트명을 검색하여 lean 명칭으로 치환:
- `summary-validator` → `unified-reviewer`
- `continuity-checker` → `unified-reviewer`
- `gemini-feedback` → `unified-reviewer` + `review_episode` MCP
- `korean-proofreader` → `korean-naturalness`
- `summary-generator` → writer 인라인 갱신
- 기타 구 참조 → lean 대응

### 7단계: summaries 스키마 점검
기존 내용 보존. lean에서 필요한 필드만 추가:
- `explained-concepts.md`: "초기 필수 설명 대상" 섹션 (필요 시)
- `why-check-report.md`: 파일 경로 확보
- EPISODE_META 형식이 lean과 일치하는지 확인 (일치하지 않으면 메타만 보정)

### 8단계: 운영 문서 갱신
- `batch-supervisor.md`: why-check 통합, 아크 전환 절차, 최종 완결 파이프라인
- 아크 매핑(ARC_MAP) 현재 소설에 맞게 설정

### 9단계: 정적 검증 (자동)
다음을 자동 점검:
- [ ] `chapters/` diff 없음 (git diff로 확인)
- [ ] old 에이전트/커맨드 참조 잔존 없음 (grep으로 전수 검색)
- [ ] dead link / 누락 파일 없음
- [ ] CLAUDE.md 섹션 1~10 전부 존재
- [ ] settings/ 파일 수 일치

체크리스트로 보고한다.

### 10단계: GPT 5.4 의미 검증
GPT 5.4에게 다음을 검토시킨다 (`mcp__external-ai__ask_gpt` 사용):

"no-title-{XXX} 소설의 old→lean 마이그레이션 결과를 검토해주세요.
old CLAUDE.md와 lean CLAUDE.md를 비교하여:
1. 의미가 보존되었는가 (규칙 변경이 아닌 구조 변경인가)
2. 누락된 규칙이 있는가
3. 한국어 예시가 손상되었는가
4. 운영 리스크가 있는가 (집필 진행 중이라면 다음 화 집필에 문제 없는가)
High / Medium / Low로 정리해주세요."

검토 결과를 반영한다.

### 11단계: 내부 agent 검증 (상황별)

#### 집필 진행 중인 소설:
- `unified-reviewer`: 최신 1화를 샘플로 읽게 해서 새 참조 체계 작동 확인
- `/why-check plan`: 다음 아크 플롯에 적용 (있으면)
- `/why-check`: 가장 최근 완결 아크에 실행 (선택)

#### 완결 소설:
- `/why-check full`: 전체 전수 검사
- `/book-review`: Claude 독자 평가
- `/book-review-gpt`: GPT 독자 평가
- `/narrative-review`: 서사 품질 리뷰 (Phase 4 교차 검증 포함)

에이전트 실행 전에 목적과 기대 산출물을 먼저 적어라.

### 12단계: 최종 보고 + 커밋
마이그레이션 결과 보고서:
1. 수정 파일 목록
2. 신규 파일 목록
3. 정적 검증 결과 (9단계)
4. GPT 검토 결과 (10단계)
5. 내부 agent 검증 결과 (11단계)
6. 남은 수동 확인 항목
7. 롤백 정보 (이전 커밋 해시)

git commit 2단계:
- 소설 폴더: `{소설명} lean 마이그레이션 완료`
- 상위 레포: config.json 변경 시만

**중요:**
- 본문 불변 원칙을 마지막에도 `git diff chapters/`로 재확인하라.
- 집필 진행 중 소설: "다음 아크부터 바로 운영 가능한 상태"가 목표.
- 완결 소설: "lean 기준 전체 검토 가능 상태"가 목표.
```

---

## 참고: old → lean 에이전트 매핑

| old 에이전트 | lean 대응 |
|-------------|-----------|
| writer | **writer** (compile_brief 기반, 인라인 요약) |
| reviewer | **unified-reviewer** (3모드 통합) |
| continuity-checker | unified-reviewer continuity 모드 |
| korean-proofreader | **korean-naturalness** |
| gemini-feedback | `review_episode` MCP + unified-reviewer |
| summary-generator | writer 인라인 갱신 (D단계) |
| full-audit | **full-audit** (1M 컨텍스트) |
| audit-verifier | full-audit 내부 |
| audit-fixer | `/audit-fix` 커맨드 |
| (없음) | **story-consultant** (INIT 시 컨셉 평가) |
| (없음) | **narrative-reviewer** (서사 리뷰 + Phase 4 교차 검증) |
| (없음) | **narrative-fixer** (S1~S6 + E1~E4 이중 모드) |
| (없음) | **book-reviewer** (독자 평가) |
| (없음) | **why-checker** (설명 누락 탐지) |

---

## 참고: 마이그레이션 후 신규 기능

| 기능 | 설명 |
|------|------|
| `/why-check` | 설명 누락 탐지 (아크 전환/완결 시) |
| `/why-check plan` | 플롯 사전 검증 (집필 전) |
| `/narrative-fix --source why-check` | 경량 설명 보강 (1~3문장) |
| `/book-review` + `/book-review-gpt` | 독자 관점 평가 (reader 파싱용 포맷) |
| narrative-review Phase 4 | 교차 검증 (book-review + why-check 참조) |
| CLAUDE.md §5.1 | 의도적 비밀 테이블 |
| CLAUDE.md §6 | AI 실행 가드레일 |
| Reader Onboarding | 세계관 용어 설명 우선순위 |

---

## 롤백

마이그레이션 실패 시:
1. `git log`에서 마이그레이션 전 커밋 확인
2. `git checkout {hash} -- .` (chapters/ 제외한 모든 파일 복원)
3. 또는 백업 브랜치에서 복원
