# workflow-plugin `feature` 구현 계획

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** 네이티브 개발부서의 워크플로우를 구조적으로 조형하는 Claude Code 플러그인을 구현한다. `feature` 커맨드, Spec 형식 템플릿, `spec-writing` skill을 포함한다.

**Architecture:** Claude Code 플러그인 규격(`.claude-plugin/plugin.json`, `skills/`, `templates/`)을 따른다. 모든 구성 요소는 마크다운 기반 프롬프트 지시문으로 Claude의 행동을 제어한다. `feature` skill이 Spec 중심 파이프라인을 강제하고, `spec-writing` skill이 대화형 탐색으로 Spec 작성을 안내하며, Spec 템플릿이 15개 섹션 × 4그룹의 계약 기반 형식을 정의한다.

**Tech Stack:** Claude Code Plugin (마크다운 skill/command), YAML frontmatter, Git

**참조 설계:** `docs/superpowers/specs/2026-04-12-workflow-plugin-feature-design.md`

---

## 파일 구조

```
workflow-plugin/
├── .claude-plugin/
│   └── plugin.json              # 플러그인 메타데이터
├── package.json                 # npm 호환 메타데이터
├── skills/
│   ├── feature/
│   │   └── SKILL.md             # feature 파이프라인 skill (메인)
│   └── spec-writing/
│       └── SKILL.md             # Spec 작성 대화형 탐색 skill
├── templates/
│   └── spec-template.md         # Spec 형식 템플릿 (15섹션, 4그룹)
├── CLAUDE.md                    # 프로젝트 지침 (수정)
└── docs/
    └── superpowers/
        ├── specs/               # 설계 문서
        └── plans/               # 구현 계획
```

각 파일의 책임:
- **`.claude-plugin/plugin.json`**: 플러그인 이름, 설명, 버전, 작성자. Claude Code가 플러그인을 인식하는 진입점.
- **`package.json`**: npm 호환 메타데이터. 버전 관리용.
- **`skills/feature/SKILL.md`**: `feature` 커맨드의 본체. Spec 중심 파이프라인의 전체 흐름(Spec 작성 → 승인 → 계획 → TDD 판단 게이트 → 구현 → 검증 → 완료), Spec 상태 머신, Spec ↔ 코드 일치 게이트를 정의.
- **`skills/spec-writing/SKILL.md`**: 대화형 탐색으로 Spec을 작성하는 skill. 맥락 파악 후 질문을 판단해서 던지고, 최종 산출물을 Spec 템플릿 형식으로 수렴.
- **`templates/spec-template.md`**: Spec 문서의 정확한 형식. 두 skill이 모두 이 템플릿을 참조하여 일관된 Spec을 생성.
- **`CLAUDE.md`**: 이 플러그인이 설치된 프로젝트에서 Claude가 따를 지침.

---

## Task 1: 플러그인 스캐폴딩

**Files:**
- Create: `.claude-plugin/plugin.json`
- Create: `package.json`

- [ ] **Step 1: `.claude-plugin/plugin.json` 생성**

```json
{
  "name": "workflow-plugin",
  "description": "Spec-driven workflow plugin for native development teams. Structures feature development through a fixed pipeline with spec-as-SOT, TDD judgment gates, and spec-code alignment enforcement.",
  "version": "0.1.0",
  "author": {
    "name": "Native Dev Team"
  },
  "keywords": [
    "workflow",
    "spec-driven",
    "sdd",
    "tdd",
    "native",
    "onboarding"
  ]
}
```

- [ ] **Step 2: `package.json` 생성**

```json
{
  "name": "workflow-plugin",
  "version": "0.1.0"
}
```

- [ ] **Step 3: 커밋**

```bash
git add .claude-plugin/plugin.json package.json
git commit -m "chore: scaffold plugin metadata"
```

---

## Task 2: Spec 템플릿

**Files:**
- Create: `templates/spec-template.md`

- [ ] **Step 1: `templates/spec-template.md` 생성**

