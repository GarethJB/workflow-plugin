# Implementation Plan: 스플래시 / 로그인 플로우

**Branch**: `001-splash-login-flow` | **Date**: 2026-04-15 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `specs/001-splash-login-flow/spec.md`

## Summary

앱 실행 시 서버 목록 조회 → 서버 자동/수동 선택 → 저장 세션 기반 자동 로그인 또는 소셜 로그인(네이버/카카오/구글/애플) → 기존 회원/미등록 분기 처리까지의 진입 플로우를 구현한다. 핵심 목표는 재방문 사용자의 3초 이내 자동 로그인과 신규 사용자의 온보딩 연결이다.

## Technical Context

**Language/Version**: NEEDS CLARIFICATION (Kotlin + Swift 또는 Flutter/React Native 중 확인 필요)
**Primary Dependencies**: 네이버 로그인 SDK, 카카오 SDK, Google Sign-In SDK, Apple Sign In API, 로컬 스토리지
**Storage**: 로컬 영속 저장소 (사용자 세션, 선택된 서버 URL)
**Testing**: NEEDS CLARIFICATION (JUnit/XCTest 또는 Flutter Test 등 플랫폼에 따라 상이)
**Target Platform**: iOS 15+, Android (API 레벨 NEEDS CLARIFICATION)
**Project Type**: mobile-app
**Performance Goals**: 저장된 세션 보유 사용자 앱 실행 → 메인 화면 3초 이내, 소셜 로그인 전체 흐름 30초 이내
**Constraints**: 세션 유효성 검증 없는 즉시 진입 (오프라인 허용), 중복 로그인 요청 방지
**Scale/Scope**: 다중 서버 환경 지원 (개발/스테이징/운영)

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

> **참고**: `.specify/memory/constitution.md`가 프로젝트별 원칙으로 아직 채워지지 않은 템플릿 상태입니다. 아래는 모바일 앱 개발의 일반적 기준을 적용합니다.

| 게이트 | 상태 | 비고 |
|--------|------|------|
| 단일 책임 원칙 | PASS | 스플래시 + 로그인 플로우는 단일 진입 기능 |
| 테스트 가능성 | PASS | 각 유저 스토리가 독립적으로 테스트 가능 |
| 보안 | PASS | 세션은 로컬 영속 저장, 소셜 SDK 통한 표준 인증 |
| 복잡도 | PASS | UI 상태 관리 복잡도는 명세 범위 내에서 정당화됨 |

## Project Structure

### Documentation (this feature)

```text
specs/001-splash-login-flow/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
│   └── ui-flow.md
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)

```text
# Option 3: Mobile app structure

android/
└── app/src/main/
    ├── splash/          # 스플래시 화면 (서버 선택 UI)
    ├── login/           # 로그인 화면 (소셜 로그인 버튼)
    └── auth/            # 인증 처리 (소셜 SDK 호출, 세션 저장)

ios/
└── Sources/
    ├── Splash/          # 스플래시 화면
    ├── Login/           # 로그인 화면
    └── Auth/            # 인증 처리

# 또는 Flutter 단일 코드베이스
lib/
├── features/
│   ├── splash/          # 스플래시 화면 + 서버 선택
│   └── login/           # 로그인 화면 + 소셜 인증
└── core/
    ├── auth/            # 인증 서비스
    └── storage/         # 세션/서버 로컬 저장
```

**Structure Decision**: 플랫폼 확인 후 결정 필요. research.md에서 기술 스택 확정 시 업데이트.

## Complexity Tracking

이 기능에 정당화가 필요한 헌법 위반 사항 없음.
