---
id: SPEC-002
title: 스플래시 · 로그인 진입 플로우
status: draft
superseded_by:
related_specs: [SPEC-001]
author: jubin
created: 2026-04-21
updated: 2026-04-21
---

# ── 정의 ──

# 1. 목적 (Purpose)

> **앱 사용자가 빠르고 일관된 진입을 하기 위해 스플래시에서 서버를 선정하고, 재방문 시 자동 로그인, 신규·미등록 시 소셜 로그인 및 가입 분기를 수행한다.**

- 시작 조건: 앱 실행
- 완료 조건: 메인 화면 또는 온보딩 화면 진입

성공 지표: 자동 로그인(쿠키 기반 즉시 진입) 이용률이 재방문 세션의 다수를 차지해야 한다. 구체 수치는 릴리스 후 로그로 설정.

# 2. 용어 정의 (Glossary)

| 용어 | 정의 |
|---|---|
| 스플래시 | 앱 실행 직후 서버 목록·자동 진입을 판별하는 첫 화면 |
| 서버 목록 | `GET /api/v1/staff/list` 응답으로 받는 접속 가능한 서버 집합 |
| API URL | 현재 앱이 바라보는 서버의 루트 URL. 로컬 저장소에 영속 저장 |
| 자동 선택 | 저장된 API URL이 있을 때 사용자 탭 없이 해당 서버로 즉시 설정하는 동작 |
| 수동 선택 | 사용자가 서버 목록 UI에서 직접 탭하여 서버를 고르는 동작 |
| 자동 로그인 | 저장된 쿠키가 존재할 때 유효성 검증 없이 즉시 메인으로 이동하는 동작 |
| socialSlct | 소셜 로그인 제공자 식별자. 값: `NAVER` / `KAKAO` / `GOOGLE` / `APPLE` |
| socialKey | 소셜 SDK 인증 성공 시 반환되는 사용자 식별 키 |
| 가입 여부 code | `/auth/isRegistered` 응답 코드. `-1`=기존 회원, `1`=미등록 |
| 세션 쿠키 | `JSESSIONID`, `remember-me` 등 서버가 `Set-Cookie`로 내려주는 인증 토큰 |

# 3. 전제 (Assumptions)

- 앱 실행 시 네트워크가 가용하다. 오프라인은 이번 Spec 범위 외.
- 4종 소셜 SDK(Naver, Kakao, Google, Apple)가 네이티브 프로젝트에 연동되어 있고 빌드·런타임에 정상 동작한다.
- 서버 인증은 쿠키 기반 세션 방식이며, `Set-Cookie`에 `JSESSIONID`·`remember-me`를 포함한다.
- 로컬 영속 저장소는 재설치 전까지 유지된다. 시스템이 저장소를 임의 초기화하는 상황은 고려 대상 외.

# 4. 외부 의존성 (Dependencies)

| 대상 | 유형 | 버전/조건 | 장애 시 영향 |
|---|---|---|---|
| `GET /api/v1/staff/list` | REST API | 서버 목록 응답 (serverName, apiUrl, imgServerUrl, photoUrl, photoUploadUrl) | 스플래시 초기화 실패 → 에러 표시, 이후 진행 불가 |
| `POST /api/v1/auth/isRegistered` | REST API | 요청 `{socialSlct, socialKey}` / 응답 `code` | 가입 분기 불가 → 에러 + 버튼 재활성화 |
| `POST /api/v1/auth/login` | REST API | 요청 `{socialSlct, socialKey}` / 응답 `Set-Cookie` | 로그인 불가 → 에러 + 버튼 재활성화 |
| Naver 로그인 SDK | SDK | 네이티브 연동 | 네이버 버튼 비활성화 효과 |
| Kakao 로그인 SDK | SDK | 네이티브 연동 | 카카오 버튼 비활성화 효과 |
| Google Sign-In SDK | SDK | 네이티브 연동 | 구글 버튼 비활성화 효과 |
| Apple Sign In | SDK | iOS 네이티브 API | 애플 버튼 비활성화 효과 (iOS) |
| 로컬 저장소 | 로컬 저장소 | 영속 Key-Value (API URL·쿠키·소셜 토큰) | 자동 로그인 불가 → 매 실행 수동 로그인 필요 |