```markdown
---
id: SPEC-XXX
title: 기능명
status: draft
superseded_by:
related_specs: []
author: 작성자
created: YYYY-MM-DD
updated: YYYY-MM-DD
---

# ── 정의 ──

# 1. 목적 (Purpose)

이 기능이 존재하는 이유.

# 2. 용어 정의 (Glossary)

| 용어 | 정의 |
|---|---|

# 3. 전제 (Assumptions)

이 Spec이 성립하기 위해 참이어야 하는 조건.

-

# 4. 외부 의존성 (Dependencies)

| 대상 | 유형 | 버전/조건 | 장애 시 영향 |
|---|---|---|---|

# ── 계약 ──

# 5. 행위 명세 (Behavior)

기능의 동작 정의.

## 정상 흐름

-

## 경계 조건

-

# 6. 에러 처리 (Error Handling)

| 에러 유형 | 복구 전략 | 사용자 피드백 | 로깅 기준 |
|---|---|---|---|

# 7. 범위 (Scope)

## 포함

-

## 제외

-

# 8. 제약 (Constraints)

-

# 9. 성능 기준 (Performance Criteria)

| 항목 | 기준 | 측정 방법 |
|---|---|---|

# ── 실현 ──

# 10. 기술 설계 (Technical Design)

## 10.1 구조

- 모듈 / 클래스 / 파일 구성
- 의존 관계

## 10.2 인터페이스

- 공개 API / 함수 시그니처 / 프로토콜
- 데이터 구조 (입출력 타입)

## 10.3 흐름

- 호출 순서 / 데이터 흐름
- 상태 전이

# 11. 플랫폼별 차이 (Platform Notes)

## iOS

-

## Android

-

# 12. 마이그레이션 (Migration)

- 전환 단계
- 하위 호환성
- 롤백 방법

# ── 보증 ──

# 13. 테스트 전략 (Test Strategy)

## 단위 테스트

-

## 통합 테스트

-

## E2E / UI 테스트

-

# 14. 수락 기준 (Acceptance Criteria)

- [ ]

# 15. 변경 이력 (Changelog)

| 날짜 | 변경 내용 | 사유 |
|---|---|---|
```

- [ ] **Step 2: 커밋**

```bash
git add templates/spec-template.md
git commit -m "feat: add spec template with 15 sections in contract-based grouping"
```

---

## Task 3: `spec-writing` skill

**Files:**
- Create: `skills/spec-writing/SKILL.md`

- [ ] **Step 1: `skills/spec-writing/SKILL.md` 생성**

