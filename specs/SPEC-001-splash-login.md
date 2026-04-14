---
id: SPEC-001
title: 스플래시 / 로그인
status: draft
superseded_by:
related_specs: [SPEC-002, SPEC-003]
author: JB
created: 2026-04-14
updated: 2026-04-14
---

## 1. 목적

앱 실행 시 서버 선택 → 자동 로그인 판별 → 소셜 로그인 → 가입 여부 분기까지의 진입 플로우를 처리한다. 기존 사용자는 홈으로, 미등록 사용자는 온보딩으로 진입시킨다.

---

## 2. 용어 정의

| 용어 | 정의 |
|------|------|
| socialSlct | 소셜 로그인 제공자 식별자 (naver/kakao/google/apple) |
| socialKey | 소셜 SDK 인증 후 획득하는 사용자 고유 키 |
| JSESSIONID | 서버 세션 식별 쿠키 |
| remember-me | 자동 로그인 유지 쿠키 |
| deviceId | User-Agent 헤더로 전달되는 디바이스 고유 식별자 |
| 자동 로그인 | 로컬 저장 쿠키 존재 시 서버 검증 없이 홈으로 즉시 이동하는 동작 |

---

## 3. 전제

- Naver/Kakao/Google/Apple 소셜 SDK가 앱에 통합되어 있다.
- 서버는 GET /api/v1/staff/list를 통해 서버 목록을 제공한다.
- 쿠키 만료 여부는 스플래시에서 검증하지 않으며, 메인 화면의 API 응답(401)으로 판별한다.

---

## 4. 외부 의존성

| 이름 | 유형 | 용도 |
|------|------|------|
| Naver 로그인 SDK | SDK | 소셜 인증 |
| Kakao 로그인 SDK | SDK | 소셜 인증 |
| Google 로그인 SDK | SDK | 소셜 인증 |
| Apple 로그인 SDK | SDK | 소셜 인증 |
| GET /api/v1/staff/list | REST API | 서버 목록 조회 |
| POST /api/v1/auth/isRegistered | REST API | 가입 여부 확인 |
| POST /api/v1/auth/login | REST API | 소셜 로그인 및 세션 쿠키 발급 |
| DataStore | 로컬 저장소 | 쿠키(JSESSIONID, remember-me) 및 API URL 영속 저장 |

---

## 5. 행위 명세

### 5.1 스플래시 초기화

1. DataStore에서 저장된 API URL 조회
2. GET /api/v1/staff/list 서버 목록 조회 (로딩 인디케이터 표시)
3. 저장된 API URL 존재 → 자동 서버 선택 (쿠키 유지)
4. 저장된 API URL 없음 → 서버 목록 UI 표시 → 사용자가 서버 선택
5. 서버 선택 완료 → API URL 설정

### 5.2 서버 선택 정책

| 구분 | 자동 선택 (저장된 URL) | 수동 선택 (사용자 탭) |
|------|----------------------|---------------------|
| 쿠키 처리 | 유지 | 삭제 |
| 이후 동작 | 쿠키 존재 시 홈 / 없으면 로그인 | 로그인 화면 이동 |
| 중복 방지 | 3초 내 중복 요청 차단 | 3초 내 중복 요청 차단 |

### 5.3 자동 로그인 판별

- 로컬 저장 쿠키 존재 → 유효성 검증 없이 즉시 홈 이동
- 로컬 저장 쿠키 없음 → 로그인 화면 이동

### 5.4 소셜 로그인 플로우

1. 소셜 버튼 터치 → 로딩 인디케이터 표시 + 모든 소셜 버튼 비활성화
2. 소셜 SDK 인증 → socialSlct + socialKey 획득
3. socialKey 로컬 저장
4. POST /api/v1/auth/isRegistered { socialSlct, socialKey }
5. code "-1" (기존 회원) → POST /api/v1/auth/login { socialSlct, socialKey } → Set-Cookie 로컬 저장 → 홈 이동
6. code "1" (미등록) → socialSlct, socialKey를 전달하며 온보딩 이동

### 5.5 쿠키 관리 정책

| 항목 | 정책 |
|------|------|
| 저장 시점 | /auth/login 응답 및 이후 모든 API의 Set-Cookie 헤더 수신 시 |
| 저장 위치 | DataStore (영속) |
| 갱신 | Set-Cookie 수신 시마다 덮어씀 |
| 전송 | 모든 API 요청 시 Cookie 헤더에 자동 포함 |
| 삭제 시점 | 수동 서버 변경 시 / 메인에서 401 감지 시 |

---

## 6. 에러 처리

| 에러 상황 | 복구 전략 | 사용자 피드백 | 로깅 |
|----------|----------|-------------|------|
| 서버 목록 조회 실패 | 무시 | 인라인 에러 | error |
| 소셜 SDK 인증 실패 | 버튼 재활성화 | 인라인 에러 | warn |
| isRegistered API 실패 | 버튼 재활성화 | 인라인 에러 | error |
| login API 실패 | 버튼 재활성화 | 인라인 에러 | error |
| login API code "-11" (계정 없음) | 버튼 재활성화 | 인라인 에러 | warn |
| 세션 만료 (메인에서 401 감지) | 화면 이동: 로그인 | 없음 | warn |
| 네트워크 오류 | 버튼 재활성화 | 인라인 에러 | warn |

---

## 7. 범위

**포함:**
- 스플래시 서버 선택 UI (자동/수동)
- 자동 로그인 판별 (쿠키 존재 여부 기반)
- 소셜 로그인 4종 (Naver/Kakao/Google/Apple)
- 가입 여부 분기 (홈 or 온보딩 라우팅)
- 쿠키 저장/갱신/삭제 정책

**제외:**
- 온보딩 플로우 (SPEC-002)
- 홈 화면 (SPEC-003)
- 회원 탈퇴 / 로그아웃

---

## 8. 제약

- 로그인 진행 중 중복 요청 방지: 모든 소셜 버튼 비활성화
- 서버 선택 3초 내 중복 요청 차단
- 자동 로그인 시 쿠키 유효성 서버 검증 없음 (메인 화면에서 처리)

---

## 9. 성능 기준

- API 응답 타임아웃: 30초

---

## 10. 기술 설계

- 아키텍처: MVI + Clean Architecture
- SplashViewModel: 서버 목록 로드 Intent → ServerState(Loading/Content/Error) 관리, API URL 설정, 쿠키 존재 여부 판별 후 라우팅
- LoginViewModel: 소셜 로그인 Intent → LoginState 관리, 가입 여부 분기 후 라우팅
- AuthRepository: DataStore 기반 쿠키(JSESSIONID, remember-me) 및 API URL 영속 저장/조회/삭제
- 로컬 저장소: DataStore

---

## 11. 플랫폼별 차이

해당 없음

---

## 12. 마이그레이션

해당 없음 (신규 개발)

---

## 13. 테스트 전략

ViewModel/UseCase 단위 테스트

---

## 14. 수락 기준

미정

---

## 15. Changelog

| 날짜 | 버전 | 내용 | 작성자 |
|------|------|------|--------|
| 2026-04-14 | 1.0 | 최초 작성 | JB |
