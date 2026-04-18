# Tasks: 스플래시 / 로그인 플로우

**Input**: Design documents from `specs/001-splash-login-flow/`
**Prerequisites**: plan.md ✓, spec.md ✓, research.md ✓, data-model.md ✓, contracts/ui-flow.md ✓

> **Path Convention**: Flutter 기준 경로 사용. 네이티브(Kotlin+Swift)의 경우 `lib/` → `app/src/main/` (Android) 또는 `Sources/` (iOS)로 조정.

## Format: `[ID] [P?] [Story] Description`

- **[P]**: 병렬 실행 가능 (다른 파일, 선행 의존 없음)
- **[USn]**: 해당 유저 스토리 (spec.md 매핑)

---

## Phase 1: Setup (공유 인프라)

**Purpose**: 소셜 SDK 등록 및 프로젝트 의존성 준비

- [ ] T001 소셜 SDK 앱 등록 확인 (Naver Developer, Kakao Developers, Google Cloud Console, Apple Developer)
- [ ] T002 [P] pubspec.yaml (또는 build.gradle/Podfile)에 소셜 SDK 의존성 추가: naver-login-sdk, kakao_flutter_sdk, google_sign_in, sign_in_with_apple
- [ ] T003 [P] 로컬 저장소 라이브러리 의존성 추가: flutter_secure_storage (또는 플랫폼별 동급 라이브러리)

---

## Phase 2: Foundational (핵심 공유 인프라)

**Purpose**: 모든 유저 스토리가 의존하는 핵심 서비스 및 모델 구현

**⚠️ CRITICAL**: 이 단계 완료 전에는 어떤 유저 스토리도 시작할 수 없음

- [ ] T004 [P] Server 모델 구현: lib/data/models/server.dart (name, apiUrl, imgServerUrl, photoUrl, photoUploadUrl)
- [ ] T005 [P] UserSession 모델 구현: lib/data/models/user_session.dart (sessionId, rememberMeToken, savedAt)
- [ ] T006 [P] SocialIdentity 모델 구현: lib/data/models/social_identity.dart (provider enum: NAVER/KAKAO/GOOGLE/APPLE, token)
- [ ] T007 LocalStorageService 구현: lib/core/storage/local_storage_service.dart
  - 세션 저장/조회/삭제 메서드
  - 서버 URL 저장/조회/삭제 메서드
  - 암호화 저장소 사용 (flutter_secure_storage)
- [ ] T008 [P] AppRouter 구현: lib/core/navigation/app_router.dart
  - 라우트 정의: Splash, Login, Main, Onboarding
  - 화면 전이 메서드: goToMain(), goToLogin(), goToOnboarding(SocialIdentity)

**Checkpoint**: Foundation 준비 완료 — 유저 스토리 구현 시작 가능

---

## Phase 3: User Story 1 - 재방문 사용자 자동 로그인 (Priority: P1) 🎯 MVP

**Goal**: 저장된 세션이 있는 사용자가 앱 실행 후 3초 이내에 메인 화면에 도달

**Independent Test**: 세션이 저장된 상태에서 앱을 실행했을 때 로그인 화면 경유 없이 메인 화면으로 이동하는지 수동 확인

### Implementation for User Story 1

- [ ] T009 [P] [US1] SplashViewModel 기본 구조 구현: lib/features/splash/splash_view_model.dart
  - SplashScreenState 정의: Loading, AutoConnecting, ServerSelection, Error
  - 세션 확인 로직 (LocalStorageService 의존)
- [ ] T010 [P] [US1] SplashScreen UI 기본 구현: lib/features/splash/splash_screen.dart
  - Loading 상태: 로딩 인디케이터 표시
  - Error 상태: 에러 메시지 표시