```markdown
---
name: spec-writing
description: "Spec 작성을 대화형 탐색으로 안내하는 skill. 개발자의 맥락을 파악한 뒤 필요한 질문을 판단해서 던지고, 최종 산출물을 15섹션 계약 기반 Spec 형식으로 수렴한다."
---

# Spec Writing

대화형 탐색으로 Spec(소스코드의 SOT)을 작성한다.

## 핵심 원칙

- **Spec = SOT.** 이 skill이 생성하는 Spec은 소스코드의 단일 진실 공급원이다. 코드는 Spec을 따르고, Spec과 다르면 코드가 틀리거나 Spec이 먼저 개정되어야 한다.
- **구조는 고정, 깊이는 가변.** 모든 Spec은 동일한 15개 섹션(4그룹)을 가진다. 가벼운 작업이면 각 섹션이 한 줄, 복잡한 작업이면 상세하게. 압축은 가능, 스킵은 불가.
- **대화형 탐색.** 섹션 순서를 강제하지 않는다. 맥락에 따라 필요한 질문을 판단해서 던진다.

## 동작 흐름

1. **맥락 파악:** 개발자의 초기 설명에서 목적, 도메인, 기술적 배경을 파악한다.
2. **탐색 질문:** 부족한 정보를 판단하여 질문한다. 한 번에 하나씩. 가능하면 다지선다로.
3. **섹션 배치:** 수집된 정보를 Spec 형식의 각 섹션에 배치한다. 내부적으로 추적하되, 개발자에게 섹션 번호를 강요하지 않는다.
4. **완성도 검증:** 모든 15개 섹션이 채워졌는지 확인한다. 부족한 섹션이 있으면 해당 맥락으로 추가 질문.
5. **Spec 생성:** 완성된 정보를 아래 Spec 형식으로 문서화한다. status는 `draft`.

## Spec 형식

Spec은 정확히 아래 구조를 따른다. `templates/spec-template.md`를 참조하여 생성한다.

### 그룹과 섹션

**정의 (Definition):**
1. 목적 (Purpose) — 이 기능이 존재하는 이유
2. 용어 정의 (Glossary) — Spec 내 도메인 용어의 정의
3. 전제 (Assumptions) — Spec이 성립하기 위해 참이어야 하는 조건
4. 외부 의존성 (Dependencies) — 의존하는 외부 시스템, SDK, API

**계약 (Contract):**
5. 행위 명세 (Behavior) — 기능의 동작 정의 (입출력, 정상 흐름, 경계 조건)
6. 에러 처리 (Error Handling) — 실패 시 동작 정의
7. 범위 (Scope) — 포함 / 제외
8. 제약 (Constraints) — 보안, 호환성, 규정 등
9. 성능 기준 (Performance Criteria) — 측정 가능한 수치 기준

**실현 (Realization):**
10. 기술 설계 (Technical Design) — 구조, 인터페이스, 흐름
11. 플랫폼별 차이 (Platform Notes) — iOS / Android 간 구현 차이
12. 마이그레이션 (Migration) — 전환 단계, 하위 호환성, 롤백

**보증 (Assurance):**
13. 테스트 전략 (Test Strategy) — 단위/통합/E2E 테스트 계획
14. 수락 기준 (Acceptance Criteria) — 체크리스트 형식의 완료 판정 기준
15. 변경 이력 (Changelog) — 날짜, 변경 내용, 사유

### Frontmatter

```yaml
---
id: SPEC-XXX
title: 기능명
status: draft
superseded_by:
related_specs: []
author: 작성자
created: YYYY-MM-DD
updated: YYYY-MM-DD
---
```

- `id`: SPEC- 접두어 + 순번 (기존 Spec 파일을 확인하여 다음 번호 부여)
- `status`: 이 skill이 생성하는 Spec은 항상 `draft`
- `created`/`updated`: 생성 당일 날짜

## 이 skill이 하는 것

- 개발자의 초기 설명에서 맥락을 파악한다
- 부족한 정보를 판단하여 질문한다 (한 번에 하나씩)
- 수집된 정보를 15개 섹션에 배치한다
- 모든 섹션이 채워졌는지 검증한다
- Spec 문서(draft 상태)를 생성한다

## 이 skill이 하지 않는 것

- 섹션 순서를 강제하지 않는다 (질문 순서는 맥락에 따라 유동적)
- 구현 방법을 결정하지 않는다 (기술 설계 섹션은 개발자의 의견을 수집하여 작성)
- Spec을 승인하지 않는다 (승인은 `feature` skill 파이프라인의 다음 단계)
- 코드를 작성하지 않는다

## 완성도 체크리스트

Spec 생성 전 아래를 확인한다:

- [ ] 15개 섹션이 모두 존재하는가
- [ ] 각 섹션에 내용이 있는가 (해당 없음이면 "해당 없음" 명시)
- [ ] 용어 정의(Glossary)에 Spec 내 도메인 용어가 모두 정의되어 있는가
- [ ] 행위 명세(Behavior)에 정상 흐름과 경계 조건이 있는가
- [ ] 수락 기준(Acceptance Criteria)이 체크리스트 형식인가
- [ ] frontmatter의 id, title, status, author, created, updated가 모두 채워졌는가

## Spec 파일 저장 위치

`specs/SPEC-XXX-<기능명>.md` (프로젝트 루트 기준)

저장 후 개발자에게 알린다:

> "Spec을 `specs/SPEC-XXX-<기능명>.md`에 draft 상태로 생성했습니다. `feature` 파이프라인의 다음 단계(승인)로 진행하시겠습니까?"
```

- [ ] **Step 2: 커밋**

```bash
git add skills/spec-writing/SKILL.md
git commit -m "feat: add spec-writing skill for conversational spec authoring"
```

---

## Task 4: `feature` skill (파이프라인 본체)

**Files:**
- Create: `skills/feature/SKILL.md`