# ── 계약 ──

# 5. 행위 명세 (Behavior)

## 정상 흐름

**스플래시 초기화:**
1. 앱 실행 시 스플래시 화면이 진입한다.
2. 로컬 저장소에서 저장된 API URL을 조회한다.
3. 서버 목록을 조회한다(`GET /api/v1/staff/list`).
4. 저장된 API URL이 존재하면 자동 선택, 없으면 서버 목록 UI를 표시한다.

**자동 선택:**
5. 저장된 API URL을 현재 API URL로 설정한다.
6. 기존 쿠키는 삭제하지 않는다.
7. 로컬에 쿠키가 존재하면 유효성 검증 없이 즉시 메인 화면으로 이동한다.
8. 쿠키가 없으면 로그인 화면으로 이동한다.

**수동 선택:**
9. 사용자가 서버 목록에서 서버를 탭한다.
10. 선택된 서버의 API URL을 현재 API URL로 설정한다.
11. 기존 저장 쿠키를 삭제한다.
12. 로그인 화면으로 이동한다.

**소셜 로그인:**
13. 사용자가 소셜 버튼(Naver/Kakao/Google/Apple) 중 하나를 탭한다.
14. 로딩 인디케이터를 표시하고 모든 소셜 버튼을 비활성화한다.
15. 해당 소셜 SDK의 인증을 호출한다.
16. 인증 성공 시 `(socialSlct, socialKey)`를 로컬에 저장한다.
17. `POST /api/v1/auth/isRegistered`로 가입 여부를 조회한다.
18. code가 `-1`(기존 회원)이면 `POST /api/v1/auth/login`을 호출하고, 응답의 `Set-Cookie`를 로컬에 영속 저장한 뒤 메인 화면으로 이동한다.
19. code가 `1`(미등록)이면 `(socialSlct, socialKey)`를 인자로 온보딩 화면으로 이동한다.

## 경계 조건

- **서버 선택 중복 방지:** 자동·수동 구분 없이 서버 선택 동작은 3초 내 중복 요청을 차단한다.
- **소셜 버튼 중복 방지:** 로딩 상태 동안 4종 소셜 버튼 전체가 비활성화된다.
- **쿠키 갱신:** 모든 API 응답의 `Set-Cookie` 헤더에서 쿠키를 추출해 저장 값을 덮어쓴다. 최신 응답이 우선이다.
- **저장 API URL 없음 + 서버 목록 비어 있음:** 자동 선택과 수동 선택 모두 불가. 에러 상태만 표시.
- **자동 선택의 쿠키 유효성:** 저장된 쿠키가 만료되었더라도 스플래시에서는 검증하지 않고 메인으로 이동한다. 만료는 메인 화면의 API 호출 결과(401 등)로 감지한다.
- **수동 서버 변경 후 쿠키:** 이전에 저장된 쿠키가 있어도 수동 선택 즉시 삭제하여, 다른 서버의 세션이 섞이지 않도록 한다.

# 6. 에러 처리 (Error Handling)

| 에러 유형 | 복구 전략 | 사용자 피드백 | 로깅 기준 |
|---|---|---|---|
| 서버 목록 조회 실패 (`/staff/list`) | 무시 — 이후 단계 진행 불가 | 에러 메시지 표시 | ERROR: endpoint·HTTP 상태·요청ID |
| 소셜 SDK 인증 실패 | 버튼 재활성화 | 에러 메시지 표시 | WARN: socialSlct·SDK 에러 코드 |
| `isRegistered` API 실패 | 버튼 재활성화 | 에러 메시지 표시 | ERROR: HTTP 상태·socialSlct |
| `login` API 실패 (네트워크·5xx) | 버튼 재활성화 | 에러 메시지 표시 | ERROR: HTTP 상태·요청ID |
| `login` code "-11" (계정 없음) | 버튼 재활성화 | 에러 메시지 표시 | WARN: socialSlct·code |
| 메인 화면에서 세션 만료 감지 (401) | 화면 이동: 로그인 → 저장 쿠키 삭제 | 안내 메시지 (세션 만료) | INFO: endpoint·socialSlct |
| 네트워크 오류 | 버튼 재활성화 | 에러 메시지 표시 | WARN: endpoint |