- [ ] T011 [US1] 자동 로그인 플로우 구현: lib/features/splash/splash_view_model.dart
  - 저장된 서버 URL 조회 (T007 의존)
  - 서버 목록 API 호출 (병렬)
  - 저장된 세션 존재 시 → goToMain() 호출 (T008 의존)
  - 저장된 세션 없음 시 → Login 상태로 전환
- [ ] T012 [US1] 세션 만료 처리 구현: lib/features/main/main_view_model.dart
  - 서버 인증 실패 응답(401 등) 감지
  - 세션 삭제 → goToLogin() 호출

**Checkpoint**: US1 완료 — 재방문 사용자 자동 로그인 동작 검증 가능

---

## Phase 4: User Story 2 - 저장된 서버로 자동 연결 (Priority: P2)

**Goal**: 저장된 서버 URL이 있으면 서버 목록 UI 없이 자동으로 해당 서버에 연결

**Independent Test**: 저장된 서버 URL이 있는 상태에서 앱 실행 시 서버 목록이 표시되지 않고 자동 연결되는지 수동 확인

### Implementation for User Story 2

- [ ] T013 [P] [US2] ServerRepository 구현: lib/core/server/server_repository.dart
  - 서버 목록 API 호출 메서드
  - 선택된 서버 URL 로컬 저장/조회 (T007 의존)
- [ ] T014 [US2] 서버 자동 선택 로직 구현: lib/features/splash/splash_view_model.dart (T011 업데이트)
  - 저장된 서버 URL 존재 시 → AutoConnecting 상태로 전환 후 세션 확인
  - 저장된 서버 URL 없음 시 → ServerSelection 상태로 전환
- [ ] T015 [US2] 서버 목록 조회 실패 처리 구현: lib/features/splash/splash_view_model.dart
  - Error 상태 전환 + 에러 메시지 (앱 재실행으로 재시도)
- [ ] T016 [P] [US2] SplashScreen AutoConnecting UI 구현: lib/features/splash/splash_screen.dart (T010 업데이트)
  - AutoConnecting 상태: 로딩 인디케이터 표시 (서버 목록 없이)

**Checkpoint**: US2 완료 — 자동 서버 연결 + 자동 로그인 전체 경로 동작 검증 가능

---

## Phase 5: User Story 3 - 서버 선택 후 소셜 로그인 (Priority: P2)

**Goal**: 저장된 서버가 없을 때 서버 목록을 표시하고, 선택 후 소셜 로그인으로 메인 화면 진입

**Independent Test**: 저장된 서버/세션 없는 상태에서 서버 선택 → 소셜 로그인 → 메인 화면까지 전체 경로 수동 확인

### Implementation for User Story 3

- [ ] T017 [P] [US3] ServerSelectionWidget 구현: lib/features/splash/widgets/server_selection_widget.dart
  - 서버 목록 표시 (Server 모델 리스트 렌더링)
  - 서버 선택 이벤트 발생
- [ ] T018 [US3] 수동 서버 선택 처리 구현: lib/features/splash/splash_view_model.dart (T014 업데이트)
  - 서버 선택 시 기존 세션 삭제 (T007 의존)
  - 선택된 서버 URL 저장 (T013 의존)
  - goToLogin() 호출 (T008 의존)
  - 3초 디바운스 적용 (중복 선택 방지)
- [ ] T019 [P] [US3] SplashScreen ServerSelection UI 구현: lib/features/splash/splash_screen.dart (T010 업데이트)
  - ServerSelection 상태: ServerSelectionWidget 표시 (T017 의존)
- [ ] T020 [P] [US3] LoginScreen UI 기본 구현: lib/features/login/login_screen.dart
  - LoginScreenState 정의: Idle, Loading, Error
  - Idle 상태: 소셜 로그인 버튼 4개 표시 (각 브랜드 가이드라인 준수)
  - Loading 상태: 로딩 인디케이터 + 버튼 전체 비활성화
  - Error 상태: 에러 메시지 + 버튼 재활성화