이 파일은 플러그인의 핵심이다. Spec 중심 파이프라인의 전체 흐름, Spec 상태 머신, TDD 판단 게이트, Spec ↔ 코드 일치 게이트를 모두 포함한다.

- [ ] **Step 1: `skills/feature/SKILL.md` 생성**

```markdown
---
name: feature
description: "Spec 중심 파이프라인으로 feature 개발을 구조적으로 조형한다. 모든 작업이 동일한 고정 파이프라인(Spec 작성 → 승인 → 계획 → TDD 판단 → 구현 → 검증 → 완료)을 통과한다. 압축은 가능, 스킵은 불가."
---

# Feature Pipeline

Spec 중심 파이프라인으로 feature 개발을 구조적으로 조형한다.

## 핵심 원칙

- **Spec = SOT.** Spec이 소스코드의 단일 진실 공급원이다.
- **구조적 조형.** 이 skill은 워크플로우 자체의 형태를 강제한다. 단계를 안내하거나 추천하는 것이 아니라, 구조를 보증한다.
- **고정 구조, 가변 깊이.** 모든 작업이 동일한 7단계 파이프라인을 통과한다. 각 단계의 밀도만 작업 규모에 따라 달라진다.

## 파이프라인

```
[1. Spec 작성] → [2. Spec 승인] → [3. 계획] → [4. TDD 판단] → [5. 구현] → [6. 검증] → [7. 완료]
    draft           approved        approved      approved      implementing  implementing    shipped