# 7. 범위 (Scope)

## 포함

- 스플래시 화면의 서버 목록 조회·표시
- 저장 API URL 기반 자동 서버 선택
- 수동 서버 선택 및 쿠키 초기화
- 저장된 쿠키 존재 여부 기반 자동 로그인 (유효성 검증 없음)
- 4종 소셜 로그인 버튼 및 중복 클릭 방지
- `isRegistered`·`login` API 호출 및 가입 분기
- 세션 쿠키의 로컬 영속 저장 및 매 API 응답 갱신

## 제외

- 온보딩 화면 내부 로직
- 메인 화면의 데이터 로딩·세션 만료 처리 이후의 UI 동작 (메인 Spec에서 별도 정의)
- 로그아웃·회원 탈퇴
- 이메일/패스워드 로그인
- 오프라인 모드
- 쿠키 만료 전 서버 측 선제 갱신 로직

# 8. 제약 (Constraints)

- 스플래시에서는 쿠키 유효성을 클라이언트 측에서 검증하지 않는다 — 만료 판별은 메인 화면의 서버 응답이 담당.
- 소셜 토큰(`socialSlct`, `socialKey`)은 가입 분기를 위해 로컬에 저장한다.
- 자동 선택 시 기존 쿠키를 유지하고, 수동 선택 시에만 삭제한다.
- 서버 선택 중복 요청은 3초 윈도우로 차단한다.

# 9. 성능 기준 (Performance Criteria)

| 항목 | 유형 | 기준 | 측정 방법 |
|---|---|---|---|
| 스플래시 초기 응답 시간 (서버 목록 조회 완료까지) | 기술 | 미정 — 보완 조건: 실기기 측정 후 결정 | 스플래시 진입 ~ `/staff/list` 응답 수신 시점 |
| 자동 로그인 경로(쿠키 존재) → 메인 진입 | 기술 | 500ms 이내 (로컬 처리만, 네트워크 제외) | 스플래시 진입 ~ 메인 UI 렌더 첫 프레임 |
| 자동 로그인 이용률 | 비즈니스 | 재방문 세션 중 다수 (초기 목표치는 릴리스 후 확정) | 로그 분석 (쿠키 기반 진입 vs 소셜 로그인 완료 카운트) |

# ── 실현 ──

# 10. 기술 설계 (Technical Design)

## 10.1 구조

- 모듈·클래스·파일 구성 — 미정 — 보완 조건: 3단계 계획에서 프로젝트 아키텍처(CLAUDE.md) 참조 후 확정.
- 의존 관계 — 소셜 SDK 4종, REST 클라이언트, 로컬 저장소(쿠키·API URL·소셜 토큰)는 별도 모듈로 분리.

> 본 섹션은 개발자 전담 영역이므로 AI 제안 없음. 실제 모듈 배치는 프로젝트 전역 아키텍처 규약에 맞춰 개발자가 직접 기술한다.

## 10.2 인터페이스

**REST API 계약:**

| 엔드포인트 | Method | 요청 | 응답 |
|---|---|---|---|
| `/api/v1/staff/list` | GET | 없음 | `[{serverName, apiUrl, imgServerUrl, photoUrl, photoUploadUrl}]` |
| `/api/v1/auth/isRegistered` | POST | `{socialSlct, socialKey}` | `{code: "-1" \| "1", ...}` |
| `/api/v1/auth/login` | POST | `{socialSlct, socialKey}` | `Set-Cookie: JSESSIONID=...; remember-me=...` |

