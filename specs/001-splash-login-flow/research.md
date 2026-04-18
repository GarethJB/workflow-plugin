# Research: 스플래시 / 로그인 플로우

**Feature**: 001-splash-login-flow  
**Date**: 2026-04-15  
**Status**: Complete

---

## NEEDS CLARIFICATION 해소

### 1. 기술 스택 (Language/Version)

**결론**: 프로젝트 소스 코드 확인이 필요합니다. 아래 두 시나리오를 준비합니다.

| 시나리오 | 기술 스택 | 근거 |
|----------|-----------|------|
| A: 크로스 플랫폼 | Flutter (Dart) | 단일 코드베이스로 iOS/Android 동시 지원, 네이버/카카오 SDK 플러터 패키지 존재 |
| B: 네이티브 | Kotlin (Android) + Swift (iOS) | Apple Sign In은 iOS에서 네이티브가 가장 안정적 |

**권장**: 기존 코드베이스가 Flutter라면 A를, 네이티브라면 B를 따릅니다. tasks.md 작성 전 확인 필요.

### 2. 테스트 프레임워크

| 시나리오 | 테스트 프레임워크 |
|----------|-----------------|
| Flutter | `flutter_test`, `mockito`, `bloc_test` |
| Android | JUnit 5 + Mockito + Espresso |
| iOS | XCTest + Quick/Nimble |

---

## 소셜 로그인 통합 패턴

### 결정: SDK 위임 방식 (표준 OAuth 플로우)

각 소셜 제공자 공식 SDK를 사용하여 인증 처리. 자체 WebView 구현 배제.

**근거**:
- Apple Sign In은 네이티브 API가 필수 (앱스토어 정책)
- 네이버/카카오는 공식 SDK가 최신 보안 정책 반영
- Google Sign In SDK는 자동 토큰 갱신 지원

**대안 검토**: OAuth 웹뷰 직접 구현 — 유지보수 부담, 보안 감사 비용으로 기각.

**소셜 제공자별 SDK**:

| 제공자 | SDK | 특이사항 |
|--------|-----|---------|
| 네이버 | naver-login-sdk (Android/iOS) | 앱 등록 필요 |
| 카카오 | kakao-sdk (Flutter: kakao_flutter_sdk) | 카카오 개발자 앱 등록 필요 |
| 구글 | google_sign_in (Flutter) / Google Sign-In SDK | SHA-1 인증서 등록 필요 (Android) |
| 애플 | sign_in_with_apple (Flutter) / AuthenticationServices | iOS 13+, Apple Developer 등록 필요 |

---

## 세션 관리 패턴

### 결정: 로컬 영속 저장 + 지연 유효성 검증

**선택**: 앱 시작 시 세션 존재 여부만 확인 → 메인 화면 진입 → 서버 응답으로 만료 감지

**근거**:
- 앱 시작 시 네트워크 요청 없이 즉각 진입 → 3초 목표 달성 가능
- 서버 응답(401 등)은 메인 화면에서 이미 처리되는 경우가 많음 (API 호출 자연 발생)
- 사용자 경험: 로딩 없는 즉시 진입이 체감 속도에 크게 기여

**대안 검토**: 앱 시작 시 세션 유효성 API 호출 — 추가 지연 발생, 오프라인 시 실패로 기각.

**저장소 선택**:

| 플랫폼 | 저장소 | 비고 |
|--------|--------|------|
| Flutter | `flutter_secure_storage` | 암호화 지원, iOS Keychain / Android KeyStore |
| Android | EncryptedSharedPreferences | API 23+ |
| iOS | Keychain | 앱 삭제 시 쿠키 데이터도 삭제 고려 |

---

## 서버 선택 UI 패턴

### 결정: 목록 선택 + 자동 기억

**선택**: 서버 목록을 원격에서 조회하여 표시 → 선택 후 로컬에 저장 → 재실행 시 자동 적용

**근거**:
- 다중 환경(개발/스테이징/운영)을 유연하게 지원
- 원격 목록 조회로 서버 추가/제거를 앱 업데이트 없이 가능

**중복 요청 방지**:
- 서버 선택 시 3초 디바운스 처리 (기획서 요구사항)
- 로그인 버튼은 처리 중 전체 비활성화

---

## 에러 처리 전략

### 결정: 인라인 에러 메시지 + 재시도 가능 상태 복원

| 에러 상황 | 처리 방식 |
|----------|---------|
| 서버 목록 조회 실패 | 화면 내 에러 메시지 표시 (앱 재실행으로 재시도) |
| 소셜 SDK 인증 실패 | 에러 메시지 표시 + 버튼 즉시 재활성화 |
| 가입 확인 API 실패 | 에러 메시지 표시 + 버튼 즉시 재활성화 |
| 로그인 API 실패 | 에러 메시지 표시 + 버튼 즉시 재활성화 |
| 네트워크 없음 | 네트워크 오류 메시지 + 버튼 재활성화 |

**근거**: 앱 재시작 없이 동일 화면에서 재시도 가능 → SC-005 충족.

---

## 해소된 NEEDS CLARIFICATION 요약

| 항목 | 결정 | 담당 |
|------|------|------|
| Language/Version | Flutter 또는 Kotlin+Swift (코드베이스 확인 필요) | 개발팀 확인 |
| 테스트 프레임워크 | 플랫폼에 따라 결정 | 개발팀 확인 |
| Android 최소 API 레벨 | 개발팀 확인 필요 | 개발팀 확인 |

> **Action Required**: tasks.md 작성 전 개발팀에 기술 스택 확인 후 plan.md Technical Context를 업데이트하세요.