```

**이 파이프라인은 무조건 순서대로 진행한다. 어떤 단계도 건너뛸 수 없다.**

## 진입

개발자가 feature를 시작하면, 현재 Spec의 상태를 확인한다:

- Spec이 없으면 → **1단계(Spec 작성)**부터 시작
- draft 상태의 Spec이 있으면 → **2단계(Spec 승인)**부터 시작
- approved 상태의 Spec이 있으면 → **3단계(계획)**부터 시작
- implementing 상태의 Spec이 있으면 → **5단계(구현)**을 이어감

## 1단계: Spec 작성

`spec-writing` skill을 호출하여 Spec을 작성한다.

**행위:**
- `spec-writing` skill을 호출한다. 이 skill이 대화형 탐색으로 Spec 문서를 생성한다.
- Spec이 `draft` 상태로 생성되면 이 단계가 완료된다.

**산출물:** `specs/SPEC-XXX-<기능명>.md` (status: draft)

**다음 단계로의 전이 조건:** Spec 파일이 존재하고 status가 `draft`이다.

## 2단계: Spec 승인

작성된 Spec을 리뷰하고 승인한다.

**행위:**
- Spec 문서를 개발자에게 제시한다.
- 개발자에게 리뷰를 요청한다:
  > "Spec을 리뷰해주세요. 수정이 필요하면 말씀해주시고, 괜찮으면 승인해주세요."
- 수정 요청 시: Spec을 수정하고 다시 리뷰를 요청한다.
- 승인 시: Spec의 frontmatter `status`를 `approved`로 변경하고 커밋한다.

**산출물:** spec.md (status: approved)

**다음 단계로의 전이 조건:** Spec의 status가 `approved`이다.

## 3단계: 계획

Spec을 기반으로 구현 계획을 수립한다.

**행위:**
- approved 상태의 Spec을 읽는다.
- Spec의 "실현" 그룹(기술 설계, 플랫폼별 차이, 마이그레이션)을 기반으로 구현 계획을 작성한다.
- 계획은 파일 단위, 모듈 단위의 작업 분해를 포함한다.
- 개발자에게 계획을 제시하고 확인을 받는다.

**산출물:** 구현 계획 (대화 내 또는 별도 문서)

**다음 단계로의 전이 조건:** 개발자가 계획을 확인했다.

## 4단계: TDD 판단 게이트

구현 직전, TDD 적용 여부를 판단한다.

**행위:**
- 개발자에게 제안한다:
  > "구현을 시작하기 전에, 이 작업에 TDD(테스트 우선 개발)를 적용하는 것을 고려해보세요. 작업의 성격(결제, 인증, 핵심 비즈니스 로직 등)에 따라 구현 정합성을 높일 수 있습니다. TDD를 적용하시겠습니까?"
- 개발자의 판단을 기다린다.
- 판단 결과를 Spec의 변경 이력(Changelog)에 기록한다:
  - "TDD 적용 결정: 예/아니오 — 사유: [개발자의 판단 근거]"

**산출물:** Spec changelog에 TDD 판단 기록

**다음 단계로의 전이 조건:** 개발자가 TDD 적용 여부를 판단했다.

### TDD 적용 시

- 구현 단계에서 **테스트를 먼저 작성**한 후 구현 코드를 작성한다.
- Red → Green → Refactor 사이클을 따른다.
- 테스트가 Spec의 행위 명세(Behavior)와 수락 기준(Acceptance Criteria)을 검증해야 한다.

### TDD 미적용 시

- 일반 구현 순서를 따른다.
- 테스트 전략(Test Strategy) 섹션에 따라 구현 후 테스트를 작성한다.

## 5단계: 구현

Spec에 따라 코드를 작성한다.

**행위:**
- Spec의 status를 `implementing`으로 변경한다.
- TDD 선택 시: 테스트 우선 사이클로 구현한다.
- TDD 미선택 시: 일반 구현 순서를 따른다.
- 구현 중 **Spec ↔ 코드 일치 게이트**를 적용한다 (아래 참조).

**산출물:** 소스 코드, 테스트 코드

**다음 단계로의 전이 조건:** 구현이 완료되었고, Spec ↔ 코드가 일치한다.

### Spec ↔ 코드 일치 게이트

구현 중 코드가 Spec과 다르게 흘러갈 경우, 다음 중 하나를 선택해야 한다:

1. **코드를 Spec에 맞게 수정한다.**
2. **Spec을 먼저 개정한 뒤 코드를 계속 작성한다.** Spec 개정 시:
   - 변경 내용과 사유를 Changelog에 기록한다
   - Spec의 `updated` 날짜를 갱신한다
   - 개정된 Spec에 대해 개발자의 확인을 받는다

**Spec과 코드가 불일치한 상태로 검증 단계에 진입할 수 없다.**

구현 중 Spec과의 괴리를 감지하면 즉시 알린다:
> "현재 구현이 Spec의 [섹션명]과 다릅니다. (1) 코드를 Spec에 맞게 수정하거나, (2) Spec을 먼저 개정하시겠습니까?"

## 6단계: 검증

수락 기준(Acceptance Criteria)의 통과를 확인한다.

**행위:**
- Spec의 14번 섹션(수락 기준)의 각 항목을 순서대로 검증한다.
- 각 항목의 통과/실패 여부를 기록한다.
- 모든 항목이 통과하면 다음 단계로 진행한다.
- 하나라도 실패하면 5단계(구현)로 돌아간다.

**산출물:** 수락 기준 체크리스트 결과

**다음 단계로의 전이 조건:** 수락 기준 전항 통과.

## 7단계: 완료

Spec을 최종 상태로 전이하고 feature를 마무리한다.

**행위:**
- Spec의 frontmatter `status`를 `shipped`로 변경한다.
- Spec의 `updated` 날짜를 갱신한다.
- 변경 이력(Changelog)에 "shipped" 기록을 추가한다.
- 커밋한다.
- 개발자에게 완료를 알린다:
  > "SPEC-XXX `<기능명>`이 shipped 상태로 전이되었습니다. feature 파이프라인이 완료되었습니다."

**산출물:** spec.md (status: shipped)

## Spec 상태 머신

```
draft → approved → implementing → shipped
                                     ↓
                                 superseded (by SPEC-XXX)