**소셜 SDK 계약:** 각 SDK는 비동기 인증 결과로 `socialKey` 상응 값을 반환한다. Naver/Kakao/Google/Apple 각각의 네이티브 API 시그니처는 플랫폼 노트 참조.

**로컬 저장소 키 (제안 `[AI 제안]`):**

- 안 1: `apiUrl`, `cookie.jsessionid`, `cookie.remember_me`, `social.slct`, `social.key` — 단일 네임스페이스
- 안 2: `auth.cookie.*`, `auth.social.*`, `server.apiUrl` — 도메인별 네임스페이스 분리

개발자 선택 후 `[AI 제안]` 태그 제거 필요.

## 10.3 흐름

상태 전이 (제안 `[AI 제안]`):

```
[Idle]
  ├─ 앱 실행 → [SplashLoading]
[SplashLoading]
  ├─ /staff/list 성공 + 저장 URL 있음 → [AutoServerSelect]
  ├─ /staff/list 성공 + 저장 URL 없음 → [ManualServerSelect]
  └─ /staff/list 실패 → [SplashError]
[AutoServerSelect]
  ├─ 쿠키 있음 → [Main]
  └─ 쿠키 없음 → [LoginIdle]
[ManualServerSelect]
  └─ 사용자 탭 → 쿠키 삭제 → [LoginIdle]
[LoginIdle]
  └─ 소셜 버튼 탭 → [LoginAuthenticating]
[LoginAuthenticating]
  ├─ SDK 실패 → [LoginError] → (자동 복귀) [LoginIdle]
  ├─ isRegistered code "-1" → /auth/login 호출 → [Main]
  ├─ isRegistered code "1" → [Onboarding]
  └─ API 실패 → [LoginError] → (자동 복귀) [LoginIdle]
```

복수 안이 필요한 경우(예: `SplashLoading`을 2개 서브 상태로 분리 vs 단일 상태 유지)는 개발자 판단으로 확정. 현재는 단일 흐름 안으로 제안.

# 11. 플랫폼별 차이 (Platform Notes)

## iOS

- Apple Sign In은 iOS 13+ 네이티브 API 사용. 낮은 버전 지원 여부 — 미정 — 보완 조건: OS 지원 정책 확정 시.
- Keychain을 쿠키 저장소로 검토 가능 (선택 사항).

## Android

- Apple Sign In은 WebView 기반 OAuth 플로우로 대체.
- `SharedPreferences` / `EncryptedSharedPreferences` 선택은 프로젝트 규약에 맞춘다.

# 12. 마이그레이션 (Migration)

- 전환 단계: 신규 기능. 기존 사용자 데이터 마이그레이션 없음.
- 하위 호환성: SPEC-001(선행 초안)에서 구조를 계승하되, 본 Spec은 정식 구현 Spec이다. SPEC-001은 초안 참조용으로만 유지.
- 롤백 방법: 릴리스 롤백 시 앱 측은 이전 버전 설치로 복구. 서버 쿠키 정책은 변화 없음.

# ── 보증 ──

# 13. 테스트 전략 (Test Strategy)

## 단위 테스트

- 저장 API URL 유무 판정 로직
- 3초 중복 요청 차단 로직
- 쿠키 파서 (`Set-Cookie` 헤더 → 키-값 추출)
- 가입 여부 code 분기(-1/1) 처리

## 통합 테스트

- `/staff/list` 응답 → 서버 목록 UI 상태 매핑
- 소셜 SDK 성공 → `isRegistered` 호출 → `login` 호출 시퀀스(모든 분기)
- 수동 서버 선택 → 쿠키 삭제 → 로그인 화면 전이
- 자동 서버 선택 + 쿠키 있음 → 메인 즉시 진입

## E2E / UI 테스트