- [ ] T021 [P] [US3] NaverLoginService 구현: lib/core/auth/social/naver_login_service.dart
  - Naver SDK 초기화 및 인증 호출
  - 성공: SocialIdentity(provider: NAVER, token: ...) 반환
  - 실패: 에러 반환
- [ ] T022 [P] [US3] KakaoLoginService 구현: lib/core/auth/social/kakao_login_service.dart
  - Kakao SDK 초기화 및 인증 호출
  - 성공: SocialIdentity(provider: KAKAO, token: ...) 반환
  - 실패: 에러 반환
- [ ] T023 [P] [US3] GoogleSignInService 구현: lib/core/auth/social/google_sign_in_service.dart
  - Google Sign-In SDK 초기화 및 인증 호출
  - 성공: SocialIdentity(provider: GOOGLE, token: ...) 반환
  - 실패: 에러 반환
- [ ] T024 [P] [US3] AppleSignInService 구현: lib/core/auth/social/apple_sign_in_service.dart
  - Apple Sign In API 호출
  - 성공: SocialIdentity(provider: APPLE, token: ...) 반환
  - 실패: 에러 반환
- [ ] T025 [US3] AuthRepository 구현: lib/core/auth/auth_repository.dart (T021~T024 의존)
  - isRegistered API 호출 메서드 (SocialIdentity → isRegistered boolean)
  - login API 호출 메서드 (SocialIdentity → UserSession)
- [ ] T026 [US3] LoginViewModel 구현: lib/features/login/login_view_model.dart (T025 의존)
  - 소셜 로그인 버튼 탭 처리 (Loading 상태 전환 + 버튼 비활성화)
  - SDK 인증 성공 → isRegistered 확인
  - 기존 회원: login API → 세션 저장 → goToMain()
  - API 실패: Error 상태 전환 + 버튼 재활성화
- [ ] T027 [US3] 중복 요청 방지 구현: lib/features/login/login_view_model.dart (T026 업데이트)
  - 처리 중 상태에서 추가 탭 무시 처리

**Checkpoint**: US3 완료 — 서버 선택 + 소셜 로그인 전체 경로 동작 검증 가능

---

## Phase 6: User Story 4 - 미등록 사용자 온보딩 연결 (Priority: P3)

**Goal**: 미등록 사용자를 소셜 인증 정보와 함께 온보딩 화면으로 안내

**Independent Test**: 서비스 미등록 소셜 계정으로 로그인 시도 시 온보딩 화면으로 이동하고 SocialIdentity가 전달되는지 수동 확인

### Implementation for User Story 4

- [ ] T028 [US4] 미등록 사용자 분기 처리 구현: lib/features/login/login_view_model.dart (T026 업데이트)
  - isRegistered false → goToOnboarding(socialIdentity) 호출 (T008 의존)
- [ ] T029 [US4] 온보딩 화면 SocialIdentity 수신 처리: lib/features/onboarding/onboarding_view_model.dart
  - 라우트 파라미터로 전달된 SocialIdentity 수신 확인
  - 온보딩 화면 초기화 (온보딩 Spec 범위 — 수신 확인만)

**Checkpoint**: US4 완료 — 전체 신규 사용자 경로 검증 가능

---

## Phase 7: Polish & Cross-Cutting Concerns

**Purpose**: 에러 메시지 통일, 로딩 인디케이터 공통화, 최종 검증

- [ ] T030 [P] 공통 에러 메시지 컴포넌트 구현: lib/core/ui/error_message_widget.dart
- [ ] T031 [P] 공통 로딩 인디케이터 컴포넌트 구현: lib/core/ui/loading_indicator_widget.dart
- [ ] T032 quickstart.md 검증 항목 실행
  - 자동 로그인 속도 3초 이내 확인
  - 중복 탭 방지 동작 확인
  - 에러 복구 (재시도 가능) 동작 확인
  - 서버 전환 시 세션 초기화 확인

---

