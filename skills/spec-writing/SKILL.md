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
