# Quickstart: 스플래시 / 로그인 플로우 개발 가이드

**Feature**: 001-splash-login-flow  
**Date**: 2026-04-15

---

## 시작 전 확인사항

### 1. 소셜 SDK 등록 (사전 작업)

각 소셜 제공자 개발자 콘솔에서 앱 등록이 필요합니다.

| 제공자 | 등록 필요 항목 |
|--------|--------------|
| 네이버 | 네이버 개발자 센터에서 앱 등록, 클라이언트 ID/Secret 발급 |
| 카카오 | Kakao Developers에서 앱 등록, 네이티브 앱 키 발급 |
| 구글 | Google Cloud Console에서 OAuth 2.0 클라이언트 ID 생성 (iOS: Bundle ID, Android: SHA-1) |
| 애플 | Apple Developer에서 Sign In with Apple 기능 활성화, Service ID 생성 |

### 2. 개발 환경 준비

```
# 기술 스택 확인 후 해당 항목 진행
# (research.md 참고: Flutter 또는 Kotlin+Swift)

# Flutter의 경우
flutter pub get

# Android 네이티브의 경우
./gradlew dependencies

# iOS 네이티브의 경우
pod install
```

---

## 구현 순서 (우선순위 순)

### Step 1: 저장된 세션 기반 자동 로그인 (P1)

> 가장 빈번한 사용자 경로. 먼저 완성하여 MVP 달성.

1. **로컬 저장소 서비스 구현**
   - 세션(sessionId, rememberMeToken) 저장/조회/삭제
   - 서버 URL 저장/조회/삭제

2. **스플래시 화면 초기화 로직**
   - 서버 목록 API 호출
   - 저장된 서버 URL 조회
   - 저장된 세션 존재 시 → 메인 화면 이동

3. **테스트**
   - 세션 있음 + 저장된 서버 → 메인 화면 이동 확인
   - 세션 있음 + 저장된 서버 없음 → 서버 목록 표시 확인

### Step 2: 서버 선택 + 로그인 화면 (P2)

1. **서버 목록 UI 구현**
   - Loading / Content(목록) / Error 상태 표시
   - 서버 선택 → 기존 세션 삭제 → 로그인 화면 이동
   - 중복 탭 방지 (3초 디바운스)

2. **로그인 화면 UI 구현**
   - 네이버/카카오/구글/애플 버튼 (각 브랜드 가이드라인 준수)
   - Idle / Loading / Error 상태 관리

3. **소셜 SDK 통합 (제공자별)**
   - 각 SDK 초기화
   - 인증 성공 → SocialIdentity(provider, token) 획득
   - 인증 실패 → 에러 메시지, 버튼 재활성화

4. **가입 여부 확인 + 분기 처리**
   - 가입 확인 API 호출 (SocialIdentity 전달)
   - 기존 회원: 로그인 API 호출 → 세션 저장 → 메인 화면
   - 미등록: 온보딩 화면 이동 (SocialIdentity 전달)

5. **테스트**
   - 각 소셜 제공자 인증 성공/실패 시나리오
   - 기존 회원 → 메인 화면 경로
   - 로그인 중 중복 탭 방지 확인

### Step 3: 미등록 사용자 온보딩 연결 (P3)

1. **온보딩 화면으로 SocialIdentity 전달**
   - 화면 전환 시 provider + token 파라미터 전달
   - 온보딩 화면에서 수신 확인

2. **테스트**
   - 미등록 계정으로 소셜 인증 → 온보딩 화면 이동 + 데이터 전달 확인

---

## 세션 관리 구현 참고

```
# 세션 저장 (로그인 성공 시)
store(sessionId, rememberMeToken)

# 세션 조회 (앱 시작 시)
session = load()
if session exists → navigate to Main
else → navigate to Login

# 세션 삭제 (서버 수동 변경 또는 만료 시)
delete(session)
```

---

## 주요 확인 포인트

1. **자동 로그인 속도**: 저장된 세션 있는 경우 → 앱 실행 후 3초 이내 메인 화면
2. **중복 요청 없음**: 로그인 중 소셜 버튼 연속 탭 → 요청 1회만 발생
3. **에러 복구**: 모든 에러 후 버튼 재활성화 → 앱 재시작 없이 재시도 가능
4. **서버 전환 시 세션 초기화**: 다른 서버 선택 → 기존 세션 삭제 확인

---

## 관련 문서

- [Spec](./spec.md) — 기능 명세 (무엇을, 왜)
- [Data Model](./data-model.md) — 엔티티 구조
- [UI Flow Contracts](./contracts/ui-flow.md) — 화면 전이 계약
- [Research](./research.md) — 기술 결정 근거
