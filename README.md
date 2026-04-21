# workflow-plugin

네이티브 개발부서의 워크플로우를 **Spec 중심**으로 구조화하는 Claude Code 플러그인. 기획·합의·구현·검증의 경계를 느슨한 대화 대신 *파일로 정착된 계약*으로 바꾸고, Claude가 그 계약을 강제·참조하도록 만든다.

> Spec-Driven Development (SDD) 철학을 팀 워크플로우로 엔지니어링한 결과물. [원문 참고](https://medium.com/@shenli3514/spec-driven-development-sdd-is-the-future-of-software-engineering-85b258cea241).

## 핵심 아이디어

- **Spec = SOT (Single Source of Truth).** Spec·코드·대화가 엇갈리면 Spec이 기준이다.
- **15섹션 고정 구조.** 모든 Spec이 동일한 4그룹(정의 §1-4 / 계약 §5-9 / 실현 §10-12 / 보증 §13-15) 형식을 따른다.
- **파이프라인은 건너뛸 수 없다.** 새 기능은 `feature` 7단계, 버그 수정은 `debug` 8단계를 순서대로 통과한다.
- **AI는 대신 결정하지 않는다.** §10.1(구조)은 개발자 전담, §10.2·10.3은 AI가 복수 안을 제안하고 개발자가 선택한다.
- **CLAUDE.md도 SOT다.** 프로젝트 전역 규약은 CLAUDE.md에 두고, 파이프라인이 직접 수정하지 않는다.

## 워크플로우

```
[기획 문서·아이디어]
        │
        ▼
  ┌───────────────┐   ┌─────────────────────────────┐
  │ spec-writing  │   │ feature (7단계)               │
  │ (Spec 작성)   │──▶│ Spec → 승인 → 계획 → Practice  │
  └───────────────┘   │       → 구현 → 검증 → 완료     │
        ▲             └────────────┬────────────────┘
        │                          │ 검증 실패
        │ 회귀 테스트 추가           ▼
        │             ┌─────────────────────────────┐
        │             │ debug (8단계)                │
        └─────────────│ 증상 → Spec 확인 → 가설 → 검증 │
                      │     → 원인 → 수정 → 회귀 → 완료│
                      └─────────────────────────────┘
```

## 스킬 구성

### 최상위 (3)

| 스킬 | 역할 | 트리거 예시 |
|---|---|---|
| [`spec-writing`](skills/spec-writing/SKILL.md) | Spec 작성·수정 전담 (15섹션 고정, 락 파일로 외부 편집 차단) | "spec 작성해줘", "spec 수정해줘" |
| [`feature`](skills/feature/SKILL.md) | 7단계 기능 개발 파이프라인 | "feature 스킬로 시작해줘" |
| [`debug`](skills/debug/SKILL.md) | 8단계 버그 수정 파이프라인 | "debug 스킬로 시작해줘" |

### Practice (3 · 위험도별)

`feature` 4단계에서 위험도에 맞춰 선택한다.

| 위험도 | Practice | 적합한 작업 |
|---|---|---|
| **고** | [`practice-tdd`](skills/practice-tdd/SKILL.md) | 결제·인증·데이터 정합성 등 회귀 민감, 로직 복잡 |
| **중** | [`practice-walking-skeleton`](skills/practice-walking-skeleton/SKILL.md) | 새 SDK·프로토콜·통신 경로 개척 (통합 리스크) |
| **저** | [`practice-implementation-first`](skills/practice-implementation-first/SKILL.md) | 내부 도구·프로토타입, 검증 범위 작음 |

혼용 가능 — 예: 관통 경로는 Walking Skeleton, 내부 도메인 로직은 TDD.

### 슬래시 커맨드

- [`/onboard`](commands/onboard.md) — 레포 맥락을 감지해 스킬·규약·진입점을 짧게 안내한다.

## 설치

Claude Code 플러그인 디렉토리에 이 저장소를 클론 또는 심볼릭 링크한다. `.claude-plugin/plugin.json`이 자동 인식된다.

플러그인이 인식되면 레포 루트에서 `/onboard`를 실행해 구성을 확인할 수 있다.

## 빠른 시작

1. 레포에 `CLAUDE.md`를 먼저 작성한다 — 프로젝트 전역 규약(아키텍처·API·상태 관리·컨벤션)을 여기 모은다.
2. 새 기능을 시작할 때 구조화된 5필드로 요청한다 ([docs/structured-request.md](docs/structured-request.md)):
   - **문제**: 한 문장
   - **맥락**: 관련 Spec·AC-NN, CLAUDE.md 제약
   - **기대 결과**: "완료"의 관찰 가능한 정의
   - **제약**: 시간·플랫폼·위험도·금지 사항
   - **산출물 형식**: Spec / 구현 커밋 / 가설 목록 등
3. `feature` 스킬이 7단계 파이프라인을 안내한다. 단계는 건너뛸 수 없다.
4. 각 단계 종료 시 `§15 Changelog`에 마커가 남아 세션이 끊겨도 재개 지점을 찾을 수 있다.

## 저장소 구조

```
workflow-plugin/
├── .claude-plugin/plugin.json      # 플러그인 매니페스트
├── CLAUDE.md                       # 플러그인 개발자용 지침 (SOT)
├── ONBOARDING.md                   # 팀원 온보딩 가이드
├── commands/
│   └── onboard.md                  # /onboard 슬래시 커맨드
├── skills/
│   ├── spec-writing/               # Spec 작성 스킬
│   ├── feature/                    # 7단계 파이프라인
│   ├── debug/                      # 8단계 파이프라인
│   └── practice-*/                 # 3개 Practice 스킬
├── templates/
│   └── spec-template.md            # 15섹션 Spec 템플릿
├── hooks/                          # Spec 파일 편집 가드
├── specs/                          # 이 레포에서 작성한 예제 Spec들
└── docs/
    ├── structured-request.md       # 요청 5필드 체계
    └── presentation.html           # 소개 발표용 슬라이드
```

## 팀원 온보딩

새 팀원은 [ONBOARDING.md](ONBOARDING.md)를 Claude Code에 붙여넣으면 대화형 안내를 받는다.

## 핵심 문서

- [플러그인 개발 지침 (CLAUDE.md)](CLAUDE.md)
- [Spec 템플릿](templates/spec-template.md)
- [구조화된 요청 5필드](docs/structured-request.md)

## 철학적 배경

이 플러그인은 Shen Li의 "Spec-Driven Development is the Future of Software Engineering"(Medium) 원칙을 팀·파이프라인 수준으로 공식화한 구현체다. 개별 개발자의 규율이 아닌 **도구·훅·스킬이 Spec 중심 흐름을 강제**한다는 점이 차별점이다.

- Spec이 AC-NN·§N 번호 체계로 검색 가능해진다.
- 락 파일 + 훅으로 Spec 파일을 직접 편집할 수 없다.
- 파이프라인 단계 전이가 Changelog 마커로 감사 가능하다.
- AI 제안에 `[AI 제안]` 태그를 달아 인간 승인 게이트를 구조에 박아둔다.