- 앱 최초 실행(저장 상태 없음) → 서버 목록 표시 → 선택 → 소셜 로그인 → 메인 진입
- 앱 재실행(쿠키 있음) → 스플래시 → 메인 즉시 진입
- 로그인 화면에서 모든 소셜 버튼 비활성화가 로딩 중 유지되는지
- `/staff/list` 실패 시 에러 메시지 노출 및 이후 진행 불가 확인
- 수동 서버 변경 후 기존 세션이 섞이지 않는지 (쿠키 삭제 검증)

# 14. 수락 기준 (Acceptance Criteria)

- [ ] AC-01 [P1]: 앱 실행 시 `/staff/list`를 호출하여 서버 목록을 조회한다.
- [ ] AC-02 [P1]: 저장된 API URL이 있으면 서버 목록 UI를 표시하지 않고 자동으로 해당 서버를 선택한다.
- [ ] AC-03 [P1]: 저장된 API URL이 없으면 서버 목록 UI를 표시하고 사용자 탭을 대기한다.
- [ ] AC-04 [P1]: 자동 선택 시 기존 저장 쿠키는 삭제하지 않는다.
- [ ] AC-05 [P1]: 수동 선택 시 기존 저장 쿠키를 삭제하고 로그인 화면으로 이동한다.
- [ ] AC-06 [P1]: 자동 선택 후 저장된 쿠키가 존재하면 유효성 검증 없이 즉시 메인 화면으로 이동한다.
- [ ] AC-07 [P1]: 자동 선택 후 저장된 쿠키가 없으면 로그인 화면으로 이동한다.
- [ ] AC-08 [P1]: 서버 선택 동작은 자동·수동 구분 없이 3초 내 중복 요청을 차단한다.
- [ ] AC-09 [P1]: 소셜 버튼(Naver/Kakao/Google/Apple) 탭 시 로딩을 표시하고 4종 버튼 전체를 비활성화한다.
- [ ] AC-10 [P1]: 소셜 SDK 인증 실패 시 에러 메시지를 표시하고 버튼을 재활성화한다.
- [ ] AC-11 [P1]: 소셜 SDK 인증 성공 시 `(socialSlct, socialKey)`를 로컬에 저장하고 `isRegistered`를 호출한다.
- [ ] AC-12 [P1]: `isRegistered` code "-1" 시 `login`을 호출하고, 응답 `Set-Cookie`를 로컬에 저장한 뒤 메인으로 이동한다.
- [ ] AC-13 [P1]: `isRegistered` code "1" 시 `(socialSlct, socialKey)`를 인자로 온보딩으로 이동한다.
- [ ] AC-14 [P1]: `isRegistered`·`login` API 실패 시 에러 메시지를 표시하고 버튼을 재활성화한다.
- [ ] AC-15 [P1]: 모든 API 응답의 `Set-Cookie`를 파싱하여 저장 쿠키를 최신 값으로 덮어쓴다.
- [ ] AC-16 [P2]: `/staff/list` 실패 시 에러 메시지를 표시하고 이후 단계로 진행하지 않는다.
- [ ] AC-17 [P2]: `login` code "-11" 수신 시 "계정 없음" 메시지를 표시하고 버튼을 재활성화한다.
- [ ] AC-18 [P2]: 네트워크 오류 발생 시 에러 메시지 표시 및 버튼 재활성화로 복구한다.

# 15. 변경 이력 (Changelog)

| 날짜 | 변경 내용 | 사유 |
|---|---|---|
| 2026-04-21 | Spec 초안 작성 (draft) | `plan/splash_login_plan.md` 기반 경로 A 분석 결과 |

> **표준 마커:**
> - `status <이전> → <이후>`: 상태 전이 (draft → approved 등)
> - `Practice: [X] — 사유: [...]`: feature 4단계에서 Practice 선택
> - `pattern-extracted: [패턴명] — [한 줄 요약]`: feature 7단계에서 재사용 가능한 패턴 발견. 파이프라인은 기록만 남기며, CLAUDE.md 반영 여부는 별도 검토에서 결정
> - `spec_flags: [AC-NN] [섹션] — [결함 요약]`: debug 5단계에서 기록한 Spec 결함 플래그