```

| 상태 | 의미 | 전이 조건 |
|---|---|---|
| `draft` | 작성 중 | spec-writing skill이 문서 생성 시 |
| `approved` | 리뷰 완료, 구현 가능 | 개발자 승인 |
| `implementing` | 구현 진행 중 | 5단계 진입 시 |
| `shipped` | 구현 완료, 코드와 일치 | 수락 기준 전항 통과 |
| `superseded` | 새 Spec으로 대체됨 | 후속 Spec이 approved될 때 |

### superseded 처리

기존 shipped Spec을 대체하는 새 Spec이 필요할 때:
1. 새 Spec을 `draft`로 작성한다.
2. 새 Spec의 `related_specs`에 기존 Spec ID를 포함한다.
3. 새 Spec이 `approved`될 때, 기존 Spec의 status를 `superseded`로 변경하고 `superseded_by`에 새 Spec ID를 기록한다.

## 깊이 가변 원칙의 적용

이 파이프라인의 모든 단계는 작업 규모와 무관하게 항상 실행된다. 달라지는 것은 각 단계의 **밀도**다:

**가벼운 작업 (예: 단순 UI 수정):**
- Spec 작성: 각 섹션 한 줄. 전체 반 페이지.
- 계획: 간단한 작업 목록.
- TDD 판단: "아니오"가 합리적.
- 구현: 빠르게.
- 검증: 수락 기준 1-2개.

**무거운 작업 (예: 결제 로직):**
- Spec 작성: 행위 명세에 경계 조건 상세. 수 페이지.
- 계획: 모듈 단위 분해, 인터페이스 정의.
- TDD 판단: "예"가 권장됨.
- 구현: 테스트 우선 사이클.
- 검증: 수락 기준 다수, 성능 기준 포함.

**구조는 같고, 밀도만 다르다.**
```

- [ ] **Step 2: 커밋**

```bash
git add skills/feature/SKILL.md
git commit -m "feat: add feature pipeline skill with spec state machine and gates"
```

---

## Task 5: CLAUDE.md 업데이트

**Files:**
- Modify: `CLAUDE.md`

- [ ] **Step 1: CLAUDE.md 수정**

기존 placeholder 내용을 실제 프로젝트 정보로 교체한다:

```markdown
# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project

workflow-plugin: 네이티브 개발부서의 워크플로우를 구조적으로 조형하는 Claude Code 플러그인.

핵심 원칙:
- Spec = SOT. 소스코드의 단일 진실 공급원.
- 구조적 조형. 워크플로우의 형태를 강제한다.
- 고정 구조, 가변 깊이. 압축은 가능, 스킵은 불가.

## Architecture

Claude Code 플러그인 규격을 따른다:
- `.claude-plugin/plugin.json` — 플러그인 메타데이터
- `skills/feature/SKILL.md` — feature 파이프라인 (메인)
- `skills/spec-writing/SKILL.md` — Spec 작성 skill
- `templates/spec-template.md` — Spec 형식 템플릿
- `specs/` — 프로젝트 Spec 파일 저장소

Spec 형식: 15개 섹션, 계약 기반 4그룹 (정의 → 계약 → 실현 → 보증).
파이프라인: Spec 작성 → 승인 → 계획 → TDD 판단 → 구현 → 검증 → 완료.
```

- [ ] **Step 2: 커밋**

```bash
git add CLAUDE.md
git commit -m "docs: update CLAUDE.md with project architecture and principles"
```

---

## Task 6: 통합 검증

**Files:** (수정 없음 — 검증만)

- [ ] **Step 1: 플러그인 구조 확인**

```bash
find . -type f -not -path './.git/*' | sort
```

Expected:
```
./.claude-plugin/plugin.json
./CLAUDE.md
./docs/superpowers/plans/2026-04-12-workflow-plugin-feature.md
./docs/superpowers/specs/2026-04-12-workflow-plugin-feature-design.md
./package.json
./skills/feature/SKILL.md
./skills/spec-writing/SKILL.md
./templates/spec-template.md
```

- [ ] **Step 2: Spec 템플릿과 skill 간 섹션 일치 확인**

`templates/spec-template.md`의 15개 섹션 제목이 `skills/spec-writing/SKILL.md`의 "그룹과 섹션" 목록과 정확히 일치하는지 확인한다.

```bash
grep -c "^# [0-9]" templates/spec-template.md
```

Expected: `15`

- [ ] **Step 3: feature skill의 파이프라인 단계가 설계 문서와 일치하는지 확인**

```bash
grep "^## [0-9]단계" skills/feature/SKILL.md | wc -l
```

Expected: `7`

- [ ] **Step 4: 최종 커밋 로그 확인**

```bash
git log --oneline
```

Expected: 설계 문서 커밋 + Task 1~5의 커밋 총 6개.