## Dependencies & Execution Order

### Phase Dependencies

- **Phase 1 (Setup)**: 즉시 시작 가능
- **Phase 2 (Foundational)**: Phase 1 완료 후 시작 — **모든 유저 스토리 블로킹**
- **Phase 3 (US1)**: Phase 2 완료 후 시작 — MVP
- **Phase 4 (US2)**: Phase 3 완료 후 시작 (T011 업데이트 필요)
- **Phase 5 (US3)**: Phase 2 완료 후 시작 가능 (US1, US2와 병렬 가능)
- **Phase 6 (US4)**: Phase 5 완료 후 시작 (T026 업데이트 필요)
- **Phase 7 (Polish)**: 원하는 유저 스토리 완료 후

### User Story Dependencies

- **US1 (P1)**: Phase 2 완료 후 즉시 시작 — 다른 스토리 의존 없음
- **US2 (P2)**: US1 완료 후 시작 (SplashViewModel 공유 로직 업데이트)
- **US3 (P2)**: Phase 2 완료 후 시작 가능 — US1, US2와 병렬 가능 (LoginScreen은 별개 화면)
- **US4 (P3)**: US3 완료 후 시작 (LoginViewModel 업데이트 필요)

### Within Each User Story

- 모델/서비스 구현 → ViewModel 구현 → UI 구현 순서
- ViewModel 완성 후 UI 연결
- 각 유저 스토리의 Checkpoint에서 독립 동작 검증

### Parallel Opportunities

- T002, T003 병렬 실행 가능 (Phase 1)
- T004, T005, T006, T007, T008 병렬 실행 가능 (Phase 2)
- T009, T010 병렬 실행 가능 (Phase 3)
- T013, T016 병렬 실행 가능 (Phase 4)
- T017, T019, T020, T021, T022, T023, T024 병렬 실행 가능 (Phase 5)
- T021~T024 (소셜 SDK 4개) 완전 병렬 실행 가능
- T030, T031 병렬 실행 가능 (Phase 7)

---

## Parallel Example: User Story 3 (소셜 SDK 구현)

```
# 소셜 SDK 4개는 완전히 독립적으로 병렬 구현 가능:
Task T021: "NaverLoginService in lib/core/auth/social/naver_login_service.dart"
Task T022: "KakaoLoginService in lib/core/auth/social/kakao_login_service.dart"
Task T023: "GoogleSignInService in lib/core/auth/social/google_sign_in_service.dart"
Task T024: "AppleSignInService in lib/core/auth/social/apple_sign_in_service.dart"

# 위 4개 완료 후 통합:
Task T025: "AuthRepository in lib/core/auth/auth_repository.dart"
```

---

## Implementation Strategy

### MVP First (User Story 1 Only)

1. Phase 1: Setup 완료
2. Phase 2: Foundational 완료 (블로킹)
3. Phase 3: US1 완료
4. **STOP and VALIDATE**: 재방문 사용자 자동 로그인 독립 검증
5. 준비 시 배포/데모

### Incremental Delivery

1. Setup + Foundational → 기반 완료
2. US1 → 자동 로그인 검증 → 배포/데모 (MVP!)
3. US2 → 서버 자동 연결 검증 → 배포/데모
4. US3 → 소셜 로그인 전체 검증 → 배포/데모
5. US4 → 신규 사용자 온보딩 연결 검증 → 배포/데모

---

## Notes

- [P] 태스크 = 다른 파일, 선행 의존 없음 → 병렬 실행 가능
- [USn] 레이블 = 해당 유저 스토리 추적성
- 경로는 Flutter 기준. 네이티브 사용 시 plan.md research.md 참고하여 조정
- **tech stack 확인 필수**: research.md의 "Action Required" 참고
- 각 Checkpoint에서 독립 동작 검증 후 다음 단계 진행
- 온보딩 화면 상세 구현은 별도 Spec/Tasks 범위
